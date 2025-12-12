import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/components/components_widget/filter_chip_widget.dart';
import 'package:interiorapp_flutter_client/showroom_tab/domain/entity/filter_entity.dart';

/// 공간 형태 필터 위젯 (주거/상업 공간 선택 및 하위 카테고리)
class SpaceTypeFilterWidget extends StatelessWidget {
  final FilterState filterState;
  final Function(String) onSpaceTypeToggle; // 'residential' 또는 'commercial'
  final Function(String) onFilterToggle; // 필터 아이템 토글
  final double? fontSize;
  final double? buttonHeight;
  final double? spacing;

  const SpaceTypeFilterWidget({
    super.key,
    required this.filterState,
    required this.onSpaceTypeToggle,
    required this.onFilterToggle,
    this.fontSize,
    this.buttonHeight,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 주거/상업 공간 선택 버튼
        Row(
          children: [
            Expanded(
              child: _buildSpaceTypeButton(
                'residential',
                '주거 공간',
                filterState.selectedSpaceType == 'residential',
                onSpaceTypeToggle,
              ),
            ),
            SizedBox(width: spacing ?? 17),
            Expanded(
              child: _buildSpaceTypeButton(
                'commercial',
                '상업 공간',
                filterState.selectedSpaceType == 'commercial',
                onSpaceTypeToggle,
              ),
            ),
          ],
        ),

        // 선택된 공간에 따른 하위 카테고리 표시
        if (filterState.selectedSpaceType == 'residential') ...[
          SizedBox(height: spacing ?? 40),
          _buildCategorySection(
            '주거 공간',
            filterState.categoryItems['주거_공간'] ?? [],
            onFilterToggle,
          ),
          SizedBox(height: spacing ?? 40),
          _buildCategorySection(
            '세부 항목',
            filterState.categoryItems['주거_세부'] ?? [],
            onFilterToggle,
          ),
        ] else if (filterState.selectedSpaceType == 'commercial') ...[
          SizedBox(height: spacing ?? 24),
          _buildCategorySection(
            '상업 공간',
            filterState.categoryItems['상업_공간'] ?? [],
            onFilterToggle,
          ),
          SizedBox(height: spacing ?? 24),
          _buildCategorySection(
            '세부 항목',
            filterState.categoryItems['상업_세부'] ?? [],
            onFilterToggle,
          ),
        ],
      ],
    );
  }

  /// 공간 타입 선택 버튼
  Widget _buildSpaceTypeButton(
    String spaceTypeId,
    String label,
    bool isSelected,
    Function(String) onTap,
  ) {
    return GestureDetector(
      onTap: () => onTap(spaceTypeId),
      child: Container(
        height: buttonHeight ?? 60,
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
              fontSize: fontSize ?? 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// 카테고리 섹션 빌드
  Widget _buildCategorySection(
    String title,
    List<FilterItem> items,
    Function(String) onFilterToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize ?? 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            return FilterChipWidget(
              item: item,
              onTap: () => onFilterToggle(item.id),
              fontSize: fontSize,
            );
          }).toList(),
        ),
      ],
    );
  }
}

