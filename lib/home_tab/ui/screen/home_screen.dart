import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/home_tab/ui/widget/adv_widget.dart';
import 'package:interiorapp_flutter_client/home_tab/ui/widget/section.dart';
import 'package:interiorapp_flutter_client/home_tab/ui/widget/image_slider_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 샘플 이미지 URL들
    final List<String> sampleImages = [
      'https://picsum.photos/400/300?random=1',
      'https://picsum.photos/400/300?random=2',
      'https://picsum.photos/400/300?random=3',
      'https://picsum.photos/400/300?random=4',
    ];

    final EdgeInsets screenPadding = ResponsiveSize.responsivePadding(context);
    final double fontScale = ResponsiveSize.fontScale(context);

    // Grid 2열 카드 비율 계산
    const int gridColumns = 2;
    const double gridGap = 16.0;
    final double contentWidth =
        MediaQuery.of(context).size.width -
        (screenPadding.horizontal) -
        (gridGap * (gridColumns - 1));
    final double tileWidth = contentWidth / gridColumns;
    final double cardHeight = ResponsiveSize.gridTileHeightByWidth(
      tileWidth: tileWidth,
      aspectRatio: 3 / 4,
      minHeight: 140,
      maxHeight: 200,
    );
    final double childAspect = tileWidth / cardHeight;
    final double sectionGap = ResponsiveSize.sectionGap(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 메인 이미지 슬라이더
            SizedBox(height: sectionGap),
            AdvWidget(
              imageUrls: sampleImages,
              borderRadius: 16,
              indicatorColor: Colors.white54,
              activeIndicatorColor: Colors.white,
              indicatorSize: 8,
            ),
            SizedBox(height: sectionGap),

            // 카테고리 섹션
            Section(
              title: Text(
                '관심있는 인테리어 방식이 있나요?',
                style: TextStyle(
                  fontSize: 18 * fontScale,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspect,
                children: [
                  _buildCategoryCard('셀프 반셀프 인테리어', Icons.living),
                  _buildCategoryCard('외주 시공', Icons.bed),
                ],
              ),
            ),
            SizedBox(height: sectionGap),

            // 인기 상품 슬라이더
            Section(
              title: Text(
                '인기 쇼룸',
                style: TextStyle(
                  fontSize: 18 * fontScale,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
                child: const Text('더보기'),
              ),
              gap: ResponsiveSize.subGap(context) * 0,
              child: ImageSliderWidget().showroomInfo(
                ref: ref,
              ),
            ),
            SizedBox(height: sectionGap),
            Section(
              title: Text(
                '추천 시공사례',
                style: TextStyle(
                  fontSize: 18 * fontScale,
                  fontWeight: FontWeight.bold,
            ),),
            trailing: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                textStyle: const TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
              child: const Text('더보기'),
            ),
            gap: ResponsiveSize.subGap(context) * 0,
            child: ImageSliderWidget().recommendBuildInfo(
              ref: ref,
            ),
          ),
          SizedBox(height: sectionGap),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
