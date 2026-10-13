import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/hot_showroom_model.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/showroom_story_model.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/provider/hot_showroom_provider.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/provider/showroom_story_provider.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/story/showroom_story_scenes.dart';

/// 스토리를 생략하지 않고, 같은 데이터를 구역별로 펼쳐 보여 준다.
class ShowroomBoardScreen extends ConsumerWidget {
  const ShowroomBoardScreen({super.key, required this.showroomId});

  final String showroomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ShowroomStoryModel?> storyAsync = ref.watch(
      showroomStoryProvider(showroomId),
    );
    final List<HotShowroomModel> listed = ref.watch(hotShowroomSliderVm);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          storyAsync.maybeWhen(
            data: (ShowroomStoryModel? story) {
              if (story == null) return const SizedBox.shrink();
              final bool favorite =
                  listed
                      .where((HotShowroomModel item) => item.id == story.id)
                      .map((HotShowroomModel item) => item.favoriteStatus)
                      .firstOrNull ??
                  story.favoriteStatus;
              return IconButton(
                onPressed: () {
                  ref
                      .read(hotShowroomSliderVm.notifier)
                      .toggleFavoriteByIndex(story.id);
                },
                icon: Icon(
                  favorite ? Icons.favorite : Icons.favorite_border,
                  color:
                      favorite
                          ? const Color(0xFFFF4D6A)
                          : Theme.of(context).colorScheme.onSurface,
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: storyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) => const Center(child: Text('이야기를 불러오지 못했어요')),
        data: (ShowroomStoryModel? story) {
          if (story == null) {
            return const Center(child: Text('이야기를 찾지 못했어요'));
          }
          return _Board(story: story);
        },
      ),
    );
  }
}

class _Board extends StatelessWidget {
  const _Board({required this.story});

  final ShowroomStoryModel story;

  @override
  Widget build(BuildContext context) {
    final String likes =
        story.likeCount > 999 ? '999+' : story.likeCount.toString();
    final ShowroomSituation? situation = story.situation;
    final List<(String, String)> facts =
        <(String, String)>[
          if (situation != null) ...<(String, String)>[
            ('업종', situation.industry),
            ('평수', situation.area),
            ('예산', situation.budget),
            ('기간', situation.period),
          ],
        ].where(((String, String) fact) => fact.$2.trim().isNotEmpty).toList();
    final ShowroomBeforeAfter? beforeAfter = story.beforeAfter;
    final ShowroomCost? cost = story.cost;
    final double bottom = MediaQuery.paddingOf(context).bottom + 40;

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 4, 16, bottom),
      children: [
        _IntroCard(story: story, likes: likes),
        if (facts.isNotEmpty) ...[
          const _SectionTitle('이 공간'),
          _Surface(child: _FactGrid(facts: facts)),
        ],
        if (beforeAfter != null) ...[
          const _SectionTitle('시공 전후'),
          _Surface(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: _BeforeAfterBlock(beforeAfter: beforeAfter),
          ),
        ],
        if (cost != null) ...[
          const _SectionTitle('공사비'),
          _Surface(child: _CostBlock(cost: cost)),
        ],
        if (story.process.isNotEmpty) ...[
          const _SectionTitle('현장 기록'),
          _ProcessLog(frames: story.process),
        ],
        if (story.guide.isNotEmpty) ...[
          const _SectionTitle('알고 가면'),
          _Surface(child: _GuideBlock(lines: story.guide)),
        ],
      ],
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.story, required this.likes});

  final ShowroomStoryModel story;
  final String likes;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: AspectRatio(
              aspectRatio: 3 / 2,
              child: StoryPhoto(url: story.thumbnailUrl),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFE4E4E4)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: Text(
                      story.themeName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: storyInk,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  story.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                    height: 1.2,
                    color: storyInk,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(story.userProfileUrl),
                      radius: 14,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        story.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: storyInk,
                        ),
                      ),
                    ),
                    Text(
                      '좋아요 $likes',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8A847A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BeforeAfterBlock extends StatelessWidget {
  const _BeforeAfterBlock({required this.beforeAfter});

  final ShowroomBeforeAfter beforeAfter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _ComparePhoto(label: '시공 전', url: beforeAfter.beforeUrl),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ComparePhoto(label: '시공 후', url: beforeAfter.afterUrl),
            ),
          ],
        ),
        if (beforeAfter.caption.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            beforeAfter.caption,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: Color(0xFF3A3834),
            ),
          ),
        ],
      ],
    );
  }
}

class _ComparePhoto extends StatelessWidget {
  const _ComparePhoto({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            StoryPhoto(url: url),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xCC000000)],
                  stops: [0.55, 1],
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CostBlock extends StatelessWidget {
  const _CostBlock({required this.cost});

  final ShowroomCost cost;

  @override
  Widget build(BuildContext context) {
    final List<ShowroomCostLine> lines =
        cost.lines
            .where(
              (ShowroomCostLine line) =>
                  line.name.trim().isNotEmpty || line.amount.trim().isNotEmpty,
            )
            .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE4E4E4)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '총 공사비',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8A847A),
                    ),
                  ),
                ),
                Text(
                  cost.total,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: storyInk,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (lines.isNotEmpty) const SizedBox(height: 6),
        for (var i = 0; i < lines.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    lines[i].name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3A3834),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  lines[i].amount,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: storyInk,
                  ),
                ),
              ],
            ),
          ),
          if (i != lines.length - 1)
            const Divider(height: 1, thickness: 1, color: Color(0xFFE8E8E8)),
        ],
      ],
    );
  }
}

class _ProcessLog extends StatelessWidget {
  const _ProcessLog({required this.frames});

  final List<ShowroomProcessFrame> frames;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
      child: Column(
        children: [
          for (var i = 0; i < frames.length; i++)
            _ProcessStep(
              frame: frames[i],
              index: i,
              last: i == frames.length - 1,
            ),
        ],
      ),
    );
  }
}

class _ProcessStep extends StatelessWidget {
  const _ProcessStep({
    required this.frame,
    required this.index,
    required this.last,
  });

  final ShowroomProcessFrame frame;
  final int index;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final String caption = frame.caption.trim();
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                DecoratedBox(
                  decoration: const BoxDecoration(
                    color: storyInk,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                if (!last)
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: SizedBox(
                        width: 1,
                        child: ColoredBox(color: Color(0xFFE4E4E4)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 8 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: StoryPhoto(url: frame.imageUrl),
                    ),
                  ),
                  if (caption.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      caption,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                        letterSpacing: -0.2,
                        color: storyInk,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideBlock extends StatelessWidget {
  const _GuideBlock({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final List<String> filled =
        lines.where((String line) => line.trim().isNotEmpty).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < filled.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == filled.length - 1 ? 0 : 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '${i + 1}'.padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                      color: Color(0xFF9A9A9A),
                    ),
                  ),
                ),
                Expanded(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: storyInk, width: 2),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Text(
                        filled[i],
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                          letterSpacing: -0.3,
                          color: storyInk,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 28, 4, 10),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: storyInk,
        ),
      ),
    );
  }
}

class _Surface extends StatelessWidget {
  const _Surface({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7E1D8)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

class _FactGrid extends StatelessWidget {
  const _FactGrid({required this.facts});

  final List<(String, String)> facts;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < facts.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: i + 2 < facts.length ? 10 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _Fact(label: facts[i].$1, value: facts[i].$2)),
                const SizedBox(width: 10),
                Expanded(
                  child:
                      i + 1 < facts.length
                          ? _Fact(
                            label: facts[i + 1].$1,
                            value: facts[i + 1].$2,
                          )
                          : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E4E4)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8A847A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                height: 1.25,
                color: storyInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
