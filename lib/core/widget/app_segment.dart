import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';

/// 세그먼트 막대와 페이지가 같이 쓰는 위치.
/// 페이지 값은 0부터 칸 수 - 1까지, 드래그와 탭 애니메이션이 같은 값을 움직인다.
class AppSegmentController extends ChangeNotifier {
  AppSegmentController({
    required TickerProvider vsync,
    required this.length,
    int initialIndex = 0,
  }) : page = initialIndex.clamp(0, length - 1).toDouble() {
    _motion = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 280),
    )..addListener(_tick);
    _motion.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) notifyListeners();
    });
  }

  final int length;
  double page;
  late final AnimationController _motion;
  double _from = 0;
  double _to = 0;
  int? _dragFrom;

  int get index => page.round().clamp(0, length - 1);

  void animateTo(int next) {
    final int target = next.clamp(0, length - 1);
    _dragFrom = null;
    _from = page;
    _to = target.toDouble();
    if ((_from - _to).abs() < 0.001) {
      page = _to;
      notifyListeners();
      return;
    }
    _motion.forward(from: 0);
  }

  void dragStart() {
    _motion.stop();
    _dragFrom = page.round().clamp(0, length - 1);
  }

  void dragBy(double deltaPages) {
    final int origin = _dragFrom ?? index;
    final double next = origin + deltaPages;
    page = next.clamp(
      (origin - 1).clamp(0, length - 1).toDouble(),
      (origin + 1).clamp(0, length - 1).toDouble(),
    );
    notifyListeners();
  }

  void dragEnd(double velocityPages) {
    final int origin = _dragFrom ?? index;
    _dragFrom = null;
    var target = page.round();
    if (velocityPages <= -0.35) target = origin - 1;
    if (velocityPages >= 0.35) target = origin + 1;
    animateTo(target);
  }

  void _tick() {
    final double t = Curves.easeOutCubic.transform(_motion.value);
    page = _from + (_to - _from) * t;
    notifyListeners();
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }
}

/// 세그먼트 컨트롤러를 만들고, 막대와 페이지를 그 아래에 둔다.
class AppSegmentHost extends StatefulWidget {
  const AppSegmentHost({
    super.key,
    required this.length,
    required this.builder,
    this.initialIndex = 0,
    this.onChanged,
  });

  final int length;
  final int initialIndex;
  final ValueChanged<int>? onChanged;
  final Widget Function(BuildContext context, AppSegmentController controller)
  builder;

  @override
  State<AppSegmentHost> createState() => _AppSegmentHostState();
}

class _AppSegmentHostState extends State<AppSegmentHost>
    with SingleTickerProviderStateMixin {
  late final AppSegmentController _controller = AppSegmentController(
    vsync: this,
    length: widget.length,
    initialIndex: widget.initialIndex,
  );
  int _reported = 0;

  @override
  void initState() {
    super.initState();
    _reported = _controller.index;
    _controller.addListener(_report);
  }

  void _report() {
    if (_controller._motion.isAnimating || _controller._dragFrom != null) {
      return;
    }
    final int next = _controller.index;
    if (next == _reported) return;
    _reported = next;
    widget.onChanged?.call(next);
  }

  @override
  void dispose() {
    _controller.removeListener(_report);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _controller);
  }
}

/// 슬라이드되는 선택 막대. 글자, 칸 수, 높이, 글자 크기, 색만 바꿔 쓴다.
class AppSegmentBar extends StatelessWidget {
  const AppSegmentBar({
    super.key,
    required this.controller,
    required this.labels,
    this.height = 36,
    this.fontSize = 13,
    this.expand = true,
    this.trackColor = AppColors.background,
    this.thumbColor = AppColors.surface,
    this.selectedColor = AppColors.textPrimary,
    this.unselectedColor = AppColors.textSecondary,
    this.borderColor,
  });

  final AppSegmentController controller;
  final List<String> labels;
  final double height;
  final double fontSize;
  final bool expand;
  final Color trackColor;
  final Color thumbColor;
  final Color selectedColor;
  final Color unselectedColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    assert(labels.length == controller.length);
    final double inset = 3;
    final double radius = height / 2;
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        final double page = controller.page.clamp(
          0,
          (labels.length - 1).toDouble(),
        );
        final Widget bar = DecoratedBox(
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(radius),
            border:
                borderColor == null
                    ? null
                    : Border.all(color: borderColor!, width: 0.7),
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double slot = constraints.maxWidth / labels.length;
              final double thumbLeft = page * slot;
              return Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: thumbLeft + inset,
                    top: inset,
                    bottom: inset,
                    width: slot - inset * 2,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: thumbColor,
                        borderRadius: BorderRadius.circular(radius - inset),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Row(
                      children: [
                        for (var i = 0; i < labels.length; i++)
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.animateTo(i),
                              behavior: HitTestBehavior.opaque,
                              child: Center(
                                child: Text(
                                  labels[i],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    height: 1,
                                    leadingDistribution:
                                        TextLeadingDistribution.even,
                                    fontWeight: FontWeight.w700,
                                    color: Color.lerp(
                                      unselectedColor,
                                      selectedColor,
                                      (1 - (page - i).abs()).clamp(0, 1),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
        if (expand) {
          return SizedBox(height: height, width: double.infinity, child: bar);
        }
        final double slot = _hugSlot(labels, fontSize);
        return SizedBox(
          height: height,
          width: slot * labels.length,
          child: bar,
        );
      },
    );
  }
}

double _hugSlot(List<String> labels, double fontSize) {
  var widest = 0.0;
  for (final String label in labels) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    if (painter.width > widest) widest = painter.width;
  }
  return widest + 28;
}

/// 세그먼트와 같은 컨트롤러로 한 칸씩 넘어가는 페이지.
class AppSegmentPages extends StatelessWidget {
  const AppSegmentPages({
    super.key,
    required this.controller,
    required this.children,
  });

  final AppSegmentController controller;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    assert(children.length == controller.length);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return _SegmentPager(
          controller: controller,
          width: constraints.maxWidth,
          height: constraints.hasBoundedHeight ? constraints.maxHeight : null,
          children: children,
        );
      },
    );
  }
}

class _SegmentPager extends StatefulWidget {
  const _SegmentPager({
    required this.controller,
    required this.width,
    required this.height,
    required this.children,
  });

  final AppSegmentController controller;
  final double width;
  final double? height;
  final List<Widget> children;

  @override
  State<_SegmentPager> createState() => _SegmentPagerState();
}

class _SegmentPagerState extends State<_SegmentPager> {
  double _dragDx = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        final double page = widget.controller.page.clamp(
          0,
          (widget.children.length - 1).toDouble(),
        );
        final double width = widget.width;
        final double? viewport = widget.height;
        final Widget body =
            viewport == null
                ? _SlidePages(
                  page: page,
                  viewportWidth: width,
                  children: widget.children,
                )
                : SizedBox(
                  width: width,
                  height: viewport,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topLeft,
                      minWidth: width * widget.children.length,
                      maxWidth: width * widget.children.length,
                      minHeight: viewport,
                      maxHeight: viewport,
                      child: Transform.translate(
                        offset: Offset(-page * width, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final Widget pageChild in widget.children)
                              SizedBox(
                                width: width,
                                height: viewport,
                                child: pageChild,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: (_) {
            _dragDx = 0;
            widget.controller.dragStart();
          },
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            if (width <= 0) return;
            _dragDx += details.delta.dx;
            widget.controller.dragBy(-_dragDx / width);
          },
          onHorizontalDragEnd: (DragEndDetails details) {
            final double velocity =
                width <= 0 ? 0 : -details.velocity.pixelsPerSecond.dx / width;
            widget.controller.dragEnd(velocity);
          },
          child: body,
        );
      },
    );
  }
}

/// 세로 스크롤 안에서는 높이를 페이지 내용에 맞추고, 가로는 한 장만 보이게 자른다.
class _SlidePages extends MultiChildRenderObjectWidget {
  const _SlidePages({
    required this.page,
    required this.viewportWidth,
    required super.children,
  });

  final double page;
  final double viewportWidth;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSlidePages(page: page, viewportWidth: viewportWidth);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSlidePages renderObject,
  ) {
    renderObject
      ..page = page
      ..viewportWidth = viewportWidth;
  }
}

class _SlideParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderSlidePages extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _SlideParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _SlideParentData> {
  _RenderSlidePages({required double page, required double viewportWidth})
    : _page = page,
      _viewportWidth = viewportWidth;

  double _page;
  double _viewportWidth;

  set page(double value) {
    if (_page == value) return;
    _page = value;
    markNeedsLayout();
  }

  set viewportWidth(double value) {
    if (_viewportWidth == value) return;
    _viewportWidth = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _SlideParentData) {
      child.parentData = _SlideParentData();
    }
  }

  @override
  void performLayout() {
    final double width =
        _viewportWidth.isFinite && _viewportWidth > 0 ? _viewportWidth : 0;
    final BoxConstraints childConstraints = BoxConstraints.tightFor(
      width: width,
    );
    final List<double> heights = <double>[];
    double x = -_page * width;
    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);
      heights.add(child.size.height);
      final _SlideParentData data = child.parentData! as _SlideParentData;
      data.offset = Offset(x, 0);
      x += width;
      child = childAfter(child);
    }
    size = constraints.constrain(Size(width, _heightFor(heights)));
  }

  double _heightFor(List<double> heights) {
    if (heights.isEmpty) return 0;
    final int last = heights.length - 1;
    final double page = _page.clamp(0, last.toDouble());
    final int from = page.floor();
    final int to = page.ceil();
    final double start = heights[from];
    final double end = heights[to];
    if (!start.isFinite || !end.isFinite) return 0;
    return start + (end - start) * (page - from);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.pushClipRect(needsCompositing, offset, Offset.zero & size, (
      PaintingContext context,
      Offset offset,
    ) {
      defaultPaint(context, offset);
    });
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
