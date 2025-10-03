import 'package:interiorapp_flutter_client/search/data/model/search_suggestion_model.dart';

/// 검색 제안 데이터 소스 인터페이스
abstract class SearchSuggestionRemoteDataSource {
  /// 연관 검색어 조회
  Future<List<SearchSuggestionModel>> getRelatedKeywords(String query);
  
  /// 추천 검색어 조회
  Future<List<SearchSuggestionModel>> getTrendingKeywords();
}
