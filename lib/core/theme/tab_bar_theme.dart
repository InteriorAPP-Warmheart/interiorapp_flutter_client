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

  static const double floatGap = 8;

  /// 화면을 가리는 3버튼 내비게이션만 피한다.
  /// 제스처 홈 표시처럼 얇은 여백은 탭바를 올리지 않는다.
  static double systemLift(BuildContext context) {
    final double obscured = MediaQuery.viewPaddingOf(context).bottom;
    return obscured >= 48 ? obscured : 0;
  }

  /// 화면 맨 아래에서 독 아래쪽까지의 거리.
  static double bottomInset(BuildContext context) =>
      systemLift(context) + floatGap;

  /// 화면 가장자리에 붙지 않는 둥근 독.
  static BoxDecoration dock(double height) => BoxDecoration(
    color: AppColors.surface.withValues(alpha: 0.96),
    borderRadius: BorderRadius.circular(height / 2),
    boxShadow: const [
      BoxShadow(color: Color(0x1F000000), blurRadius: 16, offset: Offset(0, 6)),
    ],
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
    // 칸이 좁으면 글자 너비에 맞춰 알약을 넓힌다. 넓은 칸은 작은 알약을 유지한다.
    final bool narrow = size.width < 92;
    final double pillWidth =
        narrow
            ? (size.width - 8).clamp(48.0, size.width)
            : (size.width - 22).clamp(52.0, 68.0);
    final double pillHeight = (size.height - 10).clamp(44.0, size.height - 6);
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
