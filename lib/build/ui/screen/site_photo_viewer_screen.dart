import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/construction_progress.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/site_photo_record.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/site_photo_record_tile.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';

void openSitePhotoViewer(
  BuildContext context,
  SitePhotoRecord record, {
  List<SitePhotoRecord> timeline = const <SitePhotoRecord>[],
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder:
          (BuildContext context) =>
              SitePhotoViewerScreen(record: record, timeline: timeline),
    ),
  );
}

class SitePhotoViewerScreen extends StatefulWidget {
  const SitePhotoViewerScreen({
    super.key,
    required this.record,
    this.timeline = const <SitePhotoRecord>[],
  });

  final SitePhotoRecord record;

  /// 날짜를 고르는 기록. 같은 구역만 아래 줄에 이어 준다.
  final List<SitePhotoRecord> timeline;

  @override
  State<SitePhotoViewerScreen> createState() => _SitePhotoViewerScreenState();
}

class _SitePhotoViewerScreenState extends State<SitePhotoViewerScreen> {
  late SitePhotoRecord _record;
  late final PageController _pages = PageController();
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _record = widget.record;
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _onDate(SitePhotoRecord record) {
    if (record.sameAs(_record)) return;
    if (_pages.hasClients) _pages.jumpToPage(0);
    setState(() {
      _record = record;
      _index = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final SitePhotoRecord record = _record;
    final List<SitePhotoRecord> dates = sitePhotoAreaTimeline(
      widget.record,
      widget.timeline,
    );
    final double fontScale = ResponsiveSize.fontScale(context);
    final EdgeInsets inset = ResponsiveSize.textInset(context);
    final double bottom = MediaQuery.paddingOf(context).bottom;
    final String recordKey = [
      record.area,
      record.trade,
      record.takenOn,
      record.status.name,
    ].join('\u0000');
    return Scaffold(
      backgroundColor: AppColors.imagePlaceholder,
      appBar: AppBar(
        backgroundColor: AppColors.imagePlaceholder,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: record.detailLabel.isEmpty ? kToolbarHeight : 68,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record.placeLabel,
              style: TextStyle(
                fontSize: 17 * fontScale,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: AppColors.textPrimary,
              ),
            ),
            if (record.detailLabel.isNotEmpty)
              Text(
                record.detailLabel,
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: PageView.builder(
              key: ValueKey<String>(recordKey),
              controller: _pages,
              itemCount: record.count,
              onPageChanged: (int index) => setState(() => _index = index),
              itemBuilder: (BuildContext context, int index) {
                return SizedBox.expand(
                  child: AppNetworkImage(
                    url: record.photos[index].imageUrl,
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          ),
          DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 16, bottom: 16 + bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: inset.left,
                      right: inset.right,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SitePhotoStatusLabel(
                        status: record.status,
                        fontScale: fontScale,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DateStrip(
                    records: dates,
                    selected: record,
                    photoIndex: _index,
                    fontScale: fontScale,
                    onChanged: _onDate,
                  ),
                  if (record.note.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Padding(
                      padding: EdgeInsets.only(
                        left: inset.left,
                        right: inset.right,
                      ),
                      child: Text(
                        record.note,
                        style: TextStyle(
                          fontSize: 15 * fontScale,
                          height: 1.45,
                          color: AppColors.textPrimary,
                        ),
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

class _DateStrip extends StatefulWidget {
  const _DateStrip({
    required this.records,
    required this.selected,
    required this.photoIndex,
    required this.fontScale,
    required this.onChanged,
  });

  final List<SitePhotoRecord> records;
  final SitePhotoRecord selected;
  final int photoIndex;
  final double fontScale;
  final ValueChanged<SitePhotoRecord> onChanged;

  @override
  State<_DateStrip> createState() => _DateStripState();
}

class _DateStripState extends State<_DateStrip> {
  final ScrollController _scroll = ScrollController();
  late final List<GlobalKey> _keys = List<GlobalKey>.generate(
    widget.records.length,
    (int index) => GlobalKey(),
  );

  @override
  void initState() {
    super.initState();
    _center(animated: false);
  }

  @override
  void didUpdateWidget(_DateStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.selected.sameAs(widget.selected)) {
      _center(animated: true);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  int _selectedIndex() {
    final int index = widget.records.indexWhere(
      (SitePhotoRecord record) => record.sameAs(widget.selected),
    );
    return index < 0 ? 0 : index;
  }

  void _center({required bool animated, int attempt = 0}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.records.length < 2) return;
      final BuildContext? itemContext = _keys[_selectedIndex()].currentContext;
      if (itemContext == null || !_scroll.hasClients) {
        if (attempt < 4) _center(animated: animated, attempt: attempt + 1);
        return;
      }
      Scrollable.ensureVisible(
        itemContext,
        alignment: 0.5,
        duration: animated ? const Duration(milliseconds: 280) : Duration.zero,
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<SitePhotoRecord> records = widget.records;
    if (records.isEmpty) return const SizedBox.shrink();
    final List<String?> captions = <String?>[
      for (final SitePhotoRecord record in records) _caption(record, records),
    ];
    final bool hasCaption = captions.any((String? caption) => caption != null);
    final bool hasTally = records.any(
      (SitePhotoRecord record) =>
          record.status == SitePhotoStatus.done && record.count > 1,
    );
    final double fontScale = widget.fontScale;
    final double height =
        _line(15 * fontScale) +
        (hasCaption ? 4 + _line(12 * fontScale) : 0) +
        8 +
        3 +
        (hasTally ? 6 + _line(12 * fontScale) : 0) +
        2;
    if (records.length == 1) {
      return _DateCell(
        record: records.first,
        caption: captions.first,
        hasCaption: hasCaption,
        hasTally: hasTally,
        selected: true,
        photoIndex: widget.photoIndex,
        fontScale: fontScale,
      );
    }
    final double gutter = MediaQuery.sizeOf(context).width / 2 - 56;
    return SizedBox(
      height: height,
      child: SingleChildScrollView(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: gutter),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < records.length; i++) ...[
              if (i > 0) const SizedBox(width: 32),
              KeyedSubtree(
                key: _keys[i],
                child: _DateCell(
                  record: records[i],
                  caption: captions[i],
                  hasCaption: hasCaption,
                  hasTally: hasTally,
                  selected: records[i].sameAs(widget.selected),
                  photoIndex: widget.photoIndex,
                  fontScale: fontScale,
                  onTap: () => widget.onChanged(records[i]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String? _caption(SitePhotoRecord record, List<SitePhotoRecord> records) {
  final List<SitePhotoRecord> others = <SitePhotoRecord>[
    for (final SitePhotoRecord other in records)
      if (other.takenOn == record.takenOn && !other.sameAs(record)) other,
  ];
  if (others.isEmpty) return null;
  if (others.any((SitePhotoRecord other) => other.trade == record.trade)) {
    return record.status.label;
  }
  return record.trade;
}

double _line(double fontSize) => fontSize * 1.35;

class _DateCell extends StatelessWidget {
  const _DateCell({
    required this.record,
    required this.caption,
    required this.hasCaption,
    required this.hasTally,
    required this.selected,
    required this.photoIndex,
    required this.fontScale,
    this.onTap,
  });

  final SitePhotoRecord record;
  final String? caption;
  final bool hasCaption;
  final bool hasTally;
  final bool selected;
  final int photoIndex;
  final double fontScale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final int count = record.count < 1 ? 1 : record.count;
    final bool showTally =
        selected &&
        hasTally &&
        record.status == SitePhotoStatus.done &&
        count > 1;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(
            record.takenOn,
            style: TextStyle(
              fontSize: 15 * fontScale,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              letterSpacing: -0.3,
              height: 1.35,
              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          if (hasCaption)
            SizedBox(
              height: 4 + _line(12 * fontScale),
              child:
                  caption == null
                      ? null
                      : Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          caption!,
                          style: TextStyle(
                            fontSize: 12 * fontScale,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            height: 1.35,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
            ),
          const SizedBox(height: 8),
          _PhotoTrack(count: count, index: selected ? photoIndex : null),
          if (hasTally)
            SizedBox(
              height: 6 + _line(12 * fontScale),
              child:
                  showTally
                      ? Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '${photoIndex + 1}장째',
                          style: TextStyle(
                            fontSize: 12 * fontScale,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            height: 1.35,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                      : null,
            ),
        ],
      ),
    );
  }
}

class _PhotoTrack extends StatelessWidget {
  const _PhotoTrack({required this.count, this.index});

  final int count;
  final int? index;

  @override
  Widget build(BuildContext context) {
    final double width = count <= 1 ? 28 : (20.0 + count * 14).clamp(36, 88);
    return SizedBox(
      width: width,
      height: 3,
      child: Row(
        children: [
          for (int i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: 3),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                color: i == index ? AppColors.primary : AppColors.border,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
