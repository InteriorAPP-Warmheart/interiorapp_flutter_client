import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/search/data/repository/recent_search_history_impl.dart';
import 'package:interiorapp_flutter_client/search/data/source/loacl/recent_search_history_remote_data_source_impl.dart';
import 'package:interiorapp_flutter_client/search/domain/use_case/recent_search_history_use_case.dart';
import 'package:interiorapp_flutter_client/search/data/model/recent_search_keyword_model.dart';

// Data Source Provider
final recentSearchHistoryLocalDataSourceProvider = Provider((ref) {
  return RecentSearchHistoryLocalDataSource();
});

// Repository Provider
final recentSearchHistoryRepositoryProvider = Provider((ref) {
  return RecentSearchHistoryImpl(
    localDataSource: ref.read(recentSearchHistoryLocalDataSourceProvider),
  );
});

// UseCase Provider
final recentSearchHistoryUseCaseProvider = Provider((ref) {
  return RecentSearchHistoryUseCase(ref.read(recentSearchHistoryRepositoryProvider));
});

// Future Provider for getting recent searches
final recentSearchesProvider = FutureProvider<List<RecentSearchKeyword>>((ref) async {
  return await ref.read(recentSearchHistoryUseCaseProvider).getRecentSearches();
});
