import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/showroom_story_model.dart';

/// 본문에 넣는 현장 기록. 공정, 내용, 사진, 순서를 이 카드 안에서 고친다.
class ShowroomProcessCard extends StatelessWidget {
  const ShowroomProcessCard({
    super.key,
    required this.frames,
    required this.onRemove,
    required this.onFrames,
    required this.pickImage,
    this.onLoad,
  });

  final List<ShowroomProcessFrame> frames;
  final VoidCallback onRemove;
  final ValueChanged<List<ShowroomProcessFrame>> onFrames;
  final Future<String?> Function() pickImage;
  final List<ShowroomProcessFrame> Function()? onLoad;

  ShowroomProcessFrame _frame(int index) {
    if (index < 0 || index >= frames.length) {
      return ShowroomProcessFrame(
        id: 'frame-${DateTime.now().microsecondsSinceEpoch}',
        imageUrl: '',
        caption: '',
      );
    }
    return frames[index];
  }

  void _write(int index, ShowroomProcessFrame frame) {
    final List<ShowroomProcessFrame> next = <ShowroomProcessFrame>[...frames];
    if (index < next.length) {
      next[index] = frame;
    } else {
      next.add(frame);
    }
    onFrames(next);
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD5D8DE)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 2, 4, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '현장 기록',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: onRemove,
                  canRequestFocus: false,
                  borderRadius: BorderRadius.circular(8),
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(Icons.close, size: 18),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(right: 6),
              child: Text(
                '위에서 아래로 공사가 이어져요. 손잡이를 끌어 순서를 바꿔요.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            if (onLoad != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => onFrames(onLoad!()),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    '기록에서 불러오기',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              )
            else
              const SizedBox(height: 8),
            _ProcessEditor(
              frames: frames,
              onAdd: () {
                onFrames(<ShowroomProcessFrame>[
                  ...frames,
                  ShowroomProcessFrame(
                    id: 'frame-${DateTime.now().microsecondsSinceEpoch}',
                    imageUrl: '',
                    caption: '',
                  ),
                ]);
              },
              onTrade:
                  (int index, String value) =>
                      _write(index, _frame(index).copyTrade(value)),
              onCaption:
                  (int index, String value) =>
                      _write(index, _frame(index).copyCaption(value)),
              onPhoto: (int index) async {
                final String? url = await pickImage();
                if (url == null || url.isEmpty) return;
                _write(index, _frame(index).copyImage(url));
              },
              onRemove: (int index) {
                if (index < 0 || index >= frames.length) return;
                onFrames(<ShowroomProcessFrame>[
                  for (var i = 0; i < frames.length; i++)
                    if (i != index) frames[i],
                ]);
              },
              onMove: (int oldIndex, int newIndex) {
                if (oldIndex < 0 || oldIndex >= frames.length) return;
                final List<ShowroomProcessFrame> next = <ShowroomProcessFrame>[
                  ...frames,
                ];
                final ShowroomProcessFrame frame = next.removeAt(oldIndex);
                final int target = newIndex.clamp(0, next.length);
                next.insert(target, frame);
                onFrames(next);
              },
            ),
          ],
        ),
      ),
    );
  }
}

extension on ShowroomProcessFrame {
  ShowroomProcessFrame copyTrade(String trade) {
    return ShowroomProcessFrame(
      id: id,
      trade: trade,
      imageUrl: imageUrl,
      caption: caption,
    );
  }

  ShowroomProcessFrame copyCaption(String caption) {
    return ShowroomProcessFrame(
      id: id,
      trade: trade,
      imageUrl: imageUrl,
      caption: caption,
    );
  }

  ShowroomProcessFrame copyImage(String imageUrl) {
    return ShowroomProcessFrame(
      id: id,
      trade: trade,
      imageUrl: imageUrl,
      caption: caption,
    );
  }
}

class _ProcessEditor extends StatefulWidget {
  const _ProcessEditor({
    required this.frames,
    required this.onAdd,
    required this.onTrade,
    required this.onCaption,
    required this.onPhoto,
    required this.onRemove,
    required this.onMove,
  });

  final List<ShowroomProcessFrame> frames;
  final VoidCallback onAdd;
  final void Function(int index, String value) onTrade;
  final void Function(int index, String value) onCaption;
  final ValueChanged<int> onPhoto;
  final ValueChanged<int> onRemove;
  final void Function(int oldIndex, int newIndex) onMove;

  @override
  State<_ProcessEditor> createState() => _ProcessEditorState();
}

class _ProcessRow {
  _ProcessRow({
    required String trade,
    required String caption,
    required this.key,
  }) : trade = TextEditingController(text: trade),
       caption = TextEditingController(text: caption);

  factory _ProcessRow.fromFrame(ShowroomProcessFrame frame) {
    return _ProcessRow(
      key: ValueKey<String>(
        frame.id.isEmpty ? 'process-${identityHashCode(frame)}' : frame.id,
      ),
      trade: frame.trade,
      caption: frame.caption,
    );
  }

  final Key key;
  final TextEditingController trade;
  final TextEditingController caption;

  void dispose() {
    trade.dispose();
    caption.dispose();
  }
}

class _ProcessEditorState extends State<_ProcessEditor> {
  late List<_ProcessRow> _rows;
  bool _localEdit = false;

  @override
  void initState() {
    super.initState();
    _rows = <_ProcessRow>[
      for (final ShowroomProcessFrame frame in widget.frames)
        _ProcessRow.fromFrame(frame),
    ];
  }

  @override
  void didUpdateWidget(covariant _ProcessEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_localEdit) {
      _localEdit = false;
      return;
    }
    if (!_sameFrames(oldWidget.frames, widget.frames)) {
      for (final _ProcessRow row in _rows) {
        row.dispose();
      }
      _rows = <_ProcessRow>[
        for (final ShowroomProcessFrame frame in widget.frames)
          _ProcessRow.fromFrame(frame),
      ];
    }
  }

  bool _sameFrames(
    List<ShowroomProcessFrame> before,
    List<ShowroomProcessFrame> after,
  ) {
    if (before.length != after.length) return false;
    for (var i = 0; i < before.length; i++) {
      if (before[i].id != after[i].id) return false;
    }
    return true;
  }

  void _add() {
    _localEdit = true;
    setState(
      () => _rows.add(_ProcessRow(key: UniqueKey(), trade: '', caption: '')),
    );
    widget.onAdd();
  }

  void _remove(int index) {
    _localEdit = true;
    final _ProcessRow row = _rows.removeAt(index);
    setState(() {});
    widget.onRemove(index);
    WidgetsBinding.instance.addPostFrameCallback((_) => row.dispose());
  }

  void _move(int oldIndex, int newIndex) {
    _localEdit = true;
    setState(() {
      final _ProcessRow row = _rows.removeAt(oldIndex);
      _rows.insert(newIndex, row);
    });
    widget.onMove(oldIndex, newIndex);
  }

  @override
  void dispose() {
    for (final _ProcessRow row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: _rows.length,
          onReorderItem: _move,
          proxyDecorator: (
            Widget child,
            int index,
            Animation<double> animation,
          ) {
            return AnimatedBuilder(
              animation: animation,
              builder: (BuildContext context, Widget? child) {
                final double lift = Curves.easeOut.transform(animation.value);
                return DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.08 * lift),
                        blurRadius: 10,
                        offset: Offset(0, 3 * lift),
                      ),
                    ],
                  ),
                  child: Material(
                    color: AppColors.surface,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: child,
                  ),
                );
              },
              child: child,
            );
          },
          itemBuilder: (BuildContext context, int index) {
            final _ProcessRow row = _rows[index];
            final String url =
                index < widget.frames.length
                    ? widget.frames[index].imageUrl
                    : '';
            return Padding(
              key: row.key,
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReorderableDragStartListener(
                    index: index,
                    child: const Padding(
                      padding: EdgeInsets.only(top: 22, right: 2),
                      child: Icon(
                        Icons.drag_handle,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  _ProcessPhotoWell(
                    url: url,
                    onTap: () => widget.onPhoto(index),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      children: [
                        _ProcessField(
                          controller: row.trade,
                          hint: '공정. 예: 철거',
                          onChanged:
                              (String value) => widget.onTrade(index, value),
                        ),
                        const SizedBox(height: 6),
                        _ProcessField(
                          controller: row.caption,
                          hint: '내용. 예: 철거를 먼저 비웠습니다.',
                          onChanged:
                              (String value) => widget.onCaption(index, value),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _remove(index),
                    icon: const Icon(Icons.close, size: 18),
                    color: AppColors.textSecondary,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: _add,
              borderRadius: BorderRadius.circular(12),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.add, color: AppColors.textPrimary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProcessPhotoWell extends StatelessWidget {
  const _ProcessPhotoWell({required this.url, required this.onTap});

  final String url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool filled = url.trim().isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Material(
        color: AppColors.surface,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 72,
            height: 72,
            child:
                filled
                    ? AppNetworkImage(url: url)
                    : const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
          ),
        ),
      ),
    );
  }
}

class _ProcessField extends StatelessWidget {
  const _ProcessField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 13,
          color: Color(0xFFB0B6BE),
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
