import 'package:interiorapp_flutter_client/build/data/source/quote_sample.dart';
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
      workQuote: sampleWorkQuote,
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
      statusLabel: '시공 · 견적',
      nextAction: '시공과 금액을 확인해 주세요',
      workQuote: sampleWorkQuote,
      phase: SpacePhase.estimate,
      imageUrl: 'https://picsum.photos/seed/mangwon-bakery/1200/900',
      completed: false,
      visitAppointment: VisitAppointment(
        when: DateTime(2026, 10, 21, 11, 0),
        place: '서울 마포구 망원로 00 1층',
        visitorName: '윤재원',
        visitorRole: '실사 담당',
      ),
      constructionPlan: ConstructionPlan(
        scope: [
          PlanDecision(
            conclusion: '진열대는 입구에서 바로 보이게 둠',
            customerNote: '진열대를 들어오자마자 보이게 하고 싶어요.',
            staffNote: '입구 정면 벽을 낮추고, 쇼케이스를 길 쪽에서 보이게 두기로 했어요.',
          ),
          PlanDecision(
            conclusion: '작업 공간은 안쪽에 둠',
            customerNote: '반죽과 오븐은 손님 쪽에서 덜 보이게 하고 싶어요.',
            staffNote: '안쪽을 작업대로 두고, 진열대 뒤를 계산대와 동선으로 남기기로 했어요.',
          ),
        ],
        excluded: [
          PlanDecision(
            conclusion: '2층 창고는 이번 공사에서 제외',
            customerNote: '영업은 1층만 해서, 2층은 이번에 손대지 않아도 돼요.',
            staffNote: '1층 급배수와 전기만 손보기로 하고, 2층 창고는 범위 밖에 뒀어요.',
          ),
        ],
        constraints: [
          PlanDecision(
            conclusion: '오븐 때문에 전기 증설이 필요함',
            customerNote: '오븐이랑 냉장 쇼케이스를 지금보다 늘리고 싶어요.',
            staffNote: '현재 용량으로는 오븐과 쇼케이스를 같이 쓰기 어려워서 증설을 공사 조건에 넣었어요.',
          ),
          PlanDecision(
            conclusion: '작업대 쪽으로 급배수를 옮겨야 함',
            customerNote: '싱크를 안쪽 작업대 옆에 두고 싶어요.',
            staffNote: '기존 배수는 입구 쪽이라, 안쪽 작업대까지 급배수를 옮겨야 해요.',
          ),
        ],
      ),
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

  static const List<PublicSitePhoto> _seongsuPhotos = [
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/seongsu-1024-paint-hall/900/900',
      trade: '도장',
      area: '홀',
      takenOn: '10월 24일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/seongsu-1024-wood-hall/900/900',
      trade: '목공',
      area: '홀',
      takenOn: '10월 24일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/seongsu-1024-wood-counter/900/900',
      trade: '목공',
      area: '카운터',
      takenOn: '10월 24일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/seongsu-1024-paint-window/900/900',
      trade: '도장',
      area: '창가',
      takenOn: '10월 24일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/seongsu-1022-wood-kitchen/900/900',
      trade: '목공',
      area: '주방',
      takenOn: '10월 22일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/seongsu-1022-elec-hall/900/900',
      trade: '전기',
      area: '홀',
      takenOn: '10월 22일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/seongsu-1022-elec-counter/900/900',
      trade: '전기',
      area: '카운터',
      takenOn: '10월 22일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/seongsu-1022-wood-window/900/900',
      trade: '목공',
      area: '창가',
      takenOn: '10월 22일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/seongsu-1021-wood-hall/900/900',
      trade: '목공',
      area: '홀',
      takenOn: '10월 21일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/seongsu-1021-wood-kitchen/900/900',
      trade: '목공',
      area: '주방',
      takenOn: '10월 21일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/seongsu-1018-plumb-kitchen/900/900',
      trade: '설비·급배수',
      area: '주방',
      takenOn: '10월 18일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/seongsu-1018-plumb-hall/900/900',
      trade: '설비·급배수',
      area: '홀',
      takenOn: '10월 18일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/seongsu-1018-wood-counter/900/900',
      trade: '목공',
      area: '카운터',
      takenOn: '10월 18일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/seongsu-1014-plumb-kitchen/900/900',
      trade: '설비·급배수',
      area: '주방',
      takenOn: '10월 14일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/seongsu-1014-demo-kitchen/900/900',
      trade: '철거',
      area: '주방',
      takenOn: '10월 14일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/seongsu-1008-demo-hall/900/900',
      trade: '철거',
      area: '홀',
      takenOn: '10월 8일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/seongsu-1008-demo-counter/900/900',
      trade: '철거',
      area: '카운터',
      takenOn: '10월 8일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/seongsu-1008-demo-kitchen/900/900',
      trade: '철거',
      area: '주방',
      takenOn: '10월 8일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/seongsu-1007-demo-front/900/900',
      trade: '철거',
      area: '외관',
      takenOn: '10월 7일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/seongsu-1007-demo-hall/900/900',
      trade: '철거',
      area: '홀',
      takenOn: '10월 7일',
    ),
  ];

  static const List<PublicSitePhoto> _mangwonPhotos = [
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/mangwon-1021-hall/900/900',
      trade: '실사',
      area: '홀',
      takenOn: '10월 21일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/mangwon-1021-case/900/900',
      trade: '실사',
      area: '진열대',
      takenOn: '10월 21일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/mangwon-1021-kitchen/900/900',
      trade: '실사',
      area: '주방',
      takenOn: '10월 21일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/mangwon-1021-work/900/900',
      trade: '실사',
      area: '작업대',
      takenOn: '10월 21일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/mangwon-1020-front/900/900',
      trade: '실사',
      area: '외관',
      takenOn: '10월 20일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/mangwon-1020-hall/900/900',
      trade: '실사',
      area: '홀',
      takenOn: '10월 20일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/mangwon-1020-kitchen/900/900',
      trade: '실사',
      area: '주방',
      takenOn: '10월 20일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/mangwon-1016-front/900/900',
      trade: '실사',
      area: '외관',
      takenOn: '10월 16일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/mangwon-1016-case/900/900',
      trade: '실사',
      area: '진열대',
      takenOn: '10월 16일',
    ),
  ];

  static const List<PublicSitePhoto> _yeonnamPhotos = [
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/yeonnam-0928-finish-room/900/900',
      trade: '마감',
      area: '방',
      takenOn: '9월 28일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/yeonnam-0928-finish-bath/900/900',
      trade: '마감',
      area: '욕실',
      takenOn: '9월 28일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/yeonnam-0928-finish-entry/900/900',
      trade: '마감',
      area: '현관',
      takenOn: '9월 28일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/yeonnam-0922-paint-room/900/900',
      trade: '도장',
      area: '방',
      takenOn: '9월 22일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/yeonnam-0922-paint-kitchen/900/900',
      trade: '도장',
      area: '주방',
      takenOn: '9월 22일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/yeonnam-0916-wood-room/900/900',
      trade: '목공',
      area: '방',
      takenOn: '9월 16일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/yeonnam-0916-wood-entry/900/900',
      trade: '목공',
      area: '현관',
      takenOn: '9월 16일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/yeonnam-0908-plumb-kitchen/900/900',
      trade: '설비',
      area: '주방',
      takenOn: '9월 8일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/yeonnam-0908-plumb-bath/900/900',
      trade: '설비',
      area: '욕실',
      takenOn: '9월 8일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/yeonnam-0902-demo-room/900/900',
      trade: '철거',
      area: '방',
      takenOn: '9월 2일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/yeonnam-0902-demo-kitchen/900/900',
      trade: '철거',
      area: '주방',
      takenOn: '9월 2일',
    ),
  ];

  static const List<PublicSitePhoto> _jamwonPhotos = [
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/jamwon-0819-finish-hall/900/900',
      trade: '마감',
      area: '홀',
      takenOn: '8월 19일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/jamwon-0819-finish-wash/900/900',
      trade: '마감',
      area: '샴푸대',
      takenOn: '8월 19일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/jamwon-0812-elec-hall/900/900',
      trade: '전기',
      area: '홀',
      takenOn: '8월 12일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/jamwon-0812-elec-wash/900/900',
      trade: '전기',
      area: '샴푸대',
      takenOn: '8월 12일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/jamwon-0807-wood-hall/900/900',
      trade: '목공',
      area: '홀',
      takenOn: '8월 7일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/jamwon-0807-wood-front/900/900',
      trade: '목공',
      area: '외관',
      takenOn: '8월 7일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/jamwon-0803-plumb-wash/900/900',
      trade: '설비',
      area: '샴푸대',
      takenOn: '8월 3일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/jamwon-0728-demo-hall/900/900',
      trade: '철거',
      area: '홀',
      takenOn: '7월 28일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/jamwon-0728-demo-front/900/900',
      trade: '철거',
      area: '외관',
      takenOn: '7월 28일',
    ),
  ];

  static const List<PublicSitePhoto> _haeundaePhotos = [
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/haeundae-0815-finish-room/900/900',
      trade: '마감',
      area: '객실',
      takenOn: '8월 15일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/haeundae-0815-finish-bath/900/900',
      trade: '마감',
      area: '욕실',
      takenOn: '8월 15일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/haeundae-0815-finish-terrace/900/900',
      trade: '마감',
      area: '테라스',
      takenOn: '8월 15일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/haeundae-0808-wood-room/900/900',
      trade: '목공',
      area: '객실',
      takenOn: '8월 8일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/haeundae-0808-wood-terrace/900/900',
      trade: '목공',
      area: '테라스',
      takenOn: '8월 8일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/haeundae-0802-elec-room/900/900',
      trade: '전기',
      area: '객실',
      takenOn: '8월 2일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/haeundae-0802-plumb-bath/900/900',
      trade: '설비',
      area: '욕실',
      takenOn: '8월 2일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/haeundae-0726-demo-room/900/900',
      trade: '철거',
      area: '객실',
      takenOn: '7월 26일',
    ),
    PublicSitePhoto(
      imageUrl: 'https://picsum.photos/seed/haeundae-0726-demo-terrace/900/900',
      trade: '철거',
      area: '테라스',
      takenOn: '7월 26일',
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
      recentPhotos: _seongsuPhotos,
    ),
    'project-mangwon-bakery': ConstructionProgress(
      currentLabel: '실사 내용 정리중',
      today: TodayWorkState.checking,
      todayTrade: '실사',
      todaySummary: '진열대 위치와 배수를 확인하고 있어요',
      trades: ['실사', '철거', '설비', '목공', '마감'],
      tradeIndex: 0,
      recentPhotos: _mangwonPhotos,
    ),
    'project-yeonnam-room': ConstructionProgress(
      currentLabel: '준공 완료',
      today: TodayWorkState.closing,
      todaySummary: '시공 기록을 다시 볼 수 있어요',
      trades: ['철거', '설비', '목공', '도장', '마감'],
      tradeIndex: 4,
      recentPhotos: _yeonnamPhotos,
    ),
    'project-jamwon-salon': ConstructionProgress(
      currentLabel: '준공 완료',
      today: TodayWorkState.closing,
      todaySummary: '시공 기록을 다시 볼 수 있어요',
      trades: ['철거', '설비', '목공', '전기', '마감'],
      tradeIndex: 4,
      recentPhotos: _jamwonPhotos,
    ),
    'project-haeundae-stay': ConstructionProgress(
      currentLabel: '준공 완료',
      today: TodayWorkState.closing,
      todaySummary: '시공 기록을 다시 볼 수 있어요',
      trades: ['철거', '설비', '전기', '목공', '마감'],
      tradeIndex: 4,
      recentPhotos: _haeundaePhotos,
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
    'project-mangwon-bakery': PrepRecord(
      id: 'consult-mangwon',
      placeName: '망원동 빵집',
      buildingType: '상가',
      address: '서울 마포구 망원로 00',
      detailAddress: '1층',
      area: '28',
      areaRange: '20평대',
      buildingCondition: '부분 철거',
      style: '따뜻한 우드',
      budget: '1억 원',
      budgetRange: '9천만~1.1억 원',
      period: '2개월',
      startTiming: '1개월 안',
      openTiming: '1~3개월',
      needs: '진열대를 입구에서 바로 보이게 하고, 작업 공간은 안쪽에 두고 싶어요.',
      floorPlanLabels: [],
      referenceImageLabels: [],
      industry: '베이커리',
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
