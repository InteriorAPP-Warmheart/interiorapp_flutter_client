import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:interiorapp_flutter_client/home_tab/presentation/provider/showroom_slider_provider.dart';
import 'package:interiorapp_flutter_client/utils/responsive_size.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowroomSliderWidget extends ConsumerWidget {
  const ShowroomSliderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(showroomSliderProvider);
    final currentIndex = ref.watch(showroomSliderIndexProvider);

    final double width = MediaQuery.of(context).size.width;
    final double height = ResponsiveSize.bannerHeight(
      context,
      maxWidth: width,
      aspectRatio: 16 / 9,
      minHeight: 160,
      maxHeight: 280,
      useResponsiveHeight: true,
    );
    const double vf = 0.95; // 슬라이드 가시 폭 비율
    const double gap = 12.0; // 카드 간 간격 (오른쪽 여백)

    return asyncItems.when(
      loading:
          () => SizedBox(
            width: double.infinity,
            height: height,
            child: const Center(child: CircularProgressIndicator()),
          ),
      error:
          (e, st) => SizedBox(
            width: double.infinity,
            height: height,
            child: Center(
              child: Text(
                '쇼룸을 불러오지 못했어요',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
      data: (items) {
        if (items.isEmpty) {
          return SizedBox(
            width: double.infinity,
            height: height,
            child: const Center(child: Text('표시할 쇼룸이 없어요')),
          );
        }

        // 카드 단위로 "이미지 + 아래 정보"를 한 묶음으로 만들어 슬라이더에 쌓기
        const double spacer = 8.0; // 이미지-정보 간격
        const double infoHeight = 40.0; // 정보 영역 고정 높이(한 줄 표시)
        final double cardHeight = height + spacer + infoHeight;
        final double imageHeight = height;

        return SizedBox(
          height: cardHeight,
          child: CarouselSlider.builder(
            itemCount: items.length,
            itemBuilder: (context, index, realIndex) {
              final item = items[index];
              final bool isFirst = index == 0;
              final bool isLast = index == items.length - 1;
              final EdgeInsets itemPadding = isFirst
                  ? const EdgeInsets.only(right: gap)
                  : (isLast
                      ? const EdgeInsets.only(left: gap)
                      : EdgeInsets.symmetric(horizontal: gap / 2));
              return Padding(
                padding: itemPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이미지
                    SizedBox(
                      height: imageHeight,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(item.thumbnailUrl, fit: BoxFit.cover),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.black.withOpacity(0.0),
                                    Colors.black.withOpacity(0.55),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 15,
                              bottom: 12,
                              child: Row(
                                children: const [
                                  Expanded(child: SizedBox()),
                                  Icon(
                                    Icons.bookmark_border,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: spacer),
                    // 아래 정보(한 줄) - themeName은 좌측, 나머지는 우측 정렬
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: themeName pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            maxWidth: 220,
                            minHeight: 20,
                          ),
                          child: Text(
                            item.themeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                item.userProfileUrl,
                              ),
                              radius: 12,
                            ),
                            const SizedBox(width: 6),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: Text(
                                item.userName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 12, // 텍스트 높이와 맞춤
                              child: VerticalDivider(
                                width: 10, // 좌우 여백 포함
                                thickness: 1,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            Text('${'좋아요'} ${item.likeCount > 999 ? '999+' : item.likeCount.toString()}',
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            options: CarouselOptions(
              height: cardHeight,
              viewportFraction: vf,
              padEnds: false,
              disableCenter: false,
              enableInfiniteScroll: false,
              // pageSnapping: false,
              initialPage: 0,
              autoPlay: false,
              onPageChanged:
                  (index, reason) => ref
                      .read(showroomSliderIndexProvider.notifier)
                      .changeIndex(index),
            ),
          ),
        );
      },
    );
  }
}
