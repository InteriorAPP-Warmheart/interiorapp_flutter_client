import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/search/ui/widget/combine_searchbar_widget.dart';
import 'package:interiorapp_flutter_client/search/presentation/vm/recent_search_history_vm.dart';
import 'package:interiorapp_flutter_client/search/data/model/recent_search_keyword_model.dart';

class CombineSearchScreen extends ConsumerStatefulWidget {
  const CombineSearchScreen({super.key});

  @override
  ConsumerState<CombineSearchScreen> createState() =>
      _CombineSearchScreenState();
}

class _CombineSearchScreenState extends ConsumerState<CombineSearchScreen> {
  final FocusNode _searchFocusNode = FocusNode();
  bool _isFocused = false;

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

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recentSearches = ref.watch(recentSearchHistoryVmProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: CombineSearchbarWidget(
          focusNode: _searchFocusNode,
          useGlobalController: true,
        ),
      ),
      body:
          _isFocused
              ? // 포커스 시 검색 결과 리스트
              Container(
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
              )
              : // 포커스 해제 시 기본 화면
              Center(
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
