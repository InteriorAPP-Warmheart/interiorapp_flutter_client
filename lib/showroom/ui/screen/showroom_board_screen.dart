import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/ui/space_routes.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/widget/expanding_action_button.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/quick_filter_catalog.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_reference_pick.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/hot_showroom_model.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/showroom_story_model.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/provider/hot_showroom_provider.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/provider/showroom_story_provider.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_comment_section.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_process_tour.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_space_header.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_zone_compare.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/story/showroom_story_scenes.dart';

/// 스토리를 생략하지 않고, 같은 데이터를 구역별로 펼쳐 보여 준다.
class ShowroomBoardScreen extends ConsumerStatefulWidget {
  const ShowroomBoardScreen({super.key, required this.showroomId});

  final String showroomId;

  @override
  ConsumerState<ShowroomBoardScreen> createState() =>
      _ShowroomBoardScreenState();
}

class _ShowroomBoardScreenState extends ConsumerState<ShowroomBoardScreen> {
  bool _picking = false;

  @override
  Widget build(BuildContext context) {
    final String showroomId = widget.showroomId;
    final AsyncValue<ShowroomStoryModel?> storyAsync = ref.watch(
      showroomStoryProvider(showroomId),
    );
    final List<HotShowroomModel> listed = ref.watch(hotShowroomSliderVm);

    return PopScope(
      canPop: !_picking,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop || !_picking) return;
        setState(() => _picking = false);
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          forceMaterialTransparency: true,
          notificationPredicate: (ScrollNotification notification) => false,
          leading: IconButton(
            onPressed: () {
              if (_picking) {
                setState(() => _picking = false);
                return;
              }
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
          ),
          actions: [
            storyAsync.maybeWhen(
              data: (ShowroomStoryModel? story) {
                final ShowroomStoryModel? overview =
                    story ?? _overviewFromList(listed, showroomId);
                if (overview == null) return const SizedBox.shrink();
                final bool favorite =
                    listed
                        .where(
                          (HotShowroomModel item) => item.id == overview.id,
                        )
                        .map((HotShowroomModel item) => item.favoriteStatus)
                        .firstOrNull ??
                    overview.favoriteStatus;
                return IconButton(
                  onPressed: () {
                    ref
                        .read(hotShowroomSliderVm.notifier)
                        .toggleFavoriteByIndex(overview.id);
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
        body: () {
          final ShowroomStoryModel? overview =
              storyAsync.asData?.value ?? _overviewFromList(listed, showroomId);
          if (overview != null) {
            return _Board(
              story: overview,
              picking: _picking,
              onPicking: (bool value) => setState(() => _picking = value),
            );
          }
          if (storyAsync.hasError) {
            return const Center(child: Text('이야기를 불러오지 못했어요'));
          }
          return const SizedBox.shrink();
        }(),
      ),
    );
  }
}

/// 스토리 없이 목록 카드만 있는 쇼룸. 사진과 기본 정보만 펼친다.
ShowroomStoryModel? _overviewFromList(
  List<HotShowroomModel> listed,
  String showroomId,
) {
  for (final HotShowroomModel item in listed) {
    if (item.id != showroomId) continue;
    return ShowroomStoryModel(
      id: item.id,
      title: item.title,
      themeName: item.themeName,
      thumbnailUrl: item.thumbnailUrl,
      userName: item.userName,
      userProfileUrl: item.userProfileUrl,
      likeCount: item.likeCount,
      favoriteStatus: item.favoriteStatus,
    );
  }
  return null;
}

class _Board extends StatelessWidget {
  const _Board({
    required this.story,
    required this.picking,
    required this.onPicking,
  });

  final ShowroomStoryModel story;
  final bool picking;
  final ValueChanged<bool> onPicking;

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
    final ShowroomCost? cost = story.cost;

    return _BoardScaffold(
      story: story,
      picking: picking,
      onPicking: onPicking,
      child: ShowroomBoardWithComments(
        authorName: story.userName,
        headerSlivers: [
          showroomThumbnailBar(
            context,
            imageUrl: story.thumbnailUrl,
            style: story.themeName,
            title: story.title,
            authorName: story.userName,
            authorPhotoUrl: story.userProfileUrl,
            likes: likes,
          ),
        ],
        leading: [
          if (facts.isNotEmpty || showroomHasCostDetail(cost)) ...[
            const _SectionTitle('이 공간'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ShowroomFactCard(
                facts: facts,
                cost: showroomHasCostDetail(cost) ? cost : null,
              ),
            ),
          ],
          if (story.comparisons.isNotEmpty) ...[
            const _SectionTitle('시공 전후'),
            _BoardComparisons(comparisons: story.comparisons),
          ],
          if (story.process.isNotEmpty) ...[
            const _SectionTitle('현장 기록'),
            ShowroomProcessTour(
              frames: story.process,
              wrapPhoto: (int index, ShowroomProcessFrame frame, Widget photo) {
                final String trade = frame.trade.trim();
                final String caption = frame.caption.trim();
                return ShowroomReferablePhoto(
                  id: 'process-$index',
                  label:
                      caption.isEmpty
                          ? (trade.isEmpty ? '현장 기록 ${index + 1}' : trade)
                          : caption,
                  imageUrl: frame.imageUrl,
                  child: photo,
                );
              },
            ),
          ],
          if (story.guide.isNotEmpty) ...[
            const _SectionTitle('알고 가면'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _Surface(child: _GuideBlock(lines: story.guide)),
            ),
          ],
        ],
      ),
    );
  }
}

class _BoardScaffold extends StatefulWidget {
  const _BoardScaffold({
    required this.story,
    required this.picking,
    required this.onPicking,
    required this.child,
  });

  final ShowroomStoryModel story;
  final bool picking;
  final ValueChanged<bool> onPicking;
  final Widget child;

  @override
  State<_BoardScaffold> createState() => _BoardScaffoldState();
}

class _BoardScaffoldState extends State<_BoardScaffold> {
  final ExpandingActionController _consult = ExpandingActionController();
  Map<String, ShowroomReferenceRegion> _regions =
      <String, ShowroomReferenceRegion>{};
  final Set<String> _aspects = <String>{};

  @override
  void didUpdateWidget(_BoardScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.picking && !widget.picking) {
      _regions = <String, ShowroomReferenceRegion>{};
      _aspects.clear();
    }
  }

  void _toggle(String id, String label, String imageUrl) {
    setState(() {
      final Map<String, ShowroomReferenceRegion> next =
          Map<String, ShowroomReferenceRegion>.from(_regions);
      if (next.containsKey(id)) {
        next.remove(id);
      } else {
        next[id] = ShowroomReferenceRegion(
          id: id,
          label: label,
          imageUrl: imageUrl,
        );
      }
      _regions = next;
    });
  }

  void _save(ShowroomReferenceRegion region) {
    setState(() {
      _regions = Map<String, ShowroomReferenceRegion>.from(_regions)
        ..[region.id] = region;
    });
  }

  void _submit() {
    final ShowroomStoryModel story = widget.story;
    final ShowroomSituation? situation = story.situation;
    final bool sameIndustry = _aspects.contains('같은 업종');
    final bool sameBudget = _aspects.contains('동일한 예산');
    final bool sameStyle = _aspects.contains('동일한 스타일');
    final int? budgetWon =
        sameBudget ? _wonFromLabel(situation?.budget ?? '') : null;
    context.push(
      SpaceRoutes.prepCreate,
      extra: PrepRecord(
        placeName: '',
        buildingType: '상가',
        address: '',
        detailAddress: '',
        area: '',
        buildingCondition: '',
        style: sameStyle ? _matchingStyle(story.themeName) : '',
        budget: budgetWon == null ? '' : _groupDigits(budgetWon.toString()),
        period: '',
        needs: '',
        floorPlanLabels: const <String>[],
        referenceImageLabels: const <String>[],
        industry: sameIndustry ? (situation?.industry ?? '') : '',
        styleRef: ShowroomStyleRef(
          showroomId: story.id,
          title: story.title,
          imageUrl: story.thumbnailUrl,
          aspects: [
            for (final String aspect in showroomReferenceAspects)
              if (_aspects.contains(aspect)) aspect,
          ],
          regions: _regions.values.toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.picking)
          ShowroomReferenceBanner(onClose: () => widget.onPicking(false)),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: ShowroomReferenceScope(
                  picking: widget.picking,
                  regions: _regions,
                  onToggle: _toggle,
                  onSave: _save,
                  child: Listener(
                    behavior: HitTestBehavior.translucent,
                    onPointerDown: (_) => _consult.close(),
                    child:
                        widget.picking
                            ? _ReferenceBoard(story: widget.story)
                            : widget.child,
                  ),
                ),
              ),
              if (!widget.picking)
                Positioned.fill(
                  child: ExpandingActionButton(
                    controller: _consult,
                    icon: Icons.chat_bubble_outline,
                    label: '이 스타일로 상담받기',
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    bottom: MediaQuery.paddingOf(context).bottom + 84,
                    onPressed: () => widget.onPicking(true),
                  ),
                ),
            ],
          ),
        ),
        if (widget.picking)
          ShowroomReferenceSubmitBar(
            count: _regions.length,
            aspects: _aspects,
            onAspect: (String aspect) {
              setState(() {
                if (_aspects.contains(aspect)) {
                  _aspects.remove(aspect);
                } else {
                  _aspects.add(aspect);
                }
              });
            },
            onSubmit: _submit,
          ),
      ],
    );
  }
}

/// 참고 모드. 댓글 없이, 고를 사진과 핵심 정보만 보여 준다.
class _ReferenceBoard extends StatelessWidget {
  const _ReferenceBoard({required this.story});

  final ShowroomStoryModel story;

  @override
  Widget build(BuildContext context) {
    final ShowroomSituation? situation = story.situation;
    final List<String> facts = <String>[
      if (situation != null && situation.industry.trim().isNotEmpty)
        situation.industry.trim(),
      if (situation != null && situation.area.trim().isNotEmpty)
        situation.area.trim(),
      if (situation != null && situation.budget.trim().isNotEmpty)
        situation.budget.trim(),
      if (situation != null && situation.period.trim().isNotEmpty)
        situation.period.trim(),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text(
          story.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            height: 1.25,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${story.themeName} · ${story.userName}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        if (facts.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            facts.join(' · '),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: AppColors.textPrimary,
            ),
          ),
        ],
        const SizedBox(height: 16),
        const _ReferenceLabel('대표 사진'),
        _ReferencePhoto(
          id: 'cover',
          label: '대표 사진',
          imageUrl: story.thumbnailUrl,
        ),
        if (story.comparisons.isNotEmpty) ...[
          const SizedBox(height: 22),
          const _ReferenceLabel('시공 전후'),
          for (var i = 0; i < story.comparisons.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _ReferencePair(pair: story.comparisons[i], index: i),
          ],
        ],
        if (story.process.isNotEmpty) ...[
          const SizedBox(height: 22),
          const _ReferenceLabel('현장 기록'),
          for (var i = 0; i < story.process.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _ReferencePhoto(
              id: 'process-$i',
              label:
                  story.process[i].caption.trim().isEmpty
                      ? '현장 기록 ${i + 1}'
                      : story.process[i].caption.trim(),
              imageUrl: story.process[i].imageUrl,
              caption: story.process[i].caption.trim(),
            ),
          ],
        ],
      ],
    );
  }
}

class _ReferenceLabel extends StatelessWidget {
  const _ReferenceLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ReferencePhoto extends StatelessWidget {
  const _ReferencePhoto({
    required this.id,
    required this.label,
    required this.imageUrl,
    this.caption = '',
  });

  final String id;
  final String label;
  final String imageUrl;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ShowroomReferablePhoto(
            id: id,
            label: label,
            imageUrl: imageUrl,
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: StoryPhoto(url: imageUrl),
            ),
          ),
        ),
        if (caption.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.35,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }
}

class _ReferencePair extends StatelessWidget {
  const _ReferencePair({required this.pair, required this.index});

  final ShowroomBeforeAfter pair;
  final int index;

  @override
  Widget build(BuildContext context) {
    final String zone = pair.zone.trim();
    final String beforeLabel = zone.isEmpty ? '시공 전' : '$zone 시공 전';
    final String afterLabel = zone.isEmpty ? '시공 후' : '$zone 시공 후';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (zone.isNotEmpty) ...[
          Text(
            zone,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ReferencePhoto(
                id: 'zone-$index-before',
                label: beforeLabel,
                imageUrl: pair.beforeUrl,
                caption: '시공 전',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ReferencePhoto(
                id: 'zone-$index-after',
                label: afterLabel,
                imageUrl: pair.afterUrl,
                caption: '시공 후',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BoardComparisons extends StatelessWidget {
  const _BoardComparisons({required this.comparisons});

  final List<ShowroomBeforeAfter> comparisons;

  @override
  Widget build(BuildContext context) {
    var unnamed = 0;
    final List<ShowroomZone> zones = <ShowroomZone>[];
    for (final ShowroomBeforeAfter item in comparisons) {
      final String zone = item.zone.trim();
      if (zone.isEmpty) unnamed += 1;
      zones.add(
        ShowroomZone(
          label: zone.isEmpty ? '구역 $unnamed' : zone,
          beforeUrl: item.beforeUrl,
          afterUrl: item.afterUrl,
          note: item.caption,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShowroomZoneCompare(zones: zones),
        ShowroomReferenceTargets(
          targets: [
            for (var i = 0; i < comparisons.length; i++) ...[
              ShowroomReferenceTarget(
                id: 'zone-$i-before',
                label:
                    comparisons[i].zone.trim().isEmpty
                        ? '시공 전'
                        : '${comparisons[i].zone.trim()} 시공 전',
                imageUrl: comparisons[i].beforeUrl,
              ),
              ShowroomReferenceTarget(
                id: 'zone-$i-after',
                label:
                    comparisons[i].zone.trim().isEmpty
                        ? '시공 후'
                        : '${comparisons[i].zone.trim()} 시공 후',
                imageUrl: comparisons[i].afterUrl,
              ),
            ],
          ],
        ),
      ],
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
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 10),
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
  const _Surface({required this.child});

  final Widget child;

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
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }
}

String _matchingStyle(String themeName) {
  for (final StyleMoodCard card in styleMoodCards) {
    if (themeName.contains(card.title)) return card.title;
  }
  if (themeName.contains('내추럴') || themeName.contains('우드'))
    return '따뜻하고 자연스러운';
  if (themeName.contains('다크')) return '묵직하고 도시적인';
  if (themeName.contains('미니멀') ||
      themeName.contains('화이트') ||
      themeName.contains('라이트')) {
    return '밝고 정돈된';
  }
  return '';
}

int? _wonFromLabel(String raw) {
  String text = raw.replaceAll(',', '').replaceAll(' ', '').replaceAll('원', '');
  if (text.isEmpty) return null;
  var total = 0;
  final RegExpMatch? eok = RegExp(r'(\d+)억').firstMatch(text);
  if (eok != null) {
    total += int.parse(eok.group(1)!) * 100000000;
    text = text.replaceFirst(eok.group(0)!, '');
  }
  final RegExpMatch? man = RegExp(r'(\d+)만').firstMatch(text);
  if (man != null) {
    total += int.parse(man.group(1)!) * 10000;
    text = text.replaceFirst(man.group(0)!, '');
  }
  final RegExpMatch? rest = RegExp(r'(\d+)').firstMatch(text);
  if (rest != null) total += int.parse(rest.group(1)!);
  return total == 0 ? null : total;
}

String _groupDigits(String digits) {
  if (digits.isEmpty) return '';
  final StringBuffer buffer = StringBuffer();
  final int lead = digits.length % 3;
  if (lead > 0) buffer.write(digits.substring(0, lead));
  for (int index = lead; index < digits.length; index += 3) {
    if (buffer.isNotEmpty) buffer.write(',');
    buffer.write(digits.substring(index, index + 3));
  }
  return buffer.toString();
}
