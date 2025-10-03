import 'package:interiorapp_flutter_client/search/domain/repository/search_suggestion_repo.dart';
import 'package:interiorapp_flutter_client/search/data/model/search_suggestion_model.dart';

class SearchSuggestionUseCase {
  final SearchSuggestionRepository _repository;

  SearchSuggestionUseCase(this._repository);

  /// 연관 검색어 조회
  Future<List<SearchSuggestionModel>> getRelatedKeywords(String query) async {
    return _repository.getRelatedKeywords(query);
  }

  /// 추천 검색어 조회
  Future<List<SearchSuggestionModel>> getTrendingKeywords() async {
    return _repository.getTrendingKeywords();
  }
}
