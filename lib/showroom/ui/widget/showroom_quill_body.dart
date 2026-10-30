import 'package:flutter/material.dart';
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

class _ShowroomQuillBodyState extends State<ShowroomQuillBody> {
  @override
  void initState() {
    super.initState();
    installQuillSimulatorGuard();
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
      replaceShowroomEmbed(widget.controller, offset, block);
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
            scrollController: widget.scrollController,
            config: QuillEditorConfig(
              scrollable: false,
              minHeight: 200,
              placeholder: '이 칸에 적을 내용',
              padding: EdgeInsets.zero,
              onTapOutsideEnabled: false,
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
