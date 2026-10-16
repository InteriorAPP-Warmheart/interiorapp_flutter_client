import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

abstract final class AppTypography {
  static TextStyle display(BuildContext context) => _scaled(
    context,
    fontSize: 30,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.8,
  );

  static TextStyle headline(BuildContext context) => _scaled(
    context,
    fontSize: 23,
    height: 1.35,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );

  static TextStyle title(BuildContext context) => _scaled(
    context,
    fontSize: 17,
    height: 1.4,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  static TextStyle body(BuildContext context) =>
      _scaled(context, fontSize: 14, height: 1.55, fontWeight: FontWeight.w400);

  static TextStyle caption(BuildContext context) => _scaled(
    context,
    fontSize: 12,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle _scaled(
    BuildContext context, {
    required double fontSize,
    required double height,
    required FontWeight fontWeight,
    double letterSpacing = 0,
    Color color = AppColors.textPrimary,
  }) {
    return TextStyle(
      fontSize: fontSize * ResponsiveSize.fontScale(context),
      height: height,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: color,
    );
  }
}
