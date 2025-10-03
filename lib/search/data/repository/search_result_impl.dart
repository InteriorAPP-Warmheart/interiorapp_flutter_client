import 'package:interiorapp_flutter_client/search/data/source/remote/search_result_remote_data_source.dart';
import 'package:interiorapp_flutter_client/search/domain/repository/search_result_repo.dart';
import 'package:interiorapp_flutter_client/search/data/model/search_result_model.dart';

class SearchResultImpl implements SearchResultRepository {
  final SearchResultRemoteDataSource _remoteDataSource;
  
  const SearchResultImpl({
    required SearchResultRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<SearchResultModel>> getSearchResultItems() async {
    return _remoteDataSource.getSearchResultItems();
  }

  @override
  Future<List<SearchResultModel>> searchItems(String query) async {
    return _remoteDataSource.searchItems(query);
  }

  @override
  Future<List<SearchResultModel>> searchByCategory(String query, String category) async {
    switch (category.toLowerCase()) {
      case '쇼룸':
        return _remoteDataSource.searchShowroomItems(query);
      case '스토어':
        return _remoteDataSource.searchStoreItems(query);
      case '시공':
        return _remoteDataSource.searchConstructionItems(query);
      default:
        throw ArgumentError('지원하지 않는 카테고리입니다: $category');
    }
  }
}