import 'package:interiorapp_flutter_client/build/domain/entity/construction_plan.dart';

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
    this.visitAppointment,
    this.constructionPlan,
  });

  final String id;
  final String placeName;
  final String statusLabel;
  final String nextAction;
  final SpacePhase phase;
  final String imageUrl;
  final bool completed;

  /// 전화 상담에서 정한 현장 방문. 없으면 아직 일정이 없는 것이다.
  final VisitAppointment? visitAppointment;

  /// 현장방문 이후 확정된 시공안. 없으면 아직 정리되지 않은 것이다.
  final ConstructionPlan? constructionPlan;

  int get filledSteps => phase.index + 1;
}

/// 전화 상담에서 정한 방문 일정, 위치, 방문하는 사람.
class VisitAppointment {
  const VisitAppointment({
    required this.when,
    required this.place,
    required this.visitorName,
    required this.visitorRole,
  });

  final DateTime when;
  final String place;
  final String visitorName;
  final String visitorRole;
}

enum ShowroomReferenceMarkKind { stroke, rect, ellipse }

/// 그린 선의 한 점. 값은 이미지 가로·세로 대비 0~1이다.
class ShowroomReferencePoint {
  const ShowroomReferencePoint(this.x, this.y);

  final double x;
  final double y;
}

/// 사진 위에 그린 선, 사각형, 원.
class ShowroomReferenceMark {
  const ShowroomReferenceMark.stroke(this.points, {this.color = 0xFFFFFFFF})
    : kind = ShowroomReferenceMarkKind.stroke,
      left = null,
      top = null,
      width = null,
      height = null;

  const ShowroomReferenceMark.shape({
    required this.kind,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    this.color = 0xFFFFFFFF,
  }) : points = const <ShowroomReferencePoint>[];

  final ShowroomReferenceMarkKind kind;
  final double? left;
  final double? top;
  final double? width;
  final double? height;
  final List<ShowroomReferencePoint> points;

  /// 선과 도형에 쓰는 색. ARGB.
  final int color;
}

/// 사진 안에서 고른 영역. 값은 이미지 가로·세로 대비 0~1이다.
class ShowroomReferenceCrop {
  const ShowroomReferenceCrop({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;
}

/// 쇼룸 사진 한 장, 또는 그 사진의 일부.
class ShowroomReferenceRegion {
  const ShowroomReferenceRegion({
    required this.id,
    required this.label,
    required this.imageUrl,
    this.crop,
    this.marks = const <ShowroomReferenceMark>[],
    this.asIs = false,
    this.note = '',
  });

  final String id;
  final String label;
  final String imageUrl;
  final ShowroomReferenceCrop? crop;
  final List<ShowroomReferenceMark> marks;
  final bool asIs;
  final String note;

  bool get hasMark => marks.isNotEmpty || crop != null;
}

/// 쇼룸 게시글을 상담의 참고 사례로 넘길 때 붙는 정보.
class ShowroomStyleRef {
  const ShowroomStyleRef({
    required this.showroomId,
    required this.title,
    required this.imageUrl,
    this.aspects = const <String>[],
    this.regions = const <ShowroomReferenceRegion>[],
    this.note = '',
  });

  final String showroomId;
  final String title;
  final String imageUrl;

  /// 사진에 안 보이는 참고. 동일한 스타일, 동일한 예산, 같은 업종.
  final List<String> aspects;

  /// 전체 보기에서 고른 사진과 그 일부.
  final List<ShowroomReferenceRegion> regions;

  /// 고객이 직접 적은 참고 설명.
  final String note;
}

/// 세부 마감 한 문항의 답. 고른 항목과 직접 적은 글을 함께 둔다.
class PrepFinishAnswer {
  const PrepFinishAnswer({this.choices = const <String>[], this.note = ''});

  final List<String> choices;
  final String note;

  bool get isEmpty => choices.isEmpty && note.trim().isEmpty;

  String get summary {
    final String written = note.trim();
    if (choices.isEmpty) return written;
    if (written.isEmpty) return choices.join(', ');
    return '${choices.join(', ')} · $written';
  }
}

abstract final class PrepLabels {
  static const String industryUndecided = '아직 정하지 못했어요';
  static const String areaUnknown = '정확히 몰라요';
  static const String budgetUndecided = '아직 정하지 못했어요';
  static const String periodUndecided = '아직 정하지 못했어요';
  static const String fullWork = '전체공사';
  static const String partialWork = '부분공사';
  static const String scopeUnknown = '잘 모르겠어요';
  static const String decideOnSite = '현장 상담 후 결정';
}

/// 주소에서 동네 이름을 고른다. 동·읍·면·리가 없으면 구·군을 쓴다.
String consultRegion(String address) {
  final List<String> parts = address.trim().split(RegExp(r'\s+'));
  final RegExp neighborhood = RegExp(r'([가-힣]{2,}(?:동|읍|면|리))');
  for (final String part in parts) {
    final RegExpMatch? match = neighborhood.firstMatch(part);
    if (match != null) return match.group(1)!;
  }
  for (final String part in parts) {
    if (part.endsWith('구') || part.endsWith('군')) return part;
  }
  for (final String part in parts) {
    if (part.endsWith('시') && !part.contains('특별') && !part.contains('광역'))
      return part;
  }
  return '';
}

/// 임시 공간 이름에 쓸 짧은 업종. 없으면 공간이라고 둔다.
String consultIndustryShort(String industry) {
  final String trimmed = industry.trim();
  if (trimmed.isEmpty || trimmed == PrepLabels.industryUndecided) return '공간';
  final int split = trimmed.indexOf('·');
  if (split > 0) return trimmed.substring(0, split).trim();
  return trimmed;
}

/// 이름을 비웠을 때 쓰는 `지역 + 업종`.
String consultTempPlaceName({
  required String address,
  required String industry,
}) {
  final String region = consultRegion(address);
  final String trade = consultIndustryShort(industry);
  if (region.isEmpty)
    return trade == '공간' && industry.trim().isEmpty ? '' : trade;
  return '$region $trade';
}

/// 상담 전에 정리해 둔 사전준비 한 건.
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
    this.floorPlans = const <ShowroomReferenceRegion>[],
    this.stylePhotos = const <ShowroomReferenceRegion>[],
    this.industry = '',
    this.industryGroup = '',
    this.secondaryIndustries = const <String>[],
    this.areaRange = '',
    this.budgetRange = '',
    this.startTiming = '',
    this.openTiming = '',
    this.workScope = '',
    this.contact = '',
    this.workPlace = '',
    this.finishes = const <String, PrepFinishAnswer>{},
    this.styleRef,
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

  /// 평수 옆에 올린 평면도. 표시와 설명이 들어 있다.
  final List<ShowroomReferenceRegion> floorPlans;

  /// 원하는 스타일 옆에 올린 사진. 표시와 설명이 들어 있다.
  final List<ShowroomReferenceRegion> stylePhotos;

  /// 업종. 비어 있거나 [PrepLabels.industryUndecided]이면 정식 상담으로 넘기지 않는다.
  final String industry;

  /// 대분류. 자주 있는 업종만 고르면 비어 있다.
  final String industryGroup;

  /// 대표 업종 외에 함께 고른 업종.
  final List<String> secondaryIndustries;

  /// 평수 구간. 숫자를 같이 적어도 구간은 남긴다.
  final String areaRange;

  /// 예산 구간. 금액을 같이 적어도 구간은 남긴다.
  final String budgetRange;

  /// 희망 착공 시점. 비어 있으면 아직 고르지 않은 것이다.
  final String startTiming;

  /// 희망 오픈 또는 완료 시점.
  final String openTiming;

  /// 전체공사, 부분공사, 또는 아직 모르는 상태.
  final String workScope;

  /// 상담 전화에 쓰는 연락처.
  final String contact;

  /// 부분공사일 때 손볼 곳. 전체공사이면 비어 있다.
  final String workPlace;

  /// 세부 마감. 문항 이름을 키로 둔다. 비어 있으면 아직 적지 않은 것이다.
  final Map<String, PrepFinishAnswer> finishes;

  /// 쇼룸에서 골라 온 참고 사례. 없으면 일반 상담준비다.
  final ShowroomStyleRef? styleRef;

  bool get industryReady =>
      industry.isNotEmpty && industry != PrepLabels.industryUndecided;

  bool get contactReady => contact.trim().isNotEmpty;

  String get industryLine {
    final String primary = industry.trim();
    if (secondaryIndustries.isEmpty) return primary;
    return '$primary · 보조 ${secondaryIndustries.join(', ')}';
  }

  String get areaLine {
    final String exact = area.trim();
    final String range = areaRange.trim();
    if (range.isEmpty) return exact;
    if (exact.isEmpty || exact == range) return range;
    return '$exact · $range';
  }

  String get budgetLine {
    final String amount = budget.trim();
    final String range = budgetRange.trim();
    if (amount == PrepLabels.budgetUndecided) return amount;
    if (range.isEmpty) return amount;
    if (amount.isEmpty || amount == range) return range;
    return '$amount · $range';
  }
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
