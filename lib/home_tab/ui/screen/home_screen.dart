import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/home_tab/ui/widget/my_build_project_widget.dart';
import 'package:interiorapp_flutter_client/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/home_tab/ui/widget/adv_widget.dart';
import 'package:interiorapp_flutter_client/home_tab/ui/widget/section.dart';
import 'package:interiorapp_flutter_client/home_tab/ui/widget/image_slider_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _atBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final position = _scrollController.position;
    final bool isAtBottom = position.pixels >= position.maxScrollExtent - 24;
    if (isAtBottom != _atBottom) {
      setState(() {
        _atBottom = isAtBottom;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

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

    final projects = ref.watch(projectListProvider);
    final bool isProjectBuilding =
        projects.isNotEmpty; // 테스트용: 리스트가 비어있지 않으면 표시

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
        controller: _scrollController,
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
              child: ImageSliderWidget().showroomInfo(ref: ref),
            ),
            SizedBox(height: sectionGap),
            Section(
              title: Text(
                '추천 시공사례',
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
              child: ImageSliderWidget().recommendBuildInfo(ref: ref),
            ),
            SizedBox(height: sectionGap),
            // 항상 고정높이 공간을 예약해두고 콘텐츠를 스왑하는 방식
            if (isProjectBuilding) ...[
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child:
                    _atBottom
                        ? Center(
                          key: const ValueKey('footer'),
                          child: MyBuildProjectWidget(atBottom: _atBottom),
                        )
                        : SizedBox(
                          key: const ValueKey('spacer'),
                          height: MediaQuery.of(context).size.height * 0.1,
                        ),
              ),
              SizedBox(height: sectionGap),
            ],
          ],
        ),
      ),
      floatingActionButton:
          isProjectBuilding && !_atBottom
              ? MyBuildProjectWidget(atBottom: _atBottom)
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCategoryCard(String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
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

// 테스트 프로바이더
final projectListProvider = Provider<List<String>>(
  (ref) => <String>[
    // 비우면 FAB 숨김, 아이템 넣으면 FAB 표시
    'proj-1',
    'proj-2',
  ],
);
