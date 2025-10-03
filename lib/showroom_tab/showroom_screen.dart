import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/home_tab/ui/widget/image_slider_widget.dart';
import 'package:interiorapp_flutter_client/showroom_tab/presentation/provider/filter_provider.dart';
import 'package:interiorapp_flutter_client/showroom_tab/ui/widget/filter_bottomsheet.dart';
import 'package:interiorapp_flutter_client/showroom_tab/ui/widget/post_section.dart';
import 'package:interiorapp_flutter_client/utils/responsive_size.dart';

class ShowroomScreen extends ConsumerStatefulWidget {
  const ShowroomScreen({super.key});

  @override
  ConsumerState<ShowroomScreen> createState() => _ShowroomScreenState();
}

class _ShowroomScreenState extends ConsumerState<ShowroomScreen> {
  @override
  Widget build(BuildContext context) {
    final double sectionGap = ResponsiveSize.sectionGap(context);
    final EdgeInsets screenPadding = ResponsiveSize.responsivePadding(context);
    final filterState = ref.watch(filterProvider);
    final hasSelectedFilters = ref.watch(hasSelectedFiltersProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              // 광고 Section
              Container(
                color: const Color.fromARGB(255, 233, 233, 233),
                height: 150,
                width: double.infinity,
                child: Center(
                  child: Text(
                    '광고',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ),
              ),
              SizedBox(height: sectionGap),
              Padding(
                padding: screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 필터링 버튼 Section
                    _rowFilterButton('필터', '스타일'),
                    SizedBox(height: 8),
                    _rowFilterButton('공간 형태', '예산'),
                    SizedBox(height: 8),
                    _rowFilterButton('톤앤매너', '소재'),

                    // 선택된 필터 칩들 (있을 경우에만 표시)
                    if (hasSelectedFilters) ...[
                      SizedBox(height: 16),
                      _buildSelectedFiltersSection(filterState),
                      SizedBox(height: sectionGap),

                      // 베스트 게시물 섹션 추가
                      _buildFilteredShowroomList(),
                    ] else ...[
                      SizedBox(height: sectionGap),

                      // 인기 쇼룸 Section
                      PostSection(
                        sectionTitle: '인기 쇼룸',
                        onPressed: () {},
                        child: ImageSliderWidget().showroomInfo(ref: ref),
                      ),
                      SizedBox(height: sectionGap),

                      // 동네 게시물 Section
                      PostSection(
                        sectionTitle: '동네 게시물',
                        onPressed: () {},
                        child: ImageSliderWidget().showroomInfo(ref: ref),
                      ),
                      SizedBox(height: sectionGap),

                      // 추천 시공 Section
                      PostSection(
                        sectionTitle: '추천 시공',
                        onPressed: () {},
                        child: ImageSliderWidget().recommendBuildInfo(ref: ref),
                      ),
                      SizedBox(height: sectionGap),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // 글쓰기 버튼
      floatingActionButton: SizedBox(
        width: 100,
        height: 40,
        child: FloatingActionButton.extended(
          onPressed: () {},
          icon: Icon(Icons.add, color: Colors.black, size: 18),
          label: Text(
            '글쓰기',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 253, 252, 252),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: Colors.white, width: 0),
          ),
          extendedIconLabelSpacing: 2,
        ),
      ),
    );
  }

  // 필터링 버튼
  Widget _rowFilterButton(String leftText, String rightText) {
    final filterState = ref.watch(filterProvider);

    return Row(
      children: [
        _buildCategoryButton(leftText, filterState),
        SizedBox(width: 8),
        _buildCategoryButton(rightText, filterState),
      ],
    );
  }

  // 카테고리 버튼
  Widget _buildCategoryButton(String category, filterState) {
    final hasSelection = filterState.selectedFilters.any((filter) {
      if (category == '필터') return false;
      if (category == '스타일') return filter.category == '스타일';
      if (category == '공간 형태') return filter.category == '공간 형태';
      if (category == '예산') return filter.category == '예산';
      if (category == '톤앤매너') return filter.category == '톤앤매너';
      if (category == '소재') return filter.category == '소재';
      return false;
    });

    return Expanded(
      child: InkWell(
        onTap: () {
          // 바텀시트 열기 전에 먼저 카테고리 설정하도록 함!
          if (category != '필터') {
            ref.read(filterProvider.notifier).selectCategory(category);
          }

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => FilterBottomSheet(),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: hasSelection ? Colors.black : Colors.grey[400]!,
              width: hasSelection ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            category,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontWeight: hasSelection ? FontWeight.bold : FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  // 선택된 필터 Section
  Widget _buildSelectedFiltersSection(filterState) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: const Color.fromARGB(255, 232, 232, 232),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filterState.selectedFilters.length,
          separatorBuilder: (context, index) => SizedBox(width: 8),
          itemBuilder: (context, index) {
            final filter = filterState.selectedFilters[index];
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    filter.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                    ref
                        .read(filterProvider.notifier)
                        .removeSelectedFilter(filter.id);
                    ref
                        .read(filteredShowroomListProvider.notifier)
                        .fetchFiltered();
                    },
                    child: Icon(Icons.close, size: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilteredShowroomList() {
  final filteredShowrooms = ref.watch(filteredShowroomListProvider);
  final double sectionGap = ResponsiveSize.sectionGap(context);
  

  return filteredShowrooms.when(
    data: (showrooms) {
      if (showrooms.isEmpty) {
        return _filterEmptyPostsSection();
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: showrooms.length,
        separatorBuilder: (context, index) => SizedBox(height: sectionGap),
        itemBuilder: (context, index) {
          final item = showrooms[index];
          return Container(
            height: 280,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                // 이미지 영역 (showroomInfo와 동일)
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
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
                                Colors.black.withValues(alpha: 0.0),
                                Colors.black.withValues(alpha: 0.55),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 2,
                          bottom: 0,
                          child: Row(
                            children: [
                              Expanded(child: SizedBox()),
                              IconButton(
                                onPressed: () {
                                  // 즐겨찾기 토글 로직
                                  // ref.read(filteredShowroomListProvider.notifier)
                                  //     .toggleFavorite(item.id);
                                },
                                icon: Icon(
                                  item.favoriteStatus
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(item.userProfileUrl),
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
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 12,
                          child: VerticalDivider(
                            width: 10,
                            thickness: 1,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const Text(
                          '좋아요',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          item.likeCount > 999
                              ? '999+'
                              : item.likeCount.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
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
      );
    },
    loading: () => Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(),
      ),
    ),
    error: (error, stack) => Center(child: Text('오류가 발생: $error')),
  );
}

//해당하는 검색결과가 없는 PostSection
  Widget _filterEmptyPostsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  '필터에 맞는 결과가 없어요',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: ElevatedButton(
                    onPressed: () {
                    ref.read(filterProvider.notifier).resetFilters();
                    ref
                        .read(filteredShowroomListProvider.notifier)
                        .fetchFiltered();
                  },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '쇼룸으로 돌아가기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: OutlinedButton(
                    onPressed: () {
                      //홈으로 가기 라우터
                      // GoRouter.of(context).go('/추후 예정');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.white),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '홈으로 가기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
