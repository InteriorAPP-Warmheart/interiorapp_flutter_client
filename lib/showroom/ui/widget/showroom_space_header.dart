import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/showroom_story_model.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/vm/showroom_write_vm.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_photo_ratio.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/story/showroom_story_scenes.dart';

/// 갤러리 버튼을 눌러 갤러리를 연다. 인자로 받는 맥락이 버튼의 자리다.
typedef ShowroomHighlightOpen = void Function(BuildContext photoContext);

/// 맨 위 사진을 원본 비율로 두고, 스타일, 제목, 작성자, 좋아요를 사진 위에 올린다.
Widget showroomThumbnailBar(
  BuildContext context, {
  required String imageUrl,
  required String style,
  required String title,
  String authorName = '',
  String authorPhotoUrl = '',
  String likes = '',
  bool showLike = true,
  int? commentCount,
  Color sheetColor = AppColors.background,
  VoidCallback? onPhotoTap,
  ShowroomHighlightOpen? onOpenHighlight,
}) {
  final String url = imageUrl.trim();
  return SliverToBoxAdapter(
    child: _CoverPhoto(
      url: url,
      sheetColor: sheetColor,
      onPhotoTap: onPhotoTap,
      onOpenHighlight: onOpenHighlight,
      caption: _CoverCaption(
        style: style.trim(),
        title: title.trim(),
        authorName: authorName.trim(),
        authorPhotoUrl: authorPhotoUrl.trim(),
        likes: likes.trim(),
        showLike: showLike,
        commentCount: commentCount,
      ),
    ),
  );
}

class _CoverPhoto extends StatelessWidget {
  const _CoverPhoto({
    required this.url,
    required this.sheetColor,
    required this.caption,
    this.onPhotoTap,
    this.onOpenHighlight,
  });

  final String url;
  final Color sheetColor;
  final Widget caption;
  final VoidCallback? onPhotoTap;
  final ShowroomHighlightOpen? onOpenHighlight;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const AspectRatio(
        aspectRatio: 3 / 2,
        child: ColoredBox(color: AppColors.imagePlaceholder),
      );
    }
    return ShowroomPhotoRatio(
      url: url,
      builder: (BuildContext context, double ratio) {
        return AspectRatio(
          aspectRatio: ratio <= 0 ? 3 / 2 : ratio,
          child: _CoverHit(
            url: url,
            sheetColor: sheetColor,
            caption: caption,
            onPhotoTap: onPhotoTap,
            onOpenHighlight: onOpenHighlight,
          ),
        );
      },
    );
  }
}

class _CoverHit extends StatefulWidget {
  const _CoverHit({
    required this.url,
    required this.sheetColor,
    required this.caption,
    this.onPhotoTap,
    this.onOpenHighlight,
  });

  final String url;
  final Color sheetColor;
  final Widget caption;
  final VoidCallback? onPhotoTap;
  final ShowroomHighlightOpen? onOpenHighlight;

  @override
  State<_CoverHit> createState() => _CoverHitState();
}

class _CoverHitState extends State<_CoverHit> {
  final GlobalKey _chipKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final Widget cover = Stack(
      fit: StackFit.expand,
      children: [
        StoryPhoto(url: widget.url),
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
        if (widget.onOpenHighlight != null)
          Positioned(
            top: 14,
            right: 14,
            child: KeyedSubtree(
              key: _chipKey,
              child: _HighlightChip(
                onTap: () {
                  final BuildContext? chip = _chipKey.currentContext;
                  widget.onOpenHighlight!(chip ?? context);
                },
              ),
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 24,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.sheetColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
          ),
        ),
        Positioned(left: 20, right: 20, bottom: 40, child: widget.caption),
      ],
    );
    final VoidCallback? onPhotoTap = widget.onPhotoTap;
    if (onPhotoTap == null) return cover;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPhotoTap,
      child: cover,
    );
  }
}

class _HighlightChip extends StatelessWidget {
  const _HighlightChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xCC111111),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.photo_library_outlined, size: 15, color: Colors.white),
              SizedBox(width: 6),
              Text(
                '갤러리',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverCaption extends StatelessWidget {
  const _CoverCaption({
    required this.style,
    required this.title,
    required this.authorName,
    required this.authorPhotoUrl,
    required this.likes,
    this.showLike = true,
    this.commentCount,
  });

  final String style;
  final String title;
  final String authorName;
  final String authorPhotoUrl;
  final String likes;
  final bool showLike;
  final int? commentCount;

  static const List<Shadow> _shadow = <Shadow>[
    Shadow(color: Color(0xCC000000), blurRadius: 16, offset: Offset(0, 1)),
  ];

  @override
  Widget build(BuildContext context) {
    final bool showAuthor =
        authorName.isNotEmpty || likes.isNotEmpty || commentCount != null;
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
              if (showLike) ...[
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
                const SizedBox(width: 12),
              ],
              if (commentCount != null) ...[
                const Icon(
                  Icons.mode_comment_outlined,
                  size: 15,
                  color: Colors.white,
                  shadows: _shadow,
                ),
                const SizedBox(width: 4),
                Text(
                  '댓글 $commentCount',
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
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final List<(String, String)> facts = widget.facts;
    final bool hasCost = showroomHasCostDetail(widget.cost);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: showroomChip,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
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
              const Divider(height: 1, thickness: 1, color: showroomFigureLine),
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
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!shown),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  '세부 공사비',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: showroomInk,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: shown ? 0.5 : 0,
                duration: const Duration(milliseconds: 180),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: showroomMuted,
                ),
              ),
            ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              height: 1.3,
              fontWeight: FontWeight.w500,
              color: showroomMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              height: 1.25,
              color: showroomInk,
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
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                  color: showroomMuted,
                ),
              ),
            ],
        ],
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
                      fontWeight: FontWeight.w400,
                      color: showroomInk,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _WonAmount(amount: lines[i].amount),
              ],
            ),
          ),
          if (i != lines.length - 1)
            const Divider(height: 1, thickness: 1, color: showroomFigureLine),
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
            fontWeight: FontWeight.w600,
            color: showroomInk,
          ),
        ),
        if (reading.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            reading,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: showroomMuted,
            ),
          ),
        ],
      ],
    );
  }
}
