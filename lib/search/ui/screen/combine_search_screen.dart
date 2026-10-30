import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
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
      backgroundColor: AppColors.background,
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
    final double fontScale = ResponsiveSize.fontScale(context);
    final EdgeInsets padding = ResponsiveSize.textInset(context);

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_rounded,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '궁금한 인테리어,\n무엇이든 검색하세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17 * fontScale,
                fontWeight: FontWeight.w700,
                height: 1.4,
                letterSpacing: -0.3,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '테스트를 위해서 "전체검색"을 검색하면\n모든 카테고리별 검색결과를 확인할 수 있습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13 * fontScale,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
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
    final double fontScale = ResponsiveSize.fontScale(context);
    final EdgeInsets padding = ResponsiveSize.textInset(context);

    return Padding(
      padding: padding.copyWith(top: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '최근 검색어',
                style: _sectionTitle(fontScale),
              ),
              const Spacer(),
              if (recentSearches.isNotEmpty)
                TextButton(
                  onPressed: () => ref.read(recentSearchHistoryVmProvider.notifier).clearAllSearches(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    '모두삭제',
                    style: TextStyle(
                      fontSize: 13 * fontScale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.textSecondary,
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
                        fontSize: 14 * fontScale,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
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
    final EdgeInsets padding = ResponsiveSize.textInset(context);

    return SingleChildScrollView(
      padding: padding.copyWith(top: 16, bottom: 16),
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
            Text(
              '연관 검색어',
              style: _sectionTitle(ResponsiveSize.fontScale(context)),
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
            Text(
              '추천 검색어',
              style: _sectionTitle(ResponsiveSize.fontScale(context)),
            ),
            const SizedBox(height: 12),
            ...keywords.map((keyword) => _buildSuggestionItem(keyword)),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          '추천 검색어를 불러오는 중 오류가 발생했습니다',
          style: TextStyle(
            fontSize: 14 * ResponsiveSize.fontScale(context),
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(SearchSuggestionModel suggestion) {
    final double fontScale = ResponsiveSize.fontScale(context);

    return InkWell(
      onTap: () async {
        _searchFocusNode.unfocus();
        await ref.read(recentSearchHistoryVmProvider.notifier).saveSearchKeyword(suggestion.keyword);
        if (mounted) {
          context.push(_searchResultLocation(suggestion.keyword));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(
              suggestion.type == SearchSuggestionType.related
                  ? Icons.search
                  : Icons.trending_up,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion.keyword,
                style: TextStyle(
                  fontSize: 15 * fontScale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (suggestion.isTrending)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  'HOT',
                  style: TextStyle(
                    fontSize: 10 * fontScale,
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearchItem(RecentSearchKeyword searchKeyword) {
    final double fontScale = ResponsiveSize.fontScale(context);

    return InkWell(
      onTap: () async {
        // 검색어 클릭 시 검색 실행
        _searchFocusNode.unfocus();
        // 최근 검색어에 저장 (중복 제거되므로 안전)
        await ref.read(recentSearchHistoryVmProvider.notifier).saveSearchKeyword(searchKeyword.keyword);
        // 검색 결과 페이지로 이동
        if (mounted) {
          context.push(_searchResultLocation(searchKeyword.keyword));
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
                    style: TextStyle(
                      fontSize: 15 * fontScale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatSearchTime(searchKeyword.searchedAt),
                    style: TextStyle(
                      fontSize: 12 * fontScale,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => ref.read(recentSearchHistoryVmProvider.notifier).removeSearchKeyword(searchKeyword.keyword),
              icon: Icon(Icons.close, size: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _sectionTitle(double fontScale) {
    return TextStyle(
      fontSize: 17 * fontScale,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      color: AppColors.textPrimary,
    );
  }

  String _searchResultLocation(String keyword) {
    return Uri(
      path: '/search/result',
      queryParameters: {'q': keyword.trim()},
    ).toString();
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
