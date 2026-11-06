import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// TODO: 추천 시공 활성화 시 다시 추가
// import 'package:interiorapp_flutter_client/home/ui/widget/image_slider_widget.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/filter_showroom_model.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/provider/filter_provider.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/provider/showroom_feed_browse_provider.dart';
// TODO: 폴라로이드 카드 다시 쓸 때 복구
// import 'package:interiorapp_flutter_client/showroom/ui/widget/panorama_showroom_card.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/quick_filter_bar.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/popular_showroom_card.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/post_section.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_feed_segment.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_sort_toggle.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_segment.dart';

class ShowroomScreen extends ConsumerStatefulWidget {
  const ShowroomScreen({super.key});

  @override
  ConsumerState<ShowroomScreen> createState() => _ShowroomScreenState();
}

class _ShowroomScreenState extends ConsumerState<ShowroomScreen> {
  @override
  Widget build(BuildContext context) {
    final double sectionGap = ResponsiveSize.sectionGap(context);
    final EdgeInsets screenPadding = ResponsiveSize.textInset(context);
    final hasSelectedFilters = ref.watch(hasSelectedFiltersProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        child: Center(
          child: Column(
            children: [
              // 광고 Section
              Container(
                color: const Color.fromARGB(255, 233, 233, 233),
                height: ResponsiveSize.bannerHeight(
                  context,
                  maxWidth: MediaQuery.sizeOf(context).width,
                  aspectRatio: 21 / 9,
                  minHeight: 96,
                  maxHeight: 180,
                ),
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
                    const QuickFilterBar(),
                    if (hasSelectedFilters) ...[
                      SizedBox(height: sectionGap),
                      _buildFilteredShowroomList(),
                    ],
                  ],
                ),
              ),
              if (!hasSelectedFilters)
                Padding(
                  padding: const EdgeInsets.only(top: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PostSection(
                        sectionTitle: '인기 쇼룸',
                        child: const PopularShowroomCardList(),
                      ),
                      SizedBox(height: sectionGap),
                      Padding(
                        padding: screenPadding,
                        child: const ShowroomFeedSegment(),
                      ),
                      // TODO: 추천 시공 - 데이터 준비 후 활성화
                      // SizedBox(height: sectionGap),
                      // PostSection(
                      //   sectionTitle: '추천 시공',
                      //   child: ImageSliderWidget().recommendBuildInfo(ref: ref),
                      // ),
                    ],
                  ),
                ),
              SizedBox(height: sectionGap + 10),
            ],
          ),
        ),
      ),

      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        child: FloatingActionButton(
          onPressed: () => context.push('/showroom-write'),
          tooltip: '글쓰기',
          elevation: 2,
          highlightElevation: 3,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: const CircleBorder(),
          child: const Icon(Icons.edit_outlined, size: 22),
        ),
      ),
    );
  }

  Widget _buildFilteredShowroomList() {
    final filteredShowrooms = ref.watch(filteredShowroomListProvider);

    final showrooms = filteredShowrooms.value ?? const [];
    if (filteredShowrooms.isLoading && showrooms.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (filteredShowrooms.hasError && showrooms.isEmpty) {
      return Center(child: Text('오류가 발생: ${filteredShowrooms.error}'));
    }

    return filteredShowrooms.when(
      skipLoadingOnReload: true,
      data: (List<FilteredShowroomModel> showrooms) {
        final bool pinFavorites = ref.watch(
          showroomFeedBrowseProvider.select(
            (ShowroomFeedBrowse browse) => browse.pinFavorites,
          ),
        );
        final ShowroomFeedSort initialSort =
            ref.read(showroomFeedBrowseProvider).sort;
        return AppSegmentHost(
          length: 2,
          initialIndex: initialSort == ShowroomFeedSort.popular ? 1 : 0,
          onChanged: (int index) {
            ref
                .read(showroomFeedBrowseProvider.notifier)
                .setSort(
                  index == 0
                      ? ShowroomFeedSort.latest
                      : ShowroomFeedSort.popular,
                );
          },
          builder: (BuildContext context, AppSegmentController segment) {
            Widget page(ShowroomFeedSort sort) {
              final List<FilteredShowroomModel> ordered = sortedShowroomFeed(
                showrooms,
                sort,
                likes: (FilteredShowroomModel item) => item.likeCount,
                publishedAt: (FilteredShowroomModel item) => item.publishedAt,
                pinFavorites: pinFavorites,
                favorite: (FilteredShowroomModel item) => item.favoriteStatus,
              );
              if (ordered.isEmpty) return _filterEmptyPostsSection();
              return ShowroomMasonryGrid(
                items: [
                  for (final FilteredShowroomModel item in ordered)
                    ShowroomMasonryEntry(
                      id: item.id,
                      imageUrl: item.thumbnailUrl,
                      title: item.title,
                      imageRatio: item.imageRatio,
                      likeCount: item.likeCount,
                      favoriteStatus: item.favoriteStatus,
                    ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShowroomSortToggle(controller: segment),
                const SizedBox(height: 14),
                AppSegmentPages(
                  controller: segment,
                  children: [
                    page(ShowroomFeedSort.latest),
                    page(ShowroomFeedSort.popular),
                  ],
                ),
              ],
            );
          },
        );
      },
      loading:
          () => Center(
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
