import 'package:interiorapp_flutter_client/search/domain/repository/search_suggestion_repo.dart';
import 'package:interiorapp_flutter_client/search/data/model/search_suggestion_model.dart';
import 'package:interiorapp_flutter_client/search/data/source/remote/search_suggestion_remote_data_source.dart';

class SearchSuggestionImpl implements SearchSuggestionRepository {
  final SearchSuggestionRemoteDataSource _remoteDataSource;
  
  const SearchSuggestionImpl({
    required SearchSuggestionRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<SearchSuggestionModel>> getRelatedKeywords(String query) async {
    return _remoteDataSource.getRelatedKeywords(query);
  }

  @override
  Future<List<SearchSuggestionModel>> getTrendingKeywords() async {
    return _remoteDataSource.getTrendingKeywords();
  }
}
