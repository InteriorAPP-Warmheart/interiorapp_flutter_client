import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

/// 내공간 맨 위의 상담 영역. 왼쪽은 상담 전, 오른쪽은 상담받기와 후보지다.
class ConsultLaunchBand extends StatelessWidget {
  const ConsultLaunchBand({
    super.key,
    required this.consultCount,
    required this.tradeCount,
    required this.onPrep,
    required this.onConsult,
    required this.onTrade,
  });

  final int consultCount;
  final int tradeCount;
  final VoidCallback onPrep;
  final VoidCallback onConsult;
  final VoidCallback onTrade;

  static double height(BuildContext context) {
    final AppWindow window = AppWindow.of(context);
    if (window.isExpanded) return 148;
    if (window.isMedium) return 132;
    return 116;
  }

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final String prepCaption =
        consultCount == 0 && tradeCount == 0
            ? '정리해 둔 내용이 없어요'
            : '상담준비 $consultCount · 후보지 $tradeCount';

    return SizedBox(
      height: height(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _LaunchArea(
              onTap: onPrep,
              color: AppColors.surface,
              foreground: AppColors.textPrimary,
              icon: Icons.edit_note_rounded,
              iconColor: AppColors.primary,
              label: '상담 전',
              caption: prepCaption,
              fontScale: fontScale,
              bordered: true,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _LaunchArea(
                    onTap: onConsult,
                    color: AppColors.primary,
                    foreground: AppColors.white,
                    icon: Icons.chat_bubble_outline,
                    iconColor: AppColors.white,
                    label: '상담받기',
                    fontScale: fontScale,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _LaunchArea(
                    onTap: onTrade,
                    color: AppColors.surface,
                    foreground: AppColors.textPrimary,
                    icon: Icons.add_location_alt_outlined,
                    iconColor: AppColors.primary,
                    label: '후보지 남기기',
                    fontScale: fontScale,
                    bordered: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LaunchArea extends StatelessWidget {
  const _LaunchArea({
    required this.onTap,
    required this.color,
    required this.foreground,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.fontScale,
    this.caption,
    this.bordered = false,
  });

  final VoidCallback onTap;
  final Color color;
  final Color foreground;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? caption;
  final double fontScale;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border:
                bordered
                    ? Border.all(color: AppColors.border, width: 0.7)
                    : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child:
                caption == null
                    ? Row(
                      children: [
                        Icon(icon, color: iconColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14 * fontScale,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                              letterSpacing: -0.2,
                              color: foreground,
                            ),
                          ),
                        ),
                      ],
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: iconColor, size: 22),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15 * fontScale,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: foreground,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          caption!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12 * fontScale,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}
