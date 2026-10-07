/// 상담 접수 이후의 정식 프로젝트. 고객 화면에서는 현장명으로 보여 준다.
enum SpacePhase {
  consult('상담'),
  estimate('견적'),
  design('설계'),
  construction('공사'),
  handover('준공'),
  afterCare('A/S');

  const SpacePhase(this.label);

  final String label;

  static const List<SpacePhase> timeline = SpacePhase.values;
}

class SpaceProject {
  const SpaceProject({
    required this.id,
    required this.placeName,
    required this.statusLabel,
    required this.nextAction,
    required this.phase,
    required this.imageUrl,
    required this.completed,
  });

  final String id;
  final String placeName;
  final String statusLabel;
  final String nextAction;
  final SpacePhase phase;
  final String imageUrl;
  final bool completed;

  int get filledSteps => phase.index + 1;
}

/// 상담 전에 정리해 둔 사전준비 한 건.
abstract final class PrepLabels {
  static const String industryUndecided = '아직 정하지 못했어요';
  static const String areaUnknown = '정확히 몰라요';
  static const String budgetUndecided = '아직 정하지 못했어요';
  static const String periodUndecided = '아직 정하지 못했어요';
  static const String fullWork = '전체공사';
  static const String partialWork = '부분공사';
}

class PrepRecord {
  const PrepRecord({
    this.id = '',
    required this.placeName,
    required this.buildingType,
    required this.address,
    required this.detailAddress,
    required this.area,
    required this.buildingCondition,
    required this.style,
    required this.budget,
    required this.period,
    this.periodStart,
    this.periodEnd,
    required this.needs,
    required this.floorPlanLabels,
    required this.referenceImageLabels,
    this.industry = '',
    this.workScope = '',
    this.contact = '',
    this.workPlace = '',
  });

  final String id;
  final String placeName;
  final String buildingType;
  final String address;
  final String detailAddress;
  final String area;
  final String buildingCondition;
  final String style;
  final String budget;
  final String period;

  /// 캘린더로 직접 고른 기간. 대략 기간이면 비어 있다.
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final String needs;

  /// 평면도 라벨. 비어 있으면 라벨 없이 첨부만 있는 것이다.
  final List<String> floorPlanLabels;

  /// 참고 이미지 라벨. 비어 있으면 라벨 없이 첨부만 있는 것이다.
  final List<String> referenceImageLabels;

  /// 업종. 비어 있거나 [PrepLabels.industryUndecided]이면 정식 상담으로 넘기지 않는다.
  final String industry;

  /// 전체공사 또는 부분공사.
  final String workScope;

  /// 상담 전화에 쓰는 연락처.
  final String contact;

  /// 부분공사일 때 손볼 곳. 전체공사이면 비어 있다.
  final String workPlace;

  bool get industryReady => industry.isNotEmpty && industry != PrepLabels.industryUndecided;

  bool get contactReady => contact.trim().isNotEmpty;
}

/// 상담 전에 비교해 두는 상권 후보지. 분석 점수는 만들지 않는다.
class TradeCandidate {
  const TradeCandidate({
    required this.id,
    required this.name,
    required this.industry,
    required this.address,
    required this.detailAddress,
    required this.area,
    required this.access,
    required this.transit,
    required this.parking,
    required this.landmark,
    required this.sameIndustry,
    required this.nearbyTrades,
    required this.timeBand,
    required this.visitor,
    required this.deposit,
    required this.rent,
    required this.maintenance,
    required this.premium,
    required this.rentUnknown,
    required this.reason,
    required this.interiorNotes,
  });

  final String id;
  final String name;
  final String industry;
  final String address;
  final String detailAddress;
  final String area;
  final String access;
  final String transit;
  final String parking;
  final String landmark;
  final String sameIndustry;
  final String nearbyTrades;
  final String timeBand;
  final String visitor;
  final String deposit;
  final String rent;
  final String maintenance;
  final String premium;
  final bool rentUnknown;
  final String reason;
  final List<String> interiorNotes;

  PrepRecord toConsultSeed() {
    final String note = [
      if (reason.trim().isNotEmpty) reason.trim(),
      if (interiorNotes.isNotEmpty) '공간에서 볼 점: ${interiorNotes.join(', ')}',
    ].join('\n');
    return PrepRecord(
      placeName: name,
      buildingType: '상가',
      address: address,
      detailAddress: detailAddress,
      area: area,
      buildingCondition: '',
      style: '',
      budget: '',
      period: '',
      needs: note,
      floorPlanLabels: const [],
      referenceImageLabels: const [],
      industry: industry,
    );
  }
}

abstract final class TradeChoices {
  static const String industryOther = '기타';
  static const String unknown = '잘 모르겠어요';
  static const List<String> industries = [
    '카페',
    '식당',
    '베이커리',
    '미용',
    '학원',
    '병원',
    '사무실',
    '소매',
    industryOther,
    PrepLabels.industryUndecided,
  ];
  static const List<String> access = ['큰길', '골목', '코너', unknown];
  static const List<String> transit = ['역 가까움', '버스', '차 중심', unknown];
  static const List<String> parking = ['건물 주차', '주변 주차', '주차가 어려움', unknown];
  static const List<String> sameIndustry = ['거의 없음', '몇 곳', '밀집', unknown];
  static const List<String> timeBand = ['점심', '저녁·야간', '주말', '하루 종일', unknown];
  static const List<String> visitor = ['거주', '직장인', '방문', unknown];
  static const List<String> interiorNotes = [
    '카운터·대기 동선',
    '외부 사인·조명',
    '좌석·화장실',
    '점심 피크 동선',
    '접근성·바닥',
    '파사드 차별화',
  ];
}
