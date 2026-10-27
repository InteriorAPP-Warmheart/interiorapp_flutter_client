import 'package:interiorapp_flutter_client/build/domain/entity/construction_plan.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/construction_progress.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/domain/repository/space_repository.dart';

/// 내공간 서버의 자리. 연결 전에는 세션 안의 목데이터다.
class SpaceApi {
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
      needs:
          '회의 공간을 나누고, 수납을 늘리고 싶어요. 기존 벽은 일부만 남기고, 입구에서 회의실이 바로 보이지 않게 동선을 나누고 싶어요.',
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

  final List<SpaceProject> ongoing = [
    SpaceProject(
      id: 'project-seongsu-cafe',
      placeName: '성수동 카페',
      statusLabel: '공사 진행중',
      nextAction: '오늘 목공 공사 · 내일 전기 공사',
      phase: SpacePhase.construction,
      imageUrl: 'https://picsum.photos/seed/seongsu-cafe/1200/900',
      completed: false,
      visitAppointment: VisitAppointment(
        when: DateTime(2026, 10, 29, 10, 30),
        place: '서울 성동구 성수이로 00 1층',
        visitorName: '정하늘',
        visitorRole: '실사 담당',
      ),
      constructionPlan: ConstructionPlan(
        scope: [
          PlanDecision(
            conclusion: '카운터 벽은 낮춰 새로 만듦',
            customerNote: '카운터를 입구에서 바로 보이게 하고 싶은데, 기존 벽을 남길지 고민이에요.',
            staffNote: '기존 벽이 입구 시야를 가리고, 콘센트를 새로 달아야 해서 벽을 낮춰 새로 만드는 쪽을 권했어요.',
          ),
          PlanDecision(
            conclusion: '좌석은 창가 쪽으로 둠',
            customerNote: '좌석은 창가 쪽에 두고 싶어요.',
            staffNote: '창가 폭에 좌석을 두고, 안쪽은 카운터와 동선으로 남기는 배치가 맞아요.',
          ),
        ],
        excluded: [
          PlanDecision(
            conclusion: '화장실은 이번 공사에서 제외',
            customerNote: '화장실은 이번에 손대지 않아도 돼요.',
            staffNote: '급배수 이설이 없어서 화장실은 범위 밖에 두기로 했어요.',
          ),
        ],
        constraints: [
          PlanDecision(
            conclusion: '전기는 증설이 필요함',
            customerNote: '머신과 조명을 지금보다 늘리고 싶어요.',
            staffNote: '현재 용량으로는 부족해서 증설을 공사 조건에 넣었어요.',
          ),
        ],
      ),
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

  final List<SpaceProject> finished = const [
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

  static const Map<String, ConstructionProgress> _construction = {
    'project-seongsu-cafe': ConstructionProgress(
      currentLabel: '목공 공사 진행중',
      expectedCompletion: '11월 18일',
      today: TodayWorkState.underway,
      todayTrade: '목공 공사',
      todaySummary: '벽과 천장 틀을 맞추고 있어요',
      workers: '목수 2명',
      trades: ['철거', '설비·급배수', '목공', '전기', '도장', '마감'],
      tradeIndex: 2,
      nextWhen: '내일',
      nextTrade: '전기 공사',
      nextSummary: '조명과 콘센트 배선을 시작해요',
      recentPhotos: [
        PublicSitePhoto(
          imageUrl: 'https://picsum.photos/seed/seongsu-wood-1/900/900',
          trade: '목공',
          takenOn: '10월 22일',
        ),
        PublicSitePhoto(
          imageUrl: 'https://picsum.photos/seed/seongsu-wood-2/900/900',
          trade: '목공',
          takenOn: '10월 21일',
        ),
        PublicSitePhoto(
          imageUrl: 'https://picsum.photos/seed/seongsu-demo-1/900/900',
          trade: '철거',
          takenOn: '10월 8일',
        ),
      ],
    ),
  };

  static const Map<String, PrepRecord> _keptConsults = {
    'project-seongsu-cafe': PrepRecord(
      id: 'consult-seongsu',
      placeName: '성수동 카페',
      buildingType: '상가',
      address: '서울 성동구 성수이로 00',
      detailAddress: '1층',
      area: '32',
      areaRange: '30평대',
      buildingCondition: '부분 철거',
      style: '따뜻한 우드',
      budget: '8,000만 원',
      budgetRange: '7~9천만 원',
      period: '2개월',
      startTiming: '1개월 안',
      openTiming: '1~3개월',
      needs: '카운터를 입구에서 바로 보이게 하고, 좌석은 창가 쪽으로 두고 싶어요.',
      floorPlanLabels: [],
      referenceImageLabels: [],
      industry: '카페',
      workScope: '전체공사',
      contact: '010-0000-0000',
      finishes: {
        'signboard': PrepFinishAnswer(choices: ['신규 제작']),
        'lighting': PrepFinishAnswer(choices: ['전체 교체']),
      },
    ),
  };

  ConstructionProgress? constructionFor(String projectId) =>
      _construction[projectId];

  PrepRecord? recordFor(String projectId) =>
      _receivedRecords[projectId] ?? _keptConsults[projectId];

  SpaceProject? projectForRecord(String recordId) {
    if (recordId.isEmpty) return null;
    for (final SpaceProject project in received) {
      if (_receivedRecords[project.id]?.id == recordId) return project;
    }
    return null;
  }

  SpaceProject? find(String id) {
    for (final SpaceProject project in [...received, ...ongoing, ...finished]) {
      if (project.id == id) return project;
    }
    return null;
  }

  SpaceProject receiveConsult(PrepRecord record) {
    final SpaceProject? existing = projectForRecord(record.id);
    if (existing != null) return existing;

    final String recordId =
        record.id.isEmpty
            ? 'consult-${DateTime.now().microsecondsSinceEpoch}'
            : record.id;
    final PrepRecord stored =
        record.id == recordId
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
              floorPlans: record.floorPlans,
              stylePhotos: record.stylePhotos,
              industry: record.industry,
              industryGroup: record.industryGroup,
              secondaryIndustries: record.secondaryIndustries,
              areaRange: record.areaRange,
              budgetRange: record.budgetRange,
              startTiming: record.startTiming,
              openTiming: record.openTiming,
              workScope: record.workScope,
              contact: record.contact,
              workPlace: record.workPlace,
              finishes: record.finishes,
              styleRef: record.styleRef,
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
    return project;
  }

  void saveConsult(PrepRecord record) {
    final int index = consults.indexWhere(
      (PrepRecord item) => item.id == record.id,
    );
    if (index >= 0) {
      consults[index] = record;
    } else {
      consults.insert(0, record);
    }
  }

  void saveTrade(TradeCandidate candidate) {
    final int index = trades.indexWhere(
      (TradeCandidate item) => item.id == candidate.id,
    );
    if (index >= 0) {
      trades[index] = candidate;
      return;
    }
    if (trades.length >= SpaceRepository.maxTrades) return;
    trades.insert(0, candidate);
  }
}
