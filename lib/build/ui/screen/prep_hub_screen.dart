import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/presentation/provider/build_provider.dart';
import 'package:interiorapp_flutter_client/build/presentation/vm/space_board_vm.dart';
import 'package:interiorapp_flutter_client/build/ui/space_routes.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

/// 상담준비 내역과 상권 후보지를 나눠 보여 준다.
class PrepHubScreen extends ConsumerWidget {
  const PrepHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final EdgeInsets padding = ResponsiveSize.responsivePadding(context);
    final double subGap = ResponsiveSize.subGap(context);
    final double sectionGap = ResponsiveSize.sectionGap(context);
    final double fontScale = ResponsiveSize.fontScale(context);
    final SpaceBoard board = ref.watch(spaceBoardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('상담 전')),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            padding.left,
            subGap,
            padding.right,
            sectionGap,
          ),
          children: [
            Text(
              '상담으로 넘길 내용과, 자리를 비교하는 후보지를 나눠 둡니다.',
              style: TextStyle(
                fontSize: 14 * fontScale,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: sectionGap),
            _HubSection(
              title: '상담준비',
              caption: '자리를 정한 뒤에 상담으로 넘길 내용',
              countLabel: '${board.consults.length}',
              children: [
                if (board.consults.isEmpty)
                  const _EmptyNote(label: '아직 상담준비가 없어요')
                else
                  for (var i = 0; i < board.consults.length; i++) ...[
                    if (i > 0) SizedBox(height: subGap),
                    _ConsultCard(
                      record: board.consults[i],
                      onTap:
                          () => context.push(
                            SpaceRoutes.prepRecord,
                            extra: board.consults[i],
                          ),
                    ),
                  ],
              ],
            ),
            SizedBox(height: sectionGap),
            _HubSection(
              title: '상권 후보지',
              caption: '업종을 어디에 둘지 비교하는 자리',
              countLabel: '${board.trades.length}/${SpaceBoard.maxTrades}',
              children: [
                if (board.trades.isEmpty)
                  const _EmptyNote(label: '아직 후보지가 없어요')
                else
                  for (var i = 0; i < board.trades.length; i++) ...[
                    if (i > 0) SizedBox(height: subGap),
                    _TradeCard(
                      candidate: board.trades[i],
                      onTap:
                          () => context.push(
                            SpaceRoutes.trade,
                            extra: board.trades[i],
                          ),
                    ),
                  ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HubSection extends StatelessWidget {
  const _HubSection({
    required this.title,
    required this.caption,
    required this.countLabel,
    required this.children,
  });

  final String title;
  final String caption;
  final String countLabel;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final double subGap = ResponsiveSize.subGap(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 17 * fontScale,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              countLabel,
              style: TextStyle(
                fontSize: 13 * fontScale,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          caption,
          style: TextStyle(
            fontSize: 13 * fontScale,
            height: 1.4,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: subGap),
        ...children,
      ],
    );
  }
}

class _ConsultCard extends StatelessWidget {
  const _ConsultCard({required this.record, required this.onTap});

  final PrepRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String address =
        record.detailAddress.isEmpty
            ? record.address
            : '${record.address} ${record.detailAddress}';
    final String meta = [
      if (record.industry.trim().isNotEmpty) record.industry.trim(),
      if (record.workScope.trim().isNotEmpty) record.workScope.trim(),
    ].join(' · ');

    return _HubCard(
      icon: Icons.edit_note_rounded,
      rail: AppColors.primary,
      iconColor: AppColors.white,
      title: record.placeName.trim().isEmpty ? '이름 없는 상담준비' : record.placeName,
      subtitle: address,
      chips: meta.isEmpty ? const ['업종을 아직 적지 않았어요'] : meta.split(' · '),
      onTap: onTap,
    );
  }
}

class _TradeCard extends StatelessWidget {
  const _TradeCard({required this.candidate, required this.onTap});

  final TradeCandidate candidate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String address =
        candidate.detailAddress.isEmpty
            ? candidate.address
            : '${candidate.address} ${candidate.detailAddress}';
    final String meta = [
      if (candidate.industry.trim().isNotEmpty) candidate.industry.trim(),
      if (candidate.timeBand.trim().isNotEmpty) candidate.timeBand.trim(),
    ].join(' · ');

    return _HubCard(
      icon: Icons.add_location_alt_outlined,
      rail: const Color(0xFFE7EBE4),
      iconColor: AppColors.accent,
      title: candidate.name.trim().isEmpty ? '이름 없는 후보지' : candidate.name,
      subtitle: address,
      chips: meta.isEmpty ? const ['업종을 아직 적지 않았어요'] : meta.split(' · '),
      onTap: onTap,
    );
  }
}

class _HubRail extends StatelessWidget {
  const _HubRail({
    required this.icon,
    required this.rail,
    required this.iconColor,
  });

  final IconData icon;
  final Color rail;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
      child: ColoredBox(
        color: rail,
        child: SizedBox(
          width: 46,
          child: Icon(icon, color: iconColor, size: 22),
        ),
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  const _HubCard({
    required this.icon,
    required this.rail,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.chips,
    required this.onTap,
  });

  final IconData icon;
  final Color rail;
  final Color iconColor;
  final String title;
  final String subtitle;
  final List<String> chips;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.7),
          ),
          child: Row(
            children: [
              _HubRail(icon: icon, rail: rail, iconColor: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16 * fontScale,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (subtitle.trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12 * fontScale,
                            height: 1.2,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        chips.join('  ·  '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12 * fontScale,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyNote extends StatelessWidget {
  const _EmptyNote({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.7),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14 * fontScale,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
