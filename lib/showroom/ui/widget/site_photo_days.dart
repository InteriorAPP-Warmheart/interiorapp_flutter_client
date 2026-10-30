import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/construction_progress.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';

/// 현장 사진을 날짜 가로 막대와 아래 갤러리로 고르게 한다.
class SitePhotoDays extends StatefulWidget {
  const SitePhotoDays({
    super.key,
    required this.photos,
    required this.used,
    required this.onPhoto,
    this.selected = const <String>{},
  });

  final List<PublicSitePhoto> photos;
  final bool Function(String url) used;
  final ValueChanged<String> onPhoto;
  final Set<String> selected;

  @override
  State<SitePhotoDays> createState() => _SitePhotoDaysState();
}

class _Pick {
  const _Pick({required this.date, required this.trade});

  final String date;
  final String trade;

  @override
  bool operator ==(Object other) {
    return other is _Pick && other.date == date && other.trade == trade;
  }

  @override
  int get hashCode => Object.hash(date, trade);
}

class _SitePhotoDaysState extends State<SitePhotoDays> {
  _Pick? _picked;

  @override
  Widget build(BuildContext context) {
    final List<_PhotoDay> days = _groupByDate(widget.photos);
    if (days.isEmpty) return const SizedBox.shrink();
    final _Pick pick = _currentPick(days);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 132,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (BuildContext context, int index) {
              final _PhotoDay day = days[index];
              return _DayColumn(
                day: day,
                pick: pick,
                onTrade: (String trade) {
                  setState(() {
                    _picked = _Pick(date: day.date, trade: trade);
                  });
                },
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            final Animation<Offset> slide = Tween<Offset>(
              begin: const Offset(0.06, 0),
              end: Offset.zero,
            ).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: _Gallery(
            key: ValueKey<String>('${pick.date}|${pick.trade}'),
            day: days.firstWhere((_PhotoDay day) => day.date == pick.date),
            trade: pick.trade,
            used: widget.used,
            selected: widget.selected,
            onPhoto: widget.onPhoto,
          ),
        ),
      ],
    );
  }

  _Pick _currentPick(List<_PhotoDay> days) {
    final _Pick? picked = _picked;
    if (picked != null) {
      for (final _PhotoDay day in days) {
        if (day.date == picked.date && day.trades.contains(picked.trade)) {
          return picked;
        }
      }
    }
    final _PhotoDay latest = days.first;
    return _Pick(
      date: latest.date,
      trade: latest.trades.isEmpty ? '' : latest.trades.first,
    );
  }
}

class _PhotoDay {
  const _PhotoDay({required this.date, required this.photos});

  final String date;
  final List<PublicSitePhoto> photos;

  List<String> get trades =>
      _unique(photos.map((PublicSitePhoto photo) => photo.trade));

  String get weekday => _weekdayLabel(date);
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.day,
    required this.pick,
    required this.onTrade,
  });

  final _PhotoDay day;
  final _Pick pick;
  final ValueChanged<String> onTrade;

  @override
  Widget build(BuildContext context) {
    final bool dayOn = pick.date == day.date;
    return Container(
      width: 112,
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: dayOn ? AppColors.primary : AppColors.border,
          width: dayOn ? 1.3 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            day.date,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            day.weekday.isEmpty ? ' ' : '${day.weekday}요일',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          for (final String trade in day.trades) ...[
            _TradeChip(
              label: trade,
              selected: dayOn && pick.trade == trade,
              onTap: () => onTrade(trade),
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}

class _TradeChip extends StatelessWidget {
  const _TradeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery({
    super.key,
    required this.day,
    required this.trade,
    required this.used,
    required this.selected,
    required this.onPhoto,
  });

  final _PhotoDay day;
  final String trade;
  final bool Function(String url) used;
  final Set<String> selected;
  final ValueChanged<String> onPhoto;

  @override
  Widget build(BuildContext context) {
    final List<PublicSitePhoto> photos =
        day.photos
            .where((PublicSitePhoto photo) => photo.trade == trade)
            .toList();
    final String areas = _unique(
      photos.map((PublicSitePhoto photo) => photo.area),
    ).join(' · ');
    final String when =
        day.weekday.isEmpty ? day.date : '${day.date} ${day.weekday}요일';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            trade,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            areas.isEmpty
                ? '$when · ${photos.length}장'
                : '$when · $areas · ${photos.length}장',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.35,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 128,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (BuildContext context, int index) {
                final PublicSitePhoto photo = photos[index];
                return _GalleryTile(
                  photo: photo,
                  used: used(photo.imageUrl),
                  selected: selected.contains(photo.imageUrl),
                  onTap: () => onPhoto(photo.imageUrl),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({
    required this.photo,
    required this.used,
    required this.selected,
    required this.onTap,
  });

  final PublicSitePhoto photo;
  final bool used;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String area = photo.area.trim();
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 96,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AppNetworkImage(url: photo.imageUrl),
                        if (selected)
                          const Positioned(
                            top: 6,
                            left: 6,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(2),
                                child: Icon(
                                  Icons.check,
                                  size: 12,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        if (used)
                          const Positioned(
                            top: 6,
                            right: 6,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(2),
                                child: Icon(
                                  Icons.check,
                                  size: 12,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              area.isEmpty ? photo.trade : area,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<_PhotoDay> _groupByDate(List<PublicSitePhoto> photos) {
  final Map<String, List<PublicSitePhoto>> grouped =
      <String, List<PublicSitePhoto>>{};
  for (final PublicSitePhoto photo in photos) {
    grouped.putIfAbsent(photo.takenOn, () => <PublicSitePhoto>[]).add(photo);
  }
  final List<_PhotoDay> days = [
    for (final MapEntry<String, List<PublicSitePhoto>> entry in grouped.entries)
      _PhotoDay(date: entry.key, photos: entry.value),
  ];
  days.sort(
    (_PhotoDay a, _PhotoDay b) =>
        _dateOrder(b.date).compareTo(_dateOrder(a.date)),
  );
  return days;
}

List<String> _unique(Iterable<String> values) {
  final Set<String> seen = <String>{};
  final List<String> result = <String>[];
  for (final String value in values) {
    final String text = value.trim();
    if (text.isEmpty || !seen.add(text)) continue;
    result.add(text);
  }
  return result;
}

int _dateOrder(String takenOn) {
  final RegExpMatch? match = RegExp(
    r'(\d+)\s*월\s*(\d+)\s*일',
  ).firstMatch(takenOn);
  if (match == null) return 0;
  final int month = int.tryParse(match.group(1)!) ?? 0;
  final int day = int.tryParse(match.group(2)!) ?? 0;
  return month * 100 + day;
}

String _weekdayLabel(String takenOn) {
  final RegExpMatch? match = RegExp(
    r'(\d+)\s*월\s*(\d+)\s*일',
  ).firstMatch(takenOn);
  if (match == null) return '';
  final int? month = int.tryParse(match.group(1)!);
  final int? day = int.tryParse(match.group(2)!);
  if (month == null || day == null) return '';
  const List<String> names = <String>['월', '화', '수', '목', '금', '토', '일'];
  final DateTime date = DateTime(2026, month, day);
  return names[date.weekday - 1];
}
