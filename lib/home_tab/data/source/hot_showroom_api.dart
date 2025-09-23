import 'dart:async';
import 'package:interiorapp_flutter_client/home_tab/data/model/hot_showroom_model.dart';

/// 서버 API 연동 전까지 임시 목데이터를 반환하는 API 레이어
class HotShowroomApi {
  /// 쇼룸 슬라이더 데이터 조회 (목데이터)
  Future<List<HotShowroomModel>> getHotShowroomApiData() async {
    await Future.delayed(const Duration(milliseconds: 350));

    // 서버 응답 형태를 가정한 JSON 리스트
    final List<Map<String, dynamic>> jsonList = <Map<String, dynamic>>[
      {
        'thumbnailUrl': 'https://picsum.photos/seed/showroom1/900/600',
        'themeName': '모던 라이트',
        'userName': '신짱구',
        'userProfileUrl': 'https://i.pravatar.cc/100?img=1',
        'favoriteStatus': false,
        'likeCount': 128,
      },
      {
        'thumbnailUrl': 'https://picsum.photos/seed/showroom2/900/600',
        'themeName': '내추럴 우드',
        'userName': '봉미선',
        'userProfileUrl': 'https://i.pravatar.cc/100?img=2',
        'favoriteStatus': true,
        'likeCount': 1239,
      },
      {
        'thumbnailUrl': 'https://picsum.photos/seed/showroom3/900/600',
        'themeName': '미니멀 화이트',
        'userName': '신형만',
        'userProfileUrl': 'https://i.pravatar.cc/100?img=3',
        'favoriteStatus': true,
        'likeCount': 342,
      },
      {
        'thumbnailUrl': 'https://picsum.photos/seed/showroom3/900/600',
        'themeName': '미니멀 화이트',
        'userName': '흰둥이',
        'userProfileUrl': 'https://i.pravatar.cc/100?img=4',
        'favoriteStatus': false,
        'likeCount': 477,
      },
    ];

    return HotShowroomModel.listFromJson(jsonList);
  }
}