import 'package:flutter/foundation.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';

/// 화면을 채우기 위한 샘플. 저장소가 생기기 전까지 세션 안에서만 바뀐다.
class SpaceBoard extends ChangeNotifier {
  SpaceBoard._();

  static final SpaceBoard instance = SpaceBoard._();

  static const int maxTrades = 2;

  final List<SpaceProject> received = [];
  final Map<String, PrepRecord> _receivedRecords = {};

  final List<PrepRecord> consults = [
    const PrepRecord(
      id: 'consult-hannam',
      placeName: '한남동 작은 사무실',
      buildingType: '상가',
      address: '서울 용산구 한남대로 00',
      detailAddress: '3층',
      area: '18',
      buildingCondition: '부분 철거',
      style: '미니멀',
      budget: '4,000만 원',
      period: '2개월',
      industry: '사무실',
      workScope: '부분공사',
      contact: '010-0000-0000',
      workPlace: '홀, 사무공간',
      needs: '회의 공간을 나누고, 수납을 늘리고 싶어요. 기존 벽은 일부만 남기고, 입구에서 회의실이 바로 보이지 않게 동선을 나누고 싶어요.',
      floorPlanLabels: ['1층', '2층'],
      referenceImageLabels: ['거실 예상'],
    ),
  ];

  final List<TradeCandidate> trades = [
    const TradeCandidate(
      id: 'trade-hapjeong',
      name: '합정동 식당 자리',
      industry: '식당',
      address: '서울 마포구 양화로 00',
      detailAddress: '1층',
      area: '22',
      access: '코너',
      transit: '역 가까움',
      parking: '주변 주차',
      landmark: '홍대에서 걸어오는 길, 근처 오피스',
      sameIndustry: '몇 곳',
      nearbyTrades: '카페, 주점',
      timeBand: '저녁·야간',
      visitor: '방문',
      deposit: '5,000만 원',
      rent: '250만 원',
      maintenance: '20만 원',
      premium: '없음',
      rentUnknown: false,
      reason: '골목 안쪽보다 코너라 간판이 보일 것 같아요.',
      interiorNotes: ['외부 사인·조명', '카운터·대기 동선'],
    ),
    const TradeCandidate(
      id: 'trade-jamsil',
      name: '잠실 카페 자리',
      industry: '카페',
      address: '서울 송파구 올림픽로 00',
      detailAddress: '1층',
      area: '15',
      access: '큰길',
      transit: '역 가까움',
      parking: '건물 주차',
      landmark: '아파트 단지, 지하철',
      sameIndustry: '밀집',
      nearbyTrades: '베이커리, 편의점',
      timeBand: '주말',
      visitor: '거주',
      deposit: '',
      rent: '',
      maintenance: '',
      premium: '',
      rentUnknown: true,
      reason: '주말에 가족이 많이 지날 것 같아요.',
      interiorNotes: ['좌석·화장실', '파사드 차별화'],
    ),
  ];

  PrepRecord? recordFor(String projectId) => _receivedRecords[projectId];

  SpaceProject? projectForRecord(String recordId) {
    if (recordId.isEmpty) return null;
    for (final SpaceProject project in received) {
      if (_receivedRecords[project.id]?.id == recordId) return project;
    }
    return null;
  }

  SpaceProject receiveConsult(PrepRecord record) {
    final SpaceProject? existing = projectForRecord(record.id);
    if (existing != null) return existing;

    final String recordId = record.id.isEmpty
        ? 'consult-${DateTime.now().microsecondsSinceEpoch}'
        : record.id;
    final PrepRecord stored = record.id == recordId
        ? record
        : PrepRecord(
            id: recordId,
            placeName: record.placeName,
            buildingType: record.buildingType,
            address: record.address,
            detailAddress: record.detailAddress,
            area: record.area,
            buildingCondition: record.buildingCondition,
            style: record.style,
            budget: record.budget,
            period: record.period,
            periodStart: record.periodStart,
            periodEnd: record.periodEnd,
            needs: record.needs,
            floorPlanLabels: record.floorPlanLabels,
            referenceImageLabels: record.referenceImageLabels,
            industry: record.industry,
            workScope: record.workScope,
            contact: record.contact,
            workPlace: record.workPlace,
          );
    consults.removeWhere((PrepRecord item) => item.id == stored.id);
    final SpaceProject project = SpaceProject(
      id: 'space-${stored.id}',
      placeName: stored.placeName,
      statusLabel: '상담 · 접수',
      nextAction: '담당자가 내용을 확인하고 전화로 연락해요',
      phase: SpacePhase.consult,
      imageUrl: '',
      completed: false,
    );
    received.insert(0, project);
    _receivedRecords[project.id] = stored;
    notifyListeners();
    return project;
  }

  void saveConsult(PrepRecord record) {
    final int index = consults.indexWhere((PrepRecord item) => item.id == record.id);
    if (index >= 0) {
      consults[index] = record;
    } else {
      consults.insert(0, record);
    }
    notifyListeners();
  }

  void saveTrade(TradeCandidate candidate) {
    final int index = trades.indexWhere((TradeCandidate item) => item.id == candidate.id);
    if (index >= 0) {
      trades[index] = candidate;
      notifyListeners();
      return;
    }
    if (trades.length >= maxTrades) return;
    trades.insert(0, candidate);
    notifyListeners();
  }
}

/// 화면을 채우기 위한 샘플. 인테리어는 보통 한두 건이라 목록도 짧게 둔다.
abstract final class SpaceCatalog {
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
    for (final SpaceProject project in [...SpaceBoard.instance.received, ...ongoing, ...finished]) {
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
