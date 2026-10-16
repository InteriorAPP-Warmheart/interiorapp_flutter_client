import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/home/ui/widget/image_slider_widget.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/provider/filter_provider.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/panorama_showroom_card.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/quick_filter_bar.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/popular_showroom_card.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/post_section.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

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
    final hasSelectedFilters = ref.watch(hasSelectedFiltersProvider);

    return Scaffold(
      body: SingleChildScrollView(
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
                  padding: screenPadding.add(const EdgeInsets.only(top: 28)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PostSection(
                        sectionTitle: '인기 쇼룸',
                        onPressed: () {},
                        child: const PopularShowroomCardList(),
                      ),
                      SizedBox(height: sectionGap),
                      PostSection(
                        sectionTitle: '동네 게시물',
                        onPressed: () {},
                        child: const HotShowroomCardList(),
                      ),
                      SizedBox(height: sectionGap),
                      PostSection(
                        sectionTitle: '추천 시공',
                        onPressed: () {},
                        child: ImageSliderWidget().recommendBuildInfo(ref: ref),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: sectionGap + 10),
            ],
          ),
        ),
      ),

      // 글쓰기 버튼
      floatingActionButton: SizedBox(
        width: 100,
        height: 40,
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/showroom-write'),
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
      data: (showrooms) {
        if (showrooms.isEmpty) {
          return _filterEmptyPostsSection();
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: showrooms.length,
          separatorBuilder: (context, index) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            final item = showrooms[index];
            return ShowroomPostCard(
              imageUrl: item.thumbnailUrl,
              title: item.title,
              themeName: item.themeName,
              userName: item.userName,
              userProfileUrl: item.userProfileUrl,
              favoriteStatus: item.favoriteStatus,
              likeCount: item.likeCount,
              imageHeight: showroomCardImageHeight(context),
              onFavorite: () {
                // 즐겨찾기 토글 로직
                // ref.read(filteredShowroomListProvider.notifier)
                //     .toggleFavorite(item.id);
              },
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
