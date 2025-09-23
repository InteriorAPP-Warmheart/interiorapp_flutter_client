import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:interiorapp_flutter_client/utils/responsive_size.dart';

/// 제네릭 캐러셀 섹션: 데이터 provider + 아이템/푸터 빌더로 재사용
class ImageSliderSection<T> extends ConsumerWidget {
  /// 데이터 구독 함수를 받아 타입 이슈를 피하고 유연성을 높임
  final AsyncValue<List<T>> Function(WidgetRef ref) watchItems;
  final Widget Function(BuildContext context, T item) imageBuilder;
  final Widget Function(BuildContext context, T item) infoBuilder;
  final double viewportFraction;
  final double gap;

  const ImageSliderSection({
    super.key,
    required this.watchItems,
    required this.imageBuilder,
    required this.infoBuilder,
    this.viewportFraction = 0.95,
    this.gap = 12.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = watchItems(ref);
    final double width = MediaQuery.of(context).size.width;
    final double height = ResponsiveSize.bannerHeight(
      context,
      maxWidth: width,
      aspectRatio: 16 / 9,
      minHeight: 160,
      maxHeight: 280,
      useResponsiveHeight: true,
    );
    const double spacer = 0.0;
    const double infoHeight = 40.0;
    final double cardHeight = height + spacer + infoHeight;

    return asyncItems.when(
      loading: () => SizedBox(
        height: cardHeight,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => SizedBox(
        height: cardHeight,
        child: Center(child: Text('불러오기 실패')),
      ),
      data: (items) {
        if (items.isEmpty) {
          return SizedBox(
            height: cardHeight,
            child: const Center(child: Text('표시할 항목이 없어요')),
          );
        }

        return SizedBox(
          height: cardHeight,
          child: CarouselSlider.builder(
            itemCount: items.length,
            itemBuilder: (context, index, realIndex) {
              final item = items[index];
              final bool isFirst = index == 0;
              final bool isLast = index == items.length - 1;
              final EdgeInsets itemPadding = isFirst
                  ? EdgeInsets.only(right: gap)
                  : (isLast
                      ? EdgeInsets.only(left: gap)
                      : EdgeInsets.symmetric(horizontal: gap / 2));

              return Padding(
                padding: itemPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: height,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: imageBuilder(context, item),
                      ),
                    ),
                    const SizedBox(height: spacer),
                    SizedBox(height: infoHeight, child: infoBuilder(context, item)),
                  ],
                ),
              );
            },
            options: CarouselOptions(
              height: cardHeight,
              viewportFraction: viewportFraction,
              padEnds: false,
              disableCenter: false,
              enableInfiniteScroll: false,
              initialPage: 0,
              autoPlay: false,
            ),
          ),
        );
      },
    );
  }
}


