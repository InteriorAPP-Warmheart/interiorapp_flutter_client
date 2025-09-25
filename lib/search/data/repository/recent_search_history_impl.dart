import 'package:shared_preferences/shared_preferences.dart';
import 'package:interiorapp_flutter_client/search/domain/repository/recent_search_history_repo.dart';
import 'package:interiorapp_flutter_client/search/data/model/recent_search_keyword_model.dart';
import 'dart:convert';

class RecentSearchHistoryImpl implements RecentSearchHistoryRepository {
  static const String _key = 'recent_searches';
  static const int _maxCount = 10;

  @override
  Future<void> saveSearchKeyword(String keyword) async {
    if (keyword.trim().isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    final recentSearchesJson = prefs.getString(_key);
    
    // 기존 검색어들 로드
    List<RecentSearchKeyword> recentSearches = [];
    if (recentSearchesJson != null) {
      final List<dynamic> jsonList = jsonDecode(recentSearchesJson);
      recentSearches = jsonList
          .map((json) => RecentSearchKeyword.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    
    // 중복 제거 (기존에 있던 키워드는 제거)
    recentSearches.removeWhere((item) => item.keyword == keyword);
    
    // 새 키워드 추가 (맨 앞에)
    recentSearches.insert(0, RecentSearchKeyword(
      keyword: keyword.trim(),
      searchedAt: DateTime.now(),
    ));
    
    // 최대 개수 제한
    if (recentSearches.length > _maxCount) {
      recentSearches.removeRange(_maxCount, recentSearches.length);
    }
    
    // 저장
    final jsonList = recentSearches.map((keyword) => keyword.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  @override
  Future<List<RecentSearchKeyword>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final recentSearchesJson = prefs.getString(_key);
    
    if (recentSearchesJson == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(recentSearchesJson);
    return jsonList
        .map((json) => RecentSearchKeyword.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> removeSearchKeyword(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    final recentSearchesJson = prefs.getString(_key);
    
    if (recentSearchesJson == null) return;
    
    final List<dynamic> jsonList = jsonDecode(recentSearchesJson);
    List<RecentSearchKeyword> recentSearches = jsonList
        .map((json) => RecentSearchKeyword.fromJson(json as Map<String, dynamic>))
        .toList();
    
    recentSearches.removeWhere((item) => item.keyword == keyword);
    
    final updatedJsonList = recentSearches.map((keyword) => keyword.toJson()).toList();
    await prefs.setString(_key, jsonEncode(updatedJsonList));
  }

  @override
  Future<void> clearAllSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  @override
  Future<int> getSearchCount() async {
    final searches = await getRecentSearches();
    return searches.length;
  }
}
