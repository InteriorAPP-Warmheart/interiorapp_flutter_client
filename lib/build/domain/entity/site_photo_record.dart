import 'package:interiorapp_flutter_client/build/domain/entity/construction_progress.dart';

/// 같은 날, 같은 구역, 같은 공정, 같은 상태의 사진 묶음.
class SitePhotoRecord {
  const SitePhotoRecord({
    required this.area,
    required this.trade,
    required this.takenOn,
    required this.status,
    required this.photos,
    this.note = '',
  });

  factory SitePhotoRecord.fromPhotos(List<PublicSitePhoto> photos) {
    final PublicSitePhoto first = photos.first;
    String note = '';
    for (final PublicSitePhoto photo in photos) {
      if (photo.note.isNotEmpty) {
        note = photo.note;
        break;
      }
    }
    return SitePhotoRecord(
      area: first.area,
      trade: first.trade,
      takenOn: first.takenOn,
      status: first.status,
      note: note,
      photos: List<PublicSitePhoto>.unmodifiable(photos),
    );
  }

  final String area;
  final String trade;
  final String takenOn;
  final SitePhotoStatus status;
  final String note;
  final List<PublicSitePhoto> photos;

  int get count => photos.length;

  PublicSitePhoto get cover => photos.first;

  /// 구역이 없으면 공정이 제목이다.
  String get placeLabel => area.isEmpty ? trade : area;

  String get detailLabel => area.isEmpty ? '' : trade;

  bool sameAs(SitePhotoRecord other) {
    return area == other.area &&
        trade == other.trade &&
        takenOn == other.takenOn &&
        status == other.status;
  }
}

/// 한 구역의 기록. [records]는 최근 날이 앞이다.
class SitePhotoZone {
  const SitePhotoZone({required this.area, required this.records});

  final String area;
  final List<SitePhotoRecord> records;

  /// 완료된 사진만 센다. 작업 중은 넣지 않는다.
  int get donePhotoCount => sitePhotoDoneCount(records);

  /// 가장 최근 완료. 완료가 없으면 가장 최근 기록.
  SitePhotoRecord? get coverRecord {
    for (final SitePhotoRecord record in records) {
      if (record.status == SitePhotoStatus.done) return record;
    }
    if (records.isEmpty) return null;
    return records.first;
  }

  /// 마지막 완료보다 이후 날의 작업 중.
  SitePhotoRecord? get newerUnderway {
    if (records.isEmpty) return null;
    final SitePhotoRecord newest = records.first;
    final SitePhotoRecord? cover = coverRecord;
    if (newest.status != SitePhotoStatus.underway || cover == null) {
      return null;
    }
    if (newest.sameAs(cover)) return null;
    if (sitePhotoDayOrder(newest.takenOn) <= sitePhotoDayOrder(cover.takenOn)) {
      return null;
    }
    return newest;
  }
}

int sitePhotoDoneCount(Iterable<SitePhotoRecord> records) {
  var count = 0;
  for (final SitePhotoRecord record in records) {
    if (record.status == SitePhotoStatus.done) count += record.count;
  }
  return count;
}

String sitePhotoDayLabel(DateTime day) => '${day.month}월 ${day.day}일';

/// `10월 24일`을 같은 해 안에서 비교할 수 있는 수로 바꾼다.
int sitePhotoDayOrder(String label) {
  final RegExpMatch? match = RegExp(r'(\d+)\s*월\s*(\d+)\s*일').firstMatch(label);
  if (match == null) return 0;
  final int month = int.parse(match.group(1)!);
  final int day = int.parse(match.group(2)!);
  return month * 100 + day;
}

List<SitePhotoRecord> sitePhotoRecords(List<PublicSitePhoto> photos) {
  final Map<String, List<PublicSitePhoto>> grouped =
      <String, List<PublicSitePhoto>>{};
  final List<String> order = <String>[];
  for (final PublicSitePhoto photo in photos) {
    final String key = [
      photo.area,
      photo.trade,
      photo.takenOn,
      photo.status.name,
    ].join('\u0000');
    final List<PublicSitePhoto>? existing = grouped[key];
    if (existing == null) {
      order.add(key);
      grouped[key] = <PublicSitePhoto>[photo];
    } else {
      existing.add(photo);
    }
  }
  return <SitePhotoRecord>[
    for (final String key in order) SitePhotoRecord.fromPhotos(grouped[key]!),
  ];
}

List<String> sitePhotoTrades(List<SitePhotoRecord> records) {
  final List<String> trades = <String>[];
  for (final SitePhotoRecord record in records) {
    if (record.trade.isEmpty || trades.contains(record.trade)) continue;
    trades.add(record.trade);
  }
  return trades;
}

List<SitePhotoRecord> sitePhotoRecordsForTrade(
  List<SitePhotoRecord> records,
  String? trade,
) {
  if (trade == null || trade.isEmpty) return records;
  return <SitePhotoRecord>[
    for (final SitePhotoRecord record in records)
      if (record.trade == trade) record,
  ];
}

List<SitePhotoRecord> sitePhotoRecordsForStatus(
  List<SitePhotoRecord> records,
  SitePhotoStatus? status,
) {
  if (status == null) return records;
  return <SitePhotoRecord>[
    for (final SitePhotoRecord record in records)
      if (record.status == status) record,
  ];
}

/// 같은 구역에서 지금 기록의 바로 이전 날, 바로 다음 날.
class SitePhotoDateSpan {
  const SitePhotoDateSpan({this.previous, this.next});

  final SitePhotoRecord? previous;
  final SitePhotoRecord? next;
}

SitePhotoDateSpan sitePhotoDateSpan(
  SitePhotoRecord current,
  List<SitePhotoRecord> timeline,
) {
  final int currentDay = sitePhotoDayOrder(current.takenOn);
  SitePhotoRecord? previous;
  SitePhotoRecord? next;
  for (final SitePhotoRecord record in timeline) {
    if (record.area != current.area || record.sameAs(current)) continue;
    final int day = sitePhotoDayOrder(record.takenOn);
    if (day < currentDay) {
      if (previous == null || day > sitePhotoDayOrder(previous.takenOn)) {
        previous = record;
      }
    } else if (day > currentDay) {
      if (next == null || day < sitePhotoDayOrder(next.takenOn)) {
        next = record;
      }
    }
  }
  return SitePhotoDateSpan(previous: previous, next: next);
}

/// 같은 구역의 기록을 과거에서 미래 순으로 이어 준다.
List<SitePhotoRecord> sitePhotoAreaTimeline(
  SitePhotoRecord current,
  List<SitePhotoRecord> timeline,
) {
  final List<int> indexes = <int>[
    for (int i = 0; i < timeline.length; i++)
      if (timeline[i].area == current.area) i,
  ];
  indexes.sort((int a, int b) {
    final int day = sitePhotoDayOrder(
      timeline[a].takenOn,
    ).compareTo(sitePhotoDayOrder(timeline[b].takenOn));
    if (day != 0) return day;
    return a.compareTo(b);
  });
  final List<SitePhotoRecord> records = <SitePhotoRecord>[
    for (final int index in indexes) timeline[index],
  ];
  if (records.any((SitePhotoRecord record) => record.sameAs(current))) {
    return records;
  }
  final int currentDay = sitePhotoDayOrder(current.takenOn);
  int at = records.length;
  for (int i = 0; i < records.length; i++) {
    if (sitePhotoDayOrder(records[i].takenOn) > currentDay) {
      at = i;
      break;
    }
  }
  records.insert(at, current);
  return records;
}

List<SitePhotoZone> sitePhotoZones(List<SitePhotoRecord> records) {
  final List<String> order = <String>[];
  final Map<String, List<SitePhotoRecord>> grouped =
      <String, List<SitePhotoRecord>>{};
  for (final SitePhotoRecord record in records) {
    final List<SitePhotoRecord>? existing = grouped[record.area];
    if (existing == null) {
      order.add(record.area);
      grouped[record.area] = <SitePhotoRecord>[record];
    } else {
      existing.add(record);
    }
  }
  return <SitePhotoZone>[
    for (final String area in order)
      SitePhotoZone(area: area, records: _newestFirst(grouped[area]!)),
  ];
}

List<SitePhotoRecord> _newestFirst(List<SitePhotoRecord> records) {
  final List<SitePhotoRecord> copy = List<SitePhotoRecord>.of(records);
  copy.sort((SitePhotoRecord a, SitePhotoRecord b) {
    return sitePhotoDayOrder(b.takenOn).compareTo(sitePhotoDayOrder(a.takenOn));
  });
  return copy;
}
