import 'package:interiorapp_flutter_client/search/data/model/recent_search_keyword_model.dart';

abstract class RecentSearchHistoryRepository {
  /// 최근 검색어 저장
  Future<void> saveSearchKeyword(String keyword);
  
  /// 최근 검색어 목록 조회
  Future<List<RecentSearchKeyword>> getRecentSearches();
  
  /// 선택 검색어 삭제
  Future<void> removeSearchKeyword(String keyword);
  
  /// 모든 최근 검색어 삭제
  Future<void> clearAllSearches();
  
  /// 검색어 개수 조회
  Future<int> getSearchCount();
}
