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
    this.budgetRange = const RangeValues(0, 0),
  });

  FilterState copyWith({
    Map<String, List<FilterItem>>? categoryItems,
    String? selectedCategory,
    List<SelectedFilter>? selectedFilters,
    bool clearSpaceType = false, //공간 형태 초기화 안되는 문제 떄문에 초기화하는 문제 때문에 생성
    String? selectedSpaceType,
    
    RangeValues? budgetRange,
  }) {
    return FilterState(
      categoryItems: categoryItems ?? this.categoryItems,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedFilters: selectedFilters ?? this.selectedFilters,
      selectedSpaceType: clearSpaceType ? null : (selectedSpaceType ?? this.selectedSpaceType),
      budgetRange: budgetRange ?? this.budgetRange,
    );
  }

//예산을 포맷된 문자열로 반환 (콤마 포함)
String get formattedBudgetRange {
    // 초기 상태 (0원)
    if (budgetRange.start == 0 && budgetRange.end == 0) {
      return '0원';
    }

    return '${_formatCurrency(budgetRange.start)} ~ ${_formatCurrency(budgetRange.end)}';
  }

  // 통화 포맷팅 함수
  String _formatCurrency(double value) {
    if (value == 0) return '0원';

    final intValue = value.round();

    // 억 단위 계산
    final eok = intValue ~/ 100000000;
    final remainder = intValue % 100000000;

    // 만원 단위 계산
    final manWon = remainder ~/ 10000;

    List<String> parts = [];

    if (eok > 0) {
      parts.add('$eok억');
    }

    if (manWon > 0) {
      // 만원에 콤마 추가
      final manWonStr = manWon.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
      parts.add('$manWonStr만원');
    }

    // 만원 미만은 표시하지 않음

    if (parts.isEmpty) return '0원';

    return parts.join(' ');
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