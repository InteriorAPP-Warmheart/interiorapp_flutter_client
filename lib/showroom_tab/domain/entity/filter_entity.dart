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
  final List<SelectedFilter> selectedFilters;
  final String? selectedSpaceType; // 주거/상업 선택 상태 추가

  FilterState({
    required this.categoryItems,
    this.selectedFilters = const [],
    this.selectedSpaceType,
  });

  FilterState copyWith({
    Map<String, List<FilterItem>>? categoryItems,
    List<SelectedFilter>? selectedFilters,
    String? selectedSpaceType,
  }) {
    return FilterState(
      categoryItems: categoryItems ?? this.categoryItems,
      selectedFilters: selectedFilters ?? this.selectedFilters,
      selectedSpaceType: selectedSpaceType ?? this.selectedSpaceType,
    );
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