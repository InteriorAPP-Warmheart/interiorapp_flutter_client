import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
          color: const Color(0xFFF6F4F1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE4DFD8)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 4 / 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      item.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const ColoredBox(color: Color(0xFFE6E6E6));
                      },
                    ),
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
                                  ? const Color(0xFFFF4D6A)
                                  : Colors.white,
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
                          color: Color(0xFF8A8A8A),
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
                          color: Color(0xFF1A1A1A),
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
                                color: Color(0xFF333333),
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
