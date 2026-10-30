/// 글 에디터 위젯. 문단 입력, 선택 구간 스타일, 하단 도구를 한곳에서 다룬다.
library;

import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/editor/rich_text_document.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';

export 'rich_text_document.dart';

double richTextFontSize(RichTextSize size) {
  return switch (size) {
    RichTextSize.small => 14,
    RichTextSize.medium => 16,
    RichTextSize.large => 22,
  };
}

TextAlign richTextParagraphAlign(RichTextAlign align) {
  return switch (align) {
    RichTextAlign.left => TextAlign.left,
    RichTextAlign.center => TextAlign.center,
    RichTextAlign.right => TextAlign.right,
  };
}

FontWeight richTextWeight(bool bold) =>
    bold ? FontWeight.w700 : FontWeight.w500;

class RichTextController extends TextEditingController {
  RichTextController(List<RichTextParagraph> paragraphs)
    : _paragraphs = _owned(paragraphs),
      super(text: plainTextOf(_owned(paragraphs))) {
    final ({RichTextSize size, bool bold}) style = styleAtCaret(
      paragraph,
      paragraphCaret,
    );
    typingSize = style.size;
    typingBold = style.bold;
  }

  List<RichTextParagraph> _paragraphs;
  late RichTextSize typingSize;
  late bool typingBold;
  int? _pinnedOffset;
  bool _silent = false;
  int _seq = 0;

  VoidCallback? onDocument;

  List<RichTextParagraph> get paragraphs =>
      List<RichTextParagraph>.unmodifiable(_paragraphs);

  RichTextParagraph get paragraph {
    if (_paragraphs.isEmpty) return const RichTextParagraph(id: 'p0');
    return _paragraphs[_indexAt(_caretOffset()).index];
  }

  int get paragraphCaret => _indexAt(_caretOffset()).caret;

  RichTextSize? get activeSize {
    final (int, int)? range = _range();
    if (range == null || range.$1 == range.$2) return typingSize;
    RichTextSize? size;
    var cursor = 0;
    for (final RichTextParagraph item in _paragraphs) {
      final int from = cursor;
      final int to = cursor + item.text.length;
      final int localStart = (range.$1 - from).clamp(0, item.text.length);
      final int localEnd = (range.$2 - from).clamp(0, item.text.length);
      if (localEnd > localStart) {
        final RichTextSize? piece = uniformSize(item, localStart, localEnd);
        if (piece == null) return null;
        size ??= piece;
        if (size != piece) return null;
      }
      cursor = to + 1;
    }
    return size ?? typingSize;
  }

  bool get boldActive {
    final (int, int)? range = _range();
    if (range == null || range.$1 == range.$2) return typingBold;
    var cursor = 0;
    var seen = false;
    for (final RichTextParagraph item in _paragraphs) {
      final int from = cursor;
      final int to = cursor + item.text.length;
      final int localStart = (range.$1 - from).clamp(0, item.text.length);
      final int localEnd = (range.$2 - from).clamp(0, item.text.length);
      if (localEnd > localStart) {
        seen = true;
        if (!rangeIsBold(item, localStart, localEnd)) return false;
      }
      cursor = to + 1;
    }
    return seen;
  }

  String _nextId() => '${_paragraphs.first.id}-s${_seq++}';

  int _caretOffset() {
    if (!selection.isValid) return text.length;
    return selection.extentOffset.clamp(0, text.length);
  }

  ({int index, int caret}) _indexAt(int offset) {
    final ({String id, int caret}) place = caretInParagraphs(
      _paragraphs,
      offset,
    );
    final int index = _paragraphs.indexWhere(
      (RichTextParagraph item) => item.id == place.id,
    );
    return (index: index < 0 ? 0 : index, caret: place.caret);
  }

  (int, int)? _range() {
    if (!selection.isValid) return null;
    final int start = selection.start;
    final int end = selection.end;
    return start <= end ? (start, end) : (end, start);
  }

  void _syncTyping(TextSelection next) {
    if (!next.isValid || !next.isCollapsed) return;
    if (_pinnedOffset != null && _pinnedOffset == next.extentOffset) return;
    _pinnedOffset = null;
    final ({int index, int caret}) place = _indexAt(next.extentOffset);
    final ({RichTextSize size, bool bold}) style = styleAtCaret(
      _paragraphs[place.index],
      place.caret,
    );
    typingSize = style.size;
    typingBold = style.bold;
  }

  @override
  set value(TextEditingValue newValue) {
    if (_silent) {
      super.value = newValue;
      return;
    }
    final String before = text;
    if (before == newValue.text) {
      _syncTyping(newValue.selection);
      super.value = newValue;
      return;
    }
    _paragraphs = applyDocumentEdit(
      paragraphs: _paragraphs,
      before: before,
      after: newValue.text,
      typingSize: typingSize,
      typingBold: typingBold,
      nextId: _nextId,
    );
    _pinnedOffset = null;
    _syncTyping(newValue.selection);
    super.value = newValue;
    onDocument?.call();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<InlineSpan> children = <InlineSpan>[];
    for (var index = 0; index < _paragraphs.length; index++) {
      if (index > 0) {
        children.add(TextSpan(text: '\n', style: style));
      }
      for (final RichTextRun run in _paragraphs[index].runs) {
        if (run.text.isEmpty) continue;
        children.add(
          TextSpan(
            text: run.text,
            style: TextStyle(
              color: style?.color,
              height: style?.height,
              fontSize: richTextFontSize(run.size),
              fontWeight: richTextWeight(run.bold),
            ),
          ),
        );
      }
    }
    if (children.isEmpty) return TextSpan(text: '', style: style);
    return TextSpan(style: style, children: children);
  }

  void load(RichTextParagraph paragraph, {int? caret}) {
    loadParagraphs(<RichTextParagraph>[paragraph], caret: caret);
  }

  void loadParagraphs(List<RichTextParagraph> paragraphs, {int? caret}) {
    _paragraphs = _owned(paragraphs);
    final String next = plainTextOf(_paragraphs);
    final int offset = (caret ??
            (selection.isValid ? selection.extentOffset : next.length))
        .clamp(0, next.length);
    if (caret != null && _paragraphs.isNotEmpty) {
      _pinnedOffset = null;
      final ({int index, int caret}) place = _indexAt(offset);
      final ({RichTextSize size, bool bold}) style = styleAtCaret(
        _paragraphs[place.index],
        place.caret,
      );
      typingSize = style.size;
      typingBold = style.bold;
    }
    _silent = true;
    super.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: offset),
    );
    _silent = false;
    notifyListeners();
  }

  void applySize(RichTextSize size) {
    final (int, int)? range = _range();
    if (range == null || range.$1 == range.$2) {
      typingSize = size;
      _pinnedOffset = selection.isValid ? selection.extentOffset : text.length;
      if (text.isEmpty && _paragraphs.isNotEmpty) {
        _paragraphs = <RichTextParagraph>[
          _paragraphs.first.copyWith(
            runs: <RichTextRun>[
              RichTextRun(text: '', size: size, bold: typingBold),
            ],
          ),
        ];
        onDocument?.call();
      }
      notifyListeners();
      return;
    }
    _paragraphs = _styleRange(range.$1, range.$2, size: size);
    notifyListeners();
    onDocument?.call();
  }

  void toggleBold() {
    final (int, int)? range = _range();
    if (range == null || range.$1 == range.$2) {
      typingBold = !typingBold;
      _pinnedOffset = selection.isValid ? selection.extentOffset : text.length;
      if (text.isEmpty && _paragraphs.isNotEmpty) {
        _paragraphs = <RichTextParagraph>[
          _paragraphs.first.copyWith(
            runs: <RichTextRun>[
              RichTextRun(text: '', size: typingSize, bold: typingBold),
            ],
          ),
        ];
        onDocument?.call();
      }
      notifyListeners();
      return;
    }
    final bool next = !boldActive;
    _paragraphs = _styleRange(range.$1, range.$2, bold: next);
    typingBold = next;
    notifyListeners();
    onDocument?.call();
  }

  void applyAlign(RichTextAlign align) {
    _paragraphs = <RichTextParagraph>[
      for (final RichTextParagraph item in _paragraphs)
        item.copyWith(align: align),
    ];
    notifyListeners();
    onDocument?.call();
  }

  List<RichTextParagraph> _styleRange(
    int start,
    int end, {
    RichTextSize? size,
    bool? bold,
  }) {
    var cursor = 0;
    final List<RichTextParagraph> next = <RichTextParagraph>[];
    for (final RichTextParagraph item in _paragraphs) {
      final int from = cursor;
      final int to = cursor + item.text.length;
      final int localStart = (start - from).clamp(0, item.text.length);
      final int localEnd = (end - from).clamp(0, item.text.length);
      if (localEnd > localStart && end > from && start < to) {
        next.add(
          applyInlineStyle(
            paragraph: item,
            start: localStart,
            end: localEnd,
            size: size,
            bold: bold,
          ),
        );
      } else {
        next.add(item);
      }
      cursor = to + 1;
    }
    return next;
  }

  void insert(String value) {
    final (int, int)? range = _range();
    final int start = range?.$1 ?? text.length;
    final int end = range?.$2 ?? text.length;
    final String next = text.replaceRange(start, end, value);
    this.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: start + value.length),
    );
  }
}

List<RichTextParagraph> _owned(List<RichTextParagraph> paragraphs) {
  if (paragraphs.isEmpty) {
    return const <RichTextParagraph>[RichTextParagraph(id: 'p0')];
  }
  return <RichTextParagraph>[...paragraphs];
}

class RichTextFields extends StatefulWidget {
  const RichTextFields({
    super.key,
    required this.paragraphs,
    required this.onChanged,
    required this.onActive,
    this.autofocus = false,
    this.minHeight = 200,
    this.plain = false,
  });

  final List<RichTextParagraph> paragraphs;
  final ValueChanged<List<RichTextParagraph>> onChanged;
  final void Function(RichTextController? controller, FocusNode? node) onActive;
  final bool autofocus;

  /// 비어 있을 때의 높이. 글이 이 높이를 넘으면 칸도 같이 늘어난다.
  final double minHeight;

  /// 배경 칸 없이 본문 흐름 안에 둔다.
  final bool plain;

  @override
  State<RichTextFields> createState() => _RichTextFieldsState();
}

class _RichTextFieldsState extends State<RichTextFields> {
  late final RichTextController _controller = RichTextController(
    widget.paragraphs,
  );
  late final FocusNode _node = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.onDocument = _publish;
    _node.addListener(_handleFocus);
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _node.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant RichTextFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (sameRichParagraphs(widget.paragraphs, _controller.paragraphs)) return;
    final String incoming = plainTextOf(widget.paragraphs);
    if (_node.hasFocus && _controller.text.isNotEmpty && incoming.isEmpty) {
      return;
    }
    if (_node.hasFocus) return;
    _controller.loadParagraphs(widget.paragraphs);
  }

  @override
  void dispose() {
    _node.removeListener(_handleFocus);
    _controller.dispose();
    _node.dispose();
    super.dispose();
  }

  void _publish() {
    if (sameRichParagraphs(_controller.paragraphs, widget.paragraphs)) return;
    widget.onChanged(_controller.paragraphs);
  }

  void _handleFocus() {
    if (_node.hasFocus) {
      widget.onActive(_controller, _node);
      return;
    }
    widget.onActive(null, null);
  }

  void _focusTail() {
    final int offset = _controller.text.length;
    _node.requestFocus();
    _controller.selection = TextSelection.collapsed(offset: offset);
  }

  @override
  Widget build(BuildContext context) {
    final Widget fields = ConstrainedBox(
      constraints: BoxConstraints(minHeight: widget.minHeight),
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _focusTail,
            ),
          ),
          ListenableBuilder(
            listenable: _controller,
            builder: (BuildContext context, Widget? child) {
              return TextField(
                controller: _controller,
                focusNode: _node,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                minLines: 1,
                maxLines: null,
                textAlign: richTextParagraphAlign(_controller.paragraph.align),
                scrollPadding: const EdgeInsets.only(bottom: 160),
                style: TextStyle(
                  fontSize: richTextFontSize(_controller.typingSize),
                  height: 1.45,
                  fontWeight: richTextWeight(_controller.typingBold),
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration.collapsed(
                  hintText: _controller.text.isEmpty ? '이 칸에 적을 내용' : null,
                  hintStyle: const TextStyle(
                    color: Color(0xFFB0B6BE),
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
    if (widget.plain) return fields;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFF7F8FA),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: fields,
      ),
    );
  }
}

/// 저장된 문단을 읽기 전용으로 보여 준다.
class RichTextView extends StatelessWidget {
  const RichTextView({super.key, required this.paragraphs});

  final List<RichTextParagraph> paragraphs;

  @override
  Widget build(BuildContext context) {
    final List<RichTextParagraph> visible =
        paragraphs
            .where(
              (RichTextParagraph paragraph) => paragraph.text.trim().isNotEmpty,
            )
            .toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    // 문단이 글자 너비로 줄어들면 textAlign이 움직일 자리가 없다.
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final RichTextParagraph paragraph in visible)
            Text.rich(
              TextSpan(
                children: [
                  for (final RichTextRun run in paragraph.runs)
                    TextSpan(
                      text: run.text,
                      style: TextStyle(
                        fontSize: richTextFontSize(run.size),
                        height: 1.5,
                        fontWeight: richTextWeight(run.bold),
                        color: AppColors.textPrimary,
                      ),
                    ),
                ],
              ),
              textAlign: richTextParagraphAlign(paragraph.align),
            ),
        ],
      ),
    );
  }
}

/// 글 칸에 커서가 있을 때 붙는 도구. 버튼은 포커스를 가져가지 않는다.
class RichTextToolbar extends StatelessWidget {
  const RichTextToolbar({
    super.key,
    required this.size,
    required this.bold,
    required this.align,
    required this.emojiOpen,
    required this.emojis,
    required this.onSize,
    required this.onBold,
    required this.onAlign,
    required this.onEmojiToggle,
    required this.onEmoji,
    this.onImage,
    this.onArea,
    this.retainFocus,
    this.releaseFocus,
  });

  final RichTextSize? size;
  final bool bold;
  final RichTextAlign align;
  final bool emojiOpen;
  final List<String> emojis;
  final ValueChanged<RichTextSize> onSize;
  final VoidCallback onBold;
  final ValueChanged<RichTextAlign> onAlign;
  final VoidCallback onEmojiToggle;
  final ValueChanged<String> onEmoji;
  final VoidCallback? onImage;
  final VoidCallback? onArea;
  final VoidCallback? retainFocus;
  final VoidCallback? releaseFocus;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1, color: AppColors.border),
          Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => retainFocus?.call(),
            onPointerUp: (_) => releaseFocus?.call(),
            onPointerCancel: (_) => releaseFocus?.call(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Row(
                children: [
                  _ToolButton(
                    selected: size == RichTextSize.small,
                    onTap: () => onSize(RichTextSize.small),
                    child: const Text('가', style: TextStyle(fontSize: 13)),
                  ),
                  _ToolButton(
                    selected: size == RichTextSize.medium,
                    onTap: () => onSize(RichTextSize.medium),
                    child: const Text('가', style: TextStyle(fontSize: 16)),
                  ),
                  _ToolButton(
                    selected: size == RichTextSize.large,
                    onTap: () => onSize(RichTextSize.large),
                    child: const Text('가', style: TextStyle(fontSize: 18)),
                  ),
                  _ToolButton(
                    selected: bold,
                    onTap: onBold,
                    child: const Icon(Icons.format_bold, size: 18),
                  ),
                  _ToolButton(
                    selected: align == RichTextAlign.left,
                    onTap: () => onAlign(RichTextAlign.left),
                    child: const Icon(Icons.format_align_left, size: 18),
                  ),
                  _ToolButton(
                    selected: align == RichTextAlign.center,
                    onTap: () => onAlign(RichTextAlign.center),
                    child: const Icon(Icons.format_align_center, size: 18),
                  ),
                  _ToolButton(
                    selected: align == RichTextAlign.right,
                    onTap: () => onAlign(RichTextAlign.right),
                    child: const Icon(Icons.format_align_right, size: 18),
                  ),
                  if (onImage != null)
                    _ToolButton(
                      selected: false,
                      onTap: onImage!,
                      child: const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 18,
                      ),
                    ),
                  if (onArea != null)
                    _ToolButton(
                      selected: false,
                      onTap: onArea!,
                      child: const Icon(
                        Icons.dashboard_customize_outlined,
                        size: 18,
                      ),
                    ),
                  _ToolButton(
                    selected: emojiOpen,
                    onTap: onEmojiToggle,
                    child: const Icon(Icons.emoji_emotions_outlined, size: 18),
                  ),
                ],
              ),
            ),
          ),
          if (emojiOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final String emoji in emojis)
                      InkWell(
                        onTap: () => onEmoji(emoji),
                        canRequestFocus: false,
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color: selected ? AppColors.primary : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            canRequestFocus: false,
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 36,
              child: IconTheme(
                data: IconThemeData(
                  color: selected ? AppColors.white : AppColors.textPrimary,
                ),
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.white : AppColors.textPrimary,
                  ),
                  child: Center(child: child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
