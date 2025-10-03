import 'package:interiorapp_flutter_client/search/data/source/loacl/recent_search_history_remote_data_source_impl.dart';
import 'package:interiorapp_flutter_client/search/domain/repository/recent_search_history_repo.dart';
import 'package:interiorapp_flutter_client/search/data/model/recent_search_keyword_model.dart';

class RecentSearchHistoryImpl implements RecentSearchHistoryRepository {
  final RecentSearchHistoryLocalDataSource _localDataSource;

  const RecentSearchHistoryImpl({
    required RecentSearchHistoryLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<void> saveSearchKeyword(String keyword) async {
    return _localDataSource.saveSearchKeyword(keyword);
  }

  @override
  Future<List<RecentSearchKeyword>> getRecentSearches() async {
    return _localDataSource.getRecentSearches();
  }

  @override
  Future<void> removeSearchKeyword(String keyword) async {
    return _localDataSource.removeSearchKeyword(keyword);
  }

  @override
  Future<void> clearAllSearches() async {
    return _localDataSource.clearAllSearches();
  }

  @override
  Future<int> getSearchCount() async {
    return _localDataSource.getSearchCount();
  }
}
