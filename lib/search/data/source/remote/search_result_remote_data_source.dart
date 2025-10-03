import 'package:interiorapp_flutter_client/search/data/model/search_result_model.dart';

/// 검색 결과 데이터 소스 인터페이스
abstract class SearchResultRemoteDataSource {
  /// 검색 결과 아이템 목록 조회
  Future<List<SearchResultModel>> getSearchResultItems();
  
  /// 검색어에 따른 통합 검색 결과 조회
  Future<List<SearchResultModel>> searchItems(String query);
  
  /// 쇼룸 데이터에서 검색
  Future<List<SearchResultModel>> searchShowroomItems(String query);
  
  /// 스토어 데이터에서 검색
  Future<List<SearchResultModel>> searchStoreItems(String query);
  
  /// 시공 데이터에서 검색
  Future<List<SearchResultModel>> searchConstructionItems(String query);
}
