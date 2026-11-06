import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/hot_showroom_model.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/showroom_city_catalog.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/provider/hot_showroom_provider.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/provider/showroom_feed_browse_provider.dart';
import 'package:interiorapp_flutter_client/showroom/ui/screen/showroom_board_screen.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_city_sheet.dart';
import 'package:interiorapp_flutter_client/core/widget/app_segment.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_sort_toggle.dart';

enum _FeedType { all, neighborhood }

/// 전체/동네 세그먼트 탭 + 핀터레스트 마소니리 그리드
class ShowroomFeedSegment extends ConsumerStatefulWidget {
  const ShowroomFeedSegment({super.key});

  @override
  ConsumerState<ShowroomFeedSegment> createState() =>
      _ShowroomFeedSegmentState();
}

class _ShowroomFeedSegmentState extends ConsumerState<ShowroomFeedSegment> {
  _FeedType _selected = _FeedType.all;

  @override
  Widget build(BuildContext context) {
    final String? place = ref.watch(
      showroomFeedBrowseProvider.select(
        (ShowroomFeedBrowse browse) => browse.place,
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
              index == 0 ? ShowroomFeedSort.latest : ShowroomFeedSort.popular,
            );
      },
      builder: (BuildContext context, AppSegmentController segment) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SegmentControl(
              selected: _selected,
              neighborhoodLabel: place ?? '동네',
              onAll: () => setState(() => _selected = _FeedType.all),
              onNeighborhood: () => _openNeighborhood(place),
            ),
            const SizedBox(height: 12),
            ShowroomSortToggle(controller: segment),
            const SizedBox(height: 14),
            AppSegmentPages(
              controller: segment,
              children: [
                _ShowroomMasonryGrid(
                  type: _selected,
                  place: place,
                  sort: ShowroomFeedSort.latest,
                ),
                _ShowroomMasonryGrid(
                  type: _selected,
                  place: place,
                  sort: ShowroomFeedSort.popular,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _openNeighborhood(String? place) async {
    final bool already = _selected == _FeedType.neighborhood;
    if (place != null && !already) {
      setState(() => _selected = _FeedType.neighborhood);
      return;
    }
    final String? picked = await showShowroomCitySheet(context, current: place);
    if (!mounted || picked == null) return;
    await ref.read(showroomFeedBrowseProvider.notifier).setPlace(picked);
    if (!mounted) return;
    setState(() => _selected = _FeedType.neighborhood);
  }
}

// ─── 세그먼트 컨트롤 ────────────────────────────────────────────────────────

class _SegmentControl extends StatelessWidget {
  const _SegmentControl({
    required this.selected,
    required this.neighborhoodLabel,
    required this.onAll,
    required this.onNeighborhood,
  });

  final _FeedType selected;
  final String neighborhoodLabel;
  final VoidCallback onAll;
  final VoidCallback onNeighborhood;

  @override
  Widget build(BuildContext context) {
    final int index = selected == _FeedType.all ? 0 : 1;
    return Column(
      children: [
        Row(
          children: [
            _FeedTab(
              label: '전체',
              selected: selected == _FeedType.all,
              onTap: onAll,
            ),
            _FeedTab(
              label: neighborhoodLabel,
              selected: selected == _FeedType.neighborhood,
              showChevron: true,
              onTap: onNeighborhood,
            ),
          ],
        ),
        SizedBox(
          height: 2,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double tabWidth = constraints.maxWidth / 2;
              return Stack(
                children: [
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ColoredBox(
                      color: AppColors.border,
                      child: SizedBox(height: 1),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    left: tabWidth * index,
                    width: tabWidth,
                    top: 0,
                    bottom: 0,
                    child: const ColoredBox(color: AppColors.primary),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FeedTab extends StatelessWidget {
  const _FeedTab({
    required this.label,
    required this.selected,
    required this.onTap,
    this.showChevron = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final Color color =
        selected ? AppColors.textPrimary : AppColors.textSecondary;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.2,
                    letterSpacing: -0.3,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
              if (showChevron) ...[
                const SizedBox(width: 2),
                Icon(Icons.keyboard_arrow_down, size: 18, color: color),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 마소니리 그리드 ────────────────────────────────────────────────────────

class _ShowroomMasonryGrid extends ConsumerWidget {
  const _ShowroomMasonryGrid({
    required this.type,
    required this.place,
    required this.sort,
  });

  final _FeedType type;
  final String? place;
  final ShowroomFeedSort sort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool pinFavorites = ref.watch(
      showroomFeedBrowseProvider.select(
        (ShowroomFeedBrowse browse) => browse.pinFavorites,
      ),
    );
    final List<HotShowroomModel> source = ref.watch(hotShowroomSliderVm);
    final String? place = this.place;
    final List<HotShowroomModel> scoped =
        type == _FeedType.all
            ? source
            : <HotShowroomModel>[
              for (final HotShowroomModel item in source)
                if (place != null && showroomPlaceIncludes(place, item.city))
                  item,
            ];
    final List<HotShowroomModel> items = sortedShowroomFeed(
      scoped,
      sort,
      likes: (HotShowroomModel item) => item.likeCount,
      publishedAt: (HotShowroomModel item) => item.publishedAt,
      pinFavorites: pinFavorites,
      favorite: (HotShowroomModel item) => item.favoriteStatus,
    );

    if (type == _FeedType.neighborhood && (place == null || place.isEmpty)) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            '시나 도를 고르면 그 동네 글이 보여요',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    if (items.isEmpty) {
      final String message =
          type == _FeedType.neighborhood ? '$place에는 아직 글이 없어요' : '게시물이 없어요';
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            message,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ShowroomMasonryGrid(
      items: [
        for (final HotShowroomModel item in items)
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
}

/// 핀터레스트 마소니리에 올릴 카드 한 장.
class ShowroomMasonryEntry {
  const ShowroomMasonryEntry({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.imageRatio,
    required this.likeCount,
    required this.favoriteStatus,
  });

  final String id;
  final String imageUrl;
  final String title;
  final double imageRatio;
  final int likeCount;
  final bool favoriteStatus;
}

/// 사진 비율대로 높이가 다른 3열 그리드.
class ShowroomMasonryGrid extends StatelessWidget {
  const ShowroomMasonryGrid({super.key, required this.items});

  final List<ShowroomMasonryEntry> items;

  static const int _columns = 3;
  static const double _gap = 8;
  static const double _captionHeight = 22;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double colWidth =
            (constraints.maxWidth - _gap * (_columns - 1)) / _columns;
        final List<List<Widget>> columns = List.generate(
          _columns,
          (_) => <Widget>[],
        );
        final List<double> heights = List.filled(_columns, 0);

        for (final ShowroomMasonryEntry item in items) {
          final double ratio = item.imageRatio <= 0 ? 0.8 : item.imageRatio;
          final double cardHeight = colWidth / ratio + _captionHeight;
          int target = 0;
          for (int i = 1; i < _columns; i++) {
            if (heights[i] < heights[target]) target = i;
          }
          if (columns[target].isNotEmpty) {
            columns[target].add(const SizedBox(height: _gap));
            heights[target] += _gap;
          }
          columns[target].add(
            _MasonryCard(item: item, imageAspectRatio: ratio),
          );
          heights[target] += cardHeight;
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < _columns; i++) ...[
              if (i > 0) const SizedBox(width: _gap),
              SizedBox(
                width: colWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: columns[i],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

// ─── 마소니리 카드 ────────────────────────────────────────────────────────

class _MasonryCard extends StatelessWidget {
  const _MasonryCard({required this.item, required this.imageAspectRatio});

  final ShowroomMasonryEntry item;
  final double imageAspectRatio;

  @override
  Widget build(BuildContext context) {
    final String likeLabel =
        item.likeCount > 999 ? '999+' : item.likeCount.toString();

    return OpenContainer(
      useRootNavigator: true,
      tappable: false,
      closedElevation: 0,
      openElevation: 0,
      closedColor: AppColors.background,
      openColor: AppColors.background,
      closedShape: const RoundedRectangleBorder(),
      openShape: const RoundedRectangleBorder(),
      closedBuilder: (BuildContext context, VoidCallback open) {
        return GestureDetector(
          onTap: open,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: imageAspectRatio,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppNetworkImage(url: item.imageUrl),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Icon(
                          item.favoriteStatus
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                              item.favoriteStatus
                                  ? const Color(0xFFFF4D6A)
                                  : Colors.white,
                          size: 16,
                          shadows: const [
                            Shadow(
                              color: Color(0x99000000),
                              blurRadius: 6,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        height: 1.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    item.favoriteStatus
                        ? Icons.favorite
                        : Icons.favorite_border,
                    size: 11,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    likeLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      openBuilder: (BuildContext context, VoidCallback close) {
        return ShowroomBoardScreen(showroomId: item.id);
      },
    );
  }
}
