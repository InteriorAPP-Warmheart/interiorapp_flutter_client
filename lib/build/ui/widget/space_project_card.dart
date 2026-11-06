import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/construction_progress.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';

class SpaceProjectCard extends StatelessWidget {
  const SpaceProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    this.progress,
  });

  final SpaceProject project;
  final VoidCallback onTap;
  final ConstructionProgress? progress;

  bool get _hasSchedule {
    final ConstructionProgress? work = progress;
    if (work == null) return false;
    return work.todayTrade.isNotEmpty && work.nextTrade.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.7),
          ),
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
                            Color(0x000B1F38),
                            Color(0xCC0B1F38),
                          ],
                          stops: [0.5, 0.72, 1],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),
                          Text(
                            project.placeName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
              ColoredBox(
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
                  child:
                      _hasSchedule
                          ? _ScheduleStrip(
                            progress: progress!,
                            fontScale: fontScale,
                          )
                          : _NextAction(
                            action: project.nextAction,
                            fontScale: fontScale,
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextAction extends StatelessWidget {
  const _NextAction({required this.action, required this.fontScale});

  final String action;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '다음 할 일',
          style: TextStyle(
            fontSize: 12 * fontScale,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            action,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15 * fontScale,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ],
    );
  }
}

class _ScheduleStrip extends StatelessWidget {
  const _ScheduleStrip({required this.progress, required this.fontScale});

  final ConstructionProgress progress;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _ProcessCell(
              label: '오늘',
              trade: progress.todayTrade,
              emphasized: true,
              fontScale: fontScale,
            ),
          ),
          const SizedBox(width: 12),
          const ColoredBox(color: AppColors.border, child: SizedBox(width: 1)),
          const SizedBox(width: 12),
          Expanded(
            child: _ProcessCell(
              label: progress.nextLabel,
              trade: progress.nextTrade,
              emphasized: false,
              fontScale: fontScale,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessCell extends StatelessWidget {
  const _ProcessCell({
    required this.label,
    required this.trade,
    required this.emphasized,
    required this.fontScale,
  });

  final String label;
  final String trade;
  final bool emphasized;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12 * fontScale,
            fontWeight: FontWeight.w700,
            color: emphasized ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            trade,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15 * fontScale,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
