import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:interiorapp_flutter_client/core/editor/quill_simulator_guard.dart';
import 'package:interiorapp_flutter_client/core/editor/rich_text_document.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/widget/keyboard_dismiss.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/showroom_story_model.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/showroom_body.dart';
import 'package:interiorapp_flutter_client/showroom/domain/showroom_quill_document.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_process_editor.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/write_body_editor.dart';

/// 입력 중인 줄을 키보드 위 칸에 두기 위한 스크롤 이동량.
///
/// 전후 카드처럼 앵커가 그 칸보다 크면 위와 아래를 동시에 맞출 수 없다.
/// 이미 칸과 겹치면 그대로 두고, 완전히 벗어나 있을 때만 위쪽을 칸에 붙인다.
double showroomCaretRevealDelta({
  required double viewTop,
  required double viewBottom,
  required double anchorTop,
  required double anchorBottom,
  required double margin,
  required double keepBelow,
}) {
  final double bandTop = viewTop + margin;
  final double bandBottom = viewBottom - keepBelow;
  final double band = bandBottom - bandTop;
  final double height = anchorBottom - anchorTop;
  if (height > band) {
    final bool intersects = anchorBottom > bandTop && anchorTop < bandBottom;
    if (intersects) return 0;
    return anchorTop - bandTop;
  }
  if (anchorBottom > bandBottom) return anchorBottom - bandBottom;
  if (anchorTop < bandTop) return anchorTop - bandTop;
  return 0;
}

class ShowroomQuillBody extends StatefulWidget {
  const ShowroomQuillBody({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.scrollController,
    required this.pickImages,
    this.loadRecord,
    this.chooseLayout,
  });

  final QuillController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final Future<List<String>> Function({bool multiple}) pickImages;
  final List<ShowroomProcessFrame> Function()? loadRecord;
  final Future<ShowroomImageLayout?> Function()? chooseLayout;

  @override
  State<ShowroomQuillBody> createState() => _ShowroomQuillBodyState();
}

class _ShowroomQuillBodyState extends State<ShowroomQuillBody>
    with WidgetsBindingObserver {
  final GlobalKey<EditorState> _editorKey = GlobalKey<EditorState>();
  final ScrollController _editorScroll = ScrollController();
  bool _revealScheduled = false;
  bool _parkingCaret = false;
  int _revealHold = 0;

  @override
  void initState() {
    super.initState();
    installQuillSimulatorGuard();
    WidgetsBinding.instance.addObserver(this);
    widget.focusNode.addListener(_handleFocus);
    widget.controller.addListener(_handleEdit);
  }

  @override
  void didUpdateWidget(ShowroomQuillBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocus);
      widget.focusNode.addListener(_handleFocus);
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleEdit);
      widget.controller.addListener(_handleEdit);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.focusNode.removeListener(_handleFocus);
    widget.controller.removeListener(_handleEdit);
    _editorScroll.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _scheduleReveal();
  }

  void _handleFocus() {
    if (widget.focusNode.hasFocus) _scheduleReveal();
  }

  void _handleEdit() {
    if (_parkingCaret) return;
    // 카드 줄에 커서가 있으면 캐럿 높이가 카드 전체가 된다.
    // 그 상태로는 아래 맞추기와 위 맞추기가 서로를 취소해서 스크롤이 끝없이 뒤집힌다.
    if (_parkCaretPastEmbed() || _revealHold > 0) return;
    if (widget.focusNode.hasFocus) _scheduleReveal();
  }

  /// 전후·기록 카드 줄에 놓인 커서를 다음 글줄로 옮긴다.
  /// 카드가 문서 끝이면 빈 줄을 하나 붙여 커서가 머물 자리를 만든다.
  bool _parkCaretPastEmbed() {
    final QuillController controller = widget.controller;
    final TextSelection selection = controller.selection;
    if (!selection.isValid || !selection.isCollapsed) return false;
    final Node? node =
        controller.document.queryChild(selection.extentOffset).node;
    if (node is! Line || !node.hasEmbed) return false;

    _parkingCaret = true;
    try {
      var guard = 0;
      while (guard++ < 8) {
        final TextSelection current = controller.selection;
        final Node? line =
            controller.document.queryChild(current.extentOffset).node;
        if (line is! Line || !line.hasEmbed) return true;
        final int end =
            controller.document.length == 0
                ? 0
                : controller.document.length - 1;
        final int next = line.documentOffset + line.length;
        if (next <= end && next != current.extentOffset) {
          controller.updateSelection(
            TextSelection.collapsed(offset: next),
            ChangeSource.local,
          );
          continue;
        }
        controller.replaceText(
          end,
          0,
          '\n',
          TextSelection.collapsed(offset: end + 1),
          ignoreFocus: true,
        );
      }
      return true;
    } finally {
      _parkingCaret = false;
    }
  }

  /// 전후·기록 카드 안의 탭은 글을 치는 탭이 아니다.
  /// 에디터가 같이 받으면 포커스가 켜지고, 카드 아래 줄로 스크롤이 붙는다.
  bool _tapHitsEmbed(
    TapUpDetails details,
    TextPosition Function(Offset offset) positionOf,
  ) {
    try {
      final TextPosition position = positionOf(details.globalPosition);
      final Node? line =
          widget.controller.document.queryChild(position.offset).node;
      if (line is! Line || !line.hasEmbed) return false;
    } catch (_) {
      return false;
    }
    if (widget.focusNode.hasFocus) widget.focusNode.unfocus();
    return true;
  }

  void _scheduleReveal() {
    if (_revealScheduled) return;
    _revealScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _revealScheduled = false;
      if (mounted) _revealBody();
    });
  }

  /// 본문이 키보드 위 칸에 다 들어오면 그 칸의 맨 위까지 올린다.
  /// 칸보다 길면 입력 중인 줄이 아래에 붙지 않게 더 올린다.
  void _revealBody() {
    if (!widget.focusNode.hasFocus) return;
    final ScrollController scroll = widget.scrollController;
    if (!scroll.hasClients) return;
    final RenderBox? body = context.findRenderObject() as RenderBox?;
    if (body == null || !body.hasSize || !body.attached) return;
    final RenderAbstractViewport? viewport = RenderAbstractViewport.maybeOf(
      body,
    );
    if (viewport is! RenderBox) return;
    final RenderBox view = viewport as RenderBox;
    if (!view.hasSize) return;

    final Offset viewOrigin = view.localToGlobal(Offset.zero);
    final double viewTop = viewOrigin.dy;
    final double viewHeight = view.size.height;
    final double viewBottom = viewTop + viewHeight;
    final Offset bodyOrigin = body.localToGlobal(Offset.zero);
    final double bodyTop = bodyOrigin.dy;
    final double bodyHeight = body.size.height;
    const double margin = 12;

    final double delta;
    if (bodyHeight + margin <= viewHeight) {
      delta = bodyTop - (viewTop + margin);
    } else {
      double anchorTop = bodyTop;
      double anchorBottom = bodyTop + bodyHeight;
      final EditorState? editor = _editorKey.currentState;
      final TextSelection selection = widget.controller.selection;
      if (editor != null && selection.isValid) {
        try {
          final Rect caret = editor.renderEditor.getLocalRectForCaret(
            selection.extent,
          );
          final Offset caretOrigin = editor.renderEditor.localToGlobal(
            caret.topLeft,
          );
          anchorTop = caretOrigin.dy;
          anchorBottom = caretOrigin.dy + caret.height;
        } catch (_) {}
      }
      delta = showroomCaretRevealDelta(
        viewTop: viewTop,
        viewBottom: viewBottom,
        anchorTop: anchorTop,
        anchorBottom: anchorBottom,
        margin: margin,
        keepBelow: math.max(96, viewHeight * 0.42),
      );
    }

    if (delta.abs() < 1) return;
    final double target = (scroll.offset + delta).clamp(
      scroll.position.minScrollExtent,
      scroll.position.maxScrollExtent,
    );
    if ((target - scroll.offset).abs() < 1) return;
    scroll.jumpTo(target);
  }

  late final ShowroomEmbedBuilder _embeds = ShowroomEmbedBuilder(
    pickImages:
        ({bool multiple = false}) => widget.pickImages(multiple: multiple),
    loadRecord: () => widget.loadRecord,
    chooseLayout: () {
      final Future<ShowroomImageLayout?> Function()? choose =
          widget.chooseLayout;
      if (choose == null) return Future<ShowroomImageLayout?>.value();
      return choose();
    },
    onReplace: (int offset, ShowroomBlock block) {
      _revealHold++;
      try {
        replaceShowroomEmbed(widget.controller, offset, block);
      } finally {
        _revealHold--;
      }
    },
    onDelete: (int offset) => deleteShowroomEmbed(widget.controller, offset),
  );

  @override
  Widget build(BuildContext context) {
    final TextStyle body =
        (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(
          fontSize: 16,
          height: 1.45,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        );
    final DefaultTextBlockStyle paragraph = DefaultTextBlockStyle(
      body,
      HorizontalSpacing.zero,
      VerticalSpacing.zero,
      VerticalSpacing.zero,
      null,
    );
    // Quill 기본 h1은 34px이다. 줄에 header가 붙으면 첫 글만 제목처럼 커진다.
    final DefaultStyles styles = DefaultStyles.getInstance(context).merge(
      DefaultStyles(
        h1: paragraph,
        h2: paragraph,
        h3: paragraph,
        h4: paragraph,
        h5: paragraph,
        h6: paragraph,
        paragraph: paragraph,
        sizeSmall: body.copyWith(fontSize: 14),
        sizeLarge: body.copyWith(fontSize: 22),
        sizeHuge: body.copyWith(fontSize: 22),
        placeHolder: DefaultTextBlockStyle(
          body.copyWith(
            color: const Color(0xFFB0B6BE),
            fontWeight: FontWeight.w500,
          ),
          HorizontalSpacing.zero,
          VerticalSpacing.zero,
          VerticalSpacing.zero,
          null,
        ),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: const Color(0xFFC9D0D8)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: QuillEditor(
            controller: widget.controller,
            focusNode: widget.focusNode,
            scrollController: _editorScroll,
            config: QuillEditorConfig(
              editorKey: _editorKey,
              scrollable: false,
              minHeight: 200,
              placeholder: '이 칸에 적을 내용',
              padding: EdgeInsets.zero,
              onTapOutsideEnabled: false,
              onTapUp: _tapHitsEmbed,
              customStyles: styles,
              embedBuilders: <EmbedBuilder>[_embeds],
            ),
          ),
        ),
      ),
    );
  }
}

class ShowroomQuillToolbar extends StatelessWidget {
  const ShowroomQuillToolbar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.emojiOpen,
    required this.onEmojiToggle,
    required this.onEmoji,
    required this.onImage,
    required this.onArea,
    required this.onRecord,
  });

  final QuillController controller;
  final FocusNode focusNode;
  final bool emojiOpen;
  final VoidCallback onEmojiToggle;
  final ValueChanged<String> onEmoji;
  final VoidCallback onImage;
  final VoidCallback onArea;
  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    return FocusKeepRegion(
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => focusNode.requestFocus(),
        child: Focus(
          canRequestFocus: false,
          descendantsAreFocusable: false,
          child: Material(
            color: AppColors.surface,
            child: ListenableBuilder(
              listenable: controller,
              builder: (BuildContext context, Widget? child) {
                final Style style = controller.getSelectionStyle();
                final RichTextSize size = switch (style
                    .attributes[Attribute.size.key]
                    ?.value) {
                  'small' => RichTextSize.small,
                  'large' || 'huge' => RichTextSize.large,
                  _ => RichTextSize.medium,
                };
                final bool bold = style.containsKey(Attribute.bold.key);
                final RichTextAlign align = switch (style
                    .attributes[Attribute.align.key]
                    ?.value) {
                  'center' => RichTextAlign.center,
                  'right' => RichTextAlign.right,
                  _ => RichTextAlign.left,
                };
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(height: 1, color: AppColors.border),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Row(
                        children: [
                          _ToolButton(
                            selected: size == RichTextSize.small,
                            onTap: () => _size(RichTextSize.small),
                            child: const Text(
                              '가',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          _ToolButton(
                            selected: size == RichTextSize.medium,
                            onTap: () => _size(RichTextSize.medium),
                            child: const Text(
                              '가',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          _ToolButton(
                            selected: size == RichTextSize.large,
                            onTap: () => _size(RichTextSize.large),
                            child: const Text(
                              '가',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          _ToolButton(
                            selected: bold,
                            onTap: _bold,
                            child: const Icon(Icons.format_bold, size: 18),
                          ),
                          _ToolButton(
                            selected: align == RichTextAlign.left,
                            onTap: () => _align(Attribute.leftAlignment),
                            child: const Icon(
                              Icons.format_align_left,
                              size: 18,
                            ),
                          ),
                          _ToolButton(
                            selected: align == RichTextAlign.center,
                            onTap: () => _align(Attribute.centerAlignment),
                            child: const Icon(
                              Icons.format_align_center,
                              size: 18,
                            ),
                          ),
                          _ToolButton(
                            selected: align == RichTextAlign.right,
                            onTap: () => _align(Attribute.rightAlignment),
                            child: const Icon(
                              Icons.format_align_right,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: Divider(height: 1, color: AppColors.border),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                      child: Row(
                        children: [
                          _InsertButton(
                            icon: Icons.add_photo_alternate_outlined,
                            label: '사진',
                            onTap: onImage,
                          ),
                          _InsertButton(
                            icon: Icons.swap_horiz,
                            label: '전후',
                            onTap: onArea,
                          ),
                          _InsertButton(
                            icon: Icons.format_list_numbered,
                            label: '기록',
                            onTap: onRecord,
                          ),
                          _InsertButton(
                            icon: Icons.emoji_emotions_outlined,
                            label: '이모지',
                            selected: emojiOpen,
                            onTap: onEmojiToggle,
                          ),
                        ],
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
                              for (final String emoji in showroomEmojiCatalog)
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _size(RichTextSize size) {
    final Attribute<dynamic> attribute =
        size == RichTextSize.medium
            ? Attribute.clone(Attribute.size, null)
            : SizeAttribute(size == RichTextSize.small ? 'small' : 'large');
    final TextSelection selection = controller.selection;
    final String plain = controller.document.toPlainText();
    final int max = plain.length;
    if (selection.isValid && !selection.isCollapsed) {
      controller.formatSelection(attribute);
    } else {
      // 커서가 접혀 있으면 앞으로 칠 글만 바뀌고, 이미 있는 첫 줄은 그대로 남는다.
      final int cursor =
          selection.isValid ? selection.extentOffset.clamp(0, max) : 0;
      final int start =
          cursor == 0 ? 0 : plain.lastIndexOf('\n', cursor - 1) + 1;
      final int newline = plain.indexOf('\n', start);
      final int end = newline < 0 ? max : newline;
      if (end > start) {
        controller.formatText(start, end - start, attribute);
      }
      final int length = controller.document.length;
      final int caret = cursor.clamp(0, length == 0 ? 0 : length - 1);
      controller.formatText(caret, 0, attribute);
    }
    focusNode.requestFocus();
  }

  void _bold() {
    final bool enabled = controller.getSelectionStyle().containsKey(
      Attribute.bold.key,
    );
    controller.formatSelection(
      enabled ? Attribute.clone(Attribute.bold, null) : Attribute.bold,
    );
    focusNode.requestFocus();
  }

  void _align(Attribute<String?> attribute) {
    controller.formatSelection(attribute);
    focusNode.requestFocus();
  }
}

class ShowroomEmbedBuilder extends EmbedBuilder {
  ShowroomEmbedBuilder({
    required this.pickImages,
    required this.loadRecord,
    required this.chooseLayout,
    required this.onReplace,
    required this.onDelete,
  });

  final Future<List<String>> Function({bool multiple}) pickImages;
  final List<ShowroomProcessFrame> Function()? Function() loadRecord;
  final Future<ShowroomImageLayout?> Function() chooseLayout;
  final void Function(int offset, ShowroomBlock block) onReplace;
  final void Function(int offset) onDelete;

  @override
  String get key => kShowroomEmbedType;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final ShowroomBlock? parsed = showroomBlockFromEmbed(
      embedContext.node.value,
    );
    if (parsed == null) return const SizedBox.shrink();
    return _ShowroomEmbedHost(
      block: parsed,
      offset: embedContext.node.documentOffset,
      pickImages: pickImages,
      chooseLayout: chooseLayout,
      loadRecord: loadRecord(),
      onReplace: onReplace,
      onDelete: onDelete,
    );
  }
}

class _ShowroomEmbedHost extends StatefulWidget {
  const _ShowroomEmbedHost({
    required this.block,
    required this.offset,
    required this.pickImages,
    required this.chooseLayout,
    required this.loadRecord,
    required this.onReplace,
    required this.onDelete,
  });

  final ShowroomBlock block;
  final int offset;
  final Future<List<String>> Function({bool multiple}) pickImages;
  final Future<ShowroomImageLayout?> Function() chooseLayout;
  final List<ShowroomProcessFrame> Function()? loadRecord;
  final void Function(int offset, ShowroomBlock block) onReplace;
  final void Function(int offset) onDelete;

  @override
  State<_ShowroomEmbedHost> createState() => _ShowroomEmbedHostState();
}

class _ShowroomEmbedHostState extends State<_ShowroomEmbedHost> {
  late ShowroomBlock _block = widget.block;

  @override
  void didUpdateWidget(covariant _ShowroomEmbedHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.block.id != _block.id) _block = widget.block;
  }

  void _replace(ShowroomBlock next) {
    setState(() => _block = next);
    widget.onReplace(widget.offset, next);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child:
          _block.kind == ShowroomBlockKind.process
              ? ShowroomProcessCard(
                frames: _block.frames,
                onRemove: () => widget.onDelete(widget.offset),
                onFrames:
                    (List<ShowroomProcessFrame> frames) =>
                        _replace(_block.copyWith(frames: frames)),
                onLoad: widget.loadRecord,
                pickImage: () async {
                  final List<String> urls = await widget.pickImages();
                  if (urls.isEmpty) return null;
                  return urls.first;
                },
              )
              : ShowroomImageCard(
                block: _block,
                onRemove: () => widget.onDelete(widget.offset),
                onAddImage: () async {
                  final List<String> urls = await widget.pickImages(
                    multiple: true,
                  );
                  if (!mounted || urls.isEmpty) return;
                  final List<String> next = <String>[..._block.urls, ...urls];
                  ShowroomImageLayout layout = _block.layout;
                  if (next.length <= 1) {
                    layout = ShowroomImageLayout.photo;
                  } else if (layout == ShowroomImageLayout.photo) {
                    final ShowroomImageLayout? picked =
                        await widget.chooseLayout();
                    if (!mounted || picked == null) return;
                    layout = picked;
                  }
                  _replace(_block.copyWith(urls: next, layout: layout));
                },
                onPairs: (List<ShowroomBeforeAfterPair> pairs) {
                  _replace(_block.copyWith(pairs: pairs));
                },
                pickImage: () async {
                  final List<String> urls = await widget.pickImages();
                  if (urls.isEmpty) return null;
                  return urls.first;
                },
              ),
    );
  }
}

class _InsertButton extends StatelessWidget {
  const _InsertButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Color foreground = selected ? AppColors.white : AppColors.textPrimary;
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 15, color: foreground),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        height: 1,
                        letterSpacing: -0.4,
                        color: foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
