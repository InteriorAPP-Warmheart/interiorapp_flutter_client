import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/provider/showroom_feed_browse_provider.dart';

const Color _favorite = Color(0xFFFF4D6A);

/// 왼쪽은 찜 상단, 오른쪽은 최신순·인기순.
class ShowroomSortToggle extends ConsumerWidget {
  const ShowroomSortToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ShowroomFeedBrowse browse = ref.watch(showroomFeedBrowseProvider);
    return Row(
      children: [
        _PinFavorites(
          selected: browse.pinFavorites,
          onTap:
              () => ref
                  .read(showroomFeedBrowseProvider.notifier)
                  .setPinFavorites(!browse.pinFavorites),
        ),
        const Spacer(),
        _SortSegment(
          sort: browse.sort,
          onSelect:
              (ShowroomFeedSort sort) =>
                  ref.read(showroomFeedBrowseProvider.notifier).setSort(sort),
        ),
      ],
    );
  }
}

class _PinFavorites extends StatelessWidget {
  const _PinFavorites({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color =
        selected ? AppColors.textPrimary : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.favorite : Icons.favorite_border,
              size: 15,
              color: selected ? _favorite : AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              '찜 목록',
              style: TextStyle(
                fontSize: 13,
                height: 1.2,
                letterSpacing: -0.2,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortSegment extends StatelessWidget {
  const _SortSegment({required this.sort, required this.onSelect});

  final ShowroomFeedSort sort;
  final ValueChanged<ShowroomFeedSort> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SortOption(
            label: '최신순',
            selected: sort == ShowroomFeedSort.latest,
            onTap: () => onSelect(ShowroomFeedSort.latest),
          ),
          _SortOption(
            label: '인기순',
            selected: sort == ShowroomFeedSort.popular,
            onTap: () => onSelect(ShowroomFeedSort.popular),
          ),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            height: 1.2,
            letterSpacing: -0.2,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
