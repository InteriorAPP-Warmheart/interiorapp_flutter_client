import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/search/data/model/search_result_model.dart';
import 'package:interiorapp_flutter_client/search/presentation/provider/search_provider.dart';
import 'package:interiorapp_flutter_client/search/ui/widget/combine_searchbar_widget.dart';
import 'package:interiorapp_flutter_client/search/ui/widget/search_result_section.dart';

class CombineSearchResultScreen extends ConsumerStatefulWidget {
  const CombineSearchResultScreen({super.key});

  @override
  ConsumerState<CombineSearchResultScreen> createState() =>
      _CombineSearchResultScreenState();
}

class _CombineSearchResultScreenState
    extends ConsumerState<CombineSearchResultScreen> {
  String? _searchQuery;
  final FocusNode _searchFocusNode = FocusNode();
  String _selectedCategory = '전체';

  @override
  void initState() {
    super.initState();
    // 라우트 상태에서 쿼리 파라미터 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = GoRouterState.of(context);
      _searchQuery = state.uri.queryParameters['q'];
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CombineSearchbarWidget(
          focusNode: _searchFocusNode,
          initialValue: _searchQuery,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _buildCategoryTabs(),
        ),
      ),
      body:
          _searchQuery == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      '검색어가 없습니다',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : _buildSearchResults(),
    );
  }

  Widget _buildSearchResults() {
    // 검색어가 있는 경우 각 카테고리별로 검색 결과 확인
    if (_searchQuery != null) {
      final showroomAsync = ref.watch(categorySearchResultProvider((query: _searchQuery!, category: '쇼룸')));
      final storeAsync = ref.watch(categorySearchResultProvider((query: _searchQuery!, category: '스토어')));
      final constructionAsync = ref.watch(categorySearchResultProvider((query: _searchQuery!, category: '시공')));
      
      // 각 카테고리의 로딩 상태 확인
      final isLoading = showroomAsync.isLoading || storeAsync.isLoading || constructionAsync.isLoading;
      final hasError = showroomAsync.hasError || storeAsync.hasError || constructionAsync.hasError;
      
      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (hasError) {
        return Center(
          child: Text('검색 중 오류가 발생했습니다'),
        );
      }
      
      // 각 카테고리의 결과 확인
      final showroomResults = showroomAsync.value ?? [];
      final storeResults = storeAsync.value ?? [];
      final constructionResults = constructionAsync.value ?? [];
      
      // 모든 카테고리에서 결과가 없으면 "검색 결과 없음" 표시
      if (showroomResults.isEmpty && storeResults.isEmpty && constructionResults.isEmpty) {
        return _buildNoResults();
      }
      
      // 결과가 있는 카테고리들만 표시
      return _buildSearchResultsWithCategories();
    }
    
    // 검색어가 없는 경우 기본 결과 표시
    return _buildDefaultResults();
  }

  Widget _buildSearchResultsWithCategories() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 검색어 표시
          Row(
            children: [
              Text(
                '"$_searchQuery"',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Text(
                ' 검색 결과',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 검색 결과 섹션들 (필터 적용)
          if (_shouldShow('쇼룸')) ...[
            _buildShowroomSection([]), // 빈 리스트 전달 (내부에서 검색 결과 사용)
            const SizedBox(height: 12),
          ],
          if (_shouldShow('스토어')) ...[
            _buildStoreSection([]), // 빈 리스트 전달 (내부에서 검색 결과 사용)
            const SizedBox(height: 12),
          ],
          if (_shouldShow('시공')) ...[_buildConstructionSection([])], // 빈 리스트 전달 (내부에서 검색 결과 사용)
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '"$_searchQuery"에 대한',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '검색 결과가 없습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '다른 검색어로 시도해보세요',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDefaultResults() {
    final searchResultAsync = ref.watch(searchResultProvider);
    
    return searchResultAsync.when(
      data: (data) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 검색 결과 섹션들 (필터 적용)
              if (_shouldShow('쇼룸')) ...[
                _buildShowroomSection(data),
                const SizedBox(height: 12),
              ],
              if (_shouldShow('스토어')) ...[
                _buildStoreSection(data),
                const SizedBox(height: 12),
              ],
              if (_shouldShow('시공')) ...[_buildConstructionSection(data)],
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('데이터를 불러오는 중 오류가 발생했습니다: $error'),
      ),
    );
  }

  bool _shouldShow(String category) {
    return _selectedCategory == '전체' || _selectedCategory == category;
  }

  Widget _buildCategoryTabs() {
    final List<String> categories = const ['전체', '쇼룸', '스토어', '시공'];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              for (final label in categories)
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedCategory = label),
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color:
                                _selectedCategory == label
                                    ? Colors.black
                                    : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              _selectedCategory == label
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                          color:
                              _selectedCategory == label
                                  ? Colors.black
                                  : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(height: 1, color: Colors.grey.withValues(alpha: 0.3)),
      ],
    );
  }

  Widget _buildShowroomSection(List<SearchResultModel> data) {
    final bool isFullList = _selectedCategory == '쇼룸';
    
    // 검색어가 있으면 쇼룸 전용 검색 결과를 사용, 없으면 기본 데이터 사용
    if (_searchQuery != null) {
      final showroomSearchAsync = ref.watch(categorySearchResultProvider((query: _searchQuery!, category: '쇼룸')));
      return showroomSearchAsync.when(
        data: (showroomItems) {
          if (showroomItems.isEmpty) {
            return const SizedBox.shrink();
          }
          return _buildShowroomSectionContent(showroomItems, isFullList);
        },
        loading: () => const SizedBox.shrink(),
        error: (error, stack) => const SizedBox.shrink(),
      );
    }
    
    // 검색어가 없으면 기본 데이터에서 쇼룸 관련 아이템만 필터링
    final showroomItems = data.where((item) {
      final title = item.title?.toLowerCase() ?? '';
      final content = item.contentSnippet?.toLowerCase() ?? '';
      return title.contains('거실') || title.contains('침실') || 
             title.contains('모던') || title.contains('북유럽') ||
             content.contains('인테리어') || content.contains('리모델링');
    }).toList();
    
    if (showroomItems.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return _buildShowroomSectionContent(showroomItems, isFullList);
  }

  Widget _buildShowroomSectionContent(List<SearchResultModel> showroomItems, bool isFullList) {
    final itemsToShow = isFullList ? showroomItems : showroomItems.take(3).toList();
    final hasMoreItems = showroomItems.length > 3;
    
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '쇼룸',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 8),
            SearchResultSection(
              items: itemsToShow,
              listTileHorizontalPadding: 0,
              onTapItem: (item) {
                debugPrint('tap showroom: ${item.title}');
              },
            ),
            if (!isFullList && hasMoreItems) ...[
              const SizedBox(height: 8),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedCategory = '쇼룸';
                      });
                    },
                    child: const Text('쇼룸 결과 더보기'),
                  ),
                ),
              ),
            ],
          ],
        );
  }

  Widget _buildStoreSection(List<SearchResultModel> data) {
    final bool isFullList = _selectedCategory == '스토어';
    final int previewCount = _selectedCategory == '전체' ? 4 : 3;
    
    // 검색어가 있으면 스토어 전용 검색 결과를 사용, 없으면 기본 데이터 사용
    if (_searchQuery != null) {
      final storeSearchAsync = ref.watch(categorySearchResultProvider((query: _searchQuery!, category: '스토어')));
      return storeSearchAsync.when(
        data: (storeItems) {
          if (storeItems.isEmpty) {
            return const SizedBox.shrink();
          }
          return _buildStoreSectionContent(storeItems, isFullList, previewCount);
        },
        loading: () => const SizedBox.shrink(),
        error: (error, stack) => const SizedBox.shrink(),
      );
    }
    
    // 검색어가 없으면 기본 데이터에서 스토어 관련 아이템만 필터링
    final storeItems = data.where((item) {
      final title = item.title?.toLowerCase() ?? '';
      final publisher = item.publisherNickname?.toLowerCase() ?? '';
      return title.contains('브랜드') || title.contains('램프') || 
             title.contains('체어') || title.contains('러그') ||
             title.contains('테이블') || publisher.contains('brand');
    }).toList();
    
    if (storeItems.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return _buildStoreSectionContent(storeItems, isFullList, previewCount);
  }

  Widget _buildStoreSectionContent(List<SearchResultModel> storeItems, bool isFullList, int previewCount) {
    final itemsToShow = isFullList ? storeItems : storeItems.take(previewCount).toList();
    final hasMoreItems = storeItems.length > previewCount;
    
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '스토어',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 8),
            SearchResultSection(
              items: itemsToShow,
              layout: SearchResultLayout.storeGrid,
              gridCrossAxisCount: 2,
              gridSpacing: 12,
              gridHorizontalPadding: 0,
              onTapItem: (item) {
                debugPrint('tap store: ${item.title}');
              },
            ),
            if (!isFullList && hasMoreItems) ...[
              const SizedBox(height: 12),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedCategory = '스토어';
                      });
                    },
                    child: const Text('스토어 결과 더보기'),
                  ),
                ),
              ),
            ],
          ],
        );
  }

  Widget _buildConstructionSection(List<SearchResultModel> data) {
    final bool isFullList = _selectedCategory == '시공';
    
    // 검색어가 있으면 시공 전용 검색 결과를 사용, 없으면 기본 데이터 사용
    if (_searchQuery != null) {
      final constructionSearchAsync = ref.watch(categorySearchResultProvider((query: _searchQuery!, category: '시공')));
      return constructionSearchAsync.when(
        data: (constructionItems) {
          if (constructionItems.isEmpty) {
            return const SizedBox.shrink();
          }
          return _buildConstructionSectionContent(constructionItems, isFullList);
        },
        loading: () => const SizedBox.shrink(),
        error: (error, stack) => const SizedBox.shrink(),
      );
    }
    
    // 검색어가 없으면 기본 데이터에서 시공 관련 아이템만 필터링
    final constructionItems = data.where((item) {
      final title = item.title?.toLowerCase() ?? '';
      final publisher = item.publisherNickname?.toLowerCase() ?? '';
      return title.contains('리모델링') || title.contains('공사') || 
             title.contains('시공') || title.contains('업체') ||
             publisher.contains('시공업체');
    }).toList();
    
    if (constructionItems.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return _buildConstructionSectionContent(constructionItems, isFullList);
  }

  Widget _buildConstructionSectionContent(List<SearchResultModel> constructionItems, bool isFullList) {
    final itemsToShow = isFullList ? constructionItems : constructionItems.take(3).toList();
    final hasMoreItems = constructionItems.length > 3;
    
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '시공',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 8),
            SearchResultSection(
              items: itemsToShow,
              layout: SearchResultLayout.gallery,
              maxImagesToShow: 3,
              listTileHorizontalPadding: 0,
              onTapItem: (item) {
                debugPrint('tap construction: ${item.title}');
              },
            ),
            if (!isFullList && hasMoreItems) ...[
              const SizedBox(height: 8),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedCategory = '시공';
                      });
                    },
                    child: const Text('시공 결과 더보기'),
                  ),
                ),
              ),
            ],
          ],
        );
  }
}
