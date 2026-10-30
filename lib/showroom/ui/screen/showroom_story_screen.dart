import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/hot_showroom_model.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/showroom_story_model.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/provider/hot_showroom_provider.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/provider/showroom_story_provider.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/story/showroom_story_scenes.dart';

class ShowroomStoryScreen extends ConsumerWidget {
  const ShowroomStoryScreen({super.key, required this.showroomId});

  final String showroomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ShowroomStoryModel?> storyAsync = ref.watch(
      showroomStoryProvider(showroomId),
    );
    ref.listen(showroomStoryProvider(showroomId), (previous, next) {
      final ShowroomStoryModel? story = next.asData?.value;
      if (story != null) {
        ref.read(recentShowroomProvider.notifier).remember(story.id);
      }
    });

    return Scaffold(
      backgroundColor: storyInk,
      body: storyAsync.when(
        loading: () {
          final HotShowroomModel? listed =
              ref
                  .watch(hotShowroomSliderVm)
                  .where((HotShowroomModel item) => item.id == showroomId)
                  .firstOrNull;
          if (listed == null) return const SizedBox.shrink();
          return StoryPhoto(url: listed.thumbnailUrl);
        },
        error:
            (error, stackTrace) => const Center(
              child: Text(
                '이야기를 불러오지 못했어요',
                style: TextStyle(color: Colors.white),
              ),
            ),
        data: (ShowroomStoryModel? story) {
          if (story == null) {
            return const Center(
              child: Text(
                '이야기를 찾지 못했어요',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return _StoryPager(story: story);
        },
      ),
    );
  }
}

class _Beat {
  const _Beat({required this.light, required this.reveal, required this.build});

  final bool light;
  final Duration reveal;
  final Widget Function(double progress) build;
}

class _StoryPager extends ConsumerStatefulWidget {
  const _StoryPager({required this.story});

  final ShowroomStoryModel story;

  @override
  ConsumerState<_StoryPager> createState() => _StoryPagerState();
}

class _StoryPagerState extends ConsumerState<_StoryPager>
    with SingleTickerProviderStateMixin {
  final PageController _page = PageController();
  final _PageLock _lock = _PageLock();
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: _beats(widget.story).first.reveal,
  );
  int _index = 0;
  final ValueNotifier<int> _rail = ValueNotifier<int>(0);
  final Set<int> _seen = <int>{};

  @override
  void initState() {
    super.initState();
    _page.addListener(_onPage);
    _reveal.addStatusListener(_onRevealStatus);
    _reveal.forward();
  }

  @override
  void didUpdateWidget(_StoryPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.story.id == widget.story.id) return;
    _index = 0;
    _rail.value = 0;
    _lock.origin = 0;
    _seen.clear();
    if (_page.hasClients) _page.jumpToPage(0);
    _play(0);
  }

  @override
  void dispose() {
    _page.removeListener(_onPage);
    _rail.dispose();
    _reveal.dispose();
    _page.dispose();
    super.dispose();
  }

  void _onPage() {
    if (!_page.hasClients) return;
    final double? page = _page.page;
    if (page == null) return;
    final int last = _beats(widget.story).length - 1;
    final int next = page.round().clamp(0, last < 0 ? 0 : last);
    if (next == _rail.value) return;
    _rail.value = next;
  }

  void _onRevealStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    if (_seen.contains(_index)) return;
    setState(() => _seen.add(_index));
  }

  void _play(int index) {
    final List<_Beat> beats = _beats(widget.story);
    if (beats.isEmpty) return;
    final int next = index.clamp(0, beats.length - 1);
    if (_seen.contains(next)) {
      _reveal.value = 1;
      return;
    }
    _reveal.duration = beats[next].reveal;
    _reveal.forward(from: 0);
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth > 1) return false;
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null &&
        _page.hasClients) {
      final int last = _beats(widget.story).length - 1;
      final double page = _page.page ?? _index.toDouble();
      _lock.origin = page.round().clamp(0, last < 0 ? 0 : last);
    }
    if (notification is ScrollEndNotification) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onSettled());
    }
    return false;
  }

  void _onSettled() {
    if (!mounted || !_page.hasClients) return;
    if (_page.position.isScrollingNotifier.value) return;
    final double page = _page.page ?? _index.toDouble();
    if ((page - page.round()).abs() > 0.04) return;
    final List<_Beat> beats = _beats(widget.story);
    if (beats.isEmpty) return;
    final int next = page.round().clamp(0, beats.length - 1);
    _lock.origin = next;
    if (next == _index) return;
    final int previous = _index;
    if (_reveal.value > 0) _seen.add(previous);
    setState(() => _index = next);
    _play(next);
  }

  @override
  Widget build(BuildContext context) {
    final List<HotShowroomModel> listed = ref.watch(hotShowroomSliderVm);
    final bool favorite =
        listed
            .where((HotShowroomModel item) => item.id == widget.story.id)
            .map((HotShowroomModel item) => item.favoriteStatus)
            .firstOrNull ??
        widget.story.favoriteStatus;
    final List<_Beat> beats = _beats(widget.story);

    final int index = beats.isEmpty ? 0 : _index.clamp(0, beats.length - 1);
    final bool light = beats.isEmpty ? false : beats[index].light;
    final Color iconColor = light ? storyInk : Colors.white;
    final bool onCover = index == 0;
    final bool atEnd = beats.length > 1 && index == beats.length - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: light ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      child: Stack(
        fit: StackFit.expand,
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: PageView.builder(
              controller: _page,
              scrollDirection: Axis.vertical,
              allowImplicitScrolling: true,
              physics: _OneStepPagePhysics(
                lock: _lock,
                pageCount: beats.length,
                parent: const ClampingScrollPhysics(),
              ),
              itemCount: beats.length,
              itemBuilder: (context, page) {
                return _RevealPage(
                  active: page == index,
                  seen: _seen.contains(page),
                  reveal: _reveal,
                  beat: beats[page],
                );
              },
            ),
          ),
          AnimatedBuilder(
            animation: _reveal,
            builder: (context, child) {
              final double endOpacity =
                  atEnd ? ((_reveal.value - 0.4) / 0.35).clamp(0.0, 1.0) : 0;
              return Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + 4,
                    left: 8,
                    right: 8,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.arrow_back,
                            color: iconColor,
                            shadows: _iconShadow(light),
                          ),
                        ),
                        const Spacer(),
                        if (onCover)
                          TextButton(
                            onPressed:
                                () => context.push(
                                  '/showroom/${widget.story.id}/board',
                                ),
                            child: Text(
                              '전체 보기',
                              style: TextStyle(
                                color: iconColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        IconButton(
                          onPressed: () {
                            ref
                                .read(hotShowroomSliderVm.notifier)
                                .toggleFavoriteByIndex(widget.story.id);
                          },
                          icon: Icon(
                            favorite ? Icons.favorite : Icons.favorite_border,
                            color:
                                favorite ? const Color(0xFFFF4D6A) : iconColor,
                            shadows: _iconShadow(light),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (beats.length > 1)
                    Positioned(
                      right: 14,
                      top: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: ValueListenableBuilder<int>(
                          valueListenable: _rail,
                          builder: (context, rail, child) {
                            final int safe = rail.clamp(0, beats.length - 1);
                            return _IndexRail(
                              count: beats.length,
                              index: safe,
                              light: beats[safe].light,
                            );
                          },
                        ),
                      ),
                    ),
                  if (atEnd)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: MediaQuery.paddingOf(context).bottom + 24,
                      child: IgnorePointer(
                        ignoring: endOpacity < 0.45,
                        child: Opacity(
                          opacity: endOpacity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap:
                                    () => context.push(
                                      '/showroom/${widget.story.id}/board',
                                    ),
                                child: const DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: storyInk,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(22),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 11,
                                    ),
                                    child: Text(
                                      '전체 보기',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
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
          ),
        ],
      ),
    );
  }
}

class _RevealPage extends StatelessWidget {
  const _RevealPage({
    required this.active,
    required this.seen,
    required this.reveal,
    required this.beat,
  });

  final bool active;
  final bool seen;
  final Animation<double> reveal;
  final _Beat beat;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: reveal,
      builder: (context, child) {
        final double raw =
            !active
                ? (seen ? 1 : 0)
                : seen
                ? 1
                : reveal.value;
        return beat.build(Curves.easeOutCubic.transform(raw));
      },
    );
  }
}

List<Shadow>? _iconShadow(bool light) {
  if (light) return null;
  return const <Shadow>[Shadow(color: Color(0x99000000), blurRadius: 8)];
}

class _IndexRail extends StatelessWidget {
  const _IndexRail({
    required this.count,
    required this.index,
    required this.light,
  });

  final int count;
  final int index;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final Color color = light ? storyInk : Colors.white;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          Container(
            width: 4,
            height: i == index ? 18 : 4,
            margin: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: i == index ? color : color.withValues(alpha: 0.35),
              borderRadius: const BorderRadius.all(Radius.circular(2)),
              boxShadow:
                  light
                      ? null
                      : const <BoxShadow>[
                        BoxShadow(color: Color(0x66000000), blurRadius: 4),
                      ],
            ),
          ),
      ],
    );
  }
}

List<_Beat> _beats(ShowroomStoryModel story) {
  final ShowroomSituation? situation = story.situation;
  final ShowroomCost? cost = story.cost;
  return <_Beat>[
    _Beat(
      light: false,
      reveal: const Duration(milliseconds: 520),
      build: (double progress) {
        return StoryHeroScene(story: story, progress: progress);
      },
    ),
    if (situation != null)
      _Beat(
        light: true,
        reveal: const Duration(milliseconds: 780),
        build: (double progress) {
          return StorySituationScene(situation: situation, progress: progress);
        },
      ),
    for (final ShowroomBeforeAfter pair in story.comparisons)
      _Beat(
        light: false,
        reveal: const Duration(milliseconds: 500),
        build: (double progress) {
          return StoryBeforeAfterScene(beforeAfter: pair, progress: progress);
        },
      ),
    if (cost != null)
      _Beat(
        light: false,
        reveal: const Duration(milliseconds: 720),
        build: (double progress) {
          return StoryCostScene(cost: cost, progress: progress);
        },
      ),
    for (var i = 0; i < story.process.length; i++)
      _Beat(
        light: false,
        reveal: const Duration(milliseconds: 420),
        build: (double progress) {
          return StoryProcessFrameScene(
            frame: story.process[i],
            index: i,
            count: story.process.length,
          );
        },
      ),
    if (story.guide.isNotEmpty)
      _Beat(
        light: true,
        reveal: const Duration(milliseconds: 720),
        build: (double progress) {
          return StoryGuideScene(lines: story.guide, progress: progress);
        },
      ),
  ];
}

/// 지금 제스처가 시작한 인덱스. 스크롤 중에 바로 읽는다.
class _PageLock {
  int origin = 0;
}

/// 한 번 넘기면 이웃 인덱스로만 붙는다.
class _OneStepPagePhysics extends ScrollPhysics {
  const _OneStepPagePhysics({
    required this.lock,
    required this.pageCount,
    super.parent,
  });

  final _PageLock lock;
  final int pageCount;

  @override
  _OneStepPagePhysics applyTo(ScrollPhysics? ancestor) {
    return _OneStepPagePhysics(
      lock: lock,
      pageCount: pageCount,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    final double size = position.viewportDimension;
    if (size <= 0 || pageCount <= 0) {
      return super.applyBoundaryConditions(position, value);
    }
    final int anchor = lock.origin;
    final double min = ((anchor - 1) * size).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    final double max = ((anchor + 1) * size).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (value < min) return value - min;
    if (value > max) return value - max;
    return super.applyBoundaryConditions(position, value);
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    final double size = position.viewportDimension;
    if (size <= 0 || pageCount <= 0) {
      return super.createBallisticSimulation(position, velocity);
    }
    final Tolerance tol = toleranceFor(position);
    final double page = position.pixels / size;
    final int maxIndex = pageCount - 1;
    final int anchor = lock.origin;
    final int target = (velocity > 350
            ? anchor + 1
            : velocity < -350
            ? anchor - 1
            : page.round())
        .clamp(anchor - 1, anchor + 1)
        .clamp(0, maxIndex);
    final double dest = target * size;
    final double distance = dest - position.pixels;
    if (distance.abs() < tol.distance && velocity.abs() < tol.velocity) {
      return null;
    }
    final double carried =
        distance == 0 || velocity.sign != distance.sign
            ? 0.0
            : velocity.clamp(-1600.0, 1600.0).toDouble();
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      dest,
      carried,
      tolerance: tol,
    );
  }
}
