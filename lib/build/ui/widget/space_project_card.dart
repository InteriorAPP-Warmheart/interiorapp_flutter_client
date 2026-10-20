import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';

class SpaceProjectCard extends StatelessWidget {
  const SpaceProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  final SpaceProject project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.7),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppNetworkImage(url: project.imageUrl),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x000B1F38),
                              Color(0x660B1F38),
                              Color(0xE60B1F38),
                            ],
                            stops: [0.35, 0.62, 1],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Spacer(),
                            Text(
                              project.placeName,
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 26 * fontScale,
                                fontWeight: FontWeight.w700,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              project.statusLabel,
                              style: TextStyle(
                                color: const Color(0xF2FFFFFF),
                                fontSize: 14 * fontScale,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '다음 할 일',
                              style: TextStyle(
                                fontSize: 12 * fontScale,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              project.nextAction,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15 * fontScale,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                      ),
                    ],
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
