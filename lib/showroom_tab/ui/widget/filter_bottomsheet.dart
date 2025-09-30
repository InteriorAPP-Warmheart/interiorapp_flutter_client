import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/showroom_tab/domain/entity/filter_entity.dart';
import 'package:interiorapp_flutter_client/showroom_tab/presentation/provider/filter_provider.dart';

class FilterBottomSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(filterProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '필터',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 242, 242, 242),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    padding: EdgeInsets.zero,
                    minimumSize: Size(10, 30),
                  ),
                  child: Text(
                    '닫기',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 87, 87, 87),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 카테고리 탭
          Container(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              children:
                  ['스타일', '공간 형태', '예산', '톤앤매너', '소재'].map((category) {
                    final isSelected = category == filterState.selectedCategory;
                    return GestureDetector(
                      onTap:
                          () => ref
                              .read(filterProvider.notifier)
                              .selectCategory(category),
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color:
                                  isSelected
                                      ? Colors.black
                                      : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color:
                                isSelected
                                    ? Colors.black
                                    : const Color.fromARGB(255, 183, 183, 183),
                            fontSize: 18,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),

          // 필터 컨텐츠 영역
          Expanded(child: _buildFilterContent(context, ref, filterState)),

          Divider(),
          // 하단 버튼
          Container(
            padding: EdgeInsets.only(top: 8, left: 30, right: 30, bottom: 50),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextButton(
                        onPressed:
                            () => ref.read(filterProvider.notifier).resetFilters(),
                        child: Text(
                          '초기화',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 108, 108, 108),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        minimumSize: const Size(100, 60),
                        ),
                        child: Text(
                          '적용하기',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 필터 컨텐츠 빌드 (카테고리별 분기)
Widget _buildFilterContent(
  BuildContext context,
  WidgetRef ref,
  FilterState filterState,
) {
  final category = filterState.selectedCategory;

  if (category == '공간 형태') {
    return _buildSpaceTypeFilter(ref, filterState);
  } else if (category == '예산') {
    return _buildBudgetFilter(ref, filterState);
  } else if (category == '톤앤매너') {
    return _buildToneFilter(ref, filterState);
  } else {
    return _buildDefaultFilter(ref, filterState);
  }
}

// 일반 필터 (스타일, 소재)
Widget _buildDefaultFilter(WidgetRef ref, FilterState filterState) {
  final items = filterState.categoryItems[filterState.selectedCategory] ?? [];

  return Padding(
    padding: const EdgeInsets.only(top: 27, left: 17),
    child: Wrap(
      alignment: WrapAlignment.start,
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) => _FilterChip(item: item)).toList(),
    ),
  );
}

// 공간 형태 필터 (계층 구조)
Widget _buildSpaceTypeFilter(WidgetRef ref, FilterState filterState) {
  return SingleChildScrollView(
    padding: const EdgeInsets.only(top: 27, left: 16, right: 16, bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 주거/상업 선택 (큰 버튼으로 변경)
        const Text(
          '공간 형태',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildSpaceTypeButton(
                ref,
                'residential',
                '주거 공간',
                filterState.selectedSpaceType == 'residential',
              ),
            ),
            SizedBox(width: 17),
            Expanded(
              child: _buildSpaceTypeButton(
                ref,
                'commercial',
                '상업 공간',
                filterState.selectedSpaceType == 'commercial',
              ),
            ),
          ],
        ),

        // 선택된 공간 형태의 하위 항목 표시
        if (filterState.selectedSpaceType == 'residential') ...[
          const SizedBox(height: 40),
          const Text(
            '주거 공간',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                (filterState.categoryItems['주거_공간'] ?? [])
                    .map((item) => _FilterChip(item: item))
                    .toList(),
          ),
          const SizedBox(height: 40),
          const Text(
            '세부 항목',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                (filterState.categoryItems['주거_세부'] ?? [])
                    .map((item) => _FilterChip(item: item))
                    .toList(),
          ),
        ] else if (filterState.selectedSpaceType == 'commercial') ...[
          const SizedBox(height: 24),
          const Text(
            '상업 공간',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                (filterState.categoryItems['상업_공간'] ?? [])
                    .map((item) => _FilterChip(item: item))
                    .toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            '세부 항목',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                (filterState.categoryItems['상업_세부'] ?? [])
                    .map((item) => _FilterChip(item: item))
                    .toList(),
          ),
        ],
      ],
    ),
  );
}

// 주거/상업 선택 버튼 위젯
Widget _buildSpaceTypeButton(
  WidgetRef ref,
  String spaceTypeId,
  String label,
  bool isSelected,
) {
  return GestureDetector(
    onTap: () => ref.read(filterProvider.notifier).toggleSpaceType(spaceTypeId),
    child: Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.black : Colors.grey[300]!,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}

// 톤앤매너 필터 (색상 포함) - 새로 추가
Widget _buildToneFilter(WidgetRef ref, FilterState filterState) {
  final items = filterState.categoryItems['톤앤매너'] ?? [];

  // 색상 매핑
  final Map<String, Color> colorMap = {
    'red': Colors.red,
    'orange': Colors.orange,
    'yellow': Colors.yellow,
    'green': Colors.green,
    'blue': Colors.blue,
    'purple': Colors.purple,
    'pink': Colors.pink,
    'brown': Colors.brown,
    'white': Colors.white,
    'gray': Colors.grey,
    'black': Colors.black,
  };

  return Padding(
    padding: const EdgeInsets.only(top: 27, left: 17, right: 10),
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          items.map((item) {
            final color = colorMap[item.id] ?? Colors.grey;
            return _ColorFilterChip(item: item, color: color);
          }).toList(),
    ),
  );
}

// 예산 필터 (슬라이더)
Widget _buildBudgetFilter(WidgetRef ref, FilterState filterState) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        RangeSlider(
          values: filterState.budgetRange,
          min: 0,
          max: 16000000,
          divisions: 160,
          activeColor: Colors.black,
          inactiveColor: const Color.fromARGB(255, 197, 197, 197),
          labels: RangeLabels(
            '${(filterState.budgetRange.start / 10000).round()}만원',
            '${(filterState.budgetRange.end / 10000).round()}만원',
          ),
          onChanged: (RangeValues values) {
            ref.read(filterProvider.notifier).updateBudgetRange(values);
          },
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0만원', style: TextStyle(color: Colors.grey, fontSize: 15)),
            Text('무제한', style: TextStyle(color: Colors.grey, fontSize: 15)),
          ],
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 60,
            color: const Color.fromARGB(255, 239, 238, 238),
            child: Center(
              child: Text(
                filterState.formattedBudgetRange,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// 일반 필터 칩
class _FilterChip extends ConsumerWidget {
  final FilterItem item;

  const _FilterChip({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(filterProvider.notifier).toggleFilter(item.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: item.isSelected ? Colors.black : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          item.name,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// 색상이 있는 필터 칩 (톤앤매너용)
class _ColorFilterChip extends ConsumerWidget {
  final FilterItem item;
  final Color color;

  const _ColorFilterChip({required this.item, required this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(filterProvider.notifier).toggleFilter(item.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: item.isSelected ? Colors.black : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      color == Colors.white
                          ? Colors.grey[300]!
                          : Colors.transparent,
                  width: 1,
                ),
              ),
            ),
            SizedBox(width: 8),
            Text(
              item.name,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
