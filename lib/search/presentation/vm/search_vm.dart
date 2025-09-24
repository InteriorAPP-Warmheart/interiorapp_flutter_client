import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

class SearchNotifier extends StateNotifier<String> {
  late final TextEditingController searchController;
  
  SearchNotifier() : super('') {
    searchController = TextEditingController();
    searchController.addListener(() => state = searchController.text);
  }
  
  void clear() {
    searchController.clear();
  }
  
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}