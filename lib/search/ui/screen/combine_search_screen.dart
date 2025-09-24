import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/search/ui/widget/combine_searchbar_widget.dart';

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
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _searchFocusNode.hasFocus;
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
        title: CombineSearchbarWidget(focusNode: _searchFocusNode),
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
                        TextButton(
                          onPressed: () {},
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
                      child: ListView(
                        children: [
                          _buildRecentSearchItem('욕실 리모델링'),
                          _buildRecentSearchItem('거실 인테리어'),
                          _buildRecentSearchItem('침실 가구'),
                          _buildRecentSearchItem('주방 시공'),
                        ],
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

  Widget _buildRecentSearchItem(String keyword) {
    return InkWell(
      onTap: () {
        // 검색어 클릭 시 검색 실행
        _searchFocusNode.unfocus();
      },
      child: Row(
        children: [
          Text(keyword, style: TextStyle(fontSize: 15, color: Colors.black)),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.close, size: 15, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
