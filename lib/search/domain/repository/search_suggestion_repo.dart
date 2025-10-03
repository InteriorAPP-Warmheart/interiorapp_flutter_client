import 'package:interiorapp_flutter_client/search/data/model/search_suggestion_model.dart';

abstract class SearchSuggestionRepository {
  /// 연관 검색어 조회
  Future<List<SearchSuggestionModel>> getRelatedKeywords(String query);
  
  /// 추천 검색어 조회
  Future<List<SearchSuggestionModel>> getTrendingKeywords();
}
