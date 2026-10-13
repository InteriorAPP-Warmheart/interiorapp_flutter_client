import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/prep_consult_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/space_catalog.dart';
import 'package:interiorapp_flutter_client/core/theme/app_theme.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

class SpaceDetailScreen extends StatelessWidget {
  const SpaceDetailScreen({super.key, required this.projectId});

  final String projectId;

  static const List<String> _sections = [
    '상담 · 현장검토',
    '견적 · 계약 · 추가계약',
    '설계 · 착공준비',
    '공사 진행 · 사진 · 작업기록',
    '작업자',
    '비용 · 결제 · 정산',
    '준공확인',
    'A/S',
    '전체 기록 · 증빙',
  ];

  @override
  Widget build(BuildContext context) {
    final SpaceProject? project = SpaceCatalog.find(projectId);
    if (project == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('현장을 찾지 못했어요')),
      );
    }

    final double fontScale = ResponsiveSize.fontScale(context);
    final PrepRecord? received = project.phase == SpacePhase.consult
        ? SpaceBoard.instance.recordFor(project.id)
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      appBar: AppBar(title: Text(project.placeName)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          if (received == null) ...[
          Text(
            project.statusLabel,
            style: TextStyle(
              fontSize: 15 * fontScale,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6E6E6E),
            ),
          ),
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFECECEC)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '다음 할 일',
                    style: TextStyle(
                      fontSize: 12 * fontScale,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8A8A8A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    project.nextAction,
                    style: TextStyle(
                      fontSize: 18 * fontScale,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ],
          const SizedBox(height: 20),
          Text(
            '진행',
            style: TextStyle(
              fontSize: 16 * fontScale,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < SpacePhase.timeline.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: i < project.filledSteps
                              ? const Color(0xFF1A1A1A)
                              : const Color(0xFFE6E6E6),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        SpacePhase.timeline[i].label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11 * fontScale,
                          fontWeight: i == project.phase.index
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: i == project.phase.index
                              ? const Color(0xFF1A1A1A)
                              : const Color(0xFF9A9A9A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          if (received != null)
            ConsultReceivedBody(record: received)
          else
            for (final String section in _sections)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFFECECEC)),
                  ),
                  title: Text(
                    section,
                    style: TextStyle(
                      fontSize: 15 * fontScale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Color(0xFFB0B0B0)),
                  onTap: () {},
                ),
              ),
            ),
        ],
      ),
    );
  }
}
