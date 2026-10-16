import 'package:flutter/material.dart';

/// 밝은 배경용 네이비 워드마크와 어두운 배경용 화이트 워드마크.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.onDark = false, this.height = 22});

  final bool onDark;
  final double height;

  static const String onLightAsset = 'assets/logo/wapll_logo_defalut.png';
  static const String onDarkAsset = 'assets/logo/wapll_logo_darkbackground.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      onDark ? onDarkAsset : onLightAsset,
      height: height,
      fit: BoxFit.contain,
      semanticLabel: 'WAPLL',
    );
  }
}
