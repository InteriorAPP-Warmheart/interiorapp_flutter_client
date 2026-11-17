import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
      comments: (HotShowroomModel item) => item.commentCount,
      views: (HotShowroomModel item) => item.viewCount,
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
            commentCount: item.commentCount,
            viewCount: item.viewCount,
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
    required this.commentCount,
    required this.viewCount,
    required this.favoriteStatus,
  });

  final String id;
  final String imageUrl;
  final String title;
  final double imageRatio;
  final int likeCount;
  final int commentCount;
  final int viewCount;
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

/// 카드 자리에서 글이 화면 크기로 커진다.
///
/// 글은 화면 크기로 한 번만 배치하고, 보이는 크기만 키운다.
void openShowroomPage(
  BuildContext context,
  WidgetBuilder page, {
  String? coverUrl,
  Color background = Colors.white,
  double radius = 16,
}) {
  final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
  final Rect? source = _cardRectInNavigator(context, navigator);
  navigator.push<void>(
    _ShowroomExpandRoute(
      source: source,
      page: page,
      coverUrl: coverUrl,
      background: background,
      radius: radius,
    ),
  );
}

Rect? _cardRectInNavigator(BuildContext context, NavigatorState navigator) {
  final RenderObject? cardObject = context.findRenderObject();
  final RenderObject? hostObject = navigator.context.findRenderObject();
  if (cardObject is! RenderBox || hostObject is! RenderBox) return null;
  final RenderBox card = cardObject;
  final RenderBox host = hostObject;
  if (!card.attached || !host.attached || !card.hasSize || !host.hasSize) {
    return null;
  }
  final Offset origin = host.localToGlobal(Offset.zero);
  return (card.localToGlobal(Offset.zero) - origin) & card.size;
}

class _MasonryCard extends StatelessWidget {
  const _MasonryCard({required this.item, required this.imageAspectRatio});

  final ShowroomMasonryEntry item;
  final double imageAspectRatio;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => openShowroomPage(
            context,
            (_) => ShowroomBoardScreen(showroomId: item.id),
            coverUrl: item.imageUrl,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: imageAspectRatio,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double imageHeight = constraints.maxHeight;
                final bool short = imageHeight < 108;
                final double band =
                    short
                        ? (imageHeight * 0.42).clamp(24.0, 36.0)
                        : (imageHeight * 0.4).clamp(36.0, 52.0);
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppNetworkImage(url: item.imageUrl),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: band,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Color(0xB3000000), Color(0x00000000)],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 6,
                        right: 6,
                        bottom: short ? 4 : 6,
                        child: Text(
                          item.title,
                          maxLines: short ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: short ? 10.5 : 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            height: 1.2,
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                color: Color(0x99000000),
                                blurRadius: 6,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          _CardCounts(
            likes: item.likeCount,
            comments: item.commentCount,
            views: item.viewCount,
            favorite: item.favoriteStatus,
          ),
        ],
      ),
    );
  }
}

String showroomCompactCount(int value) {
  if (value < 1000) return value.toString();
  if (value < 10000) {
    final String compact = (value / 1000).toStringAsFixed(1);
    final String trimmed =
        compact.endsWith('.0')
            ? compact.substring(0, compact.length - 2)
            : compact;
    return '$trimmed천';
  }
  final String compact = (value / 10000).toStringAsFixed(1);
  final String trimmed =
      compact.endsWith('.0')
          ? compact.substring(0, compact.length - 2)
          : compact;
  return '$trimmed만';
}

class _CountSlot extends StatelessWidget {
  const _CountSlot({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 2),
        Text(
          label,
          maxLines: 1,
          softWrap: false,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            height: 1.1,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _CardCounts extends StatelessWidget {
  const _CardCounts({
    required this.likes,
    required this.comments,
    required this.views,
    required this.favorite,
  });

  final int likes;
  final int comments;
  final int views;
  final bool favorite;

  @override
  Widget build(BuildContext context) {
    const Color heart = Color(0xFFFF4D6A);
    return _EdgeCountRow(
      children: <Widget>[
        _CountSlot(
          icon: favorite ? Icons.favorite : Icons.favorite_border,
          color: favorite ? heart : AppColors.textSecondary,
          label: showroomCompactCount(likes),
        ),
        _CountSlot(
          icon: Icons.mode_comment_outlined,
          color: AppColors.textSecondary,
          label: showroomCompactCount(comments),
        ),
        _CountSlot(
          icon: Icons.visibility_outlined,
          color: AppColors.textSecondary,
          label: showroomCompactCount(views),
        ),
      ],
    );
  }
}

/// 좋아요는 왼쪽 끝, 조회수는 오른쪽 끝.
/// 좋아요와 댓글 사이만 [gap]으로 붙이고, 남는 폭은 댓글과 조회수 사이로 보낸다.
/// 세 칸이 카드보다 넓으면 숫자 잘림 없이 줄 전체를 줄인다.
class _EdgeCountRow extends MultiChildRenderObjectWidget {
  const _EdgeCountRow({required super.children}) : super();

  static const double gap = 6;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderEdgeCountRow(gap: gap);
  }
}

class _EdgeCountParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderEdgeCountRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _EdgeCountParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _EdgeCountParentData> {
  _RenderEdgeCountRow({required double gap}) : _gap = gap;

  final double _gap;
  double _scale = 1;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _EdgeCountParentData) {
      child.parentData = _EdgeCountParentData();
    }
  }

  @override
  void performLayout() {
    final List<RenderBox> kids = <RenderBox>[];
    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(const BoxConstraints(), parentUsesSize: true);
      kids.add(child);
      final _EdgeCountParentData data =
          child.parentData! as _EdgeCountParentData;
      child = data.nextSibling;
    }
    if (kids.length != 3) {
      size = constraints.constrain(Size.zero);
      return;
    }

    final double likesWidth = kids[0].size.width;
    final double commentsWidth = kids[1].size.width;
    final double viewsWidth = kids[2].size.width;
    final double packed = likesWidth + _gap + commentsWidth + viewsWidth;
    double contentHeight = kids[0].size.height;
    if (kids[1].size.height > contentHeight) {
      contentHeight = kids[1].size.height;
    }
    if (kids[2].size.height > contentHeight) {
      contentHeight = kids[2].size.height;
    }

    final double maxWidth =
        constraints.maxWidth.isFinite ? constraints.maxWidth : packed;
    _scale = packed <= maxWidth || packed == 0 ? 1 : maxWidth / packed;

    void place(RenderBox kid, double x) {
      final _EdgeCountParentData data = kid.parentData! as _EdgeCountParentData;
      data.offset = Offset(x, (contentHeight - kid.size.height) / 2);
    }

    place(kids[0], 0);
    place(kids[1], likesWidth + _gap);
    place(
      kids[2],
      _scale < 1 ? likesWidth + _gap + commentsWidth : maxWidth - viewsWidth,
    );
    size = constraints.constrain(Size(maxWidth, contentHeight * _scale));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_scale == 1) {
      defaultPaint(context, offset);
      return;
    }
    context.pushTransform(
      needsCompositing,
      offset,
      Matrix4.diagonal3Values(_scale, _scale, 1),
      (PaintingContext context, Offset offset) {
        defaultPaint(context, offset);
      },
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final Offset local = _scale == 1 ? position : position / _scale;
    return defaultHitTestChildren(result, position: local);
  }
}

class _ShowroomExpandRoute extends PageRoute<void> {
  _ShowroomExpandRoute({
    required this.source,
    required this.page,
    required this.coverUrl,
    required this.background,
    required this.radius,
  });

  final Rect? source;
  final WidgetBuilder page;
  final String? coverUrl;
  final Color background;
  final double radius;
  bool _settled = false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  /// 커지는 동안은 뒤 목록이 보이고, 다 열리면 목록을 가린다.
  @override
  bool get opaque => _settled;

  @override
  bool get barrierDismissible => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 460);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 380);

  @override
  void install() {
    super.install();
    animation!.addStatusListener(_onStatus);
  }

  void _onStatus(AnimationStatus status) {
    final bool settled = status == AnimationStatus.completed;
    if (settled == _settled) return;
    _settled = settled;
    changedInternalState();
  }

  @override
  void dispose() {
    animation?.removeStatusListener(_onStatus);
    super.dispose();
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return page(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _ShowroomExpandTransition(
      animation: animation,
      source: source,
      coverUrl: coverUrl,
      background: background,
      radius: radius,
      child: child,
    );
  }
}

class _ShowroomExpandTransition extends StatefulWidget {
  const _ShowroomExpandTransition({
    required this.animation,
    required this.source,
    required this.coverUrl,
    required this.background,
    required this.radius,
    required this.child,
  });

  final Animation<double> animation;
  final Rect? source;
  final String? coverUrl;
  final Color background;
  final double radius;
  final Widget child;

  @override
  State<_ShowroomExpandTransition> createState() =>
      _ShowroomExpandTransitionState();
}

class _ShowroomExpandTransitionState extends State<_ShowroomExpandTransition> {
  late final CurvedAnimation _expand;
  late final CurvedAnimation _fade;

  @override
  void initState() {
    super.initState();
    _expand = CurvedAnimation(
      parent: widget.animation,
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.fastOutSlowIn,
    );
    _fade = CurvedAnimation(
      parent: widget.animation,
      curve: const Interval(0.18, 0.62, curve: Curves.easeOut),
      reverseCurve: const Interval(0.0, 0.45, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _expand.dispose();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Rect? source = widget.source;
    if (source == null) {
      return FadeTransition(opacity: _expand, child: widget.child);
    }
    return _GrowingPage(
      expand: _expand,
      coverFade: _fade,
      source: source,
      radius: widget.radius,
      background: widget.background,
      cover: _cover(),
      child: widget.child,
    );
  }

  Widget _cover() {
    final String url = widget.coverUrl?.trim() ?? '';
    if (url.isEmpty) {
      return ColoredBox(color: widget.background);
    }
    return AppNetworkImage(url: url);
  }
}

class _GrowingPage extends StatelessWidget {
  const _GrowingPage({
    required this.expand,
    required this.coverFade,
    required this.source,
    required this.radius,
    required this.background,
    required this.cover,
    required this.child,
  });

  final Animation<double> expand;
  final Animation<double> coverFade;
  final Rect source;
  final double radius;
  final Color background;
  final Widget cover;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size screen = constraints.biggest;
        final Rect end = Offset.zero & screen;
        return AnimatedBuilder(
          animation: expand,
          builder: (BuildContext context, Widget? page) {
            final double t = expand.value;
            final Rect rect = Rect.lerp(source, end, t)!;
            final double scale =
                screen.width <= 0
                    ? 1
                    : (rect.width / screen.width).clamp(0.05, 1.0);
            final double coverOpacity = (1 - coverFade.value).clamp(0.0, 1.0);
            return Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: Colors.black.withValues(alpha: 0.22 * t)),
                Positioned.fromRect(
                  rect: rect,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      lerpDouble(radius, 0, t)!,
                    ),
                    child: ColoredBox(
                      color: background,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          OverflowBox(
                            alignment: Alignment.topLeft,
                            minWidth: screen.width,
                            maxWidth: screen.width,
                            minHeight: screen.height,
                            maxHeight: screen.height,
                            child: Transform.scale(
                              alignment: Alignment.topLeft,
                              scale: scale,
                              child: page,
                            ),
                          ),
                          if (coverOpacity > 0.01)
                            IgnorePointer(
                              child: Opacity(
                                opacity: coverOpacity,
                                child: cover,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          child: RepaintBoundary(child: child),
        );
      },
    );
  }
}
