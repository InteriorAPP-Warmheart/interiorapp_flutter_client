import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/quick_filter_catalog.dart';

/// 마감 선택지의 대략적인 비용 감각. 견적이 아니라 저렴, 보통, 비쌈만 구분한다.
enum PrepCostBand {
  low('저렴'),
  mid('보통'),
  high('비쌈');

  const PrepCostBand(this.label);

  final String label;
}

/// 마감 문항의 선택지. 이름만 저장하고, 사진과 설명과 비용은 여기서 보여 준다.
class PrepFinishOption {
  const PrepFinishOption({
    required this.label,
    this.imageUrl,
    this.description,
    this.cost,
    this.undecided = false,
  });

  /// 저장되는 이름.
  final String label;

  /// 사진 주소. `assets/` 또는 https. 없으면 사진 칸만 연다.
  final String? imageUrl;

  /// 선택지 아래 짧은 설명.
  final String? description;

  /// 대략적인 비용. 아직 정하지 않은 선택지는 비워 둔다.
  final PrepCostBand? cost;

  /// 현장에서 정하는 선택지. 사진과 비용을 보여 주지 않는다.
  final bool undecided;
}

/// 상담준비 설문. 문항 이름, 안내, 선택지는 이 파일에서만 고친다.
///
/// 화면은 여기서 문항을 읽어 그린다. 입력칸의 동작은 바뀌지 않는다.
class PrepQuestion {
  const PrepQuestion({
    required this.id,
    required this.title,
    this.help,
    this.hint,
    this.emptyMessage,
    this.choices = const <String>[],
    this.options = const <PrepFinishOption>[],
    this.required = false,
    this.many = false,
    this.exclusive,
    this.freeTextChoice,
  });

  /// 저장과 화면이 문항을 구분하는 이름.
  final String id;

  /// 폼에 보이는 문항 이름.
  final String title;

  /// 문항 아래 안내. 없으면 안내를 그리지 않는다.
  final String? help;

  /// 직접 적는 칸의 예시.
  final String? hint;

  /// 비었을 때 막는 필수 문항의 안내.
  final String? emptyMessage;

  /// 고를 수 있는 항목. 직접 적는 문항은 비어 있다.
  final List<String> choices;

  /// 사진, 설명, 대략 비용이 있는 마감 선택지. 있으면 이 목록으로 그린다.
  final List<PrepFinishOption> options;

  PrepFinishOption? optionOf(String label) {
    for (final PrepFinishOption option in options) {
      if (option.label == label) return option;
    }
    return null;
  }

  /// 고르지 않으면 다음으로 넘길 수 없는지.
  final bool required;

  /// 여러 항목을 함께 고를 수 있는지. 아니면 하나만 고른다.
  final bool many;

  /// 이 항목을 고르면 같은 문항의 다른 선택은 빠진다.
  final String? exclusive;

  /// 고르면 짧은 글을 더 받는 항목. 업종의 기타가 여기 해당한다.
  final String? freeTextChoice;

  /// 여러 개를 고르는 문항에서 항목을 켜고 끈다.
  void toggle(List<String> selected, String value) {
    final String? lock = exclusive;
    if (lock != null && value == lock) {
      selected
        ..clear()
        ..add(lock);
      return;
    }
    if (lock != null) selected.remove(lock);
    if (!selected.remove(value)) selected.add(value);
  }
}

abstract final class PrepSurvey {
  static const List<String> steps = ['현장', '조건', '마감'];

  static const PrepFinishOption decideLater = PrepFinishOption(
    label: PrepLabels.decideOnSite,
    description: '현장에서 보고 정해도 돼요.',
    undecided: true,
  );

  static const PrepQuestion space = PrepQuestion(
    id: 'space',
    title: '공간',
    help: '지금은 상가 공간만 진행할 수 있어요.',
    choices: [commercial, residential],
    required: true,
  );
  static const String commercial = '상가';
  static const String residential = '주거';

  static const PrepQuestion address = PrepQuestion(
    id: 'address',
    title: '주소',
    required: true,
    emptyMessage: '주소를 검색해 주세요',
  );

  static const PrepQuestion detailAddress = PrepQuestion(
    id: 'detailAddress',
    title: '상세주소',
    hint: '건물 이름, 동, 호수',
    required: true,
    emptyMessage: '상세주소를 적어 주세요',
  );

  static const PrepQuestion placeName = PrepQuestion(
    id: 'placeName',
    title: '공간 이름',
    help: '비워 두면 지역과 업종으로 임시 이름을 넣어요.',
    hint: '예: 성수 사옥, 동탄 고기집',
  );

  static const String industryOther = '기타';

  static const PrepQuestion industry = PrepQuestion(
    id: 'industry',
    title: '업종',
    help: '자주 있는 업종을 바로 골라도 되고, 대분류에서 세부업종을 골라도 돼요. 보조 업종은 여러 개 고를 수 있어요.',
    hint: '예: 복지시설, 창고, 공방',
    choices: [
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
    ],
    required: true,
    emptyMessage: '업종을 골라 주세요',
    freeTextChoice: industryOther,
  );

  static const String industryNoteEmpty = '업종을 적어 주세요';
  static const String contactEmpty = '연락처를 적어 주세요';
  static const String contactInvalid = '연락처를 다시 확인해 주세요';

  static const PrepQuestion contact = PrepQuestion(
    id: 'contact',
    title: '연락처',
    help: '하이픈 없이 숫자만 적어 주세요. 010-0000-0000 형태로 보여 드려요.',
    hint: '01012345678',
    required: true,
    emptyMessage: contactEmpty,
  );

  static const PrepQuestion workScope = PrepQuestion(
    id: 'workScope',
    title: '공사 형태',
    help: '지금은 전체공사만 진행할 수 있어요. 아직 모르면 그렇게 골라도 돼요.',
    choices: [PrepLabels.fullWork, PrepLabels.partialWork, PrepLabels.scopeUnknown],
    required: true,
    emptyMessage: '공사 형태를 골라 주세요',
  );

  static const String partialPlaceHelp = '주방, 홀처럼 손볼 곳을 간단히 적어 주세요.';
  static const String partialPlaceHint = '예: 주방, 홀';
  static const String partialPlaceEmpty = '부분공사로 손볼 곳을 적어 주세요';

  static const PrepQuestion area = PrepQuestion(
    id: 'area',
    title: '평수',
    choices: [PrepLabels.areaUnknown],
    required: true,
    emptyMessage: '평수를 적거나, 구간을 고르거나, 정확히 모른다고 골라 주세요',
  );

  static const PrepQuestion demolition = PrepQuestion(
    id: 'demolition',
    title: '철거 여부',
    choices: ['전체 철거', '부분 철거', '철거 없음', '상담필요'],
    required: true,
    emptyMessage: '철거 여부를 골라 주세요',
  );

  static final PrepQuestion style = PrepQuestion(
    id: 'style',
    title: '원하는 스타일',
    help: '가까운 분위기를 고르거나, 원하는 스타일을 직접 적어도 돼요.',
    hint: '예: 호텔 라운지, 노출 콘크리트',
    choices: [for (final StyleMoodCard card in styleMoodCards) card.title],
    required: true,
    emptyMessage: '원하는 스타일을 고르거나 적어 주세요',
  );

  static const PrepQuestion budget = PrepQuestion(
    id: 'budget',
    title: '예산',
    help: '금액이나 구간을 고르거나, 아직 정하지 못했다고 골라도 돼요. 금액을 적으면 고른 마감과 평당으로 예산이 맞는지 가늠해요.',
    hint: '예: 30,000,000',
    required: true,
    emptyMessage: '금액이나 구간을 고르거나, 아직 정하지 못했다고 골라 주세요',
  );

  static const List<String> timingChoices = [
    '바로',
    '1개월 안',
    '1~3개월',
    '3~6개월',
    '6개월 이후',
    PrepLabels.periodUndecided,
  ];

  static const PrepQuestion startTiming = PrepQuestion(
    id: 'startTiming',
    title: '희망 착공',
    help: '대략의 시점만 골라도 돼요.',
    choices: timingChoices,
  );

  static const PrepQuestion openTiming = PrepQuestion(
    id: 'openTiming',
    title: '희망 오픈·완료',
    help: '오픈하거나 공사가 끝나길 바라는 시점이에요.',
    choices: timingChoices,
  );

  static const PrepQuestion period = PrepQuestion(
    id: 'period',
    title: '희망공사기간',
    help: '공사가 진행됨에 따라 인건비가 늘어나요. 희망하는 공사의 진행 기간을 골라 주세요. 상담을 통해 기간은 달라질 수 있어요.',
    choices: ['1개월 이내', '1개월', '2개월', PrepLabels.periodUndecided],
    required: true,
    emptyMessage: '희망공사기간을 골라 주세요',
  );

  static const PrepQuestion detailsIntro = PrepQuestion(
    id: 'detailsIntro',
    title: '마감은 정한 것만 적어도 돼요',
    help: '이 단계는 선택이에요. 전부 비워 두고 저장할 수 있고, 정한 항목만 골라 두어도 돼요.',
  );

  static const PrepQuestion signboard = PrepQuestion(
    id: 'signboard',
    title: '간판',
    hint: '예: 돌출 간판, 전면 채널',
    options: [
      PrepFinishOption(
        label: '신규 제작',
        description: '새 간판을 맞춥니다.',
        cost: PrepCostBand.high,
      ),
      PrepFinishOption(
        label: '기존 유지',
        description: '있는 간판을 그대로 둡니다.',
        cost: PrepCostBand.low,
      ),
      PrepFinishOption(
        label: '교체',
        description: '있는 간판을 새것으로 바꿉니다.',
        cost: PrepCostBand.high,
      ),
      decideLater,
    ],
  );

  static const PrepQuestion signage = PrepQuestion(
    id: 'signage',
    title: '사인물',
    hint: '예: 메뉴판, 화장실 안내',
    options: [
      PrepFinishOption(
        label: '실내 안내',
        description: '메뉴판, 화장실처럼 실내 안내입니다.',
        cost: PrepCostBand.mid,
      ),
      PrepFinishOption(
        label: '외부 사인',
        description: '입구와 외벽에 붙는 사인입니다.',
        cost: PrepCostBand.high,
      ),
      PrepFinishOption(
        label: '유리 시트',
        description: '유리에 시트와 글자를 붙입니다.',
        cost: PrepCostBand.mid,
      ),
      decideLater,
    ],
    many: true,
    exclusive: PrepLabels.decideOnSite,
  );

  static const PrepQuestion lighting = PrepQuestion(
    id: 'lighting',
    title: '조명',
    hint: '예: 매입등, 팬던트, 간접등',
    options: [
      PrepFinishOption(
        label: '전체 교체',
        description: '공간 조명을 새로 맞춥니다.',
        cost: PrepCostBand.high,
      ),
      PrepFinishOption(
        label: '부분 교체',
        description: '필요한 자리만 바꿉니다.',
        cost: PrepCostBand.mid,
      ),
      PrepFinishOption(
        label: '기존 유지',
        description: '있는 조명을 그대로 둡니다.',
        cost: PrepCostBand.low,
      ),
      decideLater,
    ],
  );

  static const PrepQuestion facilities = PrepQuestion(
    id: 'facilities',
    title: '설비',
    hint: '예: 전기 용량 15kW, 싱크 위치 이동',
    options: [
      PrepFinishOption(
        label: '수도설비 변경',
        description: '급수와 배수 위치를 바꿉니다.',
        cost: PrepCostBand.high,
      ),
      PrepFinishOption(
        label: '전기용량 변경',
        description: '전기 용량을 늘리거나 나눕니다.',
        cost: PrepCostBand.high,
      ),
      PrepFinishOption(
        label: '환기 설비 변경',
        description: '환기와 덕트를 손봅니다.',
        cost: PrepCostBand.mid,
      ),
      PrepFinishOption(
        label: '가스 설비 변경',
        description: '가스 배관을 옮기거나 늘립니다.',
        cost: PrepCostBand.high,
      ),
      decideLater,
    ],
    many: true,
    exclusive: PrepLabels.decideOnSite,
  );

  static const PrepQuestion floor = PrepQuestion(
    id: 'floor',
    title: '바닥재',
    hint: '예: 홀은 타일, 주방은 에폭시',
    options: [
      PrepFinishOption(
        label: '강마루',
        description: '나무 결이 있는 마루입니다.',
        cost: PrepCostBand.mid,
      ),
      PrepFinishOption(
        label: '타일',
        description: '물과 오염에 강한 바닥입니다.',
        cost: PrepCostBand.mid,
      ),
      PrepFinishOption(
        label: '폴리싱 타일',
        description: '표면을 갈아 광이 나는 타일입니다.',
        cost: PrepCostBand.high,
      ),
      PrepFinishOption(
        label: '데코타일',
        description: '시트로 붙이는 바닥입니다.',
        cost: PrepCostBand.low,
      ),
      PrepFinishOption(
        label: '카펫 타일',
        description: '소음이 덜한 타일형 카펫입니다.',
        cost: PrepCostBand.mid,
      ),
      decideLater,
    ],
    many: true,
    exclusive: PrepLabels.decideOnSite,
  );

  static const PrepQuestion ceiling = PrepQuestion(
    id: 'ceiling',
    title: '천장',
    hint: '예: 카운터 위만 우물천장',
    options: [
      PrepFinishOption(
        label: '노출형',
        description: '배관과 구조가 보이게 둡니다.',
        cost: PrepCostBand.mid,
      ),
      PrepFinishOption(
        label: '도장',
        description: '천장을 페인트로 마감합니다.',
        cost: PrepCostBand.low,
      ),
      PrepFinishOption(
        label: '벽지',
        description: '천장에 벽지를 바릅니다.',
        cost: PrepCostBand.low,
      ),
      PrepFinishOption(
        label: '텍스',
        description: '텍스 보드로 천장을 덮습니다.',
        cost: PrepCostBand.low,
      ),
      PrepFinishOption(
        label: '우물천장',
        description: '단을 두고 조명을 넣습니다.',
        cost: PrepCostBand.high,
      ),
      decideLater,
    ],
    many: true,
    exclusive: PrepLabels.decideOnSite,
  );

  static const PrepQuestion paint = PrepQuestion(
    id: 'paint',
    title: '도장',
    hint: '예: 벽은 따뜻한 베이지',
    options: [
      PrepFinishOption(
        label: '수성',
        description: '물에 희석하는 일반적인 페인트입니다.',
        cost: PrepCostBand.low,
      ),
      PrepFinishOption(
        label: '유성',
        description: '오염과 습기에 더 버티는 페인트입니다.',
        cost: PrepCostBand.mid,
      ),
      PrepFinishOption(
        label: '친환경',
        description: '냄새와 유해 성분을 줄인 페인트입니다.',
        cost: PrepCostBand.high,
      ),
      decideLater,
    ],
    many: true,
    exclusive: PrepLabels.decideOnSite,
  );

  /// 조건 다음에 받는 세부 문항. 모두 비워도 된다. 순서가 화면 순서다.
  static const List<PrepQuestion> details = [
    signboard,
    signage,
    lighting,
    facilities,
    floor,
    ceiling,
    paint,
  ];

  static const PrepQuestion needs = PrepQuestion(
    id: 'needs',
    title: '상담에서 말하고 싶은 점',
    hint: '예: 주방을 넓히고, 수납을 늘리고 싶어요',
    required: true,
    emptyMessage: '상담에서 말하고 싶은 점을 적어 주세요',
  );

  static List<String> get industryGroups => [
    for (final IndustryCategory category in industryCategories) category.name,
  ];

  static List<String> get areaRanges => [
    for (final NumericRangeOption option in areaRangeOptions) option.label,
  ];

  static List<String> get budgetRanges => [
    for (final NumericRangeOption option in budgetRangeOptions) option.label,
  ];

  static List<String> detailsOf(String? group) {
    if (group == null || group.isEmpty) return const <String>[];
    for (final IndustryCategory category in industryCategories) {
      if (category.name == group) {
        return [for (final IndustryDetail detail in category.details) detail.name];
      }
    }
    return const <String>[];
  }

  static String? groupOf(String detailName) {
    for (final IndustryCategory category in industryCategories) {
      for (final IndustryDetail detail in category.details) {
        if (detail.name == detailName) return category.name;
      }
    }
    return null;
  }
}
