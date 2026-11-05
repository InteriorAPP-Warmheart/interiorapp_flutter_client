import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/construction_progress.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';

void showSiteSupervisorDialog(BuildContext context, SiteSupervisor person) {
  showDialog<void>(
    context: context,
    builder:
        (BuildContext context) => _PersonDialog(
          name: person.name,
          imageUrl: person.imageUrl,
          bio: person.bio,
          facts: <_PersonFact>[
            _PersonFact('소속', person.organization),
            _PersonFact('직책', person.role),
          ],
        ),
  );
}

void showSiteWorkerDialog(BuildContext context, SiteWorker person) {
  showDialog<void>(
    context: context,
    builder:
        (BuildContext context) => _PersonDialog(
          name: person.name,
          imageUrl: person.imageUrl,
          bio: person.bio,
          facts: <_PersonFact>[
            _PersonFact('소속', person.organization),
            _PersonFact('주특기', person.role),
            _PersonFact('경력', person.career),
          ],
        ),
  );
}

class SitePersonAvatar extends StatelessWidget {
  const SitePersonAvatar({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.size,
    required this.fontScale,
  });

  final String name;
  final String imageUrl;
  final double size;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final String initial = name.isEmpty ? '' : name.substring(0, 1);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0x140B1F38),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child:
          imageUrl.isEmpty
              ? initial.isEmpty
                  ? Icon(
                    Icons.person_outline,
                    size: size * 0.42,
                    color: AppColors.primary,
                  )
                  : Text(
                    initial,
                    style: TextStyle(
                      fontSize: size * 0.36 * fontScale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  )
              : AppNetworkImage(
                url: imageUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
    );
  }
}

class _PersonFact {
  const _PersonFact(this.label, this.value);

  final String label;
  final String value;
}

class _PersonDialog extends StatelessWidget {
  const _PersonDialog({
    required this.name,
    required this.imageUrl,
    required this.bio,
    required this.facts,
  });

  final String name;
  final String imageUrl;
  final String bio;
  final List<_PersonFact> facts;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final List<_PersonFact> shown = <_PersonFact>[
      for (final _PersonFact fact in facts)
        if (fact.value.trim().isNotEmpty) fact,
    ];
    return Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                _DialogPortrait(name: name, imageUrl: imageUrl),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Tooltip(
                    message: '닫기',
                    child: Material(
                      color: AppColors.surface,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: const SizedBox(
                          width: 32,
                          height: 32,
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 20 * fontScale,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      height: 1.25,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (bio.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      bio.trim(),
                      style: TextStyle(
                        fontSize: 14 * fontScale,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (shown.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.border,
                    ),
                    const SizedBox(height: 12),
                    for (int i = 0; i < shown.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      _FactLine(fact: shown[i], fontScale: fontScale),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogPortrait extends StatelessWidget {
  const _DialogPortrait({required this.name, required this.imageUrl});

  final String name;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final String initial = name.isEmpty ? '' : name.substring(0, 1);
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: ColoredBox(
        color: const Color(0x140B1F38),
        child:
            imageUrl.isEmpty
                ? Center(
                  child:
                      initial.isEmpty
                          ? const Icon(
                            Icons.person_outline,
                            size: 42,
                            color: AppColors.primary,
                          )
                          : Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                )
                : LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return AppNetworkImage(
                      url: imageUrl,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      fit: BoxFit.cover,
                    );
                  },
                ),
      ),
    );
  }
}

class _FactLine extends StatelessWidget {
  const _FactLine({required this.fact, required this.fontScale});

  final _PersonFact fact;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 52,
          child: Text(
            fact.label,
            style: TextStyle(
              fontSize: 13 * fontScale,
              fontWeight: FontWeight.w600,
              height: 1.35,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            fact.value.trim(),
            style: TextStyle(
              fontSize: 15 * fontScale,
              fontWeight: FontWeight.w700,
              height: 1.35,
              letterSpacing: -0.2,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
