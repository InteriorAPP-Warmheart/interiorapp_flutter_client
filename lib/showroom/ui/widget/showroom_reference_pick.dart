import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/widget/app_button.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';

const List<String> showroomReferenceAspects = <String>['동일한 스타일', '동일한 예산', '같은 업종'];

ImageProvider<Object> _referenceImageProvider(String url) {
  if (url.startsWith('assets/')) return AssetImage(url);
  if (url.startsWith('/') || url.startsWith('file://')) {
    final String path = url.startsWith('file://') ? Uri.parse(url).toFilePath() : url;
    return FileImage(File(path));
  }
  return CachedNetworkImageProvider(url);
}

/// 전체 보기가 참고를 고르는 동안 사진들이 읽는 상태.
class ShowroomReferenceScope extends InheritedWidget {
  const ShowroomReferenceScope({
    super.key,
    required this.picking,
    required this.regions,
    required this.onToggle,
    required this.onSave,
    required super.child,
  });

  final bool picking;
  final Map<String, ShowroomReferenceRegion> regions;
  final void Function(String id, String label, String imageUrl) onToggle;
  final void Function(ShowroomReferenceRegion region) onSave;

  static ShowroomReferenceScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ShowroomReferenceScope>();
  }

  @override
  bool updateShouldNotify(ShowroomReferenceScope oldWidget) {
    return picking != oldWidget.picking || regions != oldWidget.regions;
  }
}

class ShowroomReferenceTarget {
  const ShowroomReferenceTarget({
    required this.id,
    required this.label,
    required this.imageUrl,
  });

  final String id;
  final String label;
  final String imageUrl;
}

/// 사진 위에 참고 선택을 얹는다. 참고 모드가 아니면 사진만 보여 준다.
class ShowroomReferablePhoto extends StatelessWidget {
  const ShowroomReferablePhoto({
    super.key,
    required this.id,
    required this.label,
    required this.imageUrl,
    required this.child,
  });

  final String id;
  final String label;
  final String imageUrl;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ShowroomReferenceScope? scope = ShowroomReferenceScope.maybeOf(context);
    if (scope == null || !scope.picking) return child;
    final ShowroomReferenceRegion? region = scope.regions[id];
    final bool selected = region != null;

    return Stack(
      children: [
        child,
        Positioned(
          top: 10,
          right: 10,
          child: _PickPill(
            label: selected ? '참고 중' : '참고',
            selected: selected,
            onTap: () => scope.onToggle(id, label, imageUrl),
          ),
        ),
        if (region != null)
          Positioned(
            left: 10,
            bottom: 10,
            child: _PickPill(
              label: region.hasMark ? '메모함' : '메모',
              selected: region.hasMark,
              onTap: () => _editRegion(context, scope, region),
            ),
          ),
      ],
    );
  }
}

/// 한 사진 안에 전·후처럼 고를 대상이 둘일 때.
class ShowroomReferenceTargets extends StatelessWidget {
  const ShowroomReferenceTargets({super.key, required this.targets});

  final List<ShowroomReferenceTarget> targets;

  @override
  Widget build(BuildContext context) {
    final ShowroomReferenceScope? scope = ShowroomReferenceScope.maybeOf(context);
    if (scope == null || !scope.picking || targets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          for (final ShowroomReferenceTarget target in targets)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      target.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (scope.regions[target.id] case final ShowroomReferenceRegion region)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _PickPill(
                        label: region.hasMark ? '메모함' : '메모',
                        selected: region.hasMark,
                        onDark: false,
                        onTap: () => _editRegion(context, scope, region),
                      ),
                    ),
                  _PickPill(
                    label: scope.regions.containsKey(target.id) ? '참고 중' : '참고',
                    selected: scope.regions.containsKey(target.id),
                    onDark: false,
                    onTap: () => scope.onToggle(target.id, target.label, target.imageUrl),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class ShowroomReferenceBanner extends StatelessWidget {
  const ShowroomReferenceBanner({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                '참고할 곳을 골라 주세요\n이미지 우측상단의 버튼을 눌러주세요',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: onClose,
              child: const Text(
                '취소',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShowroomReferenceSubmitBar extends StatelessWidget {
  const ShowroomReferenceSubmitBar({
    super.key,
    required this.count,
    required this.aspects,
    required this.onAspect,
    required this.onSubmit,
  });

  final int count;
  final Set<String> aspects;
  final ValueChanged<String> onAspect;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                count == 0 ? '고르지 않으면 게시글 전체를 참고합니다' : '$count곳을 참고합니다',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final String aspect in showroomReferenceAspects)
                    ChoiceChip(
                      label: Text(aspect),
                      selected: aspects.contains(aspect),
                      showCheckmark: false,
                      onSelected: (_) => onAspect(aspect),
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: aspects.contains(aspect) ? AppColors.white : AppColors.textPrimary,
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      side: BorderSide(
                        color: aspects.contains(aspect) ? AppColors.primary : AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              AppButton(label: '상담준비로 넘기기', onPressed: onSubmit),
            ],
          ),
        ),
      ),
    );
  }
}

/// 고른 영역을 썸네일로 자른다. 영역이 없으면 사진 전체를 보여 준다.
class ShowroomReferenceCropView extends StatelessWidget {
  const ShowroomReferenceCropView({
    super.key,
    required this.imageUrl,
    this.crop,
  });

  final String imageUrl;
  final ShowroomReferenceCrop? crop;

  @override
  Widget build(BuildContext context) {
    final Widget image = AppNetworkImage(url: imageUrl);
    final ShowroomReferenceCrop? area = crop;
    if (area == null || area.width <= 0 || area.height <= 0) return image;

    return ClipRect(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth / area.width;
          final double height = constraints.maxHeight / area.height;
          return OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: width,
            maxWidth: width,
            minHeight: height,
            maxHeight: height,
            child: Transform.translate(
              offset: Offset(-area.left * width, -area.top * height),
              child: SizedBox(width: width, height: height, child: image),
            ),
          );
        },
      ),
    );
  }
}

Future<ShowroomReferenceRegion?> showShowroomReferenceEditor(
  BuildContext context,
  ShowroomReferenceRegion region, {
  String? title,
  String saveLabel = '이 메모를 담기',
}) {
  return showModalBottomSheet<ShowroomReferenceRegion>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) => _RegionEditor(
      region: region,
      title: title,
      saveLabel: saveLabel,
    ),
  );
}

Future<void> _editRegion(
  BuildContext context,
  ShowroomReferenceScope scope,
  ShowroomReferenceRegion region,
) async {
  final ShowroomReferenceRegion? saved = await showShowroomReferenceEditor(context, region);
  if (saved == null) return;
  scope.onSave(saved);
}

class _PickPill extends StatelessWidget {
  const _PickPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.onDark = true,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final Color background =
        selected ? AppColors.primary : (onDark ? const Color(0xF2FFFFFF) : AppColors.surface);
    final Color foreground = selected ? AppColors.white : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: foreground),
          ),
        ),
      ),
    );
  }
}

enum _MarkTool { select, draw, rect, ellipse }

enum _MarkEdit { move, resize }

enum _ResizeCorner { topLeft, topRight, bottomLeft, bottomRight }

const double _handleRadius = 13;
const double _handleReach = 22;
const double _deleteRadius = 13;
const double _deleteReach = _deleteRadius;

Offset _deleteAnchor(Rect rect) => rect.topRight + const Offset(20, -20);

const List<int> _markColors = <int>[
  0xFFFFFFFF,
  0xFFFF4D6A,
  0xFFF5C542,
  0xFF3DDC97,
  0xFF2F6BFF,
];

class _RegionEditor extends StatefulWidget {
  const _RegionEditor({required this.region, this.title, this.saveLabel = '이 메모를 담기'});

  final ShowroomReferenceRegion region;
  final String? title;
  final String saveLabel;

  @override
  State<_RegionEditor> createState() => _RegionEditorState();
}

class _RegionEditorState extends State<_RegionEditor> {
  late final List<ShowroomReferenceMark> _marks = <ShowroomReferenceMark>[
    ...widget.region.marks,
    if (widget.region.marks.isEmpty && widget.region.crop != null)
      ShowroomReferenceMark.shape(
        kind: ShowroomReferenceMarkKind.rect,
        left: widget.region.crop!.left,
        top: widget.region.crop!.top,
        width: widget.region.crop!.width,
        height: widget.region.crop!.height,
      ),
  ];
  late final TextEditingController _note = TextEditingController(text: widget.region.note);
  _MarkTool _tool = _MarkTool.draw;
  int _color = 0xFFFFFFFF;
  ShowroomReferenceMark? _draft;
  List<ShowroomReferencePoint> _stroke = <ShowroomReferencePoint>[];
  double _strokePixels = 0;
  Offset? _origin;
  int? _selected;
  bool _tracking = false;
  _MarkEdit? _edit;
  _ResizeCorner? _corner;
  ShowroomReferenceMark? _editOrigin;
  Offset? _editPointer;
  double? _aspect;
  ImageStream? _imageStream;
  ImageStreamListener? _imageListener;

  @override
  void initState() {
    super.initState();
    final ImageProvider provider = _referenceImageProvider(widget.region.imageUrl);
    final ImageStream stream = provider.resolve(const ImageConfiguration());
    final ImageStreamListener listener = ImageStreamListener((ImageInfo info, bool _) {
      if (!mounted) return;
      setState(() => _aspect = info.image.width / info.image.height);
    });
    stream.addListener(listener);
    _imageStream = stream;
    _imageListener = listener;
  }

  @override
  void dispose() {
    final ImageStreamListener? listener = _imageListener;
    if (listener != null) _imageStream?.removeListener(listener);
    _note.dispose();
    super.dispose();
  }

  ShowroomReferencePoint _point(Offset position, Size size) {
    return ShowroomReferencePoint(
      (position.dx / size.width).clamp(0.0, 1.0),
      (position.dy / size.height).clamp(0.0, 1.0),
    );
  }

  void _pointerDown(Offset position, Size size) {
    _tracking = true;
    _start(position, size);
  }

  void _pointerMove(Offset position, Size size) {
    if (!_tracking) return;
    _move(position, size);
  }

  void _pointerUp() {
    if (!_tracking) return;
    _tracking = false;
    _end();
  }

  void _chooseTool(_MarkTool tool) {
    setState(() {
      _tool = tool;
      if (tool != _MarkTool.select) _selected = null;
    });
  }

  void _armEdit(int index, Offset position, _MarkEdit edit, _ResizeCorner? corner) {
    setState(() {
      _selected = index;
      _edit = edit;
      _corner = corner;
      _editOrigin = _marks[index];
      _editPointer = position;
      _origin = null;
      _draft = null;
      _stroke = <ShowroomReferencePoint>[];
    });
  }

  void _start(Offset position, Size size) {
    final int? selected = _selected;
    if (selected != null && selected >= 0 && selected < _marks.length) {
      if (_deleteAt(selected, position, size)) {
        _deleteSelected();
        return;
      }
      final _ResizeCorner? corner = _cornerAt(selected, position, size);
      if (corner != null) {
        _armEdit(selected, position, _MarkEdit.resize, corner);
        return;
      }
      if (_inSelectionBody(selected, position, size)) {
        _armEdit(selected, position, _MarkEdit.move, null);
        return;
      }
    }
    if (_tool == _MarkTool.select) {
      final int? hit = _hitTest(position, size);
      if (hit == null) {
        setState(() {
          _selected = null;
          _edit = null;
          _corner = null;
          _editOrigin = null;
          _editPointer = null;
          _origin = null;
          _draft = null;
          _stroke = <ShowroomReferencePoint>[];
        });
        return;
      }
      setState(() {
        _selected = hit;
        _edit = null;
        _corner = null;
        _editOrigin = null;
        _editPointer = null;
        _origin = null;
        _draft = null;
        _stroke = <ShowroomReferencePoint>[];
      });
      return;
    }
    final ShowroomReferencePoint point = _point(position, size);
    if (_tool == _MarkTool.draw) {
      setState(() {
        _origin = null;
        _strokePixels = 0;
        _stroke = <ShowroomReferencePoint>[point];
        _draft = ShowroomReferenceMark.stroke(_stroke, color: _color);
      });
      return;
    }
    setState(() {
      _stroke = <ShowroomReferencePoint>[];
      _origin = position;
      _draft = null;
    });
  }

  void _move(Offset position, Size size) {
    final int? selected = _selected;
    final ShowroomReferenceMark? originMark = _editOrigin;
    final Offset? pointer = _editPointer;
    if (_edit != null && selected != null && originMark != null && pointer != null) {
      final Offset delta = position - pointer;
      setState(() {
        _marks[selected] = _edit == _MarkEdit.resize
            ? _resize(originMark, _corner ?? _ResizeCorner.bottomRight, position, size)
            : _translate(originMark, delta.dx / size.width, delta.dy / size.height);
      });
      return;
    }
    if (_tool == _MarkTool.draw) {
      if (_stroke.isEmpty) return;
      final ShowroomReferencePoint point = _point(position, size);
      final ShowroomReferencePoint last = _stroke.last;
      final double dx = (point.x - last.x) * size.width;
      final double dy = (point.y - last.y) * size.height;
      if (dx * dx + dy * dy < 9) return;
      setState(() {
        _strokePixels += math.sqrt(dx * dx + dy * dy);
        _stroke = <ShowroomReferencePoint>[..._stroke, point];
        _draft = ShowroomReferenceMark.stroke(_stroke, color: _color);
      });
      return;
    }
    final Offset? origin = _origin;
    if (origin == null) return;
    final ShowroomReferenceMark? shape = _shape(origin, position, size);
    setState(() => _draft = shape);
  }

  void _end() {
    if (_edit != null) {
      setState(() {
        _edit = null;
        _corner = null;
        _editOrigin = null;
        _editPointer = null;
      });
      return;
    }
    final bool strokeKept = _tool == _MarkTool.draw && _stroke.length >= 2 && _strokePixels >= 24;
    final ShowroomReferenceMark? drawn = strokeKept
        ? ShowroomReferenceMark.stroke(List<ShowroomReferencePoint>.from(_stroke), color: _color)
        : (_tool == _MarkTool.draw ? null : _draft);
    setState(() {
      if (drawn != null) {
        _marks.add(drawn);
        _selected = _marks.length - 1;
      }
      _stroke = <ShowroomReferencePoint>[];
      _strokePixels = 0;
      _origin = null;
      _draft = null;
    });
  }

  int? _hitTest(Offset position, Size size) {
    for (int index = _marks.length - 1; index >= 0; index--) {
      if (_selectionRect(_marks[index], size).inflate(8).contains(position)) return index;
    }
    return null;
  }

  ShowroomReferenceMark _translate(ShowroomReferenceMark mark, double dx, double dy) {
    final Rect bounds = _normBounds(mark);
    if (bounds.left + dx < 0) dx = -bounds.left;
    if (bounds.right + dx > 1) dx = 1 - bounds.right;
    if (bounds.top + dy < 0) dy = -bounds.top;
    if (bounds.bottom + dy > 1) dy = 1 - bounds.bottom;
    if (mark.kind == ShowroomReferenceMarkKind.stroke) {
      return ShowroomReferenceMark.stroke(
        <ShowroomReferencePoint>[
          for (final ShowroomReferencePoint point in mark.points)
            ShowroomReferencePoint(point.x + dx, point.y + dy),
        ],
        color: mark.color,
      );
    }
    return ShowroomReferenceMark.shape(
      kind: mark.kind,
      left: (mark.left ?? 0) + dx,
      top: (mark.top ?? 0) + dy,
      width: mark.width ?? 0,
      height: mark.height ?? 0,
      color: mark.color,
    );
  }

  void _deleteSelected() {
    final int? index = _selected;
    if (index == null || index < 0 || index >= _marks.length) return;
    setState(() {
      _marks.removeAt(index);
      _selected = null;
      _edit = null;
      _corner = null;
      _editOrigin = null;
      _editPointer = null;
      _origin = null;
      _draft = null;
      _stroke = <ShowroomReferencePoint>[];
    });
  }

  bool _deleteAt(int index, Offset position, Size size) {
    final Offset anchor = _deleteAnchor(_selectionRect(_marks[index], size));
    return (position - anchor).distance <= _deleteReach;
  }

  bool _inSelectionBody(int index, Offset position, Size size) {
    final Rect rect = _selectionRect(_marks[index], size);
    final Rect inner = rect.deflate(_handleReach);
    if (inner.width >= 12 && inner.height >= 12) return inner.contains(position);
    return (position - rect.center).distance <= 18;
  }

  _ResizeCorner? _cornerAt(int index, Offset position, Size size) {
    final Rect rect = _selectionRect(_marks[index], size);
    const double reach = _handleReach;
    final List<(_ResizeCorner, Offset)> handles = <(_ResizeCorner, Offset)>[
      (_ResizeCorner.topLeft, rect.topLeft),
      (_ResizeCorner.topRight, rect.topRight),
      (_ResizeCorner.bottomLeft, rect.bottomLeft),
      (_ResizeCorner.bottomRight, rect.bottomRight),
    ];
    for (final (_ResizeCorner corner, Offset handle) in handles) {
      if ((position - handle).distance <= reach) return corner;
    }
    return null;
  }

  ShowroomReferenceMark _resize(
    ShowroomReferenceMark mark,
    _ResizeCorner corner,
    Offset finger,
    Size size,
  ) {
    final Rect visual = _selectionRect(mark, size);
    final Rect bounds = Rect.fromLTRB(
      visual.left / size.width,
      visual.top / size.height,
      visual.right / size.width,
      visual.bottom / size.height,
    );
    final double minWidth = 28 / size.width;
    final double minHeight = 28 / size.height;
    final double x = (finger.dx / size.width).clamp(0.0, 1.0);
    final double y = (finger.dy / size.height).clamp(0.0, 1.0);
    double left = bounds.left;
    double top = bounds.top;
    double right = bounds.right;
    double bottom = bounds.bottom;
    switch (corner) {
      case _ResizeCorner.topLeft:
        left = x.clamp(0.0, bounds.right - minWidth);
        top = y.clamp(0.0, bounds.bottom - minHeight);
      case _ResizeCorner.topRight:
        right = x.clamp(bounds.left + minWidth, 1.0);
        top = y.clamp(0.0, bounds.bottom - minHeight);
      case _ResizeCorner.bottomLeft:
        left = x.clamp(0.0, bounds.right - minWidth);
        bottom = y.clamp(bounds.top + minHeight, 1.0);
      case _ResizeCorner.bottomRight:
        right = x.clamp(bounds.left + minWidth, 1.0);
        bottom = y.clamp(bounds.top + minHeight, 1.0);
    }
    final Rect next = Rect.fromLTRB(left, top, right, bottom);
    if (mark.kind == ShowroomReferenceMarkKind.stroke) {
      double mapX(double value) {
        if (bounds.width < 0.0001) return next.left;
        return next.left + (value - bounds.left) / bounds.width * next.width;
      }

      double mapY(double value) {
        if (bounds.height < 0.0001) return next.top;
        return next.top + (value - bounds.top) / bounds.height * next.height;
      }

      return ShowroomReferenceMark.stroke(
        <ShowroomReferencePoint>[
          for (final ShowroomReferencePoint point in mark.points)
            ShowroomReferencePoint(mapX(point.x), mapY(point.y)),
        ],
        color: mark.color,
      );
    }
    return ShowroomReferenceMark.shape(
      kind: mark.kind,
      left: next.left,
      top: next.top,
      width: next.width,
      height: next.height,
      color: mark.color,
    );
  }

  ShowroomReferenceMark? _shape(Offset start, Offset end, Size size) {
    if (size.width <= 0 || size.height <= 0) return null;
    final double left = start.dx.clamp(0.0, size.width).toDouble();
    final double top = start.dy.clamp(0.0, size.height).toDouble();
    final double right = end.dx.clamp(0.0, size.width).toDouble();
    final double bottom = end.dy.clamp(0.0, size.height).toDouble();
    final Rect rect = Rect.fromLTRB(
      left < right ? left : right,
      top < bottom ? top : bottom,
      left < right ? right : left,
      top < bottom ? bottom : top,
    );
    if (rect.width < 36 || rect.height < 36) return null;
    return ShowroomReferenceMark.shape(
      kind: _tool == _MarkTool.ellipse
          ? ShowroomReferenceMarkKind.ellipse
          : ShowroomReferenceMarkKind.rect,
      left: rect.left / size.width,
      top: rect.top / size.height,
      width: rect.width / size.width,
      height: rect.height / size.height,
      color: _color,
    );
  }

  void _save() {
    Navigator.of(context).pop(
      ShowroomReferenceRegion(
        id: widget.region.id,
        label: widget.region.label,
        imageUrl: widget.region.imageUrl,
        marks: List<ShowroomReferenceMark>.from(_marks),
        note: _note.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double inset = MediaQuery.viewInsetsOf(context).bottom;
    final double height = (MediaQuery.sizeOf(context).height - inset) * 0.92;
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: Material(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: height,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(child: SizedBox.shrink()),
                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            child: const Text('닫기'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    widget.title ?? widget.region.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _ToolButton(
                                label: '선택',
                                icon: Icons.near_me_outlined,
                                selected: _tool == _MarkTool.select,
                                onTap: () => _chooseTool(_MarkTool.select),
                              ),
                              const SizedBox(width: 8),
                              _ToolButton(
                                label: '그리기',
                                icon: Icons.draw_outlined,
                                selected: _tool == _MarkTool.draw,
                                onTap: () => _chooseTool(_MarkTool.draw),
                              ),
                              const SizedBox(width: 8),
                              _ToolButton(
                                label: '사각형',
                                icon: Icons.crop_square,
                                selected: _tool == _MarkTool.rect,
                                onTap: () => _chooseTool(_MarkTool.rect),
                              ),
                              const SizedBox(width: 8),
                              _ToolButton(
                                label: '원',
                                icon: Icons.circle_outlined,
                                selected: _tool == _MarkTool.ellipse,
                                onTap: () => _chooseTool(_MarkTool.ellipse),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: '되돌리기',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        onPressed: _marks.isEmpty
                            ? null
                            : () => setState(() {
                                _marks.removeLast();
                                _selected = null;
                              }),
                        icon: const Icon(Icons.undo),
                        color: AppColors.primary,
                        disabledColor: AppColors.border,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final int color in _markColors) ...[
                        _ColorDot(
                          color: color,
                          selected: _color == color,
                          onTap: () => setState(() => _color = color),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        const double gutter = 32;
                        final double? aspect = _aspect;
                        final double slotW = constraints.maxWidth;
                        final double slotH = constraints.maxHeight;
                        if (aspect == null || aspect <= 0) {
                          return const ColoredBox(color: AppColors.imagePlaceholder);
                        }
                        final double availW = math.max(1, slotW - gutter * 2);
                        final double availH = math.max(1, (slotH - gutter * 2) * 0.96);
                        double imageW = availW;
                        double imageH = imageW / aspect;
                        if (imageH > availH) {
                          imageH = availH;
                          imageW = imageH * aspect;
                        }
                        final Size size = Size(imageW, imageH);
                        final Offset origin = Offset((slotW - imageW) / 2, gutter);
                        return SizedBox(
                          width: slotW,
                          height: slotH,
                          child: Listener(
                              onPointerDown: (PointerDownEvent event) =>
                                  _pointerDown(event.localPosition - origin, size),
                              onPointerMove: (PointerMoveEvent event) =>
                                  _pointerMove(event.localPosition - origin, size),
                              onPointerUp: (PointerUpEvent event) => _pointerUp(),
                              onPointerCancel: (PointerCancelEvent event) => _pointerUp(),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onVerticalDragStart: (DragStartDetails details) {},
                                onVerticalDragUpdate: (DragUpdateDetails details) {},
                                onVerticalDragEnd: (DragEndDetails details) {},
                                onHorizontalDragStart: (DragStartDetails details) {},
                                onHorizontalDragUpdate: (DragUpdateDetails details) {},
                                onHorizontalDragEnd: (DragEndDetails details) {},
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Positioned(
                                      left: origin.dx,
                                      top: origin.dy,
                                      width: size.width,
                                      height: size.height,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: AppNetworkImage(
                                          url: widget.region.imageUrl,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: _MarkPainter(
                                          origin: origin,
                                          imageSize: size,
                                          marks: _marks,
                                          draft: _draft,
                                          selected: _draft == null ? _selected : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _note,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 15, height: 1.4),
                    decoration: InputDecoration(
                      hintText: '이 부분에서 참고하고 싶은 점',
                      hintStyle: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppButton(label: widget.saveLabel, onPressed: _save),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color, required this.selected, required this.onTap});

  final int color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.textPrimary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: DecoratedBox(
            decoration: BoxDecoration(color: Color(color), shape: BoxShape.circle),
            child: const SizedBox(width: 16, height: 16),
          ),
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            children: [
              Icon(icon, size: 16, color: selected ? AppColors.white : AppColors.primary),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.white : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({
    this.origin = Offset.zero,
    this.imageSize,
    required this.marks,
    this.draft,
    this.selected,
  });

  final Offset origin;
  final Size? imageSize;
  final List<ShowroomReferenceMark> marks;
  final ShowroomReferenceMark? draft;
  final int? selected;

  @override
  void paint(Canvas canvas, Size size) {
    final Size image = imageSize ?? size;
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    for (final ShowroomReferenceMark mark in <ShowroomReferenceMark>[
      ...marks,
      if (draft != null) draft!,
    ]) {
      final Color color = Color(mark.color);
      final Paint stroke = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final Paint fill = Paint()
        ..color = color.withValues(alpha: 0.22)
        ..style = PaintingStyle.fill;
      _paintMark(canvas, image, mark, stroke, fill);
    }
    final int? index = selected;
    if (index != null && index >= 0 && index < marks.length) {
      final Rect rect = _selectionRect(marks[index], image);
      canvas.drawRect(
        rect,
        Paint()
          ..color = const Color(0xFFFFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      for (final Offset handle in <Offset>[
        rect.topLeft,
        rect.topRight,
        rect.bottomLeft,
        rect.bottomRight,
      ]) {
        _paintKnob(canvas, handle, _handleRadius);
      }
      final Offset remove = _deleteAnchor(rect);
      _paintKnob(canvas, remove, _deleteRadius);
      final Paint icon = Paint()
        ..color = const Color(0xFF0B1F38)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(remove + const Offset(-4, -4), remove + const Offset(4, 4), icon);
      canvas.drawLine(remove + const Offset(-4, 4), remove + const Offset(4, -4), icon);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MarkPainter oldDelegate) => true;
}

void _paintKnob(Canvas canvas, Offset center, double radius) {
  canvas.drawCircle(center, radius, Paint()..color = const Color(0xFFFFFFFF));
  canvas.drawCircle(
    center,
    radius,
    Paint()
      ..color = const Color(0xFF0B1F38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2,
  );
}

void _paintMark(
  Canvas canvas,
  Size size,
  ShowroomReferenceMark mark,
  Paint stroke,
  Paint fill,
) {
  switch (mark.kind) {
    case ShowroomReferenceMarkKind.stroke:
      if (mark.points.length < 2) return;
      final Path path = Path()
        ..moveTo(mark.points.first.x * size.width, mark.points.first.y * size.height);
      for (final ShowroomReferencePoint point in mark.points.skip(1)) {
        path.lineTo(point.x * size.width, point.y * size.height);
      }
      canvas.drawPath(path, stroke);
    case ShowroomReferenceMarkKind.rect:
      final Rect rect = _markRect(mark, size);
      canvas.drawRect(rect, fill);
      canvas.drawRect(rect, stroke);
    case ShowroomReferenceMarkKind.ellipse:
      final Rect rect = _markRect(mark, size);
      canvas.drawOval(rect, fill);
      canvas.drawOval(rect, stroke);
  }
}

Rect _pixelBounds(ShowroomReferenceMark mark, Size size) {
  final Rect bounds = _normBounds(mark);
  return Rect.fromLTRB(
    bounds.left * size.width,
    bounds.top * size.height,
    bounds.right * size.width,
    bounds.bottom * size.height,
  );
}

Rect _selectionRect(ShowroomReferenceMark mark, Size size) {
  Rect rect = _pixelBounds(mark, size);
  const double minSpan = 36;
  if (rect.width < minSpan) {
    final double extra = (minSpan - rect.width) / 2;
    rect = Rect.fromLTRB(rect.left - extra, rect.top, rect.right + extra, rect.bottom);
  }
  if (rect.height < minSpan) {
    final double extra = (minSpan - rect.height) / 2;
    rect = Rect.fromLTRB(rect.left, rect.top - extra, rect.right, rect.bottom + extra);
  }
  return rect;
}

Rect _normBounds(ShowroomReferenceMark mark) {
  if (mark.kind != ShowroomReferenceMarkKind.stroke) {
    return Rect.fromLTWH(mark.left ?? 0, mark.top ?? 0, mark.width ?? 0, mark.height ?? 0);
  }
  if (mark.points.isEmpty) return Rect.zero;
  double minX = mark.points.first.x;
  double minY = mark.points.first.y;
  double maxX = minX;
  double maxY = minY;
  for (final ShowroomReferencePoint point in mark.points) {
    if (point.x < minX) minX = point.x;
    if (point.y < minY) minY = point.y;
    if (point.x > maxX) maxX = point.x;
    if (point.y > maxY) maxY = point.y;
  }
  return Rect.fromLTRB(minX, minY, maxX, maxY);
}

Rect _markRect(ShowroomReferenceMark mark, Size size) {
  return Rect.fromLTWH(
    (mark.left ?? 0) * size.width,
    (mark.top ?? 0) * size.height,
    (mark.width ?? 0) * size.width,
    (mark.height ?? 0) * size.height,
  );
}

/// 사진과 그 위에 남긴 표시를 함께 보여 준다.
class ShowroomReferenceMarkView extends StatelessWidget {
  const ShowroomReferenceMarkView({
    super.key,
    required this.imageUrl,
    this.crop,
    this.marks = const <ShowroomReferenceMark>[],
  });

  final String imageUrl;
  final ShowroomReferenceCrop? crop;
  final List<ShowroomReferenceMark> marks;

  @override
  Widget build(BuildContext context) {
    if (marks.isEmpty) {
      return ShowroomReferenceCropView(imageUrl: imageUrl, crop: crop);
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        AppNetworkImage(url: imageUrl),
        CustomPaint(
          painter: _MarkPainter(marks: marks),
          child: const SizedBox.expand(),
        ),
      ],
    );
  }
}
