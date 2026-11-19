import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/build/ui/space_routes.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/widget/expanding_action_button.dart';
// 공사 진행률 카드. 홈 대시보드가 이 역할을 맡는 동안 화면에서는 빼 둔다.
// import 'package:interiorapp_flutter_client/home/ui/widget/my_build_project_widget.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/home/ui/widget/adv_widget.dart';
import 'package:interiorapp_flutter_client/home/ui/widget/home_space_dashboard.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/popular_showroom_card.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/post_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final ExpandingActionController _consult = ExpandingActionController();

  /// 스크롤 끝에서 진행률 카드를 한 줄로 접을 때 쓰던 위치.
  // bool _atBottom = false;

  /// 접힌 상담 버튼 크기. [ExpandingActionButton] 기본값과 맞춘다.
  static const double _consultSize = 56;

  /// 진행률 카드 위에서 상담 버튼을 띄우던 간격.
  // static const double _consultAboveCard = 12;

  /// 탭 바 위로 상담 버튼을 띄우는 간격.
  static const double _consultAboveTab = 16;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    // 이미지 높이가 잡히며 나는 알림은 스크롤이 아니다.
    if (!_scrollController.position.isScrollingNotifier.value) return;
    _consult.close();
    // 진행률 카드가 목록 끝에서 한 줄로 바뀌던 감지.
    // final position = _scrollController.position;
    // final bool isAtBottom = position.pixels >= position.maxScrollExtent - 24;
    // if (isAtBottom != _atBottom) {
    //   setState(() {
    //     _atBottom = isAtBottom;
    //   });
    // }
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

    // 진행률 카드가 떠 있을 때 상담 버튼을 카드 위로 올리던 계산.
    // final projects = ref.watch(projectListProvider);
    // final bool isProjectBuilding = projects.isNotEmpty;
    // final bool showProjectCard = isProjectBuilding && !_atBottom;
    // final double consultBottom =
    //     isProjectBuilding
    //         ? tabSlot +
    //             MyBuildProjectWidget.floatBottom +
    //             MyBuildProjectWidget.expandedHeight(context) +
    //             _consultAboveCard
    //         : tabSlot + _consultAboveTab;
    // final double projectCardReserve =
    //     showProjectCard
    //         ? consultBottom + _consultSize + MyBuildProjectWidget.overlayGap
    //         : isProjectBuilding
    //         ? tabSlot + MyBuildProjectWidget.floatBottom
    //         : consultBottom + _consultSize + MyBuildProjectWidget.overlayGap;

    final double sectionGap = ResponsiveSize.sectionGap(context);
    // extendBody가 알려 주는 탭바 실제 높이. 상담 버튼은 이 위로 둔다.
    final double tabSlot = MediaQuery.paddingOf(context).bottom;
    final double consultBottom = tabSlot + _consultAboveTab;
    final double bottomReserve = consultBottom + _consultSize + 12;

    return Scaffold(
      body: Stack(
        children: [
          Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => _consult.close(),
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.only(bottom: bottomReserve),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: sectionGap),
                  Padding(
                    padding: ResponsiveSize.textInset(context),
                    child: AdvWidget(
                      imageUrls: sampleImages,
                      borderRadius: 16,
                      indicatorColor: Colors.white54,
                      activeIndicatorColor: Colors.white,
                      indicatorSize: 8,
                    ),
                  ),
                  SizedBox(height: sectionGap),
                  const HomeSpaceDashboard(),
                  SizedBox(height: sectionGap),
                  const PostSection(
                    sectionTitle: '인기 쇼룸',
                    child: PopularShowroomCardList(),
                  ),
                  // TODO: 추천 시공사례 - 데이터 준비 후 활성화
                  // SizedBox(height: sectionGap),
                  // PostSection(
                  //   sectionTitle: '추천 시공사례',
                  //   child: ImageSliderWidget().recommendBuildInfo(ref: ref),
                  // ),
                  SizedBox(height: sectionGap),
                  // 스크롤 끝에서는 진행률을 한 줄로 접어 보여 주던 자리.
                  // if (isProjectBuilding && _atBottom) ...[
                  //   Center(child: MyBuildProjectWidget(atBottom: true)),
                  //   const SizedBox(height: 8),
                  // ],
                ],
              ),
            ),
          ),

          // 탭바 위에 공사 진행률을 항상 띄우던 카드.
          // if (showProjectCard)
          //   Positioned(
          //     bottom: tabSlot + MyBuildProjectWidget.floatBottom,
          //     left: 0,
          //     right: 0,
          //     child: Center(child: MyBuildProjectWidget(atBottom: false)),
          //   ),
          Positioned.fill(
            child: ExpandingActionButton(
              controller: _consult,
              icon: Icons.support_agent_outlined,
              label: '상담받기',
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              collapsedSize: _consultSize,
              bottom: consultBottom,
              onPressed: () => context.push(SpaceRoutes.prepCreate),
            ),
          ),
        ],
      ),
    );
  }
}

// 진행률 카드 표시용 테스트 목록. 카드가 다시 붙으면 홈에서 이 값을 본다.
// final projectListProvider = Provider<List<String>>(
//   (ref) => <String>[
//     'proj-1',
//     'proj-2',
//   ],
// );
