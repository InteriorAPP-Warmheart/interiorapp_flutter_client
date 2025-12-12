import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/showroom_tab/domain/entity/filter_entity.dart';

/// 일반 필터 칩 위젯 (재사용 가능)
class FilterChipWidget extends StatelessWidget {
  final FilterItem item;
  final VoidCallback onTap;
  final double? fontSize;

  const FilterChipWidget({
    super.key,
    required this.item,
    required this.onTap,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
          style: TextStyle(
            fontSize: fontSize ?? 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// 색상이 있는 필터 칩 위젯 (톤앤매너용, 재사용 가능)
class ColorFilterChipWidget extends StatelessWidget {
  final FilterItem item;
  final Color color;
  final VoidCallback onTap;
  final double? fontSize;

  const ColorFilterChipWidget({
    super.key,
    required this.item,
    required this.color,
    required this.onTap,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            const SizedBox(width: 8),
            Text(
              item.name,
              style: TextStyle(
                fontSize: fontSize ?? 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

