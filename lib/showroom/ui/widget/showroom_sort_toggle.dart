import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/widget/app_segment.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/provider/showroom_feed_browse_provider.dart';

const Color _favorite = Color(0xFFFF4D6A);

/// 왼쪽은 찜 상단, 오른쪽은 최신순·인기순.
class ShowroomSortToggle extends ConsumerWidget {
  const ShowroomSortToggle({super.key, required this.controller});

  final AppSegmentController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool pinFavorites = ref.watch(
      showroomFeedBrowseProvider.select(
        (ShowroomFeedBrowse browse) => browse.pinFavorites,
      ),
    );
    return Row(
      children: [
        _PinFavorites(
          selected: pinFavorites,
          onTap:
              () => ref
                  .read(showroomFeedBrowseProvider.notifier)
                  .setPinFavorites(!pinFavorites),
        ),
        const Spacer(),
        AppSegmentBar(
          controller: controller,
          labels: const <String>['최신순', '인기순'],
          expand: false,
          height: 30,
          fontSize: 12,
          trackColor: AppColors.background,
          thumbColor: AppColors.surface,
          selectedColor: AppColors.textPrimary,
          unselectedColor: AppColors.textSecondary,
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
