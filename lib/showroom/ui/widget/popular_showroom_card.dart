import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/hot_showroom_model.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/provider/hot_showroom_provider.dart';
import 'package:interiorapp_flutter_client/showroom/ui/screen/showroom_story_screen.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/story/showroom_story_scenes.dart';

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

    final double inset = ResponsiveSize.textInset(context).left;
    final double screen = MediaQuery.sizeOf(context).width;
    final double cardWidth = screen - inset - 48;
    final double imageHeight = cardWidth * 5 / 4;
    return SizedBox(
      height: imageHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: inset),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 18),
        itemBuilder: (context, index) {
          final HotShowroomModel item = items[index];
          return SizedBox(
            width: cardWidth,
            child: OpenContainer(
              useRootNavigator: true,
              tappable: false,
              closedElevation: 0,
              openElevation: 0,
              closedColor: storyInk,
              openColor: storyInk,
              closedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              openShape: const RoundedRectangleBorder(),
              closedBuilder: (BuildContext context, VoidCallback open) {
                return _LookbookCard(
                  item: item,
                  onOpen: open,
                  onFavorite: () {
                    ref
                        .read(hotShowroomSliderVm.notifier)
                        .toggleFavoriteByIndex(item.id);
                  },
                );
              },
              openBuilder: (BuildContext context, VoidCallback close) {
                return ShowroomStoryScreen(showroomId: item.id);
              },
            ),
          );
        },
      ),
    );
  }
}

class _LookbookCard extends StatelessWidget {
  const _LookbookCard({
    required this.item,
    required this.onOpen,
    required this.onFavorite,
  });

  final HotShowroomModel item;
  final VoidCallback onOpen;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final String likeLabel =
        item.likeCount > 999 ? '999+' : item.likeCount.toString();

    return GestureDetector(
      onTap: onOpen,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(url: item.thumbnailUrl),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 88,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.62),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 14,
              right: 14,
              child: GestureDetector(
                onTap: onFavorite,
                behavior: HitTestBehavior.opaque,
                child: Icon(
                  item.favoriteStatus ? Icons.favorite : Icons.favorite_border,
                  color:
                      item.favoriteStatus
                          ? const Color(0xFFFF4D6A)
                          : AppColors.white,
                  size: 24,
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
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.themeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      color: Color(0xE6FFFFFF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: AppNetworkImage(url: item.userProfileUrl),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          item.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                            color: Color(0xCCFFFFFF),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.favorite,
                        size: 13,
                        color: Color(0xCCFFFFFF),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        likeLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                          color: Color(0xCCFFFFFF),
                        ),
                      ),
                    ],
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
