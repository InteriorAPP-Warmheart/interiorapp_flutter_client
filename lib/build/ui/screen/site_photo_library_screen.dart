import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/construction_progress.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/site_photo_record.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/site_photo_viewer_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/site_photo_record_tile.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';

void openSitePhotoLibrary(BuildContext context, List<PublicSitePhoto> photos) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) => SitePhotoLibraryScreen(photos: photos),
    ),
  );
}

void openSitePhotoDay(
  BuildContext context, {
  required String dayLabel,
  required List<SitePhotoRecord> records,
  List<SitePhotoRecord> timeline = const <SitePhotoRecord>[],
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder:
          (BuildContext context) => SitePhotoDayScreen(
            dayLabel: dayLabel,
            records: records,
            timeline: timeline,
          ),
    ),
  );
}

class SitePhotoDayScreen extends StatelessWidget {
  const SitePhotoDayScreen({
    super.key,
    required this.dayLabel,
    required this.records,
    this.timeline = const <SitePhotoRecord>[],
  });

  final String dayLabel;
  final List<SitePhotoRecord> records;
  final List<SitePhotoRecord> timeline;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final EdgeInsets inset = ResponsiveSize.textInset(context);
    final int donePhotos = sitePhotoDoneCount(records);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: donePhotos > 0 ? 64 : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dayLabel),
            if (donePhotos > 0)
              Text(
                '$donePhotos장',
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          inset.left,
          12,
          inset.right,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        itemCount: records.length,
        separatorBuilder:
            (BuildContext context, int index) => const SizedBox(height: 8),
        itemBuilder: (BuildContext context, int index) {
          final SitePhotoRecord record = records[index];
          return SitePhotoPreviewCard(
            record: record,
            fontScale: fontScale,
            onTap:
                () => openSitePhotoViewer(context, record, timeline: timeline),
          );
        },
      ),
    );
  }
}

class SitePhotoLibraryScreen extends StatefulWidget {
  const SitePhotoLibraryScreen({super.key, required this.photos});

  final List<PublicSitePhoto> photos;

  @override
  State<SitePhotoLibraryScreen> createState() => _SitePhotoLibraryScreenState();
}

class _SitePhotoLibraryScreenState extends State<SitePhotoLibraryScreen> {
  String? _trade;
  SitePhotoStatus? _status;
  String? _openArea;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final EdgeInsets inset = ResponsiveSize.textInset(context);
    final List<SitePhotoRecord> records = sitePhotoRecords(widget.photos);
    final List<String> trades = sitePhotoTrades(records);
    final List<SitePhotoRecord> shown = sitePhotoRecordsForStatus(
      sitePhotoRecordsForTrade(records, _trade),
      _status,
    );
    final List<SitePhotoZone> zones = sitePhotoZones(shown);
    final String? openArea =
        zones.any((SitePhotoZone zone) => zone.area == _openArea)
            ? _openArea
            : null;
    final int donePhotos = sitePhotoDoneCount(shown);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: donePhotos > 0 ? 64 : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('현장사진'),
            if (donePhotos > 0)
              Text(
                '$donePhotos장',
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
          if (trades.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: inset.left),
                itemCount: trades.length + 1,
                separatorBuilder:
                    (BuildContext context, int index) =>
                        const SizedBox(width: 6),
                itemBuilder: (BuildContext context, int index) {
                  final String? trade = index == 0 ? null : trades[index - 1];
                  final String label = trade ?? '전체';
                  return _TradeChip(
                    label: label,
                    selected: _trade == trade,
                    fontScale: fontScale,
                    onTap: () => setState(() => _trade = trade),
                  );
                },
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(inset.left, 10, inset.right, 0),
            child: _StatusSwitch(
              status: _status,
              fontScale: fontScale,
              onChanged: (SitePhotoStatus? status) {
                setState(() => _status = status);
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child:
                zones.isEmpty
                    ? Center(
                      child: Text(
                        _emptyPhotoLabel(_trade, _status),
                        style: TextStyle(
                          fontSize: 14 * fontScale,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                    : ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        inset.left,
                        0,
                        inset.right,
                        24 + MediaQuery.paddingOf(context).bottom,
                      ),
                      itemCount: zones.length,
                      separatorBuilder:
                          (BuildContext context, int index) =>
                              const SizedBox(height: 10),
                      itemBuilder: (BuildContext context, int index) {
                        final SitePhotoZone zone = zones[index];
                        return _ZoneBand(
                          zone: zone,
                          expanded: openArea == zone.area,
                          fontScale: fontScale,
                          onToggle: () {
                            setState(() {
                              _openArea =
                                  openArea == zone.area ? null : zone.area;
                            });
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _StatusSwitch extends StatelessWidget {
  const _StatusSwitch({
    required this.status,
    required this.fontScale,
    required this.onChanged,
  });

  final SitePhotoStatus? status;
  final double fontScale;
  final ValueChanged<SitePhotoStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          children: [
            _StatusSegment(
              label: '모두',
              selected: status == null,
              fontScale: fontScale,
              onTap: () => onChanged(null),
            ),
            _StatusSegment(
              label: '완료',
              selected: status == SitePhotoStatus.done,
              fontScale: fontScale,
              onTap: () => onChanged(SitePhotoStatus.done),
            ),
            _StatusSegment(
              label: '작업 중',
              selected: status == SitePhotoStatus.underway,
              fontScale: fontScale,
              onTap: () => onChanged(SitePhotoStatus.underway),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusSegment extends StatelessWidget {
  const _StatusSegment({
    required this.label,
    required this.selected,
    required this.fontScale,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double fontScale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13 * fontScale,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _emptyPhotoLabel(String? trade, SitePhotoStatus? status) {
  final bool tradeOn = trade != null && trade.isNotEmpty;
  if (status == SitePhotoStatus.done) {
    return tradeOn ? '이 공정의 완료된 사진이 아직 없어요' : '완료된 현장사진이 아직 없어요';
  }
  if (status == SitePhotoStatus.underway) {
    return tradeOn ? '이 공정의 작업 중인 사진이 아직 없어요' : '작업 중인 현장사진이 아직 없어요';
  }
  return '이 공정의 현장사진이 아직 없어요';
}

class _TradeChip extends StatelessWidget {
  const _TradeChip({
    required this.label,
    required this.selected,
    required this.fontScale,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double fontScale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: 0.7,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13 * fontScale,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ZoneBand extends StatelessWidget {
  const _ZoneBand({
    required this.zone,
    required this.expanded,
    required this.fontScale,
    required this.onToggle,
  });

  final SitePhotoZone zone;
  final bool expanded;
  final double fontScale;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final SitePhotoRecord? cover = zone.coverRecord;
    final SitePhotoRecord? underway = zone.newerUnderway;
    if (cover == null) return const SizedBox.shrink();
    final String title = zone.area.isEmpty ? cover.trade : zone.area;
    final String trade = zone.area.isEmpty ? '' : cover.trade;

    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: AppColors.surface,
            child: InkWell(
              onTap: onToggle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AppNetworkImage(url: cover.cover.imageUrl),
                        Positioned(
                          left: 12,
                          top: 12,
                          child: SitePhotoStatusLabel(
                            status: cover.status,
                            fontScale: fontScale,
                            onPhoto: true,
                          ),
                        ),
                        if (cover.status == SitePhotoStatus.done &&
                            zone.donePhotoCount > 0)
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: const Color(0xCC0B1F38),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Text(
                                  '${zone.donePhotoCount}장',
                                  style: TextStyle(
                                    fontSize: 12 * fontScale,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      14,
                      14,
                      14,
                      underway == null ? 14 : 0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 18 * fontScale,
                                  height: 1.3,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (trade.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  trade,
                                  style: TextStyle(
                                    fontSize: 14 * fontScale,
                                    height: 1.35,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 2),
                              Text(
                                cover.takenOn,
                                style: TextStyle(
                                  fontSize: 13 * fontScale,
                                  height: 1.35,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            expanded ? '접기' : '기록 보기',
                            style: TextStyle(
                              fontSize: 13 * fontScale,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (underway != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(height: 1, color: AppColors.border),
                          const SizedBox(height: 12),
                          SitePhotoStatusLabel(
                            status: underway.status,
                            fontScale: fontScale,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            underway.trade,
                            style: TextStyle(
                              fontSize: 14 * fontScale,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            underway.takenOn,
                            style: TextStyle(
                              fontSize: 13 * fontScale,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child:
                expanded
                    ? Padding(
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
                      child: Column(
                        children: [
                          const Divider(height: 1, color: AppColors.border),
                          const SizedBox(height: 12),
                          for (int i = 0; i < zone.records.length; i++) ...[
                            if (i > 0) const SizedBox(height: 10),
                            SitePhotoPreviewCard(
                              record: zone.records[i],
                              fontScale: fontScale,
                              showDate: true,
                              onTap:
                                  () => openSitePhotoViewer(
                                    context,
                                    zone.records[i],
                                    timeline: zone.records,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    )
                    : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
