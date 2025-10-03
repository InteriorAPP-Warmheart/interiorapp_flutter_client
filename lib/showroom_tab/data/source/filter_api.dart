import 'dart:async';
import 'package:interiorapp_flutter_client/showroom_tab/data/model/filter_showroom_model.dart';

class FilteredShowroomApi {
  // 서버 응답 형태를 가정한 JSON 리스트 (목데이터)
  final List<Map<String, dynamic>> jsonList = <Map<String, dynamic>>[
    {
      'id': 'showroom1',
      'thumbnailUrl': 'https://picsum.photos/seed/showroom1/900/600',
      'themeName': '따뜻한 북유럽 스타일 거실',
      'userName': '디자이너 수',
      'userProfileUrl': 'https://i.pravatar.cc/150?img=1',
      'favoriteStatus': true,
      'likeCount': 245,
      'budget': 8500000, 
      'tags': ['northern', 'apartment', 'living_room', 'white', 'wood'],
    },
    {
      'id': 'showroom2',
      'thumbnailUrl': 'https://picsum.photos/seed/showroom2/900/600',
      'themeName': '모던',
      'userName': '인테리어 박',
      'userProfileUrl': 'https://i.pravatar.cc/150?img=2',
      'favoriteStatus': false,
      'likeCount': 189,
      'budget': 12000000, 
      'tags': ['minimal', 'modern', 'apartment', 'bedroom', 'white', 'tile'],
    },
    {
      'id': 'showroom3',
      'thumbnailUrl': 'https://picsum.photos/seed/showroom3/900/600',
      'themeName': '빈티지 감성 카페 인테리어',
      'userName': '스튜디오 이현',
      'userProfileUrl': 'https://i.pravatar.cc/150?img=3',
      'favoriteStatus': true,
      'likeCount': 512,
      'budget': 25000000, 
      'tags': ['vintage', 'restaurant', 'store_hall', 'brown', 'wood', 'lighting'],
    },
    {
      'id': 'showroom4',
      'thumbnailUrl': 'https://picsum.photos/seed/showroom4/900/600',
      'themeName': '인더스트리얼 오피스 공간',
      'userName': '공간연구소',
      'userProfileUrl': 'https://i.pravatar.cc/150?img=4',
      'favoriteStatus': false,
      'likeCount': 324,
      'budget': 18000000, 
      'tags': ['industrial', 'office', 'work_space', 'gray', 'black', 'steel_floor'],
    },
    {
      'id': 'showroom5',
      'thumbnailUrl': 'https://picsum.photos/seed/showroom5/900/600',
      'themeName': '내추럴 원룸 인테리어',
      'userName': '홈스타일링최',
      'userProfileUrl': 'https://i.pravatar.cc/150?img=5',
      'favoriteStatus': true,
      'likeCount': 167,
      'budget': 4500000, 
      'tags': ['natural', 'one_room', 'living_room', 'green', 'wood', 'wallpaper'],
    },
    {
      'id': 'showroom6',
      'thumbnailUrl': 'https://picsum.photos/seed/showroom6/900/600',
      'themeName': '클래식 침실 디자인',
      'userName': '럭셔리홈',
      'userProfileUrl': 'https://i.pravatar.cc/150?img=6',
      'favoriteStatus': false,
      'likeCount': 431,
      'budget': 15000000, 
      'tags': ['classic', 'villa', 'bathroom', 'white', 'brown', 'lighting'],
    },
    {
      'id': 'showroom7',
      'thumbnailUrl': 'https://picsum.photos/seed/showroom7/900/600',
      'themeName': '모던 아파트 거실',
      'userName': '디자인하우스',
      'userProfileUrl': 'https://i.pravatar.cc/150?img=7',
      'favoriteStatus': true,
      'likeCount': 298,
      'budget': 9800000, 
      'tags': ['modern', 'apartment', 'living_room', 'gray', 'tile', 'lighting'],
    },
    {
      'id': 'showroom8',
      'thumbnailUrl': 'https://picsum.photos/seed/showroom8/900/600',
      'themeName': '호텔 스타일 침실',
      'userName': '프리미엄 인테리어',
      'userProfileUrl': 'https://i.pravatar.cc/150?img=8',
      'favoriteStatus': false,
      'likeCount': 678,
      'budget': 22000000,
      'tags': ['hotel', 'apartment', 'bathroom', 'white', 'gray', 'paint'],
    },
    {
      'id': 'showroom9',
      'thumbnailUrl': 'https://picsum.photos/seed/showroom9/900/600',
      'themeName': '컬러포인트 키즈룸',
      'userName': '키즈공간연구소',
      'userProfileUrl': 'https://i.pravatar.cc/150?img=9',
      'favoriteStatus': true,
      'likeCount': 234,
      'budget': 6500000, 
      'tags': ['colorpoint', 'apartment', 'kids_room', 'yellow', 'blue', 'wallpaper'],
    },
    {
      'id': 'showroom10',
      'thumbnailUrl': 'https://picsum.photos/seed/showroom10/900/600',
      'themeName': '아트월 거실 디자인',
      'userName': '아트인테리어',
      'userProfileUrl': 'https://i.pravatar.cc/150?img=10',
      'favoriteStatus': false,
      'likeCount': 389,
      'budget': 11000000, 
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
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // 필터가 하나도 없으면 전체 목록 반환
    if ((styles == null || styles.isEmpty) &&
        (spaceTypes == null || spaceTypes.isEmpty) &&
        (minBudget == null && maxBudget == null) &&
        (tones == null || tones.isEmpty) &&
        (materials == null || materials.isEmpty)) {
      return FilteredShowroomModel.listFromJson(jsonList);
    }

    // 필터링 로직
    final filteredList = jsonList.where((item) {
      final tags = List<String>.from(item['tags'] as List);
      final budget = (item['budget'] as num?)?.toDouble() ?? 0.0;

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
    jsonList[idx] = {
      ...current,
      'favoriteStatus': !currFav,
    };
    return FilteredShowroomModel.fromJson(jsonList[idx]);
  }
}