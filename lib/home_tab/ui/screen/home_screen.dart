import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/home_tab/ui/widget/my_build_project_widget.dart';
import 'package:interiorapp_flutter_client/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/home_tab/ui/widget/adv_widget.dart';
import 'package:interiorapp_flutter_client/home_tab/ui/widget/section.dart';
import 'package:interiorapp_flutter_client/home_tab/ui/widget/image_slider_widget.dart';

enum CategoryType { self, outsourcing }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _atBottom = false;
  bool _isCardExpanded = false;
  CategoryType? _expandedCardType;
  late AnimationController _cardController;
  late AnimationController _rotationController;
  late Animation<double> _cardAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // 카드 크기 애니메이션 (열기: 600ms, 닫기: 300ms)
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // 회전 애니메이션 (열기: 800ms, 닫기: 400ms)
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // 크기 애니메이션 (1.0 ↔ 1.5)
    _cardAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeInOut),
    );

    // 회전 애니메이션 (0 ↔ π)
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 3.14159265359, // π (180도)
    ).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
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

  void _onCardTap(CategoryType type) {
    if (_isCardExpanded && _expandedCardType == type) {
      // 같은 카드를 다시 탭하면 닫기 - 역순 애니메이션
      _closeCard();
    } else {
      // 다른 카드나 처음 탭하면 열기
      _openCard(type);
    }
  }

  void _openCard(CategoryType type) {
    setState(() {
      _isCardExpanded = true;
      _expandedCardType = type;
    });
    
    // 열기 애니메이션: 크기 확대 후 회전 시작 (느린 속도)
    _cardController.duration = const Duration(milliseconds: 600);
    _rotationController.duration = const Duration(milliseconds: 800);
    
    _cardController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _rotationController.forward();
    });
  }

  void _closeCard() {
    // 닫기 애니메이션: 빠른 속도로 설정 후 역순 실행
    _cardController.duration = const Duration(milliseconds: 300);
    _rotationController.duration = const Duration(milliseconds: 400);
    
    // 먼저 회전 복원, 그 다음 크기 축소
    _rotationController.reverse().then((_) {
      _cardController.reverse().then((_) {
        setState(() {
          _isCardExpanded = false;
          _expandedCardType = null;
        });
      });
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _cardController.dispose();
    _rotationController.dispose();
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
    const double gridGap = 12.0;
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
      body: Stack(
        children: [
          // 메인 콘텐츠
          SingleChildScrollView(
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

                // 카테고리 섹션 (제목만)
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
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: childAspect,
                    children: [
                      SizedBox(
                        height: cardHeight, // 카드 크기 고정
                        child:
                            (_isCardExpanded &&
                                    _expandedCardType == CategoryType.self)
                                ? Container() // 확장된 카드는 숨기기
                                : _buildGridCard(
                                  '셀프 반셀프 인테리어',
                                  Icons.living,
                                  CategoryType.self,
                                ),
                      ),
                      SizedBox(
                        height: cardHeight,
                        child:
                            (_isCardExpanded &&
                                    _expandedCardType ==
                                        CategoryType.outsourcing)
                                ? Container() // 확장된 카드는 숨기기
                                : _buildGridCard(
                                  '외주 시공',
                                  Icons.bed,
                                  CategoryType.outsourcing,
                                ),
                      ),
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
                        color: Colors.black,
                      ),
                    ),
                    child: const Text(
                      '더보기',
                      style: TextStyle(color: Colors.black),
                    ),
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
                    child: const Text(
                      '더보기',
                      style: TextStyle(color: Colors.black),
                    ),
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

          // 배경 오버레이 (카드가 확장될 때)
          if (_isCardExpanded)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeCard, // 배경 탭하면 역순 애니메이션으로 닫기
                child: Container(color: Colors.black.withValues(alpha: 0.5)),
              ),
            ),

          // 확장된 카드 (화면 중앙에 표시)
          if (_isCardExpanded)
            Positioned.fill(
              child: Center(
                child: Hero(
                  tag:
                      'category_${_expandedCardType!.name}', // 그리드 카드와 동일한 Hero 태그
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _cardAnimation,
                      _rotationAnimation,
                    ]),
                    builder: (context, child) {
                      final isBackSide = _rotationAnimation.value > 1.57079632679; // π/2

                      return Transform.scale(
                        scale: _cardAnimation.value,
                        child: Transform(
                          alignment: Alignment.center,
                          transform:
                              Matrix4.identity()
                                ..setEntry(3, 2, 0.001) // 원근감
                                ..rotateY(_rotationAnimation.value),
                          child:
                              isBackSide
                                  ? Transform(
                                    alignment: Alignment.center,
                                    transform:
                                        Matrix4.identity()
                                          ..rotateY(3.14159265359), // π (180도)
                                    child: _buildBackCard(),
                                  )
                                  : _buildFrontCard(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

          // FloatingActionButton (카드가 확장되지 않았을 때만 표시)
          if (!_isCardExpanded && isProjectBuilding && !_atBottom)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(child: MyBuildProjectWidget(atBottom: _atBottom)),
            ),
        ],
      ),
    );
  }

  Widget _buildGridCard(String title, IconData icon, CategoryType type) {
    return GestureDetector(
      onTap: () => _onCardTap(type),
      child: Hero(
        tag: 'category_${type.name}', // 고유한 Hero 태그
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.grey[600]),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 200,
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _expandedCardType == CategoryType.self ? Icons.living : Icons.bed,
              size: 60,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              _expandedCardType == CategoryType.self ? '셀프 반셀프 인테리어' : '외주 시공',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 200,
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.blueGrey[600],
        ),
        child: Column(
          children: [
            // 닫기 버튼
            Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: GestureDetector(
                  onTap: _closeCard, // 역순 애니메이션으로 닫기
                  child: const Icon(Icons.close, size: 20, color: Colors.white),
                ),
              ),
            ),

            // 내용
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 50, color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      _expandedCardType == CategoryType.self
                          ? '셀프 반셀프 인테리어'
                          : '외주 시공',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
