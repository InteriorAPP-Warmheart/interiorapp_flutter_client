import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/filter_entity.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/quick_filter_catalog.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/provider/filter_provider.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/filter_chip_widget.dart';

class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({super.key});

  static const Color _ink = AppColors.textPrimary;
  static const Color _line = AppColors.border;
  static const Color _mute = AppColors.textSecondary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FilterState filterState = ref.watch(filterProvider);
    final String category =
        quickFilterLabels.contains(filterState.selectedCategory)
            ? filterState.selectedCategory
            : industryFilterLabel;

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.86,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: _line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 4),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '필터',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    '닫기',
                    style: TextStyle(color: _ink, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox(
                height: 40,
                child: Row(
                  children: [
                    for (final String label in quickFilterLabels)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: _SheetCategoryTab(
                            label: quickFilterShortLabels[label] ?? label,
                            selected: label == category,
                            onTap:
                                () => ref
                                    .read(filterProvider.notifier)
                                    .selectCategory(label),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: _buildFilterContent(ref, filterState, category)),
          const Divider(height: 1, color: _line),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              16 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      ref.read(filterProvider.notifier).resetFilters();
                      ref
                          .read(filteredShowroomListProvider.notifier)
                          .fetchFiltered();
                    },
                    child: const Text(
                      '초기화',
                      style: TextStyle(
                        fontSize: 16,
                        color: _ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () {
                      ref
                          .read(filteredShowroomListProvider.notifier)
                          .fetchFiltered();
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '적용하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterContent(
    WidgetRef ref,
    FilterState filterState,
    String category,
  ) {
    switch (category) {
      case industryFilterLabel:
        return _buildIndustryFilter(ref, filterState);
      case areaFilterLabel:
        return _buildRangeFilter(
          ref: ref,
          filterState: filterState,
          question: '얼마나 큰 공간인가요?',
          helper: '비슷한 평수를 여러 구간으로 함께 볼 수 있어요.',
          categoryKey: areaFilterLabel,
          options: areaRangeOptions,
        );
      case budgetFilterLabel:
        return _buildRangeFilter(
          ref: ref,
          filterState: filterState,
          question: '얼마에 하셨나요?',
          helper: '실제 공사비와 가까운 구간을 고르세요.',
          categoryKey: budgetRangeCategoryKey,
          options: budgetRangeOptions,
        );
      case styleFilterLabel:
        return _buildStyleFilter(ref, filterState);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildIndustryFilter(WidgetRef ref, FilterState filterState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _QuestionHeader(
          question: '무슨 공간인가요?',
          helper: '대분류를 먼저 고르고, 필요할 때만 세부 업종을 선택하세요.',
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: industryCategories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final IndustryCategory category = industryCategories[index];
              final bool expanded =
                  filterState.expandedIndustryId == category.id;
              final bool majorSelected = _isItemSelected(
                filterState,
                industryFilterLabel,
                category.id,
              );
              final int detailCount =
                  category.details
                      .where(
                        (detail) => _isItemSelected(
                          filterState,
                          industryDetailCategoryKey,
                          detail.id,
                        ),
                      )
                      .length;

              return DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: majorSelected || detailCount > 0 ? _ink : _line,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        ref
                            .read(filterProvider.notifier)
                            .toggleExpandedIndustry(category.id);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                category.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _ink,
                                ),
                              ),
                            ),
                            if (detailCount > 0)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  '$detailCount',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _ink,
                                  ),
                                ),
                              )
                            else if (majorSelected)
                              const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Text(
                                  '전체',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _ink,
                                  ),
                                ),
                              ),
                            Icon(
                              expanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: _ink,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (expanded) ...[
                      const Divider(height: 1, color: _line),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilterChipWidget(
                                item: FilterItem(
                                  id: category.id,
                                  name: '이 업종 전체',
                                  isSelected: majorSelected,
                                ),
                                fontSize: 14,
                                onTap:
                                    () => _toggle(
                                      ref,
                                      () => ref
                                          .read(filterProvider.notifier)
                                          .toggleIndustryMajor(category.id),
                                    ),
                              ),
                              for (final IndustryDetail detail
                                  in category.details)
                                FilterChipWidget(
                                  item: FilterItem(
                                    id: detail.id,
                                    name: detail.name,
                                    isSelected: _isItemSelected(
                                      filterState,
                                      industryDetailCategoryKey,
                                      detail.id,
                                    ),
                                    parentId: category.id,
                                  ),
                                  fontSize: 14,
                                  onTap:
                                      () => _toggle(
                                        ref,
                                        () => ref
                                            .read(filterProvider.notifier)
                                            .toggleIndustryDetail(detail.id),
                                      ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRangeFilter({
    required WidgetRef ref,
    required FilterState filterState,
    required String question,
    required String helper,
    required String categoryKey,
    required List<NumericRangeOption> options,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _QuestionHeader(question: question, helper: helper),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: options.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final NumericRangeOption option = options[index];
              final bool selected = _isItemSelected(
                filterState,
                categoryKey,
                option.id,
              );
              return Material(
                color: selected ? AppColors.background : AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: InkWell(
                  onTap:
                      () => _toggle(
                        ref,
                        () => ref
                            .read(filterProvider.notifier)
                            .toggleFilterWithCategory(option.id, categoryKey),
                      ),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option.label,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _ink,
                            ),
                          ),
                        ),
                        Icon(
                          selected ? Icons.check_circle : Icons.circle_outlined,
                          color:
                              selected ? AppColors.primary : AppColors.border,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStyleFilter(WidgetRef ref, FilterState filterState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _QuestionHeader(
          question: '어떤 느낌의 공간을 찾고 계세요?',
          helper: '여러 느낌을 함께 고를 수 있어요.',
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.74,
            ),
            itemCount: styleMoodCards.length,
            itemBuilder: (context, index) {
              final StyleMoodCard card = styleMoodCards[index];
              final bool selected = _isItemSelected(
                filterState,
                styleMoodCategoryKey,
                card.id,
              );
              return _StyleMoodTile(
                card: card,
                selected: selected,
                onTap:
                    () => _toggle(
                      ref,
                      () => ref
                          .read(filterProvider.notifier)
                          .toggleFilterWithCategory(
                            card.id,
                            styleMoodCategoryKey,
                          ),
                    ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _isItemSelected(FilterState filterState, String categoryKey, String id) {
    final List<FilterItem> items =
        filterState.categoryItems[categoryKey] ?? const [];
    for (final FilterItem item in items) {
      if (item.id == id) return item.isSelected;
    }
    return false;
  }

  void _toggle(WidgetRef ref, VoidCallback change) {
    change();
    ref.read(filteredShowroomListProvider.notifier).fetchFiltered();
  }
}

class _SheetCategoryTab extends StatelessWidget {
  const _SheetCategoryTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color:
                  selected ? FilterBottomSheet._ink : FilterBottomSheet._mute,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionHeader extends StatelessWidget {
  const _QuestionHeader({required this.question, required this.helper});

  final String question;
  final String helper;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: FilterBottomSheet._ink,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            helper,
            style: const TextStyle(
              fontSize: 13,
              color: FilterBottomSheet._mute,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _StyleMoodTile extends StatelessWidget {
  const _StyleMoodTile({
    required this.card,
    required this.selected,
    required this.onTap,
  });

  final StyleMoodCard card;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(card.gradientStart),
                          Color(card.gradientEnd),
                        ],
                      ),
                    ),
                  ),
                  if (selected)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: FilterBottomSheet._ink,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: FilterBottomSheet._ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.35,
                      color: FilterBottomSheet._mute,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
