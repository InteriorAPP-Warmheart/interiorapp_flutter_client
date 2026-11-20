import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/editor/rich_text_document.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_asset_image.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/showroom_body.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/showroom_story_model.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_photo_gallery.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_photo_ratio.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_process_tour.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_wipe_compare.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_zone_compare.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/story/showroom_story_scenes.dart';

class ShowroomBodyView extends StatelessWidget {
  const ShowroomBodyView({super.key, required this.blocks, this.onOpenImage});

  final List<ShowroomBlock> blocks;

  /// 본문 사진 순서. 표지를 앞에 붙인 화면은 이 인덱스에 더해 연다.
  final ValueChanged<int>? onOpenImage;

  @override
  Widget build(BuildContext context) {
    final List<ShowroomBlock> visible =
        blocks.where((ShowroomBlock block) => block.hasContent).toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    final List<String> urls = showroomReadingImageUrls(blocks);
    void open(int index) {
      final ValueChanged<int>? onOpenImage = this.onOpenImage;
      if (onOpenImage != null) {
        onOpenImage(index);
        return;
      }
      openShowroomPhotoGallery(context, urls: urls, initialIndex: index);
    }

    final List<Widget> children = <Widget>[];
    var cursor = 0;
    for (var index = 0; index < visible.length; index++) {
      final ShowroomBlock block = visible[index];
      if (block.kind == ShowroomBlockKind.text) {
        children.add(_ReadingText(block: block));
      } else if (block.kind == ShowroomBlockKind.process) {
        final List<ShowroomProcessFrame> frames = <ShowroomProcessFrame>[
          for (final ShowroomProcessFrame frame in block.frames)
            if (frame.imageUrl.trim().isNotEmpty ||
                frame.trade.trim().isNotEmpty ||
                frame.caption.trim().isNotEmpty)
              frame,
        ];
        if (frames.isEmpty) continue;
        final int start = cursor;
        children.add(
          ShowroomProcessTour(
            frames: frames,
            wrapPhoto: (
              int frameIndex,
              ShowroomProcessFrame frame,
              Widget photo,
            ) {
              final String url = frame.imageUrl.trim();
              if (url.isEmpty) return photo;
              var seen = 0;
              for (var i = 0; i < frameIndex; i++) {
                if (frames[i].imageUrl.trim().isNotEmpty) seen += 1;
              }
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => open(start + seen),
                child: photo,
              );
            },
          ),
        );
        cursor +=
            frames
                .where(
                  (ShowroomProcessFrame frame) =>
                      frame.imageUrl.trim().isNotEmpty,
                )
                .length;
      } else if (block.layout == ShowroomImageLayout.beforeAfter) {
        final List<ShowroomZone> zones = _zonesOf(<ShowroomBlock>[block]);
        if (zones.isEmpty) continue;
        final List<int> beforeIndex = <int>[];
        final List<int> afterIndex = <int>[];
        for (final ShowroomZone zone in zones) {
          beforeIndex.add(zone.beforeUrl.trim().isEmpty ? -1 : cursor++);
          afterIndex.add(zone.afterUrl.trim().isEmpty ? -1 : cursor++);
        }
        children.add(
          ShowroomZoneCompare(
            zones: zones,
            onOpen: (int zoneIndex, bool showingAfter) {
              final int before = beforeIndex[zoneIndex];
              final int after = afterIndex[zoneIndex];
              final int picked =
                  showingAfter
                      ? (after >= 0 ? after : before)
                      : (before >= 0 ? before : after);
              if (picked >= 0) open(picked);
            },
          ),
        );
      } else {
        final int start = cursor;
        children.add(
          _ImageLayoutView(block: block, startIndex: start, onOpen: open),
        );
        cursor += showroomPhotoOffset(block.urls, block.urls.length);
      }
      if (index == visible.length - 1) continue;
      children.add(SizedBox(height: _readingGap(block, visible[index + 1])));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

const TextStyle _readingBody = TextStyle(
  fontSize: 16,
  height: 1.6,
  letterSpacing: 0,
  fontWeight: FontWeight.w400,
  color: showroomInk,
);

/// 글과 사진 사이는 같은 간격이다. 카페 글은 위아래를 다르게 벌리지 않는다.
double _readingGap(ShowroomBlock current, ShowroomBlock next) {
  return 16;
}

class _ReadingText extends StatelessWidget {
  const _ReadingText({required this.block});

  final ShowroomBlock block;

  @override
  Widget build(BuildContext context) {
    final List<
      ({String text, RichTextAlign align, RichTextSize size, bool bold})
    >
    lines =
        <({String text, RichTextAlign align, RichTextSize size, bool bold})>[];
    for (final RichTextParagraph paragraph in block.paragraphs) {
      final RichTextSize size =
          paragraph.runs.isEmpty
              ? RichTextSize.medium
              : paragraph.runs.first.size;
      final bool bold = paragraph.runs.any((RichTextRun run) => run.bold);
      final List<String> chunks =
          paragraph.text
              .split(RegExp(r'\n\s*\n'))
              .map((String chunk) => chunk.trim())
              .where((String chunk) => chunk.isNotEmpty)
              .toList();
      for (final String chunk in chunks) {
        lines.add((
          text: chunk,
          align: paragraph.align,
          size: size,
          bold: bold,
        ));
      }
    }
    if (lines.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: ResponsiveSize.textInset(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < lines.length; index++) ...[
            if (index > 0)
              SizedBox(
                height: lines[index - 1].size == RichTextSize.large ? 8 : 12,
              ),
            Text(
              lines[index].text,
              textAlign: switch (lines[index].align) {
                RichTextAlign.left => TextAlign.left,
                RichTextAlign.center => TextAlign.center,
                RichTextAlign.right => TextAlign.right,
              },
              style: _readingStyle(lines[index].size, lines[index].bold),
            ),
          ],
        ],
      ),
    );
  }
}

TextStyle _readingStyle(RichTextSize size, bool bold) {
  return switch (size) {
    RichTextSize.large => _readingBody.copyWith(
      fontSize: 22,
      height: 1.35,
      letterSpacing: -0.4,
      fontWeight: FontWeight.w700,
    ),
    RichTextSize.small => _readingBody.copyWith(
      fontSize: 14,
      height: 1.55,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    ),
    RichTextSize.medium => _readingBody.copyWith(
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    ),
  };
}

List<ShowroomZone> _zonesOf(List<ShowroomBlock> blocks) {
  final List<ShowroomZone> zones = <ShowroomZone>[];
  var unnamed = 0;
  for (final ShowroomBlock block in blocks) {
    if (block.kind != ShowroomBlockKind.images) continue;
    if (block.layout != ShowroomImageLayout.beforeAfter) continue;
    for (final ShowroomBeforeAfterPair pair in block.pairs) {
      if (!pair.hasImage) continue;
      final String caption = pair.caption.trim();
      unnamed += caption.isEmpty ? 1 : 0;
      zones.add(
        ShowroomZone(
          label: caption.isEmpty ? '구역 $unnamed' : caption,
          beforeUrl: pair.beforeUrl,
          afterUrl: pair.afterUrl,
        ),
      );
    }
  }
  return zones;
}

class ShowroomImageCard extends StatelessWidget {
  const ShowroomImageCard({
    super.key,
    required this.block,
    required this.onRemove,
    required this.onAddImage,
    required this.onPairs,
    required this.pickImage,
  });

  final ShowroomBlock block;
  final VoidCallback onRemove;
  final VoidCallback onAddImage;
  final ValueChanged<List<ShowroomBeforeAfterPair>> onPairs;
  final Future<String?> Function() pickImage;

  String get _label {
    return switch (block.layout) {
      ShowroomImageLayout.photo => '사진',
      ShowroomImageLayout.slider => '슬라이드',
      ShowroomImageLayout.gallery => '갤러리',
      ShowroomImageLayout.stack => '나열',
      ShowroomImageLayout.beforeAfter => '전후',
    };
  }

  @override
  Widget build(BuildContext context) {
    if (showroomSoloEmoticon(block)) {
      return GestureDetector(
        onLongPress: onRemove,
        child: Align(
          alignment: Alignment.center,
          child: _ShowroomEmoticon(url: block.urls.first.trim()),
        ),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD5D8DE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 2, 4, 0),
            child: Row(
              children: [
                Text(
                  _label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: onRemove,
                  canRequestFocus: false,
                  borderRadius: BorderRadius.circular(8),
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(Icons.close, size: 18),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              10,
              0,
              block.layout == ShowroomImageLayout.beforeAfter ? 4 : 10,
              8,
            ),
            child:
                block.layout == ShowroomImageLayout.beforeAfter
                    ? _ZoneWrite(
                      pairs: block.pairs,
                      onChanged: onPairs,
                      pickImage: pickImage,
                    )
                    : _FlatImages(
                      urls: block.urls,
                      layout: block.layout,
                      onAdd: onAddImage,
                    ),
          ),
        ],
      ),
    );
  }
}

class _FlatImages extends StatelessWidget {
  const _FlatImages({
    required this.urls,
    required this.layout,
    required this.onAdd,
  });

  final List<String> urls;
  final ShowroomImageLayout layout;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (urls.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              '사진을 올리면 이 배치로 보여요. 여러 장 넣을 수 있어요.',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          )
        else if (layout == ShowroomImageLayout.photo)
          _EditorImage(url: urls.first, aspectRatio: 4 / 5)
        else if (layout == ShowroomImageLayout.stack)
          Column(
            children: [
              for (var index = 0; index < urls.length; index++) ...[
                if (index > 0) const SizedBox(height: 8),
                _EditorImage(url: urls[index], aspectRatio: 3 / 2),
              ],
            ],
          )
        else if (layout == ShowroomImageLayout.slider)
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final _SliderMeasure measure = _SliderMeasure.of(
                viewport: constraints.maxWidth,
                inset: 0,
                several: urls.length > 1,
              );
              return SizedBox(
                height: measure.cardWidth * 5 / 4,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.manual,
                  itemCount: urls.length,
                  separatorBuilder:
                      (context, index) => SizedBox(width: measure.gap),
                  itemBuilder: (BuildContext context, int index) {
                    final String url = urls[index];
                    if (showroomEmoticonUrl(url)) {
                      return _ShowroomEmoticon(url: url);
                    }
                    return _PhotoTile(
                      url: url,
                      width: measure.cardWidth,
                      height: measure.cardWidth * 5 / 4,
                    );
                  },
                ),
              );
            },
          )
        else
          _FocusGallery(urls: urls),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('사진 추가'),
        ),
      ],
    );
  }
}

class _FocusGallery extends StatefulWidget {
  const _FocusGallery({
    required this.urls,
    this.radius = 12,
    this.thumbInset = 0,
    this.onOpen,
  });

  final List<String> urls;
  final double radius;

  /// 작은 사진 줄만 안으로 들인다. 큰 사진은 주어진 폭을 그대로 쓴다.
  final double thumbInset;

  /// 큰 사진을 누르면 그 장부터 연다. 작은 사진은 큰 사진만 바꾼다.
  final ValueChanged<int>? onOpen;

  @override
  State<_FocusGallery> createState() => _FocusGalleryState();
}

class _FocusGalleryState extends State<_FocusGallery> {
  int _index = 0;

  @override
  void didUpdateWidget(covariant _FocusGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.urls.isEmpty) {
      _index = 0;
    } else if (_index >= widget.urls.length) {
      _index = widget.urls.length - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.urls.isEmpty) return const SizedBox.shrink();
    final int index = _index.clamp(0, widget.urls.length - 1);
    return Column(
      children: [
        showroomEmoticonUrl(widget.urls[index])
            ? Align(
              alignment: Alignment.center,
              child: _ShowroomEmoticon(url: widget.urls[index]),
            )
            : GestureDetector(
              onTap: widget.onOpen == null ? null : () => widget.onOpen!(index),
              child: ShowroomPhotoRatio(
                url: widget.urls[index],
                builder: (BuildContext context, double aspectRatio) {
                  return ClipRRect(
                    key: ValueKey<String>(widget.urls[index]),
                    borderRadius: BorderRadius.circular(widget.radius),
                    child: AspectRatio(
                      aspectRatio: aspectRatio,
                      child: AppNetworkImage(
                        url: widget.urls[index],
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ),
        if (widget.urls.length > 1) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: widget.thumbInset),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
              itemCount: widget.urls.length,
              separatorBuilder:
                  (context, thumbIndex) => const SizedBox(width: 8),
              itemBuilder: (BuildContext context, int thumbIndex) {
                final bool selected = thumbIndex == index;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _index = thumbIndex),
                    canRequestFocus: false,
                    borderRadius: BorderRadius.circular(10),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              selected ? AppColors.primary : AppColors.border,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child:
                            showroomEmoticonUrl(widget.urls[thumbIndex])
                                ? _ShowroomEmoticon(
                                  url: widget.urls[thumbIndex],
                                  size: 56,
                                )
                                : _PhotoTile(
                                  url: widget.urls[thumbIndex],
                                  width: 72,
                                  height: 56,
                                ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _ZoneWrite extends StatefulWidget {
  const _ZoneWrite({
    required this.pairs,
    required this.onChanged,
    required this.pickImage,
  });

  final List<ShowroomBeforeAfterPair> pairs;
  final ValueChanged<List<ShowroomBeforeAfterPair>> onChanged;
  final Future<String?> Function() pickImage;

  @override
  State<_ZoneWrite> createState() => _ZoneWriteState();
}

class _ZoneWriteState extends State<_ZoneWrite> {
  final Map<String, TextEditingController> _captions =
      <String, TextEditingController>{};
  int _index = 0;
  bool _after = false;

  List<ShowroomBeforeAfterPair> get _pairs =>
      widget.pairs.isEmpty
          ? const <ShowroomBeforeAfterPair>[ShowroomBeforeAfterPair(id: 'pair')]
          : widget.pairs;

  @override
  void didUpdateWidget(covariant _ZoneWrite oldWidget) {
    super.didUpdateWidget(oldWidget);
    final Set<String> ids =
        _pairs.map((ShowroomBeforeAfterPair pair) => pair.id).toSet();
    final List<String> gone =
        _captions.keys.where((String id) => !ids.contains(id)).toList();
    for (final String id in gone) {
      _captions.remove(id)?.dispose();
    }
    if (_index >= _pairs.length) _index = 0;
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _captions.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _caption(ShowroomBeforeAfterPair pair) {
    return _captions.putIfAbsent(
      pair.id,
      () => TextEditingController(text: pair.caption),
    );
  }

  void _replace(int index, ShowroomBeforeAfterPair next) {
    final List<ShowroomBeforeAfterPair> pairs = <ShowroomBeforeAfterPair>[
      for (var i = 0; i < _pairs.length; i++)
        if (i == index) next else _pairs[i],
    ];
    widget.onChanged(pairs);
  }

  Future<void> _attach(ShowroomBeforeAfterPair pair) async {
    final String? url = await widget.pickImage();
    if (!mounted || url == null || url.isEmpty) return;
    final int index = _pairs.indexWhere(
      (ShowroomBeforeAfterPair item) => item.id == pair.id,
    );
    if (index < 0) return;
    final ShowroomBeforeAfterPair current = _pairs[index];
    _replace(
      index,
      _after
          ? current.copyWith(afterUrl: url)
          : current.copyWith(beforeUrl: url),
    );
  }

  void _addZone() {
    final ShowroomBeforeAfterPair created = ShowroomBeforeAfterPair(
      id: 'pair-${DateTime.now().microsecondsSinceEpoch}',
    );
    setState(() {
      _index = _pairs.length;
      _after = false;
    });
    widget.onChanged(<ShowroomBeforeAfterPair>[..._pairs, created]);
  }

  void _removeZone(int index) {
    if (_pairs.length < 2) return;
    final List<ShowroomBeforeAfterPair> pairs = <ShowroomBeforeAfterPair>[
      ..._pairs,
    ]..removeAt(index);
    setState(() => _index = index.clamp(0, pairs.length - 1));
    widget.onChanged(pairs);
  }

  @override
  Widget build(BuildContext context) {
    final int index = _index.clamp(0, _pairs.length - 1);
    final ShowroomBeforeAfterPair pair = _pairs[index];
    final String url = _after ? pair.afterUrl : pair.beforeUrl;
    final String side = _after ? '시공 후' : '시공 전';
    final bool filled = url.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                key: ValueKey<String>(pair.id),
                controller: _caption(pair),
                onChanged:
                    (String value) =>
                        _replace(index, pair.copyWith(caption: value)),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: '위치. 예: 홀',
                  hintStyle: const TextStyle(
                    color: Color(0xFFB0B6BE),
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFD5D8DE)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFD5D8DE)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            if (_pairs.length > 1)
              IconButton(
                onPressed: () => _removeZone(index),
                icon: const Icon(Icons.close, size: 18),
                color: AppColors.textSecondary,
              ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Material(
            color: AppColors.surface,
            child: InkWell(
              onTap: () => _attach(pair),
              canRequestFocus: false,
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (filled)
                      AppNetworkImage(url: url)
                    else
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_photo_alternate_outlined,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$side 사진',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    if (filled) ShowroomCompareBadge(label: side),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ShowroomBeforeAfterToggle(
          after: _after,
          onChanged: (bool after) => setState(() => _after = after),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _pairs.length + 1,
            separatorBuilder:
                (BuildContext context, int chip) => const SizedBox(width: 10),
            itemBuilder: (BuildContext context, int chip) {
              if (chip == _pairs.length) {
                return _AddZoneChip(onTap: _addZone);
              }
              final ShowroomBeforeAfterPair item = _pairs[chip];
              final String name = item.caption.trim();
              return _ZonePick(
                label: name.isEmpty ? '위치 ${chip + 1}' : name,
                imageUrl:
                    item.afterUrl.isNotEmpty ? item.afterUrl : item.beforeUrl,
                selected: chip == index,
                onTap: () => setState(() => _index = chip),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ZonePick extends StatelessWidget {
  const _ZonePick({
    required this.label,
    required this.imageUrl,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String imageUrl;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 84,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? storyInk : const Color(0xFFE7E1D8),
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 76,
                    height: 68,
                    child:
                        imageUrl.isEmpty
                            ? const ColoredBox(
                              color: AppColors.imagePlaceholder,
                            )
                            : AppNetworkImage(url: imageUrl),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? storyInk : const Color(0xFF8A847A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddZoneChip extends StatelessWidget {
  const _AddZoneChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const SizedBox(
        width: 84,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(14)),
                border: Border.fromBorderSide(
                  BorderSide(color: Color(0xFFD5D8DE)),
                ),
              ),
              child: SizedBox(
                width: 80,
                height: 72,
                child: Icon(Icons.add, size: 20, color: AppColors.textPrimary),
              ),
            ),
            SizedBox(height: 6),
            Text(
              '위치 추가',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8A847A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 슬라이더 한 장의 너비.
/// 화면 전체에서는 왼쪽이 글과 같고, 다음 장은 글의 오른쪽 끝에서 여백만큼 보인다.
/// 이미 여백 안이면 다음 장만 살짝 보이게 너비를 잡는다.
class _SliderMeasure {
  const _SliderMeasure({
    required this.inset,
    required this.gap,
    required this.cardWidth,
  });

  final double inset;
  final double gap;
  final double cardWidth;

  static const double _gap = 8;
  static const double _peek = 32;

  static _SliderMeasure of({
    required double viewport,
    required double inset,
    required bool several,
  }) {
    final double pad = inset < 0 ? 0 : inset;
    if (!several) {
      final double width = viewport - pad * 2;
      return _SliderMeasure(
        inset: pad,
        gap: _gap,
        cardWidth: width > 0 ? width : viewport,
      );
    }
    if (pad == 0) {
      final double width = viewport - _peek;
      return _SliderMeasure(
        inset: 0,
        gap: _gap,
        cardWidth: width > 0 ? width : viewport,
      );
    }
    final double width = viewport - pad * 2 - _gap;
    return _SliderMeasure(
      inset: pad,
      gap: _gap,
      cardWidth: width > 0 ? width : viewport,
    );
  }
}

class _ImageLayoutView extends StatelessWidget {
  const _ImageLayoutView({
    required this.block,
    required this.startIndex,
    required this.onOpen,
  });

  final ShowroomBlock block;
  final int startIndex;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    if (block.layout == ShowroomImageLayout.photo) {
      final String url = block.urls.isEmpty ? '' : block.urls.first;
      if (url.isEmpty) return const SizedBox.shrink();
      if (showroomEmoticonUrl(url)) {
        return Align(
          alignment: Alignment.center,
          child: _ShowroomEmoticon(url: url),
        );
      }
      return ShowroomReadingFigure(
        child: _ReadingPhoto(url: url, onTap: () => onOpen(startIndex)),
      );
    }
    if (block.layout == ShowroomImageLayout.stack) {
      final List<String> urls =
          block.urls.where((String url) => url.trim().isNotEmpty).toList();
      if (urls.isEmpty) return const SizedBox.shrink();
      return Column(
        children: [
          for (var index = 0; index < urls.length; index++) ...[
            if (index > 0) const SizedBox(height: 8),
            showroomEmoticonUrl(urls[index])
                ? Align(
                  alignment: Alignment.center,
                  child: _ShowroomEmoticon(url: urls[index]),
                )
                : _ReadingPhoto(
                  url: urls[index],
                  onTap:
                      () =>
                          onOpen(startIndex + showroomPhotoOffset(urls, index)),
                ),
          ],
        ],
      );
    }
    if (block.layout == ShowroomImageLayout.gallery) {
      final List<String> urls =
          block.urls.where((String url) => url.trim().isNotEmpty).toList();
      if (urls.isEmpty) return const SizedBox.shrink();
      return _FocusGallery(
        urls: urls,
        radius: 0,
        thumbInset: ResponsiveSize.textInset(context).left,
        onOpen: (int index) {
          if (showroomEmoticonUrl(urls[index])) return;
          onOpen(startIndex + showroomPhotoOffset(urls, index));
        },
      );
    }
    if (block.layout == ShowroomImageLayout.slider) {
      final String first = block.urls.isEmpty ? '' : block.urls.first;
      return ShowroomPhotoRatio(
        url: first,
        builder: (BuildContext context, double aspectRatio) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double inset = ResponsiveSize.textInset(context).left;
              final _SliderMeasure measure = _SliderMeasure.of(
                viewport: constraints.maxWidth,
                inset: inset,
                several: block.urls.length > 1,
              );
              final double height = measure.cardWidth / aspectRatio;
              return SizedBox(
                height: height,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: measure.inset),
                  itemCount: block.urls.length,
                  separatorBuilder:
                      (context, index) => SizedBox(width: measure.gap),
                  itemBuilder: (BuildContext context, int index) {
                    final String url = block.urls[index];
                    if (showroomEmoticonUrl(url)) {
                      return _ShowroomEmoticon(url: url);
                    }
                    final int seen = showroomPhotoOffset(block.urls, index);
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap:
                          url.trim().isEmpty
                              ? null
                              : () => onOpen(startIndex + seen),
                      child: SizedBox(
                        width: measure.cardWidth,
                        height: height,
                        child: AppNetworkImage(url: url, fit: BoxFit.contain),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      );
    }
    return Padding(
      padding: ResponsiveSize.textInset(context),
      child: _FocusGallery(urls: block.urls, radius: 14),
    );
  }
}

class _ReadingPhoto extends StatelessWidget {
  const _ReadingPhoto({required this.url, required this.onTap});

  final String url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ShowroomPhotoRatio(
        url: url,
        builder: (BuildContext context, double aspectRatio) {
          return AspectRatio(
            aspectRatio: aspectRatio,
            child: AppNetworkImage(url: url, fit: BoxFit.contain),
          );
        },
      ),
    );
  }
}

class _EditorImage extends StatelessWidget {
  const _EditorImage({required this.url, required this.aspectRatio});

  final String url;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    if (showroomEmoticonUrl(url)) {
      return Align(
        alignment: Alignment.center,
        child: _ShowroomEmoticon(url: url),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: AppNetworkImage(url: url),
      ),
    );
  }
}

class _ShowroomEmoticon extends StatelessWidget {
  const _ShowroomEmoticon({
    required this.url,
    this.size = showroomEmoticonSize,
  });

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AppAssetImage(url, width: size, height: size, fit: BoxFit.contain);
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.url, this.width, this.height});

  final String url;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: width,
        height: height,
        child: AppNetworkImage(url: url),
      ),
    );
  }
}
