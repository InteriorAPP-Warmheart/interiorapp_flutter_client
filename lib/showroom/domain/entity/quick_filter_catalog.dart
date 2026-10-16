import 'package:interiorapp_flutter_client/showroom/domain/entity/filter_entity.dart';

/// 쇼룸 탐색의 1차 빠른 필터.
const String industryFilterLabel = '업종';
const String areaFilterLabel = '면적';
const String budgetFilterLabel = '예산';
const String styleFilterLabel = '스타일·분위기';

const List<String> quickFilterLabels = [
  industryFilterLabel,
  areaFilterLabel,
  budgetFilterLabel,
  styleFilterLabel,
];

/// 좁은 칸에 넣는 짧은 이름. 시트 제목과 선택값은 전체 이름을 쓴다.
const Map<String, String> quickFilterShortLabels = {
  industryFilterLabel: '업종',
  areaFilterLabel: '면적',
  budgetFilterLabel: '예산',
  styleFilterLabel: '스타일',
};

/// 대분류와 세부업종을 나눠 담는 내부 키.
const String industryDetailCategoryKey = '업종_세부';
const String budgetRangeCategoryKey = '예산_구간';
const String styleMoodCategoryKey = '스타일_분위기';

/// 고객에게는 숨기고, 스타일 카드와 사례를 연결하는 내부 태그.
abstract final class AtmosphereTags {
  static const bright = 'brightness:bright';
  static const mid = 'brightness:mid';
  static const dark = 'brightness:dark';

  static const warm = 'temperature:warm';
  static const neutralTemperature = 'temperature:neutral';
  static const cool = 'temperature:cool';

  static const achromatic = 'color:achromatic';
  static const neutralColor = 'color:neutral';
  static const woodTone = 'color:wood';
  static const accent = 'color:accent';
  static const colorful = 'color:colorful';

  static const smooth = 'texture:smooth';
  static const natural = 'texture:natural';
  static const wood = 'texture:wood';
  static const stone = 'texture:stone';
  static const metal = 'texture:metal';
  static const rough = 'texture:rough';

  static const tidy = 'impression:tidy';
  static const comfortable = 'impression:comfortable';
  static const luxury = 'impression:luxury';
  static const character = 'impression:character';
  static const urban = 'impression:urban';
  static const classic = 'impression:classic';

  static const simple = 'density:simple';
  static const balanced = 'density:balanced';
  static const detailed = 'density:detailed';
}

class IndustryDetail {
  const IndustryDetail({required this.id, required this.name});

  final String id;
  final String name;
}

class IndustryCategory {
  const IndustryCategory({
    required this.id,
    required this.name,
    required this.details,
  });

  final String id;
  final String name;
  final List<IndustryDetail> details;
}

class NumericRangeOption {
  const NumericRangeOption({
    required this.id,
    required this.label,
    required this.minInclusive,
    this.maxExclusive,
  });

  final String id;
  final String label;
  final double minInclusive;
  final double? maxExclusive;

  bool contains(double value) {
    if (value < minInclusive) return false;
    final double? max = maxExclusive;
    if (max == null) return true;
    return value < max;
  }
}

class StyleMoodCard {
  const StyleMoodCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.gradientStart,
    required this.gradientEnd,
    required this.tags,
  });

  final String id;
  final String title;
  final String subtitle;
  final int gradientStart;
  final int gradientEnd;

  /// 카드 하나에 사례를 고정하지 않고, 이 태그 조합으로 사례를 찾는다.
  final List<String> tags;
}

const List<IndustryCategory> industryCategories = [
  IndustryCategory(
    id: 'fnb',
    name: '식음료',
    details: [
      IndustryDetail(id: 'fnb_cafe', name: '카페·베이커리·디저트'),
      IndustryDetail(id: 'fnb_restaurant', name: '일반음식점'),
      IndustryDetail(id: 'fnb_korean', name: '한식'),
      IndustryDetail(id: 'fnb_chinese', name: '중식'),
      IndustryDetail(id: 'fnb_japanese', name: '일식'),
      IndustryDetail(id: 'fnb_western', name: '양식'),
      IndustryDetail(id: 'fnb_grill', name: '고깃집·구이'),
      IndustryDetail(id: 'fnb_fast', name: '치킨·피자·패스트푸드'),
      IndustryDetail(id: 'fnb_bar', name: '주점·바·펍'),
      IndustryDetail(id: 'fnb_snack', name: '분식·간편식'),
      IndustryDetail(id: 'fnb_takeout', name: '테이크아웃'),
      IndustryDetail(id: 'fnb_delivery', name: '배달·포장전문'),
      IndustryDetail(id: 'fnb_deli', name: '식품판매·델리'),
    ],
  ),
  IndustryCategory(
    id: 'beauty',
    name: '뷰티·미용',
    details: [
      IndustryDetail(id: 'beauty_hair', name: '헤어샵·바버샵'),
      IndustryDetail(id: 'beauty_nail', name: '네일샵'),
      IndustryDetail(id: 'beauty_skin', name: '피부관리·에스테틱'),
      IndustryDetail(id: 'beauty_makeup', name: '메이크업·퍼스널컬러'),
      IndustryDetail(id: 'beauty_lash', name: '속눈썹·왁싱'),
      IndustryDetail(id: 'beauty_spa', name: '마사지·스파'),
      IndustryDetail(id: 'beauty_scalp', name: '두피관리'),
      IndustryDetail(id: 'beauty_complex', name: '뷰티복합매장'),
    ],
  ),
  IndustryCategory(
    id: 'medical',
    name: '의료·헬스케어',
    details: [
      IndustryDetail(id: 'medical_clinic', name: '일반의원'),
      IndustryDetail(id: 'medical_dental', name: '치과'),
      IndustryDetail(id: 'medical_oriental', name: '한의원'),
      IndustryDetail(id: 'medical_derma', name: '피부과·성형외과'),
      IndustryDetail(id: 'medical_ent', name: '안과·이비인후과'),
      IndustryDetail(id: 'medical_ortho', name: '정형외과·재활'),
      IndustryDetail(id: 'medical_checkup', name: '검진센터'),
      IndustryDetail(id: 'medical_vet', name: '동물병원'),
      IndustryDetail(id: 'medical_pharmacy', name: '약국'),
      IndustryDetail(id: 'medical_counsel', name: '상담·심리센터'),
      IndustryDetail(id: 'medical_daycare', name: '주간보호센터'),
    ],
  ),
  IndustryCategory(
    id: 'education',
    name: '교육·학원',
    details: [
      IndustryDetail(id: 'edu_exam', name: '입시·보습'),
      IndustryDetail(id: 'edu_language', name: '어학'),
      IndustryDetail(id: 'edu_kids', name: '유아·아동'),
      IndustryDetail(id: 'edu_art', name: '미술·음악·예체능'),
      IndustryDetail(id: 'edu_coding', name: '컴퓨터·코딩·직업교육'),
      IndustryDetail(id: 'edu_study', name: '독서실·스터디카페'),
      IndustryDetail(id: 'edu_class', name: '교습소·소규모 클래스'),
      IndustryDetail(id: 'edu_complex', name: '교육복합공간'),
    ],
  ),
  IndustryCategory(
    id: 'office',
    name: '사무·업무공간',
    details: [
      IndustryDetail(id: 'office_general', name: '일반 사무실'),
      IndustryDetail(id: 'office_startup', name: '스타트업·IT 오피스'),
      IndustryDetail(id: 'office_professional', name: '전문직 사무실'),
      IndustryDetail(id: 'office_shared', name: '공유오피스'),
      IndustryDetail(id: 'office_meeting', name: '회의·교육센터'),
      IndustryDetail(id: 'office_lounge', name: '기업라운지'),
      IndustryDetail(id: 'office_hq', name: '본사·지사'),
      IndustryDetail(id: 'office_private', name: '개인오피스'),
    ],
  ),
  IndustryCategory(
    id: 'retail',
    name: '판매·리테일',
    details: [
      IndustryDetail(id: 'retail_fashion', name: '패션·의류'),
      IndustryDetail(id: 'retail_lifestyle', name: '잡화·라이프스타일'),
      IndustryDetail(id: 'retail_cosmetics', name: '화장품'),
      IndustryDetail(id: 'retail_eyewear', name: '안경·렌즈'),
      IndustryDetail(id: 'retail_electronics', name: '전자기기'),
      IndustryDetail(id: 'retail_furniture', name: '가구·인테리어소품'),
      IndustryDetail(id: 'retail_flower', name: '꽃·식물'),
      IndustryDetail(id: 'retail_book', name: '서점·문구'),
      IndustryDetail(id: 'retail_select', name: '편집숍'),
      IndustryDetail(id: 'retail_grocery', name: '식품·마트·전문판매'),
      IndustryDetail(id: 'retail_showroom', name: '브랜드쇼룸'),
      IndustryDetail(id: 'retail_popup', name: '팝업스토어'),
    ],
  ),
  IndustryCategory(
    id: 'fitness',
    name: '운동·피트니스',
    details: [
      IndustryDetail(id: 'fitness_gym', name: '헬스장'),
      IndustryDetail(id: 'fitness_pt', name: 'PT'),
      IndustryDetail(id: 'fitness_pilates', name: '필라테스'),
      IndustryDetail(id: 'fitness_yoga', name: '요가'),
      IndustryDetail(id: 'fitness_golf', name: '골프연습장'),
      IndustryDetail(id: 'fitness_screen', name: '스크린골프'),
      IndustryDetail(id: 'fitness_boxing', name: '복싱·격투기'),
      IndustryDetail(id: 'fitness_dance', name: '댄스'),
      IndustryDetail(id: 'fitness_rehab', name: '재활·체형교정'),
      IndustryDetail(id: 'fitness_etc', name: '기타 운동시설'),
    ],
  ),
  IndustryCategory(
    id: 'culture',
    name: '문화·취미·콘텐츠',
    details: [
      IndustryDetail(id: 'culture_photo', name: '사진관·스튜디오'),
      IndustryDetail(id: 'culture_video', name: '영상·촬영스튜디오'),
      IndustryDetail(id: 'culture_workshop', name: '공방'),
      IndustryDetail(id: 'culture_gallery', name: '갤러리·전시'),
      IndustryDetail(id: 'culture_stage', name: '공연·연습실'),
      IndustryDetail(id: 'culture_karaoke', name: '노래연습장'),
      IndustryDetail(id: 'culture_pc', name: 'PC방·게임공간'),
      IndustryDetail(id: 'culture_board', name: '보드게임·취미공간'),
      IndustryDetail(id: 'culture_comic', name: '만화카페·북카페'),
    ],
  ),
  IndustryCategory(
    id: 'stay',
    name: '숙박·여가',
    details: [
      IndustryDetail(id: 'stay_hotel', name: '호텔'),
      IndustryDetail(id: 'stay_motel', name: '모텔'),
      IndustryDetail(id: 'stay_guest', name: '게스트하우스'),
      IndustryDetail(id: 'stay_pension', name: '펜션'),
      IndustryDetail(id: 'stay_shared', name: '숙박형 공유공간'),
      IndustryDetail(id: 'stay_party', name: '파티룸'),
      IndustryDetail(id: 'stay_kids', name: '키즈카페'),
      IndustryDetail(id: 'stay_play', name: '실내놀이터'),
      IndustryDetail(id: 'stay_pet', name: '반려동물 카페·놀이터'),
    ],
  ),
  IndustryCategory(
    id: 'life',
    name: '생활서비스',
    details: [
      IndustryDetail(id: 'life_laundry', name: '세탁소·빨래방'),
      IndustryDetail(id: 'life_repair', name: '수선·리페어'),
      IndustryDetail(id: 'life_carwash', name: '세차·디테일링'),
      IndustryDetail(id: 'life_auto', name: '자동차관련매장'),
      IndustryDetail(id: 'life_realty', name: '부동산'),
      IndustryDetail(id: 'life_travel', name: '여행사'),
      IndustryDetail(id: 'life_finance', name: '보험·금융상담'),
      IndustryDetail(id: 'life_telecom', name: '통신대리점'),
      IndustryDetail(id: 'life_parcel', name: '택배·물류접점'),
      IndustryDetail(id: 'life_wedding', name: '웨딩·행사상담'),
    ],
  ),
  IndustryCategory(
    id: 'professional',
    name: '전문서비스·공공·복지',
    details: [
      IndustryDetail(id: 'pro_legal', name: '법률·세무·회계'),
      IndustryDetail(id: 'pro_design', name: '건축·디자인·컨설팅'),
      IndustryDetail(id: 'pro_religion', name: '종교시설'),
      IndustryDetail(id: 'pro_welfare', name: '복지시설'),
      IndustryDetail(id: 'pro_care', name: '요양·돌봄'),
      IndustryDetail(id: 'pro_nonprofit', name: '비영리·협회'),
      IndustryDetail(id: 'pro_public', name: '공공서비스공간'),
      IndustryDetail(id: 'pro_community', name: '커뮤니티공간'),
    ],
  ),
  IndustryCategory(
    id: 'production',
    name: '생산·작업·특수공간',
    details: [
      IndustryDetail(id: 'prod_manufacture', name: '소규모제조·공방'),
      IndustryDetail(id: 'prod_kitchen', name: '식품제조·주방'),
      IndustryDetail(id: 'prod_studio', name: '작업실'),
      IndustryDetail(id: 'prod_warehouse', name: '창고·물류'),
      IndustryDetail(id: 'prod_lab', name: '연구실·랩'),
      IndustryDetail(id: 'prod_repair', name: '정비·수리'),
      IndustryDetail(id: 'prod_special', name: '기타 특수상업시설'),
    ],
  ),
  IndustryCategory(
    id: 'mixed',
    name: '복합공간·기타',
    details: [
      IndustryDetail(id: 'mixed_multi', name: '복합업종'),
      IndustryDetail(id: 'mixed_other', name: '기타 상업공간'),
    ],
  ),
];

const List<NumericRangeOption> areaRangeOptions = [
  NumericRangeOption(
    id: 'area_under_10',
    label: '10평 미만',
    minInclusive: 0,
    maxExclusive: 10,
  ),
  NumericRangeOption(
    id: 'area_10_20',
    label: '10~20평',
    minInclusive: 10,
    maxExclusive: 20,
  ),
  NumericRangeOption(
    id: 'area_20_30',
    label: '20~30평',
    minInclusive: 20,
    maxExclusive: 30,
  ),
  NumericRangeOption(
    id: 'area_30_50',
    label: '30~50평',
    minInclusive: 30,
    maxExclusive: 50,
  ),
  NumericRangeOption(
    id: 'area_50_100',
    label: '50~100평',
    minInclusive: 50,
    maxExclusive: 100,
  ),
  NumericRangeOption(id: 'area_over_100', label: '100평 이상', minInclusive: 100),
];

const List<NumericRangeOption> budgetRangeOptions = [
  NumericRangeOption(
    id: 'budget_under_30m',
    label: '3천만 원 미만',
    minInclusive: 0,
    maxExclusive: 30000000,
  ),
  NumericRangeOption(
    id: 'budget_30_50m',
    label: '3천만~5천만 원',
    minInclusive: 30000000,
    maxExclusive: 50000000,
  ),
  NumericRangeOption(
    id: 'budget_50_100m',
    label: '5천만~1억 원',
    minInclusive: 50000000,
    maxExclusive: 100000000,
  ),
  NumericRangeOption(
    id: 'budget_100_200m',
    label: '1억~2억 원',
    minInclusive: 100000000,
    maxExclusive: 200000000,
  ),
  NumericRangeOption(
    id: 'budget_over_200m',
    label: '2억 원 이상',
    minInclusive: 200000000,
  ),
];

const List<StyleMoodCard> styleMoodCards = [
  StyleMoodCard(
    id: 'mood_bright_tidy',
    title: '밝고 정돈된',
    subtitle: '화이트·뉴트럴 / 깔끔한 선',
    gradientStart: 0xFFF7F4EF,
    gradientEnd: 0xFFE6E0D8,
    tags: [
      AtmosphereTags.bright,
      AtmosphereTags.neutralTemperature,
      AtmosphereTags.achromatic,
      AtmosphereTags.smooth,
      AtmosphereTags.tidy,
      AtmosphereTags.simple,
    ],
  ),
  StyleMoodCard(
    id: 'mood_warm_natural',
    title: '따뜻하고 자연스러운',
    subtitle: '우드·베이지 / 자연 질감',
    gradientStart: 0xFFF3E6D4,
    gradientEnd: 0xFFC4A078,
    tags: [
      AtmosphereTags.mid,
      AtmosphereTags.warm,
      AtmosphereTags.woodTone,
      AtmosphereTags.natural,
      AtmosphereTags.wood,
      AtmosphereTags.comfortable,
    ],
  ),
  StyleMoodCard(
    id: 'mood_calm_luxury',
    title: '차분하고 고급스러운',
    subtitle: '딥톤·스톤 / 절제된 디테일',
    gradientStart: 0xFF5C574F,
    gradientEnd: 0xFF2F2C28,
    tags: [
      AtmosphereTags.dark,
      AtmosphereTags.neutralTemperature,
      AtmosphereTags.stone,
      AtmosphereTags.luxury,
      AtmosphereTags.balanced,
    ],
  ),
  StyleMoodCard(
    id: 'mood_vivid',
    title: '선명하고 개성 있는',
    subtitle: '컬러포인트 / 강한 포인트 요소',
    gradientStart: 0xFFF8E4D4,
    gradientEnd: 0xFFD4654A,
    tags: [
      AtmosphereTags.bright,
      AtmosphereTags.warm,
      AtmosphereTags.accent,
      AtmosphereTags.character,
      AtmosphereTags.detailed,
    ],
  ),
  StyleMoodCard(
    id: 'mood_urban',
    title: '묵직하고 도시적인',
    subtitle: '다크톤·메탈 / 거친 질감',
    gradientStart: 0xFF4A4A4A,
    gradientEnd: 0xFF1A1A1A,
    tags: [
      AtmosphereTags.dark,
      AtmosphereTags.cool,
      AtmosphereTags.achromatic,
      AtmosphereTags.metal,
      AtmosphereTags.rough,
      AtmosphereTags.urban,
    ],
  ),
  StyleMoodCard(
    id: 'mood_soft',
    title: '부드럽고 감성적인',
    subtitle: '밝은 우드·파스텔 / 곡선·부드러운 질감',
    gradientStart: 0xFFF8EDE8,
    gradientEnd: 0xFFE4C6C0,
    tags: [
      AtmosphereTags.bright,
      AtmosphereTags.warm,
      AtmosphereTags.woodTone,
      AtmosphereTags.comfortable,
      AtmosphereTags.balanced,
    ],
  ),
  StyleMoodCard(
    id: 'mood_practical',
    title: '깔끔하고 실용적인',
    subtitle: '중성톤 / 단순한 구성·관리 편의',
    gradientStart: 0xFFF3F3EF,
    gradientEnd: 0xFFD5D5CE,
    tags: [
      AtmosphereTags.mid,
      AtmosphereTags.neutralTemperature,
      AtmosphereTags.neutralColor,
      AtmosphereTags.smooth,
      AtmosphereTags.simple,
      AtmosphereTags.balanced,
    ],
  ),
  StyleMoodCard(
    id: 'mood_classic',
    title: '클래식하고 깊이 있는',
    subtitle: '짙은 우드·장식 / 디테일 강조',
    gradientStart: 0xFF8A6852,
    gradientEnd: 0xFF3E2A22,
    tags: [
      AtmosphereTags.mid,
      AtmosphereTags.warm,
      AtmosphereTags.woodTone,
      AtmosphereTags.wood,
      AtmosphereTags.classic,
      AtmosphereTags.detailed,
    ],
  ),
];

Map<String, List<FilterItem>> browseFilterItems() {
  return {
    industryFilterLabel: [
      for (final IndustryCategory category in industryCategories)
        FilterItem(id: category.id, name: category.name),
    ],
    industryDetailCategoryKey: [
      for (final IndustryCategory category in industryCategories)
        for (final IndustryDetail detail in category.details)
          FilterItem(id: detail.id, name: detail.name, parentId: category.id),
    ],
    areaFilterLabel: [
      for (final NumericRangeOption option in areaRangeOptions)
        FilterItem(id: option.id, name: option.label),
    ],
    budgetRangeCategoryKey: [
      for (final NumericRangeOption option in budgetRangeOptions)
        FilterItem(id: option.id, name: option.label),
    ],
    styleMoodCategoryKey: [
      for (final StyleMoodCard card in styleMoodCards)
        FilterItem(id: card.id, name: card.title),
    ],
  };
}

String? parentIndustryId(String detailId) {
  for (final IndustryCategory category in industryCategories) {
    for (final IndustryDetail detail in category.details) {
      if (detail.id == detailId) return category.id;
    }
  }
  return null;
}

/// 세부업종이 있으면 그 업종만, 없으면 대분류 전체를 본다.
List<String> effectiveIndustryIds(Iterable<String> selectedIds) {
  final Set<String> selected = selectedIds.toSet();
  final List<String> effective = [];

  for (final IndustryCategory category in industryCategories) {
    final List<String> details = [
      for (final IndustryDetail detail in category.details)
        if (selected.contains(detail.id)) detail.id,
    ];
    if (details.isNotEmpty) {
      effective.addAll(details);
      continue;
    }
    if (selected.contains(category.id)) {
      effective.add(category.id);
    }
  }

  return effective;
}

bool matchesAnyRange(
  double value,
  Iterable<String> selectedIds,
  List<NumericRangeOption> options,
) {
  final Set<String> selected = selectedIds.toSet();
  for (final NumericRangeOption option in options) {
    if (selected.contains(option.id) && option.contains(value)) {
      return true;
    }
  }
  return false;
}

StyleMoodCard? styleMoodById(String id) {
  for (final StyleMoodCard card in styleMoodCards) {
    if (card.id == id) return card;
  }
  return null;
}

bool matchesStyleMood(
  List<String> atmosphereTags,
  Iterable<String> selectedCardIds,
) {
  for (final String cardId in selectedCardIds) {
    final StyleMoodCard? card = styleMoodById(cardId);
    if (card == null) continue;
    var overlap = 0;
    for (final String tag in card.tags) {
      if (atmosphereTags.contains(tag)) overlap++;
    }
    if (overlap >= 2) return true;
  }
  return false;
}
