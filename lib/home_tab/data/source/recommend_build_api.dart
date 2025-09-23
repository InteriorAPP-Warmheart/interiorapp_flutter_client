import 'dart:async';
import 'package:interiorapp_flutter_client/home_tab/data/model/recommend_build_model.dart';

class RecommendBuildApi {


      // 서버 응답 형태를 가정한 JSON 리스트 (목데이터)
    final List<Map<String, dynamic>> jsonList = <Map<String, dynamic>>[
      {
        'id': 'case1',
        'thumbnailUrl': 'https://picsum.photos/seed/case1/900/600',
        'companyName': '바론 인테리어',
        'buildAddress': '서울 마포구 합정동',
        'buildPeriod': 23,
        'buildCost': 12000000,
        'favoriteStatus': true,
        'rating': 4.7,
      },
      {
        'id': 'case2',
        'thumbnailUrl': 'https://picsum.photos/seed/case2/900/600',
        'companyName': '소담 하우징',
        'buildAddress': '경기 성남시 분당구',
        'buildPeriod': 48,
        'buildCost': 18500000,
        'favoriteStatus': false,
        'rating': 4.3,
      },
      {
        'id': 'case3',
        'thumbnailUrl': 'https://picsum.photos/seed/case3/900/600',
        'companyName': '무드디자인',
        'buildAddress': '서울 강남구 역삼동',
        'buildPeriod': 415,
        'buildCost': 8900000,
        'favoriteStatus': false,
        'rating': 4.9,
      },
    ];



  Future<List<RecommendBuildModel>> getRecommendBuildApiData() async {
    await Future.delayed(const Duration(milliseconds: 350));

    return RecommendBuildModel.listFromJson(jsonList);
  }


  Future<RecommendBuildModel> updateFavoriteStatus(String id) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final idx = jsonList.indexWhere((e) => e['id'] == id);
    if (idx == -1) {
      return RecommendBuildModel.fromJson(jsonList.first);
    }
    final current = jsonList[idx];
    final bool currFav = (current['favoriteStatus'] == true);
    jsonList[idx] = {
      ...current,
      'favoriteStatus': !currFav,
    };
    return RecommendBuildModel.fromJson(jsonList[idx]);
  }
}