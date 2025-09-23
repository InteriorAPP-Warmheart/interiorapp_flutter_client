import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/home_tab/ui/widget/showroom_slider_widget.dart';
import 'package:interiorapp_flutter_client/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/home_tab/ui/widget/adv_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      body: SingleChildScrollView(
        padding: screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 메인 이미지 슬라이더
            const SizedBox(height: 16),
            AdvWidget(
              imageUrls: sampleImages,
              borderRadius: 16,
              indicatorColor: Colors.white54,
              activeIndicatorColor: Colors.white,
              indicatorSize: 8,
            ),

            const SizedBox(height: 32),

            // 카테고리 섹션
            Text(
              '관심있는 인테리어 방식이 있나요?',
              style: TextStyle(
                fontSize: 18 * fontScale,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 그리드 카테고리
            GridView.count(
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

            const SizedBox(height: 32),

            // 인기 상품 슬라이더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '인기 쇼룸',
                  style: TextStyle(
                    fontSize: 18 * fontScale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  child: const Text('더보기'),
                ),
              ],
            ),

            // 인기 쇼룸 슬라이더
            const ShowroomSliderWidget(),

            SizedBox(height: 32),
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
