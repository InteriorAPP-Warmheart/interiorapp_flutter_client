import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카테고리 탭
          const SizedBox(height: 8),

          // 검색 결과 섹션들 (필터 적용)
          if (_shouldShow('쇼룸')) ...[
            _buildShowroomSection(),
            const SizedBox(height: 12),
          ],
          if (_shouldShow('스토어')) ...[
            _buildStoreSection(),
            const SizedBox(height: 12),
          ],
          if (_shouldShow('시공')) ...[_buildConstructionSection()],
        ],
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

  Widget _buildShowroomSection() {
    final searchResultAsync = ref.watch(searchResultProvider);
    final bool isFullList = _selectedCategory == '쇼룸';
    
    return searchResultAsync.when(
      data: (data) {
        final itemsToShow = isFullList ? data : data.take(3).toList(); // .take: 처음에 3개 가져오기
        final hasMoreItems = data.length > 3;
        
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('데이터를 불러오는 중 오류가 발생했습니다: $error'),
      ),
    );
  }

  Widget _buildStoreSection() {
    final searchResultAsync = ref.watch(searchResultProvider);
    final bool isFullList = _selectedCategory == '스토어';
    final int previewCount = _selectedCategory == '전체' ? 4 : 3;
    
    return searchResultAsync.when(
      data: (data) {
        final itemsToShow = isFullList ? data : data.take(previewCount).toList();
        final hasMoreItems = data.length > previewCount;
        
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('데이터를 불러오는 중 오류가 발생했습니다: $error'),
      ),
    );
  }

  Widget _buildConstructionSection() {
    final searchResultAsync = ref.watch(searchResultProvider);
    final bool isFullList = _selectedCategory == '시공';
    
    return searchResultAsync.when(
      data: (data) {
        final itemsToShow = isFullList ? data : data.take(3).toList();
        final hasMoreItems = data.length > 3;
        
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('데이터를 불러오는 중 오류가 발생했습니다: $error'),
      ),
    );
  }
}
