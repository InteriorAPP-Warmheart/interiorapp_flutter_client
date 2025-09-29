import 'package:interiorapp_flutter_client/search/data/model/search_result_model.dart';
import 'package:interiorapp_flutter_client/search/domain/repository/search_result_repo.dart';

class SearchResultUseCase {
  final SearchResultRepository _repository;
  SearchResultUseCase(this._repository);

  Future<List<SearchResultModel>> getSearchResultItems() async {
    return _repository.getSearchResultItems();
  }
}