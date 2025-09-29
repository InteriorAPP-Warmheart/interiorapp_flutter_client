import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/search/presentation/provider/search_provider.dart';

class SearchNotifier extends Notifier<String> {
  late final TextEditingController searchController;
  
  @override
  String build() {
    searchController = TextEditingController();
    searchController.addListener(() => state = searchController.text);
    return '';
  }
  
  void clear() {
    searchController.clear();
  }
  
  void dispose() {
    searchController.dispose();
  }

  Future<void> loadSearchResultItems() async {
    await ref.read(searchResultUseCaseProvider).getSearchResultItems();
    // 검색 결과는 별도의 provider에서 관리됩니다
  }
}