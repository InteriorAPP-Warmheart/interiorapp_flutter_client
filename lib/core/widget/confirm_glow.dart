import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';

/// 확인이 필요한 알림의 숨결. 0에서 1로 커졌다 사라진다.
double confirmGlowAmount(double t) => math.sin(t * math.pi).abs();

/// [active]일 때 같은 주기로 [builder]에 0–1 진행을 넘긴다.
class ConfirmPulse extends StatefulWidget {
  const ConfirmPulse({super.key, required this.active, required this.builder});

  final bool active;
  final Widget Function(BuildContext context, double t) builder;

  @override
  State<ConfirmPulse> createState() => _ConfirmPulseState();
}

class _ConfirmPulseState extends State<ConfirmPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.active) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant ConfirmPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active == oldWidget.active) return;
    if (widget.active) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return widget.builder(context, _controller.value);
      },
    );
  }
}

/// 아이콘 주변으로 번지는 빛. 가운데와 가장자리는 비워서 원판과 네모가 보이지 않는다.
class ConfirmHaloPainter extends CustomPainter {
  const ConfirmHaloPainter(this.glow);

  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    if (glow <= 0) return;
    final Offset center = size.center(Offset.zero);
    final double radius = size.shortestSide / 2;
    final Paint paint =
        Paint()
          ..shader = RadialGradient(
            colors: <Color>[
              AppColors.error.withValues(alpha: 0),
              AppColors.error.withValues(alpha: 0.42 * glow),
              AppColors.error.withValues(alpha: 0),
            ],
            stops: const <double>[0.34, 0.62, 1],
          ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(ConfirmHaloPainter oldDelegate) =>
      oldDelegate.glow != glow;
}

/// 둥근 칸 안쪽을 따라 번지는 빛. 칸 모양 밖으로 네모나게 잘리지 않는다.
class ConfirmRimPainter extends CustomPainter {
  const ConfirmRimPainter(this.glow);

  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    if (glow <= 0) return;
    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(13),
    );
    canvas.save();
    canvas.clipRRect(rrect);
    final Paint paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
          ..color = AppColors.error.withValues(alpha: 0.55 * glow);
    canvas.drawRRect(rrect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(ConfirmRimPainter oldDelegate) => oldDelegate.glow != glow;
}
