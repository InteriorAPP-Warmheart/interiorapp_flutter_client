import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/ui/space_routes.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_button.dart';

/// 남겨 둔 상권 후보지. 점수나 성공 예측은 보여 주지 않는다.
class TradeDetailScreen extends StatelessWidget {
  const TradeDetailScreen({super.key, required this.candidate});

  final TradeCandidate? candidate;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final TradeCandidate? current = candidate;
    if (current == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('상권 후보지')),
        body: Center(
          child: Text(
            '후보지를 찾을 수 없어요',
            style: TextStyle(
              fontSize: 16 * fontScale,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      );
    }
    final EdgeInsets padding = ResponsiveSize.responsivePadding(context);
    final double subGap = ResponsiveSize.subGap(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('상권 후보지')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            padding.left,
            subGap,
            padding.right,
            subGap,
          ),
          child: TradeDetailView(
            candidate: current,
            onEdit: () => context.push(SpaceRoutes.tradeCreate, extra: current),
          ),
        ),
      ),
    );
  }
}

class TradeDetailView extends StatelessWidget {
  const TradeDetailView({super.key, required this.candidate, this.onEdit});

  final TradeCandidate candidate;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final double sectionGap = ResponsiveSize.sectionGap(context);
    final String address =
        candidate.detailAddress.isEmpty
            ? candidate.address
            : '${candidate.address} ${candidate.detailAddress}';
    final String area =
        candidate.area.isEmpty
            ? ''
            : candidate.area == PrepLabels.areaUnknown
            ? candidate.area
            : '${candidate.area}평';

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Text(
                candidate.name,
                style: TextStyle(
                  fontSize: 22 * fontScale,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  letterSpacing: -0.3,
                  color: AppColors.textPrimary,
                ),
              ),
              if (address.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  address,
                  style: TextStyle(
                    fontSize: 14 * fontScale,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              SizedBox(height: sectionGap),
              _Section(
                title: '자리',
                fontScale: fontScale,
                child: _FactGrid(
                  fontScale: fontScale,
                  items: [
                    _Fact(
                      icon: Icons.category_outlined,
                      label: '업종',
                      value: candidate.industry,
                    ),
                    _Fact(
                      icon: Icons.square_foot_outlined,
                      label: '평수',
                      value: area,
                    ),
                  ],
                ),
              ),
              SizedBox(height: sectionGap),
              _Section(
                title: '입지에서 보인 것',
                fontScale: fontScale,
                child: _FactGrid(
                  fontScale: fontScale,
                  items: [
                    _Fact(
                      icon: Icons.signpost_outlined,
                      label: '길',
                      value: candidate.access,
                    ),
                    _Fact(
                      icon: Icons.directions_transit_outlined,
                      label: '이동',
                      value: candidate.transit,
                    ),
                    _Fact(
                      icon: Icons.local_parking_outlined,
                      label: '주차',
                      value: candidate.parking,
                    ),
                    _Fact(
                      icon: Icons.apartment_outlined,
                      label: '주변 이정표',
                      value: candidate.landmark,
                    ),
                  ],
                ),
              ),
              SizedBox(height: sectionGap),
              _Section(
                title: '주변과 사람',
                fontScale: fontScale,
                child: _FactGrid(
                  fontScale: fontScale,
                  items: [
                    _Fact(
                      icon: Icons.storefront_outlined,
                      label: '같은 업종',
                      value: candidate.sameIndustry,
                    ),
                    _Fact(
                      icon: Icons.store_outlined,
                      label: '주변에 많은 업종',
                      value: candidate.nearbyTrades,
                    ),
                    _Fact(
                      icon: Icons.schedule_outlined,
                      label: '시간대',
                      value: candidate.timeBand,
                    ),
                    _Fact(
                      icon: Icons.people_outline,
                      label: '주로 오는 사람',
                      value: candidate.visitor,
                    ),
                  ],
                ),
              ),
              SizedBox(height: sectionGap),
              _Section(
                title: '아는 임대 조건',
                fontScale: fontScale,
                child:
                    candidate.rentUnknown
                        ? const _FactRow(
                          icon: Icons.payments_outlined,
                          label: '임대 조건',
                          value: '아직 몰라요',
                        )
                        : _FactGrid(
                          fontScale: fontScale,
                          items: [
                            _Fact(
                              icon: Icons.account_balance_wallet_outlined,
                              label: '보증금',
                              value: candidate.deposit,
                            ),
                            _Fact(
                              icon: Icons.payments_outlined,
                              label: '월세',
                              value: candidate.rent,
                            ),
                            _Fact(
                              icon: Icons.receipt_long_outlined,
                              label: '관리비',
                              value: candidate.maintenance,
                            ),
                            _Fact(
                              icon: Icons.key_outlined,
                              label: '권리금',
                              value: candidate.premium,
                            ),
                          ],
                        ),
              ),
              if (candidate.reason.trim().isNotEmpty) ...[
                SizedBox(height: sectionGap),
                _Section(
                  title: '이 자리를 고른 이유',
                  fontScale: fontScale,
                  child: _FactRow(
                    icon: Icons.chat_bubble_outline,
                    label: '이유',
                    value: candidate.reason,
                  ),
                ),
              ],
              if (candidate.interiorNotes.isNotEmpty) ...[
                SizedBox(height: sectionGap),
                _Section(
                  title: '인테리어에서 볼 점',
                  fontScale: fontScale,
                  child: _FactRow(
                    icon: Icons.chair_outlined,
                    label: '메모',
                    value: candidate.interiorNotes.join(' · '),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onEdit != null) ...[
          AppButton(
            label: '수정',
            variant: AppButtonVariant.secondary,
            onPressed: onEdit,
          ),
          const SizedBox(height: 8),
        ],
        AppButton(
          label: '이 후보지로 상담준비',
          onPressed:
              () => context.push(
                SpaceRoutes.prepCreate,
                extra: candidate.toConsultSeed(),
              ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.fontScale,
    required this.child,
  });

  final String title;
  final double fontScale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.7),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 17 * fontScale,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _Fact {
  const _Fact({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;
}

class _FactGrid extends StatelessWidget {
  const _FactGrid({required this.items, required this.fontScale});

  final List<_Fact> items;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _FactCell(fact: items[i], fontScale: fontScale),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child:
                      i + 1 < items.length
                          ? _FactCell(fact: items[i + 1], fontScale: fontScale)
                          : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _FactCell extends StatelessWidget {
  const _FactCell({required this.fact, required this.fontScale});

  final _Fact fact;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final bool empty = fact.value.trim().isEmpty;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(fact.icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    fact.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12 * fontScale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              empty ? '아직 없어요' : fact.value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14 * fontScale,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: empty ? AppColors.textSecondary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final bool empty = value.trim().isEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12 * fontScale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                empty ? '아직 없어요' : value,
                style: TextStyle(
                  fontSize: 15 * fontScale,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color:
                      empty ? AppColors.textSecondary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
