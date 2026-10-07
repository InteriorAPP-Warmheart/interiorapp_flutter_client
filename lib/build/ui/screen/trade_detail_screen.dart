import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/ui/space_routes.dart';
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
        backgroundColor: const Color(0xFFFCFCFC),
        appBar: AppBar(title: const Text('상권 후보지')),
        body: Center(
          child: Text(
            '후보지를 찾을 수 없어요',
            style: TextStyle(fontSize: 16 * fontScale, color: const Color(0xFF1A1A1A)),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      appBar: AppBar(title: const Text('상권 후보지')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            ResponsiveSize.responsivePadding(context).left,
            ResponsiveSize.subGap(context),
            ResponsiveSize.responsivePadding(context).right,
            ResponsiveSize.subGap(context),
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
    final String address = candidate.detailAddress.isEmpty
        ? candidate.address
        : '${candidate.address} ${candidate.detailAddress}';
    final String area = candidate.area.isEmpty
        ? '미입력'
        : candidate.area == PrepLabels.areaUnknown
            ? candidate.area
            : '${candidate.area}평';
    final String rent = candidate.rentUnknown
        ? '아직 몰라요'
        : [
            if (candidate.deposit.isNotEmpty) '보증금 ${candidate.deposit}',
            if (candidate.rent.isNotEmpty) '월세 ${candidate.rent}',
            if (candidate.maintenance.isNotEmpty) '관리비 ${candidate.maintenance}',
            if (candidate.premium.isNotEmpty) '권리금 ${candidate.premium}',
          ].join(' · ');

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Text(
                candidate.name,
                style: TextStyle(fontSize: 26 * fontScale, fontWeight: FontWeight.w700, height: 1.25),
              ),
              const SizedBox(height: 8),
              Text(
                '이 기록은 상권이 좋은지 나쁜지를 정하지 않아요. 나중에 분석할 때 쓸 조건만 남겨 둔 후보지예요.',
                style: TextStyle(fontSize: 14 * fontScale, height: 1.45, color: const Color(0xFF1A1A1A)),
              ),
              SizedBox(height: sectionGap),
              _Block(
                title: '자리',
                fontScale: fontScale,
                lines: [
                  address,
                  '${candidate.industry.isEmpty ? '업종 미입력' : candidate.industry} · $area',
                ],
              ),
              SizedBox(height: sectionGap),
              _Block(
                title: '입지에서 보인 것',
                fontScale: fontScale,
                lines: [
                  '길 ${candidate.access}',
                  '이동 ${candidate.transit}',
                  '주차 ${candidate.parking}',
                  if (candidate.landmark.isNotEmpty) candidate.landmark,
                ],
              ),
              SizedBox(height: sectionGap),
              _Block(
                title: '주변과 사람',
                fontScale: fontScale,
                lines: [
                  '같은 업종 ${candidate.sameIndustry}',
                  if (candidate.nearbyTrades.isNotEmpty) '주변에 많은 업종 ${candidate.nearbyTrades}',
                  '시간대 ${candidate.timeBand}',
                  '주로 ${candidate.visitor}',
                ],
              ),
              SizedBox(height: sectionGap),
              _Block(
                title: '아는 임대 조건',
                fontScale: fontScale,
                lines: [rent.isEmpty ? '적어 둔 금액이 없어요' : rent],
              ),
              if (candidate.reason.isNotEmpty) ...[
                SizedBox(height: sectionGap),
                _Block(title: '이 자리를 고른 이유', fontScale: fontScale, lines: [candidate.reason]),
              ],
              if (candidate.interiorNotes.isNotEmpty) ...[
                SizedBox(height: sectionGap),
                _Block(
                  title: '인테리어에서 볼 점',
                  fontScale: fontScale,
                  lines: [candidate.interiorNotes.join(', ')],
                ),
              ],
            ],
          ),
        ),
        if (onEdit != null) ...[
          AppButton(label: '수정', variant: AppButtonVariant.secondary, onPressed: onEdit),
          const SizedBox(height: 8),
        ],
        AppButton(
          label: '이 후보지로 상담준비',
          onPressed: () => context.push(SpaceRoutes.prepCreate, extra: candidate.toConsultSeed()),
        ),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.fontScale, required this.lines});

  final String title;
  final double fontScale;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E4E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 13 * fontScale, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (final String line in lines) ...[
            Text(line, style: TextStyle(fontSize: 15 * fontScale, height: 1.45, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}
