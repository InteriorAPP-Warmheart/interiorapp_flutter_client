import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

class AppTabBarTheme {
  static double iconSize(BuildContext context) =>
      18 * ResponsiveSize.fontScale(context);

  static TextStyle labelStyle(BuildContext context) => TextStyle(
    fontSize: 12 * ResponsiveSize.fontScale(context),
    fontWeight: FontWeight.w600,
  );

  static TextStyle unselectedLabelStyle(BuildContext context) => TextStyle(
    fontSize: 12 * ResponsiveSize.fontScale(context),
    fontWeight: FontWeight.w500,
  );

  static double height(BuildContext context) =>
      ResponsiveSize.bottomNavHeight(context);

  static BoxDecoration get decoration => const BoxDecoration(
    color: AppColors.surface,
    border: Border(top: BorderSide(color: AppColors.border, width: 0.7)),
  );

  static Color get selectedColor => AppColors.white;
  static Color get unselectedColor => AppColors.textSecondary;

  static Decoration get indicator => const _SelectedTabPill();
}

class _SelectedTabPill extends Decoration {
  const _SelectedTabPill();

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return const _SelectedTabPillPainter();
  }
}

class _SelectedTabPillPainter extends BoxPainter {
  const _SelectedTabPillPainter();

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Size size = configuration.size ?? Size.zero;
    final double pillWidth = (size.width - 22).clamp(52.0, 68.0);
    final double pillHeight = (size.height - 12).clamp(50.0, 56.0);
    final Rect rect = Rect.fromCenter(
      center: offset + Offset(size.width / 2, size.height / 2),
      width: pillWidth,
      height: pillHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(pillHeight / 2)),
      Paint()..color = AppColors.primary,
    );
  }
}
