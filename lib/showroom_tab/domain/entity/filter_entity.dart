import 'package:flutter/material.dart';

class FilterItem {
  final String id;
  final String name;
  final bool isSelected;
  final String? parentId; // 상위 카테고리 ID 추가 <--- 공간 형태에서 주거/상업 나뉘어져서 추가함!

  FilterItem({
    required this.id,
    required this.name,
    this.isSelected = false,
    this.parentId,
  });

  FilterItem copyWith({
    String? id,
    String? name,
    bool? isSelected,
    String? parentId,
  }) {
    return FilterItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isSelected: isSelected ?? this.isSelected,
      parentId: parentId ?? this.parentId,
    );
  }
}

class FilterState {
  final Map<String, List<FilterItem>> categoryItems;
  final String selectedCategory; // 현재 선택된 카테고리
  final List<SelectedFilter> selectedFilters;
  final String? selectedSpaceType; // 주거/상업 선택 상태
  final RangeValues budgetRange; // 예산 범위

  FilterState({
    required this.categoryItems,
    required this.selectedCategory,
    this.selectedFilters = const [],
    this.selectedSpaceType,
    this.budgetRange = const RangeValues(0, 16000000),
  });

  FilterState copyWith({
    Map<String, List<FilterItem>>? categoryItems,
    String? selectedCategory,
    List<SelectedFilter>? selectedFilters,
    String? selectedSpaceType,
    RangeValues? budgetRange,
  }) {
    return FilterState(
      categoryItems: categoryItems ?? this.categoryItems,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedFilters: selectedFilters ?? this.selectedFilters,
      selectedSpaceType: selectedSpaceType ?? this.selectedSpaceType,
      budgetRange: budgetRange ?? this.budgetRange,
    );
  }

  // 예산을 포맷된 문자열로 반환
  String get formattedBudgetRange {
    final min = (budgetRange.start / 10000).round();
    final max = (budgetRange.end / 10000).round();
    return '$min만원 ~ $max만원';
  }
}

class SelectedFilter {
  final String id;
  final String name;
  final String category;

  SelectedFilter({
    required this.id,
    required this.name,
    required this.category,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectedFilter &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}