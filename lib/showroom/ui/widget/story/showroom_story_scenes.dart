import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/showroom_story_model.dart';

const Color storyInk = Color(0xFF111111);
const Color storyPaper = Color(0xFFF6F3EE);

/// 글이 올라오는 데 쓰는 진행 구간.
const double storyRiseSpan = 0.28;

/// 항목이 모두 나타난 진행률. 스크롤이 머무는 지점.
double storyItemsSettle({
  required double start,
  required double step,
  required int count,
}) {
  if (count <= 0) return 0;
  final double end = start + (count - 1) * step + storyRiseSpan;
  return end.clamp(0.0, 0.96);
}

/// 사진 위 글이 읽히도록 위와 아래를 어둡게 덮는다.
class StoryPhotoScrim extends StatelessWidget {
  const StoryPhotoScrim({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xB3000000),
            Color(0x00000000),
            Color(0x00000000),
            Color(0xF2000000),
          ],
          stops: [0.0, 0.24, 0.46, 1.0],
        ),
      ),
    );
  }
}

class StoryPhoto extends StatelessWidget {
  const StoryPhoto({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return AppNetworkImage(
      url: url,
      width: double.infinity,
      height: double.infinity,
      placeholderColor: const Color(0xFF2A2A2A),
    );
  }
}

class StoryKicker extends StatelessWidget {
  const StoryKicker(this.label, {super.key, required this.onDark});

  final String label;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final double top = MediaQuery.paddingOf(context).top + 72;
    return Padding(
      padding: EdgeInsets.fromLTRB(28, top, 28, 0),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
          color: onDark ? const Color(0xCCFFFFFF) : const Color(0xFF8A8A8A),
        ),
      ),
    );
  }
}

class StoryScrollCue extends StatefulWidget {
  const StoryScrollCue({super.key, required this.opacity});

  final double opacity;

  @override
  State<StoryScrollCue> createState() => _StoryScrollCueState();
}

class _StoryScrollCueState extends State<StoryScrollCue>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.opacity,
      child: AnimatedBuilder(
        animation: _motion,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 8 * _motion.value),
            child: child,
          );
        },
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '아래로 스크롤',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }
}

class StoryHeroScene extends StatelessWidget {
  const StoryHeroScene({
    super.key,
    required this.story,
    required this.progress,
  });

  final ShowroomStoryModel story;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final String likes =
        story.likeCount > 999 ? '999+' : story.likeCount.toString();
    const double hint = 1;
    final double bottom = MediaQuery.paddingOf(context).bottom + 28;

    return Stack(
      fit: StackFit.expand,
      children: [
        StoryPhoto(url: story.thumbnailUrl),
        const StoryPhotoScrim(),
        Positioned(
          left: 28,
          right: 28,
          bottom: bottom + 72,
          child: Transform.translate(
            offset: Offset(0, -10 * progress),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story.themeName,
                  style: const TextStyle(
                    color: Color(0xE6FFFFFF),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  story.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(story.userProfileUrl),
                      radius: 14,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${story.userName}  ·  좋아요 $likes',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: bottom,
          child: StoryScrollCue(opacity: hint),
        ),
      ],
    );
  }
}

class StorySituationScene extends StatelessWidget {
  const StorySituationScene({
    super.key,
    required this.situation,
    required this.progress,
  });

  final ShowroomSituation situation;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final List<(String, String)> facts = <(String, String)>[
      ('업종', situation.industry),
      ('평수', situation.area),
      ('예산', situation.budget),
      ('기간', situation.period),
    ];

    return ColoredBox(
      color: storyPaper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StoryKicker('이 공간', onDark: false),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < facts.length; i++)
                    _Rise(
                      progress: progress,
                      start: 0.18 + i * 0.18,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              facts[i].$1,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8A8A8A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              facts[i].$2,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.6,
                                height: 1.15,
                                color: storyInk,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StoryBeforeAfterScene extends StatefulWidget {
  const StoryBeforeAfterScene({
    super.key,
    required this.beforeAfter,
    required this.progress,
  });

  final ShowroomBeforeAfter beforeAfter;
  final double progress;

  @override
  State<StoryBeforeAfterScene> createState() => _StoryBeforeAfterSceneState();
}

class _StoryBeforeAfterSceneState extends State<StoryBeforeAfterScene> {
  double _fraction = 0.5;

  void _drag(double delta, double width) {
    if (width <= 0) return;
    setState(() {
      _fraction = (_fraction + delta / width).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.paddingOf(context).bottom + 28;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;
        final double x = _fraction * width;
        return Stack(
          fit: StackFit.expand,
          children: [
            StoryPhoto(url: widget.beforeAfter.afterUrl),
            ClipRect(
              clipper: _LeftFractionClipper(_fraction),
              child: StoryPhoto(url: widget.beforeAfter.beforeUrl),
            ),
            const StoryPhotoScrim(),
            Positioned(
              left: x - 1.5,
              top: 0,
              width: 3,
              height: height,
              child: const ColoredBox(color: Colors.white),
            ),
            Positioned(
              left: x - 18,
              top: height / 2 - 18,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(Icons.swap_horiz, size: 20, color: storyInk),
                ),
              ),
            ),
            Positioned(
              left: 28,
              right: 28,
              bottom: bottom,
              child: Opacity(
                opacity: widget.progress.clamp(0.0, 1.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.beforeAfter.caption,
                      style: const TextStyle(
                        color: Color(0xE6FFFFFF),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Text(
                          '시공 전',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Spacer(),
                        Text(
                          '시공 후',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const StoryKicker('시공 전후', onDark: true),
            Positioned(
              left: 32,
              top: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (DragUpdateDetails details) {
                  _drag(details.delta.dx, width);
                },
                child: const SizedBox.expand(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class StoryCostScene extends StatelessWidget {
  const StoryCostScene({super.key, required this.cost, required this.progress});

  final ShowroomCost cost;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: storyInk,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StoryKicker('공사비', onDark: true),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '총 공사비',
                    style: TextStyle(
                      color: Color(0xFF9A9A9A),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cost.total,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 28),
                  for (var i = 0; i < cost.lines.length; i++)
                    _Rise(
                      progress: progress,
                      start: 0.22 + i * 0.16,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                cost.lines[i].name,
                                style: const TextStyle(
                                  color: Color(0xFFD0D0D0),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              cost.lines[i].amount,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StoryProcessFrameScene extends StatelessWidget {
  const StoryProcessFrameScene({
    super.key,
    required this.frame,
    required this.index,
    required this.count,
    required this.progress,
  });

  final ShowroomProcessFrame frame;
  final int index;
  final int count;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.paddingOf(context).bottom + 28;

    return Stack(
      fit: StackFit.expand,
      children: [
        StoryPhoto(url: frame.imageUrl),
        const StoryPhotoScrim(),
        const StoryKicker('현장 기록', onDark: true),
        Positioned(
          left: 28,
          right: 28,
          bottom: bottom,
          child: _Rise(
            progress: progress,
            start: 0.08,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1} / $count',
                  style: const TextStyle(
                    color: Color(0xE6FFFFFF),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  frame.caption,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                    letterSpacing: -0.3,
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

class StoryGuideScene extends StatelessWidget {
  const StoryGuideScene({
    super.key,
    required this.lines,
    required this.progress,
  });

  final List<String> lines;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: storyPaper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StoryKicker('알고 가면', onDark: false),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < lines.length; i++)
                    _Rise(
                      progress: progress,
                      start: 0.2 + i * 0.2,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 22),
                        child: Text(
                          lines[i],
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                            letterSpacing: -0.4,
                            color: storyInk,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeftFractionClipper extends CustomClipper<Rect> {
  const _LeftFractionClipper(this.fraction);

  final double fraction;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(
      0,
      0,
      size.width * fraction.clamp(0.0, 1.0),
      size.height,
    );
  }

  @override
  bool shouldReclip(covariant _LeftFractionClipper oldClipper) {
    return oldClipper.fraction != fraction;
  }
}

class _Rise extends StatelessWidget {
  const _Rise({
    required this.progress,
    required this.start,
    required this.child,
  });

  final double progress;
  final double start;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double appear = ((progress - start) / storyRiseSpan).clamp(0.0, 1.0);
    return Opacity(
      opacity: appear,
      child: Transform.translate(
        offset: Offset(0, (1 - appear) * 16),
        child: child,
      ),
    );
  }
}
