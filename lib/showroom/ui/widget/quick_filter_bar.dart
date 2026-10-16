import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/filter_entity.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/quick_filter_catalog.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/provider/filter_provider.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/filter_bottomsheet.dart';

class QuickFilterBar extends ConsumerWidget {
  const QuickFilterBar({super.key});

  static const Color ink = AppColors.textPrimary;
  static const Color mute = AppColors.textSecondary;
  static const Color faint = AppColors.textSecondary;
  static const Color paper = AppColors.surface;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<SelectedFilter> selected =
        ref.watch(filterProvider).selectedFilters;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var index = 0; index < quickFilterLabels.length; index++) ...[
          if (index > 0) const SizedBox(width: 6),
          Expanded(
            child: _FilterCell(
              eyebrow: quickFilterShortLabels[quickFilterLabels[index]]!,
              value: _valueLabel(quickFilterLabels[index], selected),
              selected: selected.any(
                (filter) => filter.category == quickFilterLabels[index],
              ),
              onTap: () => _openSheet(context, ref, quickFilterLabels[index]),
            ),
          ),
        ],
        if (selected.isNotEmpty) ...[
          const SizedBox(width: 8),
          _ResetIconButton(
            onTap: () {
              ref.read(filterProvider.notifier).resetFilters();
              ref.read(filteredShowroomListProvider.notifier).fetchFiltered();
            },
          ),
        ],
      ],
    );
  }

  String _valueLabel(String label, List<SelectedFilter> selected) {
    final List<SelectedFilter> matched =
        selected.where((filter) => filter.category == label).toList();
    if (matched.isEmpty) return '전체';
    if (matched.length == 1) return matched.first.name;
    return '${matched.length}개 선택';
  }

  void _openSheet(BuildContext context, WidgetRef ref, String category) {
    ref.read(filterProvider.notifier).selectCategory(category);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const FilterBottomSheet(),
    );
  }
}

class _FilterCell extends StatelessWidget {
  const _FilterCell({
    required this.eyebrow,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String eyebrow;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  height: 1,
                  fontWeight: FontWeight.w500,
                  color:
                      selected
                          ? const Color(0xB3FFFFFF)
                          : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResetIconButton extends StatelessWidget {
  const _ResetIconButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '필터 초기화',
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: const SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              Icons.restart_alt_rounded,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
