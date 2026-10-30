import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/showroom_story_model.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/vm/showroom_write_vm.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/story/showroom_story_scenes.dart';

/// 가로로 납작하면 공간 사진의 위아래가 많이 잘린다. 거의 정사각으로 둔다.
double showroomThumbnailExtent(BuildContext context) {
  return MediaQuery.sizeOf(context).width * 0.96;
}

/// 맨 위 사진을 크게 두고, 스크롤하면 상담 화면처럼 위로 접힌다.
/// 스타일, 제목, 작성자, 좋아요는 사진 위에 올린다.
SliverAppBar showroomThumbnailBar(
  BuildContext context, {
  required String imageUrl,
  required String style,
  required String title,
  String authorName = '',
  String authorPhotoUrl = '',
  String likes = '',
}) {
  final String url = imageUrl.trim();
  return SliverAppBar(
    primary: false,
    automaticallyImplyLeading: false,
    pinned: false,
    toolbarHeight: 0,
    elevation: 0,
    scrolledUnderElevation: 0,
    shadowColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    forceMaterialTransparency: true,
    backgroundColor: AppColors.background,
    expandedHeight: showroomThumbnailExtent(context),
    flexibleSpace: FlexibleSpaceBar(
      collapseMode: CollapseMode.pin,
      background: Stack(
        fit: StackFit.expand,
        children: [
          if (url.isEmpty)
            const ColoredBox(color: AppColors.imagePlaceholder)
          else
            StoryPhoto(url: url),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x00000000),
                  Color(0x00000000),
                  Color(0x73000000),
                  Color(0xE6000000),
                ],
                stops: [0.0, 0.34, 0.62, 1.0],
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 24,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 40,
            child: _CoverCaption(
              style: style.trim(),
              title: title.trim(),
              authorName: authorName.trim(),
              authorPhotoUrl: authorPhotoUrl.trim(),
              likes: likes.trim(),
            ),
          ),
        ],
      ),
    ),
  );
}

class _CoverCaption extends StatelessWidget {
  const _CoverCaption({
    required this.style,
    required this.title,
    required this.authorName,
    required this.authorPhotoUrl,
    required this.likes,
  });

  final String style;
  final String title;
  final String authorName;
  final String authorPhotoUrl;
  final String likes;

  static const List<Shadow> _shadow = <Shadow>[
    Shadow(color: Color(0xCC000000), blurRadius: 16, offset: Offset(0, 1)),
  ];

  @override
  Widget build(BuildContext context) {
    final bool showAuthor = authorName.isNotEmpty || likes.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (style.isNotEmpty) ...[
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0x8C000000),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xB3FFFFFF)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                style,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  color: Colors.white,
                  shadows: _shadow,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (title.isNotEmpty)
          Text(
            title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              height: 1.2,
              color: Colors.white,
              shadows: _shadow,
            ),
          ),
        if (showAuthor) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              if (authorName.isNotEmpty) ...[
                DecoratedBox(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(1.5),
                    child: CircleAvatar(
                      radius: 13,
                      backgroundColor: const Color(0x66000000),
                      backgroundImage:
                          authorPhotoUrl.startsWith('http')
                              ? NetworkImage(authorPhotoUrl)
                              : null,
                      child:
                          authorPhotoUrl.startsWith('http')
                              ? null
                              : const Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.white,
                              ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    authorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: _shadow,
                    ),
                  ),
                ),
              ] else
                const Spacer(),
              const Icon(Icons.favorite, size: 15, color: Colors.white),
              if (likes.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  likes,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    shadows: _shadow,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

bool showroomHasCostDetail(ShowroomCost? cost) {
  if (cost == null) return false;
  if (cost.total.trim().isNotEmpty) return true;
  return cost.lines.any(
    (ShowroomCostLine line) =>
        line.name.trim().isNotEmpty || line.amount.trim().isNotEmpty,
  );
}

class ShowroomFactCard extends StatefulWidget {
  const ShowroomFactCard({super.key, required this.facts, this.cost});

  final List<(String, String)> facts;
  final ShowroomCost? cost;

  @override
  State<ShowroomFactCard> createState() => _ShowroomFactCardState();
}

class _ShowroomFactCardState extends State<ShowroomFactCard> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    final List<(String, String)> facts = widget.facts;
    final bool hasCost = showroomHasCostDetail(widget.cost);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7E1D8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (var i = 0; i < facts.length; i += 2)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i + 2 < facts.length || hasCost ? 10 : 0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _Fact(label: facts[i].$1, value: facts[i].$2),
                    ),
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
            if (hasCost) ...[
              _CostDetailToggle(
                shown: _open,
                onChanged: (bool shown) => setState(() => _open = shown),
              ),
              if (_open) ...[
                const SizedBox(height: 10),
                ShowroomCostCard(cost: widget.cost!, embedded: true),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _CostDetailToggle extends StatelessWidget {
  const _CostDetailToggle({required this.shown, required this.onChanged});

  final bool shown;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => onChanged(!shown),
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE4E4E4)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '세부 공사비',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: storyInk,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: shown ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: Color(0xFF8A847A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
            if (label == '예산')
              if (CostFormattingViewModel.wonReading(value)
                  case final String reading when reading.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  reading,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: Color(0xFF8A847A),
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }
}

class ShowroomCostCard extends StatelessWidget {
  const ShowroomCostCard({
    super.key,
    required this.cost,
    this.embedded = false,
  });

  final ShowroomCost cost;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final List<ShowroomCostLine> lines =
        cost.lines
            .where(
              (ShowroomCostLine line) =>
                  line.name.trim().isNotEmpty || line.amount.trim().isNotEmpty,
            )
            .toList();
    final Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                _WonAmount(amount: lines[i].amount),
              ],
            ),
          ),
          if (i != lines.length - 1)
            const Divider(height: 1, thickness: 1, color: Color(0xFFE8E8E8)),
        ],
      ],
    );
    if (embedded) return body;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7E1D8)),
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: body),
    );
  }
}

class _WonAmount extends StatelessWidget {
  const _WonAmount({required this.amount});

  final String amount;

  @override
  Widget build(BuildContext context) {
    final String reading = CostFormattingViewModel.wonReading(amount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          amount,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: storyInk,
          ),
        ),
        if (reading.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            reading,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8A847A),
            ),
          ),
        ],
      ],
    );
  }
}
