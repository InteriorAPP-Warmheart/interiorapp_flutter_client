import 'package:interiorapp_flutter_client/search/data/model/search_result_model.dart';

/// 검색 결과 데이터 소스 인터페이스
abstract class SearchResultRemoteDataSource {
  /// 검색 결과 아이템 목록 조회
  Future<List<SearchResultModel>> getSearchResultItems();
}
