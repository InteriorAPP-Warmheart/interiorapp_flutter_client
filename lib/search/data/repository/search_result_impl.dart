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
}