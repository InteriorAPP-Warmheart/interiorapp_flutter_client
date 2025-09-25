import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/search/ui/widget/combine_searchbar_widget.dart';

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
          _buildCategoryTabs(),
          const SizedBox(height: 12),

          // 검색 결과 섹션들 (필터 적용)
          if (_shouldShow('쇼룸')) ...[
            _buildResultSection('쇼룸', Icons.storefront, _buildMockResults('쇼룸')),
            const SizedBox(height: 16),
          ],
          if (_shouldShow('스토어')) ...[
            _buildResultSection(
              '스토어',
              Icons.shopping_bag,
              _buildMockResults('스토어'),
            ),
            const SizedBox(height: 16),
          ],
          if (_shouldShow('시공')) ...[
            _buildResultSection(
              '시공',
              Icons.home_work,
              _buildMockResults('시공'),
            ),
          ],
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
        Row(
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
                          color: _selectedCategory == label
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
                        fontWeight: _selectedCategory == label
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: _selectedCategory == label
                            ? Colors.black
                            : Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        // const SizedBox(height: 4),
        Container(height: 1, color: Colors.grey.withValues(alpha: 0.3)),
      ],
    );
  }

  Widget _buildResultSection(
    String title,
    IconData icon,
    List<Widget> results,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // TODO: 해당 카테고리 상세 페이지로 이동
                print('$title 더보기');
              },
              child: Text('더보기'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...results,
      ],
    );
  }

  List<Widget> _buildMockResults(String category) {
    return List.generate(3, (index) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.image, color: Colors.grey[400]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_searchQuery 관련 $category ${index + 1}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '검색어 "$_searchQuery"와 관련된 $category 정보입니다.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
