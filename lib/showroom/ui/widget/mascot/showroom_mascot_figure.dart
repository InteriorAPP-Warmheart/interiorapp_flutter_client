import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/mascot/showroom_mascot_assets.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/mascot/showroom_mascot_motion.dart';

/// 화면 크기에 맞춰 디코드할 한 변. 원본 320px을 그대로 올리지 않는다.
int showroomMascotCachePx(double size, double devicePixelRatio) {
  final int px = (size * devicePixelRatio).round();
  if (px < 1) return 1;
  if (px > 512) return 512;
  return px;
}

/// 앱바에 올리는 와플 스프라이트. 프레임 선택은 포즈가 하고, 크기는 칸에 맞춘다.
class ShowroomMascotFigure extends StatelessWidget {
  const ShowroomMascotFigure({
    super.key,
    required this.pose,
    required this.cycle,
    required this.size,
  });

  final ShowroomMascotPose pose;
  final double cycle;
  final double size;

  @override
  Widget build(BuildContext context) {
    final int px = showroomMascotCachePx(
      size,
      MediaQuery.devicePixelRatioOf(context),
    );
    return Image.asset(
      showroomMascotFrame(pose, cycle),
      width: size,
      height: size,
      fit: BoxFit.contain,
      cacheWidth: px,
      cacheHeight: px,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      excludeFromSemantics: true,
    );
  }
}
