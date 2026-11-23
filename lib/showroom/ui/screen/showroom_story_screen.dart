import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/hot_showroom_model.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/showroom_story_model.dart';
import 'package:interiorapp_flutter_client/mypage/presentation/provider/mypage_provider.dart';
import 'package:interiorapp_flutter_client/mypage/presentation/record_showroom_view.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/provider/hot_showroom_provider.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/provider/showroom_story_provider.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/showroom_body.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_photo_gallery.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_photo_ratio.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_font_scale.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/story/showroom_story_scenes.dart';

/// 갤러리 버튼에서 화면이 쏟아져 나오고, 돌아갈 때는 그 버튼으로 작아져 빨려 들어간다.
void openShowroomHighlight(BuildContext context, {required String showroomId}) {
  final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
  final Rect? source = _highlightOrigin(context, navigator);
  navigator.push<void>(
    _HighlightRoute(
      source: source,
      page: (_) => ShowroomStoryScreen(showroomId: showroomId),
    ),
  );
}

Rect? _highlightOrigin(BuildContext context, NavigatorState navigator) {
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

double _highlightSpan(double t, double begin, double end) {
  if (end <= begin) return t >= end ? 1 : 0;
  return ((t - begin) / (end - begin)).clamp(0.0, 1.0);
}

class _HighlightRoute extends PageRoute<void> {
  _HighlightRoute({required this.source, required this.page});

  final Rect? source;
  final WidgetBuilder page;
  bool _settled = false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => _settled;

  @override
  bool get barrierDismissible => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 480);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 360);

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
    return _HighlightTransition(
      animation: animation,
      source: source,
      child: child,
    );
  }
}

class _HighlightTransition extends StatelessWidget {
  const _HighlightTransition({
    required this.animation,
    required this.source,
    required this.child,
  });

  final Animation<double> animation;
  final Rect? source;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? page) {
        if (page == null) return const SizedBox.shrink();
        final double t = animation.value;
        if (animation.status == AnimationStatus.completed || t >= 1) {
          return page;
        }
        final bool returning = animation.status == AnimationStatus.reverse;
        final double motion =
            returning ? Curves.easeInCubic.transform(t) : _spillOut(t);
        final Size screen = MediaQuery.sizeOf(context);
        final Offset anchor = source?.center ?? Offset(screen.width - 36, 72);
        final double scrim = motion.clamp(0.0, 1.0);
        return ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              ColoredBox(color: Color.fromRGBO(17, 17, 17, 0.22 * scrim)),
              if (motion > 0.012)
                Transform(
                  alignment: Alignment.topLeft,
                  transform: _pulledFrom(anchor, motion),
                  child: page,
                ),
            ],
          ),
        );
      },
      child: RepaintBoundary(child: child),
    );
  }
}

/// 버튼에서 화면이 조금 넘쳤다가 제자리로 앉는다.
double _spillOut(double t) {
  const double s = 0.7;
  final double u = t - 1;
  final double value = 1 + (s + 1) * u * u * u + s * u * u;
  if (value < 0) return 0;
  if (value > 1.04) return 1.04;
  return value;
}

Matrix4 _pulledFrom(Offset anchor, double scale) {
  return Matrix4.identity()
    ..translateByDouble(anchor.dx, anchor.dy, 0, 1)
    ..scaleByDouble(scale, scale, 1, 1)
    ..translateByDouble(-anchor.dx, -anchor.dy, 0, 1);
}

class ShowroomStoryScreen extends ConsumerWidget {
  const ShowroomStoryScreen({
    super.key,
    required this.showroomId,
    this.liftsCover = false,
  });

  final String showroomId;
  final bool liftsCover;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ShowroomStoryModel?> storyAsync = ref.watch(
      showroomStoryProvider(showroomId),
    );
    ref.listen(showroomStoryProvider(showroomId), (previous, next) {
      final ShowroomStoryModel? story = next.asData?.value;
      if (story == null) return;
      final String place =
          ref
              .read(hotShowroomSliderVm)
              .where((HotShowroomModel item) => item.id == story.id)
              .map((HotShowroomModel item) => item.city)
              .firstOrNull ??
          '';
      recordShowroomView(
        recent: ref.read(recentContentVmProvider.notifier),
        memory: ref.read(recentShowroomProvider.notifier),
        id: story.id,
        thumbnailUrl: story.thumbnailUrl,
        title: story.title,
        category: story.themeName,
        authorName: story.userName,
        place: place,
      );
    });

    return ShowroomFontScale(
      child: Scaffold(
      backgroundColor: Colors.transparent,
      body: storyAsync.when(
        loading: () => const SizedBox.shrink(),
        error:
            (error, stackTrace) => const ColoredBox(
              color: storyPaper,
              child: Center(
                child: Text(
                  '이야기를 불러오지 못했어요',
                  style: TextStyle(color: storyInk),
                ),
              ),
            ),
        data: (ShowroomStoryModel? story) {
          if (story == null) {
            return const ColoredBox(
              color: storyPaper,
              child: Center(
                child: Text('이야기를 찾지 못했어요', style: TextStyle(color: storyInk)),
              ),
            );
          }
          return _StoryLookbook(story: story, liftsCover: liftsCover);
        },
      ),
      ),
    );
  }
}

class _LookFrame {
  const _LookFrame.photo(this.url);

  final String url;
}

class _StoryLookbook extends ConsumerStatefulWidget {
  const _StoryLookbook({required this.story, required this.liftsCover});

  final ShowroomStoryModel story;
  final bool liftsCover;

  @override
  ConsumerState<_StoryLookbook> createState() => _StoryLookbookState();
}

class _StoryLookbookState extends ConsumerState<_StoryLookbook> {
  Animation<double>? _route;
  bool _settled = false;
  bool _pastHero = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Animation<double>? next = ModalRoute.of(context)?.animation;
    if (identical(next, _route)) return;
    _route?.removeStatusListener(_onRoute);
    _route = next;
    next?.addStatusListener(_onRoute);
    _settled = next == null || next.status == AnimationStatus.completed;
  }

  void _onRoute(AnimationStatus status) {
    final bool settled = status == AnimationStatus.completed;
    if (settled == _settled || !mounted) return;
    setState(() => _settled = settled);
  }

  @override
  void dispose() {
    _route?.removeStatusListener(_onRoute);
    super.dispose();
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    final bool past = notification.metrics.pixels > 280;
    if (past == _pastHero) return false;
    setState(() => _pastHero = past);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final ShowroomStoryModel story = widget.story;
    final List<HotShowroomModel> listed = ref.watch(hotShowroomSliderVm);
    final bool favorite =
        listed
            .where((HotShowroomModel item) => item.id == story.id)
            .map((HotShowroomModel item) => item.favoriteStatus)
            .firstOrNull ??
        story.favoriteStatus;
    final String place =
        listed
            .where((HotShowroomModel item) => item.id == story.id)
            .map((HotShowroomModel item) => item.city)
            .firstOrNull ??
        '';
    final List<_LookFrame> frames = _lookFrames(story);
    final Animation<double> motion =
        _route ?? const AlwaysStoppedAnimation<double>(1);
    final _Arrive arrive = _Arrive(
      animation: motion,
      settled: true,
      count: frames.length,
    );
    final List<Widget> plates = _composeLook(
      frames: frames,
      title: story.title,
      place: place.trim().isNotEmpty ? place.trim() : story.themeName.trim(),
      width: MediaQuery.sizeOf(context).width,
      arrive: arrive,
      revealCover: widget.liftsCover && !_settled,
    );
    final Color favoriteColor =
        favorite ? const Color(0xFFFF4D6A) : Colors.white;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _pastHero ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: storyPaper),
            CustomScrollView(
              physics:
                  _settled
                      ? const ClampingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
              slivers: [
                SliverList(delegate: SliverChildListDelegate(plates)),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.paddingOf(context).bottom + 28,
                  ),
                ),
              ],
            ),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 6,
              left: 12,
              right: 12,
              child: _HighlightChrome(
                animation: motion,
                settled: true,
                child: Row(
                  children: [
                    _LookChromeButton(
                      icon: Icons.arrow_back,
                      color: Colors.white,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    _LookChromeButton(
                      icon: favorite ? Icons.favorite : Icons.favorite_border,
                      color: favoriteColor,
                      onPressed: () {
                        ref
                            .read(hotShowroomSliderVm.notifier)
                            .toggleFavoriteByIndex(story.id);
                      },
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

class _CoverFade extends StatelessWidget {
  const _CoverFade({
    required this.play,
    required this.animation,
    required this.child,
  });

  final bool play;
  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!play) return child;
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: _highlightSpan(animation.value, 0.42, 0.68),
          child: child,
        );
      },
    );
  }
}

class _HighlightChrome extends StatelessWidget {
  const _HighlightChrome({
    required this.animation,
    required this.settled,
    required this.child,
  });

  final Animation<double> animation;
  final bool settled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (settled) return child;
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (BuildContext context, Widget? child) {
        final double u = Curves.easeOut.transform(
          _highlightSpan(animation.value, 0.0, 0.22),
        );
        return Opacity(
          opacity: u,
          child: Transform.translate(
            offset: Offset(18 * (1 - u), -10 * (1 - u)),
            child: child,
          ),
        );
      },
    );
  }
}

class _LookChromeButton extends StatelessWidget {
  const _LookChromeButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0x59000000),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: color,
          shadows: const <Shadow>[
            Shadow(color: Color(0x66000000), blurRadius: 8),
          ],
        ),
      ),
    );
  }
}

const double _lookGap = 10;
const double _lookInset = 16;
const BorderRadius _lookRadius = BorderRadius.all(Radius.circular(18));

/// 하이라이트가 펼쳐진 뒤 사진이 제자리로 들어오는 타이밍.
class _Arrive {
  _Arrive({
    required this.animation,
    required this.settled,
    required this.count,
  });

  final Animation<double> animation;
  final bool settled;
  final int count;
  int _next = 0;

  int take() {
    final int index = _next;
    _next += 1;
    return index;
  }

  Widget place(Widget child, {required Offset from, double lead = 0}) {
    return at(take(), child, from: from, lead: lead);
  }

  Widget at(int index, Widget child, {required Offset from, double lead = 0}) {
    if (settled) return child;
    return _LookArrive(
      animation: animation,
      index: index,
      count: count,
      lead: lead,
      from: from,
      child: child,
    );
  }
}

class _LookArrive extends StatelessWidget {
  const _LookArrive({
    required this.animation,
    required this.index,
    required this.count,
    required this.lead,
    required this.from,
    required this.child,
  });

  final Animation<double> animation;
  final int index;
  final int count;
  final double lead;
  final Offset from;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final int total = count < 1 ? 1 : count;
    final double step = (0.42 / total).clamp(0.02, 0.045);
    final double start = (0.04 + lead + index * step).clamp(0.0, 0.48);
    final double end = (start + 0.34).clamp(start + 0.16, 0.78);
    final Curve motionCurve = Interval(start, end, curve: Curves.easeOutCubic);
    final Curve fadeCurve = Interval(
      start,
      start + (end - start) * 0.35,
      curve: Curves.easeOut,
    );
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (BuildContext context, Widget? child) {
        final double t = animation.value;
        final double motion = motionCurve.transform(t);
        final double fade = fadeCurve.transform(t);
        return Opacity(
          opacity: fade,
          child: Transform.translate(
            offset: Offset(from.dx * (1 - motion), from.dy * (1 - motion)),
            child: Transform.scale(
              scale: 0.96 + 0.04 * motion,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

List<Widget> _composeLook({
  required List<_LookFrame> frames,
  required String title,
  required String place,
  required double width,
  required _Arrive arrive,
  required bool revealCover,
}) {
  final List<Widget> plates = <Widget>[];
  var index = 0;
  if (frames.isNotEmpty) {
    plates.add(
      _LookHero(
        url: frames.first.url,
        title: title,
        place: place,
        arrive: arrive,
        revealCover: revealCover,
        captionIndex: arrive.take(),
      ),
    );
    index = 1;
  }
  final List<String> run = <String>[];
  void flush() {
    plates.addAll(_composeRun(run, width, arrive));
    run.clear();
  }

  for (; index < frames.length; index++) {
    run.add(frames[index].url);
  }
  flush();
  return plates;
}

List<Widget> _composeRun(List<String> urls, double width, _Arrive arrive) {
  final List<Widget> plates = <Widget>[];
  var index = 0;
  var step = 0;
  while (index < urls.length) {
    final int left = urls.length - index;
    final int cycle = step % 3;
    if (cycle == 2 && left >= 3) {
      plates.add(
        _LookTrio(
          urls: urls.sublist(index, index + 3),
          height: width * 0.92,
          arrive: arrive,
        ),
      );
      index += 3;
    } else if (cycle == 1 && left >= 2) {
      plates.add(
        _LookPair(
          leading: urls[index],
          trailing: urls[index + 1],
          height: width * 0.62,
          leadingFlex: 3,
          trailingFlex: 2,
          arrive: arrive,
        ),
      );
      index += 2;
    } else if (left == 2) {
      plates.add(
        _LookPair(
          leading: urls[index],
          trailing: urls[index + 1],
          height: width * 0.52,
          leadingFlex: 1,
          trailingFlex: 1,
          arrive: arrive,
        ),
      );
      index += 2;
    } else {
      plates.add(_LookFeature(url: urls[index], arrive: arrive));
      index += 1;
    }
    step += 1;
  }
  return plates;
}

class _LookHero extends StatelessWidget {
  const _LookHero({
    required this.url,
    required this.title,
    required this.place,
    required this.arrive,
    required this.revealCover,
    required this.captionIndex,
  });

  final String url;
  final String title;
  final String place;
  final _Arrive arrive;
  final bool revealCover;
  final int captionIndex;

  @override
  Widget build(BuildContext context) {
    return ShowroomPhotoRatio(
      url: url,
      builder: (BuildContext context, double ratio) {
        return AspectRatio(
          aspectRatio: ratio <= 0 ? 3 / 2 : ratio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _CoverFade(
                play: revealCover,
                animation: arrive.animation,
                child: StoryPhoto(url: url),
              ),
              _CoverFade(
                play: revealCover,
                animation: arrive.animation,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Color(0x00000000),
                        Color(0x00000000),
                        Color(0xCC111111),
                      ],
                      stops: <double>[0, 0.46, 1],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 28,
                child: arrive.at(
                  captionIndex,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (place.isNotEmpty)
                        Text(
                          place,
                          style: const TextStyle(
                            color: Color(0xE6FFFFFF),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                          ),
                        ),
                      if (place.isNotEmpty) const SizedBox(height: 8),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ],
                  ),
                  from: const Offset(20, -12),
                  lead: 0.02,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LookFeature extends StatelessWidget {
  const _LookFeature({required this.url, required this.arrive});

  final String url;
  final _Arrive arrive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_lookInset, 18, _lookInset, 0),
      child: arrive.place(
        ClipRRect(borderRadius: _lookRadius, child: _LookPhoto(url: url)),
        from: const Offset(24, -28),
      ),
    );
  }
}

class _LookPair extends StatelessWidget {
  const _LookPair({
    required this.leading,
    required this.trailing,
    required this.height,
    required this.leadingFlex,
    required this.trailingFlex,
    required this.arrive,
  });

  final String leading;
  final String trailing;
  final double height;
  final int leadingFlex;
  final int trailingFlex;
  final _Arrive arrive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_lookInset, _lookGap, _lookInset, 0),
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(
              flex: leadingFlex,
              child: arrive.place(
                _LookCell(url: leading),
                from: const Offset(32, -18),
              ),
            ),
            const SizedBox(width: _lookGap),
            Expanded(
              flex: trailingFlex,
              child: arrive.place(
                _LookCell(url: trailing),
                from: const Offset(14, -26),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LookTrio extends StatelessWidget {
  const _LookTrio({
    required this.urls,
    required this.height,
    required this.arrive,
  });

  final List<String> urls;
  final double height;
  final _Arrive arrive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_lookInset, _lookGap, _lookInset, 0),
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: arrive.place(
                _LookCell(url: urls[0]),
                from: const Offset(30, -22),
              ),
            ),
            const SizedBox(width: _lookGap),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(
                    child: arrive.place(
                      _LookCell(url: urls[1]),
                      from: const Offset(12, -30),
                    ),
                  ),
                  const SizedBox(height: _lookGap),
                  Expanded(
                    child: arrive.place(
                      _LookCell(url: urls[2]),
                      from: const Offset(18, -14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LookCell extends StatelessWidget {
  const _LookCell({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: _lookRadius,
      child: SizedBox.expand(child: StoryPhoto(url: url)),
    );
  }
}

class _LookPhoto extends StatelessWidget {
  const _LookPhoto({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ShowroomPhotoRatio(
      url: url,
      builder: (BuildContext context, double ratio) {
        return AspectRatio(
          aspectRatio: ratio <= 0 ? 3 / 2 : ratio,
          child: StoryPhoto(url: url),
        );
      },
    );
  }
}

/// 표지로 누른 사진부터, 본문에 있는 사진을 순서대로 모은다.
List<_LookFrame> _lookFrames(ShowroomStoryModel story) {
  final List<_LookFrame> frames = <_LookFrame>[];
  final Set<String> seen = <String>{};

  void addPhoto(String raw) {
    final String url = raw.trim();
    if (url.isEmpty || showroomEmoticonUrl(url) || !seen.add(url)) return;
    frames.add(_LookFrame.photo(url));
  }

  var fromBody = false;
  void addAfter(String raw) {
    final String url = raw.trim();
    if (url.isEmpty) return;
    fromBody = true;
    addPhoto(url);
  }

  addPhoto(story.thumbnailUrl);
  for (final ShowroomBlock block in story.blocks) {
    if (block.kind == ShowroomBlockKind.text || showroomSoloEmoticon(block)) {
      continue;
    }
    if (block.kind == ShowroomBlockKind.process) {
      for (final ShowroomProcessFrame frame in block.frames) {
        addAfter(frame.imageUrl);
      }
      continue;
    }
    if (block.layout == ShowroomImageLayout.beforeAfter) {
      for (final ShowroomBeforeAfterPair pair in block.pairs) {
        addAfter(pair.afterUrl);
      }
      continue;
    }
    for (final String url in block.urls) {
      addAfter(url);
    }
  }
  if (!fromBody) {
    for (final ShowroomBeforeAfter pair in story.comparisons) {
      addAfter(pair.afterUrl);
    }
    for (final ShowroomProcessFrame frame in story.process) {
      addAfter(frame.imageUrl);
    }
  }
  return frames;
}
