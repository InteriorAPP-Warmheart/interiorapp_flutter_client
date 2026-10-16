import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_theme.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

enum AppButtonVariant { primary, secondary }

/// 화면 공통 버튼. 채움 버튼과 테두리 버튼 두 가지만 둔다.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final bool primary = variant == AppButtonVariant.primary;
    final Color foreground = primary ? AppColors.white : AppColors.primary;
    final Color background = primary ? AppColors.primary : AppColors.surface;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side:
                primary
                    ? BorderSide.none
                    : const BorderSide(color: AppColors.primary),
          ),
          textStyle: TextStyle(
            fontSize: 16 * fontScale,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
