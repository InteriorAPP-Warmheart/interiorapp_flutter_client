import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';

/// 화면을 채우기 위한 샘플. 인테리어는 보통 한두 건이라 목록도 짧게 둔다.
abstract final class SpaceCatalog {
  static const InteriorPrep prep = InteriorPrep(
    activePlaceName: '한남동 작은 사무실',
    activeSummary: '공간 조건을 정리하는 중',
    candidates: ['합정동 식당', '잠실 아파트'],
  );

  static const List<SpaceProject> ongoing = [
    SpaceProject(
      id: 'project-seongsu-cafe',
      placeName: '성수동 카페',
      statusLabel: '공사진행 · 주요시공',
      nextAction: '벽 마감 사진을 확인해 주세요',
      phase: SpacePhase.construction,
      imageUrl: 'https://picsum.photos/seed/seongsu-cafe/1200/900',
      completed: false,
    ),
    SpaceProject(
      id: 'project-mangwon-bakery',
      placeName: '망원동 빵집',
      statusLabel: '견적 · 계약',
      nextAction: '견적서를 확인해 주세요',
      phase: SpacePhase.estimate,
      imageUrl: 'https://picsum.photos/seed/mangwon-bakery/1200/900',
      completed: false,
    ),
  ];

  static SpaceProject? find(String id) {
    for (final SpaceProject project in [...ongoing, ...finished]) {
      if (project.id == id) return project;
    }
    return null;
  }

  static const List<SpaceProject> finished = [
    SpaceProject(
      id: 'project-yeonnam-room',
      placeName: '연남동 자취방',
      statusLabel: '완료 · 준공확인',
      nextAction: 'A/S 기간이 남아 있어요',
      phase: SpacePhase.afterCare,
      imageUrl: 'https://picsum.photos/seed/yeonnam-room/1200/900',
      completed: true,
    ),
    SpaceProject(
      id: 'project-jamwon-salon',
      placeName: '잠원동 미용실',
      statusLabel: '완료 · A/S 종료',
      nextAction: '기록을 다시 볼 수 있어요',
      phase: SpacePhase.afterCare,
      imageUrl: 'https://picsum.photos/seed/jamwon-salon/1200/900',
      completed: true,
    ),
    SpaceProject(
      id: 'project-haeundae-stay',
      placeName: '해운대 스테이',
      statusLabel: '완료 · 준공확인',
      nextAction: '기록을 다시 볼 수 있어요',
      phase: SpacePhase.handover,
      imageUrl: 'https://picsum.photos/seed/haeundae-stay/1200/900',
      completed: true,
    ),
  ];
}
