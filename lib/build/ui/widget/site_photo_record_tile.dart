import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/construction_progress.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/site_photo_record.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';

class SitePhotoStatusLabel extends StatelessWidget {
  const SitePhotoStatusLabel({
    super.key,
    required this.status,
    required this.fontScale,
    this.onPhoto = false,
  });

  final SitePhotoStatus status;
  final double fontScale;
  final bool onPhoto;

  @override
  Widget build(BuildContext context) {
    final bool done = status == SitePhotoStatus.done;
    final Color foreground =
        onPhoto
            ? (done ? AppColors.accent : AppColors.textPrimary)
            : (done ? AppColors.accent : AppColors.textSecondary);
    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            onPhoto
                ? AppColors.white
                : done
                ? const Color(0x14687A5E)
                : AppColors.surface,
        borderRadius: BorderRadius.circular(99),
        border: onPhoto || !done ? Border.all(color: AppColors.border) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          status.label,
          style: TextStyle(
            fontSize: 12 * fontScale,
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: foreground,
          ),
        ),
      ),
    );
  }
}

class SitePhotoPreviewCard extends StatelessWidget {
  const SitePhotoPreviewCard({
    super.key,
    required this.record,
    required this.fontScale,
    required this.onTap,
    this.showDate = false,
  });

  final SitePhotoRecord record;
  final double fontScale;
  final VoidCallback onTap;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 148,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 124),
                  child: AppNetworkImage(url: record.cover.imageUrl),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.placeLabel,
                        style: TextStyle(
                          fontSize: 16 * fontScale,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (record.detailLabel.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          record.detailLabel,
                          style: TextStyle(
                            fontSize: 14 * fontScale,
                            height: 1.3,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (showDate && record.takenOn.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          record.takenOn,
                          style: TextStyle(
                            fontSize: 13 * fontScale,
                            height: 1.3,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (record.note.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          record.note,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13 * fontScale,
                            height: 1.35,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      if (record.status == SitePhotoStatus.done)
                        SitePhotoStatusLabel(
                          status: SitePhotoStatus.done,
                          fontScale: fontScale,
                        )
                      else
                        SitePhotoStatusLabel(
                          status: SitePhotoStatus.underway,
                          fontScale: fontScale,
                        ),
                    ],
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
