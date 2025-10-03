import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/search/ui/widget/combine_searchbar_widget.dart';
import 'package:interiorapp_flutter_client/search/presentation/vm/recent_search_history_vm.dart';
import 'package:interiorapp_flutter_client/search/data/model/recent_search_keyword_model.dart';
import 'package:interiorapp_flutter_client/search/presentation/provider/search_provider.dart';
import 'package:interiorapp_flutter_client/search/data/model/search_suggestion_model.dart';

class CombineSearchScreen extends ConsumerStatefulWidget {
  const CombineSearchScreen({super.key});

  @override
  ConsumerState<CombineSearchScreen> createState() =>
      _CombineSearchScreenState();
}

class _CombineSearchScreenState extends ConsumerState<CombineSearchScreen> {
  final FocusNode _searchFocusNode = FocusNode();
  bool _isFocused = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
    // 초기 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recentSearchHistoryVmProvider.notifier).loadRecentSearches();
    });
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _searchFocusNode.hasFocus;
    });
    if (_isFocused) {
      ref.read(recentSearchHistoryVmProvider.notifier).loadRecentSearches();
    }
  }

  void _onSearchQueryChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CombineSearchbarWidget(
          focusNode: _searchFocusNode,
          useGlobalController: true,
          onQueryChanged: _onSearchQueryChanged,
        ),
      ),
      body: _isFocused
          ? _buildSearchSuggestions()
          : _buildDefaultScreen(),
    );
  }

  Widget _buildDefaultScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            '궁금한 인테리어,\n무엇이든 검색하세요',
            style: TextStyle(fontSize: 18, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    if (_searchQuery.trim().isEmpty) {
      return _buildRecentSearches();
    } else {
      return _buildSearchSuggestionsContent();
    }
  }

  Widget _buildRecentSearches() {
    final recentSearches = ref.watch(recentSearchHistoryVmProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '최근 검색어',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFAFAFAF),
                ),
              ),
              const Spacer(),
              if (recentSearches.isNotEmpty)
                TextButton(
                  onPressed: () => ref.read(recentSearchHistoryVmProvider.notifier).clearAllSearches(),
                  child: Text(
                    '모두삭제',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: recentSearches.isEmpty
                ? Center(
                    child: Text(
                      '최근 검색어가 없습니다',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : ListView(
                    children: recentSearches
                        .map((searchKeyword) => _buildRecentSearchItem(searchKeyword))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestionsContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 연관 검색어 섹션
          _buildRelatedKeywordsSection(),
          const SizedBox(height: 24),
          // 추천 검색어 섹션
          _buildTrendingKeywordsSection(),
        ],
      ),
    );
  }

  Widget _buildRelatedKeywordsSection() {
    final relatedKeywordsAsync = ref.watch(relatedKeywordsProvider(_searchQuery));
    
    return relatedKeywordsAsync.when(
      data: (keywords) {
        if (keywords.isEmpty) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '연관 검색어',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFFAFAFAF),
              ),
            ),
            const SizedBox(height: 12),
            ...keywords.map((keyword) => _buildSuggestionItem(keyword)),
          ],
        );
      },
      loading: () => const SizedBox.shrink(), // 로딩 중일 때는 아무것도 표시하지 않음
      error: (error, stack) => const SizedBox.shrink(), // 에러 발생 시에도 아무것도 표시하지 않음
    );
  }

  Widget _buildTrendingKeywordsSection() {
    final trendingKeywordsAsync = ref.watch(trendingKeywordsProvider);
    
    return trendingKeywordsAsync.when(
      data: (keywords) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '추천 검색어',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFFAFAFAF),
              ),
            ),
            const SizedBox(height: 12),
            ...keywords.map((keyword) => _buildSuggestionItem(keyword)),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('추천 검색어를 불러오는 중 오류가 발생했습니다'),
      ),
    );
  }

  Widget _buildSuggestionItem(SearchSuggestionModel suggestion) {
    return InkWell(
      onTap: () async {
        _searchFocusNode.unfocus();
        await ref.read(recentSearchHistoryVmProvider.notifier).saveSearchKeyword(suggestion.keyword);
        if (mounted) {
          context.push('/search/result?q=${suggestion.keyword}');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              suggestion.type == SearchSuggestionType.related 
                  ? Icons.search 
                  : Icons.trending_up,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion.keyword,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ),
            if (suggestion.isTrending)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'HOT',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearchItem(RecentSearchKeyword searchKeyword) {
    return InkWell(
      onTap: () async {
        // 검색어 클릭 시 검색 실행
        _searchFocusNode.unfocus();
        // 최근 검색어에 저장 (중복 제거되므로 안전)
        await ref.read(recentSearchHistoryVmProvider.notifier).saveSearchKeyword(searchKeyword.keyword);
        // 검색 결과 페이지로 이동
        if (mounted) {
          context.push('/search/result?q=${searchKeyword.keyword}');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    searchKeyword.keyword, 
                    style: TextStyle(fontSize: 15, color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatSearchTime(searchKeyword.searchedAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => ref.read(recentSearchHistoryVmProvider.notifier).removeSearchKeyword(searchKeyword.keyword),
              icon: Icon(Icons.close, size: 15, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSearchTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
