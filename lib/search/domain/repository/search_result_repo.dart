import 'package:interiorapp_flutter_client/search/data/model/search_result_model.dart';

abstract class SearchResultRepository {
  Future<List<SearchResultModel>> getSearchResultItems();
}