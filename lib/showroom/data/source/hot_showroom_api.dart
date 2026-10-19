import 'dart:async';
import 'package:interiorapp_flutter_client/showroom/data/model/hot_showroom_model.dart';

/// 서버 API 연동 전까지 임시 목데이터를 반환하는 API 레이어
class HotShowroomApi {
  // 서버 응답 형태를 가정한 JSON 리스트
  final List<Map<String, dynamic>> jsonList = <Map<String, dynamic>>[
    _item('showroom1', '01.jpg', 800 / 1280, '동탄 횟집', '모던 라이트', '신짱구', 1, false, 128),
    _item('showroom2', '02.jpg', 800 / 800, '봉담 성심당', '내추럴 우드', '봉미선', 2, true, 1239),
    _item('showroom3', '03.jpg', 800 / 1040, '인천 야간공격센터', '미니멀 화이트', '신형만', 3, true, 342),
    _item('showroom4', '04.jpg', 800 / 600, '차돈이 동탄역점', '모던 다크', '흰둥이', 4, false, 477),
    _item('showroom5', '05.jpg', 800 / 1400, '수원 북카페', '웜 베이지', '철수', 5, false, 86),
    _item('showroom6', '06.jpg', 800 / 920, '판교 와인바', '딥 그린', '유리', 6, true, 654),
    _item('showroom7', '07.jpg', 800 / 680, '강남 헤어샵', '소프트 그레이', '맹구', 7, false, 211),
    _item('showroom8', '08.jpg', 800 / 1160, '제주 게스트하우스', '린넨 화이트', '훈이', 8, false, 903),
    _item('showroom9', '09.jpg', 800 / 800, '해운대 브런치', '선셋 테라코타', '짱아', 9, true, 1580),
    _item('showroom10', '10.jpg', 800 / 1320, '성수 편집샵', '콘크리트', '나미리', 10, false, 74),
    _item('showroom11', '11.jpg', 800 / 640, '잠실 베이커리', '크림 우드', '채성아', 11, false, 266),
    _item('showroom12', '12.jpg', 800 / 1000, '홍대 레코드샵', '미드나잇', '이슬이', 12, true, 419),
    _item('showroom13', '13.jpg', 800 / 1440, '여의도 오피스', '블랙 스틸', '신영식', 13, false, 55),
    _item('showroom14', '14.jpg', 800 / 880, '광교 플라워', '세이지', '오수', 14, true, 732),
    _item('showroom15', '15.jpg', 800 / 760, '부산 횟집', '오션 블루', '김전일', 15, false, 188),
    _item('showroom16', '16.jpg', 800 / 1200, '대전 공방', '테라조', '고길동', 16, false, 97),
    _item('showroom17', '17.jpg', 800 / 720, '일산 키즈카페', '파스텔', '둘리', 17, true, 1102),
    _item('showroom18', '18.jpg', 800 / 1080, '청담 클리닉', '아이보리', '또치', 18, false, 364),
  ];

  static Map<String, dynamic> _item(
    String id,
    String fileName,
    double imageRatio,
    String title,
    String themeName,
    String userName,
    int avatar,
    bool favorite,
    int likes,
  ) {
    return {
      'id': id,
      'thumbnailUrl': 'assets/images/showroom/$fileName',
      'title': title,
      'themeName': themeName,
      'userName': userName,
      'userProfileUrl': 'https://i.pravatar.cc/100?img=$avatar',
      'favoriteStatus': favorite,
      'likeCount': likes,
      'imageRatio': imageRatio,
    };
  }

  /// 쇼룸 슬라이더 데이터 조회 (목데이터)
  Future<List<HotShowroomModel>> getHotShowroomApiData() async {
    await Future.delayed(const Duration(milliseconds: 350));

    return HotShowroomModel.listFromJson(jsonList);
  }

  Future<HotShowroomModel> updateFavoriteStatus(String id) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final idx = jsonList.indexWhere((e) => e['id'] == id);
    if (idx == -1) {
      // id가 없으면 그대로 첫 항목 반환(디버그용)
      return HotShowroomModel.fromJson(jsonList.first);
    }
    // 상태 토글을 더미 데이터에도 반영하여 일관성 유지
    final current = jsonList[idx];
    final bool currFav = (current['favoriteStatus'] == true);
    jsonList[idx] = {...current, 'favoriteStatus': !currFav};
    return HotShowroomModel.fromJson(jsonList[idx]);
  }
}
