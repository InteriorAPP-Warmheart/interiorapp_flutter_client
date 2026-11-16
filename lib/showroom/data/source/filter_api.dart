import 'dart:async';
import 'package:interiorapp_flutter_client/showroom/data/model/filter_showroom_model.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/quick_filter_catalog.dart';

class FilteredShowroomApi {
  // 서버 응답 형태를 가정한 JSON 리스트 (목데이터)
  final List<Map<String, dynamic>> jsonList = <Map<String, dynamic>>[
    {
      'id': 'showroom-warmheart',
      'thumbnailUrl': 'assets/images/showroom_real/wh/wh_01.webp',
      'imageRatio': 2048 / 1365,
      'title': '동탄 웜하트사무실',
      'themeName': '깔끔하고 실용적인',
      'userName': '웜하트',
      'userProfileUrl': 'https://i.pravatar.cc/100?img=12',
      'favoriteStatus': false,
      'likeCount': 32,
      'commentCount': 4,
      'viewCount': 560,
      'publishedAt': '2026-11-16',
      'budget': 20000000,
      'areaPyeong': 22,
      'industryIds': <String>['office', 'office_professional'],
      'atmosphereTags': <String>[
        'brightness:mid',
        'temperature:neutral',
        'color:neutral',
        'texture:smooth',
        'density:simple',
        'density:balanced',
      ],
      'tags': <String>['office', 'white', 'practical'],
    },
    {
      'id': 'showroom-ddonga',
      'thumbnailUrl': 'assets/images/showroom_real/ddonga/ddonga_main05.webp',
      'imageRatio': 2048 / 1365,
      'title': '남한강 뚱아농장',
      'themeName': '따뜻하고 자연스러운',
      'userName': '뚱아농장',
      'userProfileUrl': 'https://i.pravatar.cc/100?img=32',
      'favoriteStatus': false,
      'likeCount': 48,
      'commentCount': 4,
      'viewCount': 560,
      'publishedAt': '2026-11-10',
      'budget': 140000000,
      'areaPyeong': 70,
      'industryIds': <String>['fnb', 'fnb_cafe'],
      'atmosphereTags': <String>[
        'brightness:mid',
        'temperature:warm',
        'color:wood',
        'texture:natural',
        'texture:wood',
        'impression:comfortable',
      ],
      'tags': <String>['cafe', 'wood', 'warm'],
    },
    {
      'id': 'showroom1',
      'thumbnailUrl': 'assets/images/showroom/01.jpg',
      'imageRatio': 800 / 1280,
      'title': '북유럽 거실의 오후',
      'themeName': '따뜻한 북유럽 스타일 거실',
      'userName': '디자이너 수',
      'userProfileUrl': 'https://i.pravatar.cc/150?img=1',
      'favoriteStatus': true,
      'likeCount': 245,
      'commentCount': 27,
      'viewCount': 3780,
      'budget': 8500000,
      'areaPyeong': 22,
      'industryIds': <String>[],
      'atmosphereTags': [
        'brightness:bright',
        'temperature:neutral',
        'color:achromatic',
        'texture:smooth',
        'impression:tidy',
        'density:simple',
      ],
      'tags': ['northern', 'apartment', 'living_room', 'white', 'wood'],
    },
    {
      'id': 'showroom2',
      'thumbnailUrl': 'assets/images/showroom/02.jpg',
      'imageRatio': 800 / 800,
      'title': '선을 줄인 침실',
      'themeName': '모던',
      'userName': '인테리어 박',
      'userProfileUrl': 'https://i.pravatar.cc/150?img=2',
      'favoriteStatus': false,
      'likeCount': 189,
      'commentCount': 21,
      'viewCount': 2940,
      'budget': 12000000,
      'areaPyeong': 14,
      'industryIds': <String>[],
      'atmosphereTags': [
        'brightness:mid',
        'temperature:neutral',
        'color:neutral',
        'texture:smooth',
        'density:simple',
        'density:balanced',
      ],
      'tags': ['minimal', 'modern', 'apartment', 'bedroom', 'white', 'tile'],
    },
    {
      'id': 'showroom3',
      'thumbnailUrl': 'assets/images/showroom/03.jpg',
      'imageRatio': 800 / 1040,
      'title': '골목 안 작은 카페',
      'themeName': '빈티지 감성 카페 인테리어',
      'userName': '스튜디오 이현',
      'userProfileUrl': 'https://i.pravatar.cc/150?img=3',
      'favoriteStatus': true,
      'likeCount': 512,
      'commentCount': 57,
      'viewCount': 7980,
      'budget': 25000000,
      'areaPyeong': 16,
      'industryIds': ['fnb', 'fnb_cafe'],
      'atmosphereTags': [
        'brightness:mid',
        'temperature:warm',
        'color:wood',
        'texture:natural',
        'texture:wood',
        'impression:comfortable',
      ],
      'tags': [
        'vintage',
        'restaurant',
        'store_hall',
        'brown',
        'wood',
        'lighting',
      ],
    },
    {
      'id': 'showroom4',
      'thumbnailUrl': 'assets/images/showroom/04.jpg',
      'imageRatio': 800 / 600,
      'title': '철과 콘크리트의 사무실',
      'themeName': '인더스트리얼 오피스 공간',
      'userName': '공간연구소',
      'userProfileUrl': 'https://i.pravatar.cc/150?img=4',
      'favoriteStatus': false,
      'likeCount': 324,
      'commentCount': 36,
      'viewCount': 5040,
      'budget': 42000000,
      'areaPyeong': 35,
      'industryIds': ['office', 'office_general'],
      'atmosphereTags': [
        'brightness:dark',
        'temperature:cool',
        'color:achromatic',
        'texture:metal',
        'texture:rough',
        'impression:urban',
      ],
      'tags': [
        'industrial',
        'office',
        'work_space',
        'gray',
        'black',
        'steel_floor',
      ],
    },
    {
      'id': 'showroom5',
      'thumbnailUrl': 'assets/images/showroom/05.jpg',
      'imageRatio': 800 / 1400,
      'title': '창가에 둔 원룸',
      'themeName': '내추럴 원룸 인테리어',
      'userName': '홈스타일링최',
      'userProfileUrl': 'https://i.pravatar.cc/150?img=5',
      'favoriteStatus': true,
      'likeCount': 167,
      'commentCount': 19,
      'viewCount': 2660,
      'budget': 4500000,
      'areaPyeong': 7,
      'industryIds': <String>[],
      'atmosphereTags': [
        'brightness:bright',
        'temperature:warm',
        'color:wood',
        'texture:natural',
        'impression:comfortable',
      ],
      'tags': [
        'natural',
        'one_room',
        'living_room',
        'green',
        'wood',
        'wallpaper',
      ],
    },
    {
      'id': 'showroom6',
      'thumbnailUrl': 'assets/images/showroom/06.jpg',
      'imageRatio': 800 / 920,
      'title': '클래식한 침실',
      'themeName': '클래식 침실 디자인',
      'userName': '럭셔리홈',
      'userProfileUrl': 'https://i.pravatar.cc/150?img=6',
      'favoriteStatus': false,
      'likeCount': 431,
      'commentCount': 48,
      'viewCount': 6720,
      'budget': 15000000,
      'areaPyeong': 26,
      'industryIds': <String>[],
      'atmosphereTags': [
        'brightness:mid',
        'temperature:warm',
        'color:wood',
        'texture:wood',
        'impression:classic',
        'density:detailed',
      ],
      'tags': ['classic', 'villa', 'bathroom', 'white', 'brown', 'lighting'],
    },
    {
      'id': 'showroom7',
      'thumbnailUrl': 'assets/images/showroom/07.jpg',
      'imageRatio': 800 / 680,
      'title': '모던 아파트의 거실',
      'themeName': '모던 아파트 거실',
      'userName': '디자인하우스',
      'userProfileUrl': 'https://i.pravatar.cc/150?img=7',
      'favoriteStatus': true,
      'likeCount': 298,
      'commentCount': 33,
      'viewCount': 4620,
      'budget': 9800000,
      'areaPyeong': 24,
      'industryIds': <String>[],
      'atmosphereTags': [
        'brightness:bright',
        'temperature:neutral',
        'color:achromatic',
        'texture:smooth',
        'impression:tidy',
      ],
      'tags': [
        'modern',
        'apartment',
        'living_room',
        'gray',
        'tile',
        'lighting',
      ],
    },
    {
      'id': 'showroom8',
      'thumbnailUrl': 'assets/images/showroom/08.jpg',
      'imageRatio': 800 / 1160,
      'title': '호텔처럼 머무는 밤',
      'themeName': '호텔 스타일 침실',
      'userName': '프리미엄 인테리어',
      'userProfileUrl': 'https://i.pravatar.cc/150?img=8',
      'favoriteStatus': false,
      'likeCount': 678,
      'commentCount': 75,
      'viewCount': 10500,
      'budget': 78000000,
      'areaPyeong': 62,
      'industryIds': ['stay', 'stay_hotel'],
      'atmosphereTags': [
        'brightness:dark',
        'temperature:neutral',
        'texture:stone',
        'impression:luxury',
        'density:balanced',
      ],
      'tags': ['hotel', 'apartment', 'bathroom', 'white', 'gray', 'paint'],
    },
    {
      'id': 'showroom9',
      'thumbnailUrl': 'assets/images/showroom/09.jpg',
      'imageRatio': 800 / 800,
      'title': '색이 있는 아이 방',
      'themeName': '컬러포인트 키즈룸',
      'userName': '키즈공간연구소',
      'userProfileUrl': 'https://i.pravatar.cc/150?img=9',
      'favoriteStatus': true,
      'likeCount': 234,
      'commentCount': 26,
      'viewCount': 3640,
      'budget': 6500000,
      'areaPyeong': 8,
      'industryIds': <String>[],
      'atmosphereTags': [
        'brightness:bright',
        'temperature:warm',
        'color:accent',
        'impression:character',
        'density:detailed',
        'color:colorful',
      ],
      'tags': [
        'colorpoint',
        'apartment',
        'kids_room',
        'yellow',
        'blue',
        'wallpaper',
      ],
    },
    {
      'id': 'showroom10',
      'thumbnailUrl': 'assets/images/showroom/10.jpg',
      'imageRatio': 800 / 1320,
      'title': '벽이 작품인 거실',
      'themeName': '아트월 거실 디자인',
      'userName': '아트인테리어',
      'userProfileUrl': 'https://i.pravatar.cc/150?img=10',
      'favoriteStatus': false,
      'likeCount': 389,
      'commentCount': 43,
      'viewCount': 6020,
      'budget': 11000000,
      'areaPyeong': 20,
      'industryIds': ['culture', 'culture_gallery'],
      'atmosphereTags': [
        'brightness:mid',
        'temperature:warm',
        'color:wood',
        'texture:wood',
        'impression:classic',
        'density:detailed',
      ],
      'tags': ['artwall', 'villa', 'living_room', 'white', 'black', 'paint'],
    },
  ];

  Future<List<FilteredShowroomModel>> getFilteredShowrooms({
    List<String>? styles,
    List<String>? spaceTypes,
    double? minBudget,
    double? maxBudget,
    List<String>? tones,
    List<String>? materials,
    List<String>? industryIds,
    List<String>? areaRangeIds,
    List<String>? budgetRangeIds,
    List<String>? styleMoodIds,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final bool hasQuickFilter =
        (industryIds != null && industryIds.isNotEmpty) ||
        (areaRangeIds != null && areaRangeIds.isNotEmpty) ||
        (budgetRangeIds != null && budgetRangeIds.isNotEmpty) ||
        (styleMoodIds != null && styleMoodIds.isNotEmpty);

    // 필터가 하나도 없으면 전체 목록 반환
    if ((styles == null || styles.isEmpty) &&
        (spaceTypes == null || spaceTypes.isEmpty) &&
        (minBudget == null && maxBudget == null) &&
        (tones == null || tones.isEmpty) &&
        (materials == null || materials.isEmpty) &&
        !hasQuickFilter) {
      return FilteredShowroomModel.listFromJson(jsonList);
    }

    final List<String> effectiveIndustries =
        industryIds == null ? const [] : effectiveIndustryIds(industryIds);

    // 필터링 로직
    final filteredList =
        jsonList.where((item) {
          final tags = List<String>.from(item['tags'] as List);
          final budget = (item['budget'] as num?)?.toDouble() ?? 0.0;
          final area = (item['areaPyeong'] as num?)?.toDouble();
          final itemIndustries = List<String>.from(
            (item['industryIds'] as List?) ?? const [],
          );
          final atmosphereTags = List<String>.from(
            (item['atmosphereTags'] as List?) ?? const [],
          );

          // 스타일 필터
          if (styles != null && styles.isNotEmpty) {
            if (!tags.any((tag) => styles.contains(tag))) {
              return false;
            }
          }

          // 공간 형태 필터 (공간 타입 + 세부 공간 모두 포함)
          if (spaceTypes != null && spaceTypes.isNotEmpty) {
            if (!tags.any((tag) => spaceTypes.contains(tag))) {
              return false;
            }
          }

          // 예산 필터
          if (minBudget != null && budget < minBudget) {
            return false;
          }
          if (maxBudget != null && budget > maxBudget) {
            return false;
          }

          // 톤앤매너 필터
          if (tones != null && tones.isNotEmpty) {
            if (!tags.any((tag) => tones.contains(tag))) {
              return false;
            }
          }

          // 소재 필터
          if (materials != null && materials.isNotEmpty) {
            if (!tags.any((tag) => materials.contains(tag))) {
              return false;
            }
          }

          if (effectiveIndustries.isNotEmpty &&
              !itemIndustries.any(effectiveIndustries.contains)) {
            return false;
          }

          if (areaRangeIds != null && areaRangeIds.isNotEmpty) {
            if (area == null ||
                !matchesAnyRange(area, areaRangeIds, areaRangeOptions)) {
              return false;
            }
          }

          if (budgetRangeIds != null && budgetRangeIds.isNotEmpty) {
            if (!matchesAnyRange(budget, budgetRangeIds, budgetRangeOptions)) {
              return false;
            }
          }

          if (styleMoodIds != null &&
              styleMoodIds.isNotEmpty &&
              !matchesStyleMood(atmosphereTags, styleMoodIds)) {
            return false;
          }
          return true;
        }).toList();

    return FilteredShowroomModel.listFromJson(filteredList);
  }

  Future<FilteredShowroomModel> updateFavoriteStatus(String id) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final idx = jsonList.indexWhere((e) => e['id'] == id);
    if (idx == -1) {
      return FilteredShowroomModel.fromJson(jsonList.first);
    }
    final current = jsonList[idx];
    final bool currFav = (current['favoriteStatus'] == true);
    jsonList[idx] = {...current, 'favoriteStatus': !currFav};
    return FilteredShowroomModel.fromJson(jsonList[idx]);
  }
}
