import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/home/ui/widget/my_build_project_widget.dart';
import 'package:interiorapp_flutter_client/core/theme/app_typography.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/home/ui/widget/adv_widget.dart';
import 'package:interiorapp_flutter_client/home/ui/widget/section.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/popular_showroom_card.dart';

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

    final projects = ref.watch(projectListProvider);
    final bool isProjectBuilding =
        projects.isNotEmpty; // 테스트용: 리스트가 비어있지 않으면 표시

    final double sectionGap = ResponsiveSize.sectionGap(context);
    final bool showProjectCard = isProjectBuilding && !_atBottom;
    // extendBody가 알려 주는 탭바 실제 높이. 카드와 맨 아래 버튼은 이 위로 둔다.
    final double tabSlot = MediaQuery.paddingOf(context).bottom;
    final double projectCardReserve =
        showProjectCard
            ? MyBuildProjectWidget.expandedHeight(context) +
                MyBuildProjectWidget.floatBottom +
                MyBuildProjectWidget.overlayGap +
                tabSlot
            : tabSlot + MyBuildProjectWidget.floatBottom;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: screenPadding.copyWith(bottom: projectCardReserve),
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

                // 인기 상품 슬라이더
                Section(
                  title: Text('인기 쇼룸', style: AppTypography.title(context)),
                  trailing: TextButton(
                    onPressed: () {},
                    child: Text('더보기', style: AppTypography.caption(context)),
                  ),
                  gap: ResponsiveSize.subGap(context) * 0,
                  child: const PopularShowroomCardList(),
                ),
                // TODO: 추천 시공사례 - 데이터 준비 후 활성화
                // SizedBox(height: sectionGap),
                // Section(
                //   title: Text('추천 시공사례', style: AppTypography.title(context)),
                //   trailing: TextButton(
                //     onPressed: () {},
                //     child: Text('더보기', style: AppTypography.caption(context)),
                //   ),
                //   gap: ResponsiveSize.subGap(context) * 0,
                //   child: ImageSliderWidget().recommendBuildInfo(ref: ref),
                // ),
                SizedBox(height: sectionGap),
                if (isProjectBuilding && _atBottom) ...[
                  Center(child: MyBuildProjectWidget(atBottom: true)),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),

          if (showProjectCard)
            Positioned(
              bottom: tabSlot + MyBuildProjectWidget.floatBottom,
              left: 0,
              right: 0,
              child: Center(child: MyBuildProjectWidget(atBottom: false)),
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
