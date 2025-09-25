import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/search/presentation/provider/recent_search_history_provider.dart';
import 'package:interiorapp_flutter_client/search/data/model/recent_search_keyword_model.dart';

class RecentSearchHistoryVm extends Notifier<List<RecentSearchKeyword>> {
  @override
  List<RecentSearchKeyword> build() {
    return [];
  }

  /// 최근 검색어 로드
  Future<void> loadRecentSearches() async {
    final searches = await ref.read(recentSearchHistoryUseCaseProvider).getRecentSearches();
    state = searches;
  }

  /// 검색어 저장
  Future<void> saveSearchKeyword(String keyword) async {
    await ref.read(recentSearchHistoryUseCaseProvider).saveSearchKeyword(keyword);
    await loadRecentSearches();
  }

  /// 특정 검색어 삭제
  Future<void> removeSearchKeyword(String keyword) async {
    await ref.read(recentSearchHistoryUseCaseProvider).removeSearchKeyword(keyword);
    await loadRecentSearches();
  }

  /// 모든 검색어 삭제
  Future<void> clearAllSearches() async {
    await ref.read(recentSearchHistoryUseCaseProvider).clearAllSearches();
    await loadRecentSearches();
  }
}

// ViewModel Provider
final recentSearchHistoryVmProvider = NotifierProvider<RecentSearchHistoryVm, List<RecentSearchKeyword>>(
  RecentSearchHistoryVm.new,
);
