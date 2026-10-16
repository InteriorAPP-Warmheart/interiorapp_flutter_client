import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/theme/app_spacing.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/hot_showroom_model.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/provider/hot_showroom_provider.dart';

/// 인기 쇼룸. 대표 사진 한 장을 가로로 넘긴다.
class PopularShowroomCardList extends ConsumerWidget {
  const PopularShowroomCardList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<HotShowroomModel> items = ref.watch(hotShowroomSliderVm);
    if (items.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('표시할 항목이 없어요')),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = constraints.maxWidth * 0.78;
        final double imageHeight = cardWidth * 5 / 4;
        const double captionHeight = 128;
        return SizedBox(
          height: imageHeight + captionHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 18),
            itemBuilder: (context, index) {
              final HotShowroomModel item = items[index];
              return SizedBox(
                width: cardWidth,
                child: _LookbookCard(
                  item: item,
                  onFavorite: () {
                    ref
                        .read(hotShowroomSliderVm.notifier)
                        .toggleFavoriteByIndex(item.id);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _LookbookCard extends StatelessWidget {
  const _LookbookCard({required this.item, required this.onFavorite});

  final HotShowroomModel item;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final String likeLabel =
        item.likeCount > 999 ? '999+' : item.likeCount.toString();

    return GestureDetector(
      onTap: () => context.push('/showroom/${item.id}'),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.border, width: 0.7),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 4 / 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(url: item.thumbnailUrl),
                    Positioned(
                      top: 14,
                      right: 14,
                      child: GestureDetector(
                        onTap: onFavorite,
                        behavior: HitTestBehavior.opaque,
                        child: Icon(
                          item.favoriteStatus
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                              item.favoriteStatus
                                  ? AppColors.accent
                                  : AppColors.white,
                          size: 26,
                          shadows: const [
                            Shadow(
                              color: Color(0x99000000),
                              blurRadius: 6,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 128,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.themeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                          height: 1.2,
                          color: AppColors.accent,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                          height: 1.25,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Spacer(),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(item.userProfileUrl),
                            radius: 11,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${item.userName}  ·  좋아요 $likeLabel',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
