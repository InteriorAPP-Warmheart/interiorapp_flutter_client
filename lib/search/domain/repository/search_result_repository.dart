import 'package:interiorapp_flutter_client/search/data/model/search_result_model.dart';

abstract class SearchResultRepository {
  /// 기본 검색 결과 아이템 목록 조회
  Future<List<SearchResultModel>> getSearchResultItems();
  
  /// 검색어에 따른 통합 검색 결과 조회
  Future<List<SearchResultModel>> searchItems(String query);
  
  /// 카테고리별 검색 결과 조회
  Future<List<SearchResultModel>> searchByCategory(String query, String category);
}