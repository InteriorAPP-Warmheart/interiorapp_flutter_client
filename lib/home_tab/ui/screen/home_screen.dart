import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/home_tab/ui/widget/showroom_slider_widget.dart';
import 'package:interiorapp_flutter_client/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/home_tab/ui/widget/adv_widget.dart';
import 'package:interiorapp_flutter_client/home_tab/ui/widget/section.dart';
import 'package:interiorapp_flutter_client/home_tab/ui/widget/generic_carousel_section.dart';
import 'package:interiorapp_flutter_client/home_tab/presentation/provider/showroom_slider_provider.dart';
import 'package:interiorapp_flutter_client/home_tab/data/model/showroom_slider_model.dart';

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
              child: ImageSliderSection<ShowroomSliderModel>(
                watchItems: (ref) => ref.watch(showroomSliderProvider),
                imageBuilder: (context, item) {
                  return Stack(
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
                            Icon(Icons.bookmark_border, color: Colors.white, size: 30),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                infoBuilder: (context, item) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(maxWidth: 220, minHeight: 20),
                        child: Text(
                          item.themeName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(backgroundImage: NetworkImage(item.userProfileUrl), radius: 12),
                          const SizedBox(width: 6),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 120),
                            child: Text(
                              item.userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          const Text('좋아요', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey)),
                          const SizedBox(width: 2),
                          Text(
                            item.likeCount > 999 ? '999+' : item.likeCount.toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  );
                },
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
            child: ImageSliderSection<ShowroomSliderModel>(
              watchItems: (ref) => ref.watch(showroomSliderProvider),
              imageBuilder: (context, item) {
                return Image.network(item.thumbnailUrl, fit: BoxFit.cover);
              },
              infoBuilder: (context, item) {
                return Text(item.themeName);
              },
            ),
          ),
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
