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
    final EdgeInsets padding = ResponsiveSize.textInset(context);
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
                  fontSize: 28 * fontScale,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  letterSpacing: -0.4,
                  color: AppColors.textPrimary,
                ),
              ),
              if (address.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14 * fontScale,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                height: 84,
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: _ToneFact(
                        icon: Icons.storefront_outlined,
                        label: '업종',
                        value: candidate.industry,
                        fontScale: fontScale,
                        dark: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: _ToneFact(
                        icon: Icons.square_foot_outlined,
                        label: '평수',
                        value: area,
                        fontScale: fontScale,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: sectionGap),
              _Section(
                title: '입지에서 보인 것',
                fontScale: fontScale,
                child: Column(
                  children: [
                    SizedBox(
                      height: 148,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: _ToneFact(
                              icon: Icons.signpost_outlined,
                              label: '길',
                              value: candidate.access,
                              fontScale: fontScale,
                              stacked: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 4,
                            child: Column(
                              children: [
                                Expanded(
                                  child: _ToneFact(
                                    icon: Icons.directions_transit_outlined,
                                    label: '이동',
                                    value: candidate.transit,
                                    fontScale: fontScale,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: _ToneFact(
                                    icon: Icons.local_parking_outlined,
                                    label: '주차',
                                    value: candidate.parking,
                                    fontScale: fontScale,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ChipFact(
                      icon: Icons.apartment_outlined,
                      label: '주변 이정표',
                      value: candidate.landmark,
                      fontScale: fontScale,
                    ),
                  ],
                ),
              ),
              SizedBox(height: sectionGap),
              _Section(
                title: '주변과 사람',
                fontScale: fontScale,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ChipFact(
                      icon: Icons.storefront_outlined,
                      label: '같은 업종',
                      value: candidate.sameIndustry,
                      fontScale: fontScale,
                    ),
                    _ChipFact(
                      icon: Icons.store_outlined,
                      label: '주변에 많은 업종',
                      value: candidate.nearbyTrades,
                      fontScale: fontScale,
                    ),
                    _ChipFact(
                      icon: Icons.schedule_outlined,
                      label: '시간대',
                      value: candidate.timeBand,
                      fontScale: fontScale,
                    ),
                    _ChipFact(
                      icon: Icons.people_outline,
                      label: '주로 오는 사람',
                      value: candidate.visitor,
                      fontScale: fontScale,
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
                        ? const _QuietNote(
                          icon: Icons.payments_outlined,
                          text: '아직 몰라요',
                        )
                        : Column(
                          children: [
                            _MoneyLine(
                              label: '월세',
                              value: candidate.rent,
                              fontScale: fontScale,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _ChipFact(
                                  icon: Icons.account_balance_wallet_outlined,
                                  label: '보증금',
                                  value: candidate.deposit,
                                  fontScale: fontScale,
                                ),
                                _ChipFact(
                                  icon: Icons.receipt_long_outlined,
                                  label: '관리비',
                                  value: candidate.maintenance,
                                  fontScale: fontScale,
                                ),
                                _ChipFact(
                                  icon: Icons.key_outlined,
                                  label: '권리금',
                                  value: candidate.premium,
                                  fontScale: fontScale,
                                ),
                              ],
                            ),
                          ],
                        ),
              ),
              if (candidate.reason.trim().isNotEmpty) ...[
                SizedBox(height: sectionGap),
                _NoteBlock(
                  icon: Icons.chat_bubble_outline,
                  title: '이 자리를 고른 이유',
                  body: candidate.reason,
                  fontScale: fontScale,
                ),
              ],
              if (candidate.interiorNotes.isNotEmpty) ...[
                SizedBox(height: sectionGap),
                _NoteBlock(
                  icon: Icons.chair_outlined,
                  title: '인테리어에서 볼 점',
                  body: candidate.interiorNotes.join(' · '),
                  fontScale: fontScale,
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

class _ToneFact extends StatelessWidget {
  const _ToneFact({
    required this.icon,
    required this.label,
    required this.value,
    required this.fontScale,
    this.dark = false,
    this.stacked = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final double fontScale;
  final bool dark;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final bool empty = value.trim().isEmpty;
    final String shown = empty ? '아직 없어요' : value;
    final Color foreground = dark ? AppColors.white : AppColors.textPrimary;
    final Color muted =
        dark ? const Color(0xB3FFFFFF) : AppColors.textSecondary;
    final Widget body = Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child:
          stacked
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: dark ? AppColors.white : AppColors.accent,
                  ),
                  const Spacer(),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11 * fontScale,
                      height: 1.15,
                      fontWeight: FontWeight.w600,
                      color: muted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      shown,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 22 * fontScale,
                        height: 1.15,
                        fontWeight: FontWeight.w700,
                        color: empty ? muted : foreground,
                      ),
                    ),
                  ),
                ],
              )
              : Row(
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: dark ? AppColors.white : AppColors.accent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11 * fontScale,
                            height: 1.15,
                            fontWeight: FontWeight.w600,
                            color: muted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            shown,
                            softWrap: false,
                            style: TextStyle(
                              fontSize: (dark ? 18 : 15) * fontScale,
                              height: 1.15,
                              fontWeight: FontWeight.w700,
                              color: empty ? muted : foreground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AppColors.primary : AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: body,
    );
  }
}

class _MoneyLine extends StatelessWidget {
  const _MoneyLine({
    required this.label,
    required this.value,
    required this.fontScale,
  });

  final String label;
  final String value;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final bool empty = value.trim().isEmpty;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                size: 20,
                color: AppColors.white,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12 * fontScale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xB3FFFFFF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    empty ? '아직 없어요' : value,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 22 * fontScale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
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

class _ChipFact extends StatelessWidget {
  const _ChipFact({
    required this.icon,
    required this.label,
    required this.value,
    required this.fontScale,
  });

  final IconData icon;
  final String label;
  final String value;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final bool empty = value.trim().isEmpty;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AppColors.accent),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '$label  ${empty ? '아직 없어요' : value}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12 * fontScale,
                    fontWeight: FontWeight.w600,
                    color:
                        empty ? AppColors.textSecondary : AppColors.textPrimary,
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

class _QuietNote extends StatelessWidget {
  const _QuietNote({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15 * fontScale,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _NoteBlock extends StatelessWidget {
  const _NoteBlock({
    required this.icon,
    required this.title,
    required this.body,
    required this.fontScale,
  });

  final IconData icon;
  final String title;
  final String body;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.7),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: AppColors.accent),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12 * fontScale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: TextStyle(
                      fontSize: 16 * fontScale,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
