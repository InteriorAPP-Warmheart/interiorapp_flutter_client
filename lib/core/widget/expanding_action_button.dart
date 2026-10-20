import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';

/// 펼친 버튼을 바깥에서 접을 때 쓴다.
class ExpandingActionController {
  VoidCallback? _close;

  void close() => _close?.call();
}

/// 아이콘에서 시작해 왼쪽으로 구르며 펼쳐지는 버튼.
///
/// [label] 길이에 맞춰 펼친 너비가 정해진다.
/// 부모는 [Stack]이어야 하고, 버튼은 오른쪽 아래에 붙는다.
class ExpandingActionButton extends StatefulWidget {
  const ExpandingActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.controller,
    this.backgroundColor = AppColors.primary,
    this.foregroundColor = AppColors.white,
    this.iconSize = 22,
    this.collapsedSize = 56,
    this.right = 16,
    this.bottom,
    this.textStyle = const TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 15,
      fontWeight: FontWeight.w700,
    ),
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final ExpandingActionController? controller;
  final Color backgroundColor;
  final Color foregroundColor;
  final double iconSize;
  final double collapsedSize;
  final double right;

  /// 부모 아래에서의 거리. 비우면 안전 영역 위로 16만큼 올린다.
  final double? bottom;

  final TextStyle textStyle;

  @override
  State<ExpandingActionButton> createState() => _ExpandingActionButtonState();
}

class _ExpandingActionButtonState extends State<ExpandingActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expand;
  late final Animation<double> _label;
  double _expanded = 56;

  @override
  void initState() {
    super.initState();
    widget.controller?._close = _close;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      reverseDuration: const Duration(milliseconds: 750),
    );
    _expand = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
      reverseCurve: Curves.easeInOutSine,
    );
    _label = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.12, 1, curve: Curves.easeInOutSine),
      reverseCurve: const Interval(0.4, 1, curve: Curves.easeInOutSine),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _measure();
  }

  @override
  void didUpdateWidget(ExpandingActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller?._close == _close) {
        oldWidget.controller?._close = null;
      }
      widget.controller?._close = _close;
    }
    if (oldWidget.label != widget.label ||
        oldWidget.textStyle != widget.textStyle ||
        oldWidget.collapsedSize != widget.collapsedSize) {
      _measure();
    }
  }

  @override
  void dispose() {
    if (widget.controller?._close == _close) widget.controller?._close = null;
    _controller.dispose();
    super.dispose();
  }

  void _measure() {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: widget.label, style: widget.textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final double collapsed = widget.collapsedSize;
    _expanded = painter.width + 40;
    if (_expanded < collapsed) _expanded = collapsed;
  }

  void _close() {
    if (_controller.value == 0) return;
    _controller.reverse();
  }

  void _activate() {
    if (_controller.isCompleted) {
      _controller.value = 0;
      widget.onPressed();
      return;
    }
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final double bottom =
        widget.bottom ?? MediaQuery.paddingOf(context).bottom + 16;
    final double collapsed = widget.collapsedSize;
    final Color foreground = widget.foregroundColor;
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double width = collapsed + (_expanded - collapsed) * _expand.value;
        final double travel =
            (_expanded + widget.iconSize / 2 - collapsed / 2) * _expand.value;
        return Stack(
          children: [
            Positioned(
              right: widget.right,
              bottom: bottom,
              child: RepaintBoundary(
                child: Material(
                  color: widget.backgroundColor,
                  elevation: 2,
                  shadowColor: const Color(0x33000000),
                  borderRadius: BorderRadius.circular(collapsed / 2),
                  clipBehavior: Clip.antiAlias,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _activate,
                    child: SizedBox(
                      height: collapsed,
                      width: width,
                      child: Stack(
                        clipBehavior: Clip.antiAlias,
                        children: [
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: Transform.translate(
                                filterQuality: FilterQuality.medium,
                                offset: Offset(
                                  (1 - _expand.value) * (_expanded - collapsed) / 2,
                                  0,
                                ),
                                child: Opacity(
                                  opacity: _label.value,
                                  child: Text(
                                    widget.label,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.clip,
                                    style: widget.textStyle.copyWith(
                                      color: foreground,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            width: collapsed,
                            height: collapsed,
                            child: Transform.translate(
                              filterQuality: FilterQuality.medium,
                              offset: Offset(-travel, 0),
                              child: Transform.rotate(
                                filterQuality: FilterQuality.medium,
                                angle: -travel / (collapsed / 2),
                                child: Center(
                                  child: Icon(
                                    widget.icon,
                                    color: foreground,
                                    size: widget.iconSize,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
