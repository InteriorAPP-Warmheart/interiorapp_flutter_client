import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/ui/space_catalog.dart';
import 'package:interiorapp_flutter_client/build/ui/space_routes.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

/// 상담준비 내역과 상권 후보지를 나눠 보여 준다.
class PrepHubScreen extends StatelessWidget {
  const PrepHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = ResponsiveSize.responsivePadding(context);
    final double subGap = ResponsiveSize.subGap(context);
    final double sectionGap = ResponsiveSize.sectionGap(context);
    final double fontScale = ResponsiveSize.fontScale(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      appBar: AppBar(title: const Text('상담 전')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: SpaceBoard.instance,
          builder: (BuildContext context, Widget? child) {
            final SpaceBoard board = SpaceBoard.instance;
            return ListView(
              padding: EdgeInsets.fromLTRB(padding.left, subGap, padding.right, sectionGap),
              children: [
                Text(
                  '상담 전에\n정리해 둔 것들',
                  style: TextStyle(fontSize: 28 * fontScale, fontWeight: FontWeight.w700, height: 1.25),
                ),
                const SizedBox(height: 8),
                Text(
                  '상담으로 넘길 내용과, 자리를 비교하는 후보지를 따로 둡니다.',
                  style: TextStyle(fontSize: 14 * fontScale, height: 1.45, color: const Color(0xFF1A1A1A)),
                ),
                SizedBox(height: sectionGap),
                _HubSection(
                  mark: '01',
                  title: '상담준비',
                  caption: '자리를 정한 뒤에 상담으로 넘길 내용',
                  countLabel: '${board.consults.length}',
                  children: [
                    if (board.consults.isEmpty)
                      const _EmptyNote(label: '아직 상담준비가 없어요')
                    else
                      for (var i = 0; i < board.consults.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        _ConsultCard(
                          record: board.consults[i],
                          onTap: () => context.push(SpaceRoutes.prepRecord, extra: board.consults[i]),
                        ),
                      ],
                  ],
                ),
                SizedBox(height: sectionGap),
                _HubSection(
                  mark: '02',
                  title: '상권 후보지',
                  caption: '업종을 어디에 둘지 비교하는 자리. 점수는 없어요.',
                  countLabel: '${board.trades.length}/${SpaceBoard.maxTrades}',
                  children: [
                    if (board.trades.isEmpty)
                      const _EmptyNote(label: '아직 후보지 없어요')
                    else
                      for (var i = 0; i < board.trades.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        _TradeCard(
                          candidate: board.trades[i],
                          onTap: () => context.push(SpaceRoutes.trade, extra: board.trades[i]),
                        ),
                      ],
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HubSection extends StatelessWidget {
  const _HubSection({
    required this.mark,
    required this.title,
    required this.caption,
    required this.countLabel,
    required this.children,
  });

  final String mark;
  final String title;
  final String caption;
  final String countLabel;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              mark,
              style: TextStyle(fontSize: 13 * fontScale, fontWeight: FontWeight.w700, color: const Color(0xFF8C7358)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 20 * fontScale, fontWeight: FontWeight.w700, height: 1.2),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                countLabel,
                style: TextStyle(fontSize: 12 * fontScale, fontWeight: FontWeight.w700, color: const Color(0xFFFFFFFF)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          caption,
          style: TextStyle(fontSize: 13 * fontScale, height: 1.4, color: const Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 12),
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
    final double fontScale = ResponsiveSize.fontScale(context);
    final String address = record.detailAddress.isEmpty
        ? record.address
        : '${record.address} ${record.detailAddress}';
    return _SurfaceCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            record.placeName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 18 * fontScale, fontWeight: FontWeight.w700, height: 1.25),
          ),
          if (address.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13 * fontScale, height: 1.35, color: const Color(0xFF1A1A1A)),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _MetaChip(label: record.industry.isEmpty ? '업종 미입력' : record.industry),
              if (record.workScope.isNotEmpty) _MetaChip(label: record.workScope),
            ],
          ),
        ],
      ),
    );
  }
}

class _TradeCard extends StatelessWidget {
  const _TradeCard({required this.candidate, required this.onTap});

  final TradeCandidate candidate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final String address = candidate.detailAddress.isEmpty
        ? candidate.address
        : '${candidate.address} ${candidate.detailAddress}';
    return _SurfaceCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            candidate.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 18 * fontScale, fontWeight: FontWeight.w700, height: 1.25),
          ),
          const SizedBox(height: 4),
          Text(
            address,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13 * fontScale, height: 1.35, color: const Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _MetaChip(label: candidate.industry.isEmpty ? '업종 미입력' : candidate.industry),
              if (candidate.timeBand.isNotEmpty) _MetaChip(label: candidate.timeBand),
              if (candidate.sameIndustry.isNotEmpty) _MetaChip(label: '같은 업종 ${candidate.sameIndustry}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFFFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE4E4E4)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: child),
              const Icon(Icons.arrow_forward_rounded, color: Color(0xFF1A1A1A)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3EE),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12 * fontScale, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A)),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4E4E4)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 14 * fontScale, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A)),
      ),
    );
  }
}
