import 'package:interiorapp_flutter_client/search/domain/repository/recent_search_history_repo.dart';
import 'package:interiorapp_flutter_client/search/data/model/recent_search_keyword_model.dart';

class RecentSearchHistoryUseCase {
  final RecentSearchHistoryRepository _repository;

  RecentSearchHistoryUseCase(this._repository);

  /// 최근 검색어 저장
  Future<void> saveSearchKeyword(String keyword) async {
    return _repository.saveSearchKeyword(keyword);
  }

  /// 최근 검색어 목록 조회
  Future<List<RecentSearchKeyword>> getRecentSearches() async {
    return _repository.getRecentSearches();
  }

  /// 선택 검색어 삭제
  Future<void> removeSearchKeyword(String keyword) async {
    return _repository.removeSearchKeyword(keyword);
  }

  /// 모든 최근 검색어 삭제
  Future<void> clearAllSearches() async {
    return _repository.clearAllSearches();
  }

  /// 검색어 개수 조회
  Future<int> getSearchCount() async {
    return _repository.getSearchCount();
  }
}
