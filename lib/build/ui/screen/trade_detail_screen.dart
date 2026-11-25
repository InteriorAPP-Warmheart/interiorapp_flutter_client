import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/presentation/provider/build_provider.dart';
import 'package:interiorapp_flutter_client/build/ui/space_routes.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/prep_detail_parts.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_button.dart';

/// 저장한 입지. 점수나 성공 예측은 보여 주지 않는다.
class TradeDetailScreen extends ConsumerWidget {
  const TradeDetailScreen({super.key, required this.candidate});

  final TradeCandidate? candidate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final TradeCandidate? passed = candidate;
    // 수정 후 돌아오면 넘겨받은 값이 아니라 저장된 최신 값을 보여 줘야 한다.
    final TradeCandidate? current =
        passed == null
            ? null
            : ref
                    .watch(spaceBoardProvider)
                    .trades
                    .where((TradeCandidate item) => item.id == passed.id)
                    .firstOrNull ??
                passed;
    if (current == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('저장한 입지')),
        body: Center(
          child: Text(
            '입지를 찾을 수 없어요',
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
      appBar: AppBar(title: const Text('저장한 입지')),
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

/// 사진, 핵심 두 값, 위치·주변·임대·메모 순서로 읽는다. 아래 버튼은 늘 보인다.
class TradeDetailView extends StatelessWidget {
  const TradeDetailView({super.key, required this.candidate, this.onEdit});

  final TradeCandidate candidate;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final double sectionGap = ResponsiveSize.sectionGap(context);
    final double subGap = ResponsiveSize.subGap(context);
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
    final bool hasMemo =
        candidate.reason.trim().isNotEmpty ||
        candidate.interiorNotes.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.only(bottom: sectionGap),
            children: [
              DetailHero(
                imageUrl: prepCoverAsset(
                  candidate.industry,
                  candidate.id,
                  photo: candidate.coverPhoto,
                ),
                eyebrow: '입지',
                title:
                    candidate.name.trim().isEmpty ? '이름 없는 입지' : candidate.name,
                address: address,
              ),
              SizedBox(height: subGap),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border, width: 0.7),
                ),
                child: DetailFacts(
                  facts: [('용도', candidate.industry), ('평수', area)],
                ),
              ),
              SizedBox(height: sectionGap),
              DetailSection(
                title: '위치와 접근',
                children: [
                  DetailRow(label: '길', value: candidate.access),
                  DetailRow(label: '이동', value: candidate.transit),
                  DetailRow(label: '주차', value: candidate.parking),
                  DetailRow(label: '주변 이정표', value: candidate.landmark),
                ],
              ),
              SizedBox(height: sectionGap),
              DetailSection(
                title: '주변과 사람',
                children: [
                  DetailRow(label: '같은 업종', value: candidate.sameIndustry),
                  DetailRow(label: '주변에 많은 업종', value: candidate.nearbyTrades),
                  DetailRow(label: '시간대', value: candidate.timeBand),
                  DetailRow(label: '주로 오는 사람', value: candidate.visitor),
                ],
              ),
              SizedBox(height: sectionGap),
              DetailSection(
                title: '임대 조건',
                children:
                    candidate.rentUnknown
                        ? const [DetailQuiet(text: '임대 조건은 아직 몰라요.')]
                        : [
                          DetailHighlight(label: '월세', value: candidate.rent),
                          DetailRow(label: '보증금', value: candidate.deposit),
                          DetailRow(label: '관리비', value: candidate.maintenance),
                          DetailRow(label: '권리금', value: candidate.premium),
                        ],
              ),
              if (hasMemo) ...[
                SizedBox(height: sectionGap),
                DetailSection(
                  title: '메모',
                  children: [
                    if (candidate.reason.trim().isNotEmpty)
                      DetailNote(label: '이곳을 보는 이유', body: candidate.reason),
                    if (candidate.interiorNotes.isNotEmpty)
                      DetailTags(
                        label: '인테리어에서 먼저 볼 점',
                        tags: candidate.interiorNotes,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: subGap),
        Row(
          children: [
            if (onEdit != null) ...[
              Expanded(
                flex: 2,
                child: AppButton(
                  label: '수정',
                  variant: AppButtonVariant.secondary,
                  onPressed: onEdit,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              flex: 5,
              child: AppButton(
                label: '이 입지로 상담 준비',
                onPressed:
                    () => context.push(
                      SpaceRoutes.prepCreate,
                      extra: candidate.toConsultSeed(),
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
