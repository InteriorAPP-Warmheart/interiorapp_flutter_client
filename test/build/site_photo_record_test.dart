import 'package:flutter_test/flutter_test.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/construction_progress.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/site_photo_record.dart';

void main() {
  test('같은 날 같은 구역 같은 공정은 한 기록이고 장 순서는 유지된다', () {
    final List<SitePhotoRecord> records =
        sitePhotoRecords(const <PublicSitePhoto>[
          PublicSitePhoto(
            imageUrl: 'a',
            trade: '도장',
            area: '홀',
            takenOn: '10월 24일',
            note: '벽 도장 완료',
          ),
          PublicSitePhoto(
            imageUrl: 'b',
            trade: '도장',
            area: '홀',
            takenOn: '10월 24일',
          ),
          PublicSitePhoto(
            imageUrl: 'c',
            trade: '도장',
            area: '창가',
            takenOn: '10월 24일',
            status: SitePhotoStatus.underway,
          ),
        ]);

    expect(records, hasLength(2));
    expect(records.first.count, 2);
    expect(
      records.first.photos.map((PublicSitePhoto photo) => photo.imageUrl),
      ['a', 'b'],
    );
    expect(records.first.note, '벽 도장 완료');
    expect(records.last.status, SitePhotoStatus.underway);
    expect(records.last.area, '창가');
  });

  test('구역 커버는 최근 완료이고 그 이후 작업 중만 따로 남긴다', () {
    final List<SitePhotoZone> zones = sitePhotoZones(
      sitePhotoRecords(const <PublicSitePhoto>[
        PublicSitePhoto(
          imageUrl: 'old',
          trade: '목공',
          area: '창가',
          takenOn: '10월 22일',
        ),
        PublicSitePhoto(
          imageUrl: 'now',
          trade: '도장',
          area: '창가',
          takenOn: '10월 24일',
          status: SitePhotoStatus.underway,
        ),
        PublicSitePhoto(
          imageUrl: 'hall-old',
          trade: '철거',
          area: '홀',
          takenOn: '10월 8일',
        ),
        PublicSitePhoto(
          imageUrl: 'hall-now',
          trade: '도장',
          area: '홀',
          takenOn: '10월 24일',
        ),
        PublicSitePhoto(
          imageUrl: 'hall-same-day',
          trade: '전기',
          area: '홀',
          takenOn: '10월 24일',
          status: SitePhotoStatus.underway,
        ),
      ]),
    );

    final SitePhotoZone window = zones.firstWhere(
      (SitePhotoZone zone) => zone.area == '창가',
    );
    expect(window.coverRecord?.trade, '목공');
    expect(window.newerUnderway?.trade, '도장');
    expect(window.newerUnderway?.takenOn, '10월 24일');
    expect(window.donePhotoCount, 1);

    final SitePhotoZone hall = zones.firstWhere(
      (SitePhotoZone zone) => zone.area == '홀',
    );
    expect(hall.coverRecord?.cover.imageUrl, 'hall-now');
    expect(hall.newerUnderway, isNull);
    expect(hall.donePhotoCount, 2);
  });

  test('공정과 상태는 따로 거른다', () {
    final List<SitePhotoRecord> records =
        sitePhotoRecords(const <PublicSitePhoto>[
          PublicSitePhoto(
            imageUrl: 'a',
            trade: '목공',
            area: '홀',
            takenOn: '10월 24일',
          ),
          PublicSitePhoto(
            imageUrl: 'b',
            trade: '목공',
            area: '창가',
            takenOn: '10월 24일',
            status: SitePhotoStatus.underway,
          ),
          PublicSitePhoto(
            imageUrl: 'c',
            trade: '도장',
            area: '홀',
            takenOn: '10월 22일',
          ),
        ]);

    final List<SitePhotoRecord> woodDone = sitePhotoRecordsForStatus(
      sitePhotoRecordsForTrade(records, '목공'),
      SitePhotoStatus.done,
    );
    expect(woodDone, hasLength(1));
    expect(woodDone.single.area, '홀');

    final List<SitePhotoRecord> underway = sitePhotoRecordsForStatus(
      records,
      SitePhotoStatus.underway,
    );
    expect(underway, hasLength(1));
    expect(sitePhotoTrades(records), ['목공', '도장']);
  });

  test('날짜 이동은 같은 구역의 바로 이전 날과 다음 날만 고른다', () {
    SitePhotoRecord record({
      required String area,
      required String trade,
      required String takenOn,
      SitePhotoStatus status = SitePhotoStatus.done,
    }) {
      return SitePhotoRecord(
        area: area,
        trade: trade,
        takenOn: takenOn,
        status: status,
        photos: const <PublicSitePhoto>[
          PublicSitePhoto(imageUrl: 'p', trade: '', takenOn: ''),
        ],
      );
    }

    final SitePhotoRecord older = record(
      area: '홀',
      trade: '철거',
      takenOn: '10월 8일',
    );
    final SitePhotoRecord earlierSameDay = record(
      area: '홀',
      trade: '목공',
      takenOn: '10월 22일',
    );
    final SitePhotoRecord laterSameDay = record(
      area: '홀',
      trade: '전기',
      takenOn: '10월 23일',
      status: SitePhotoStatus.underway,
    );
    final SitePhotoRecord current = record(
      area: '홀',
      trade: '도장',
      takenOn: '10월 24일',
    );
    final SitePhotoRecord next = record(
      area: '홀',
      trade: '도장',
      takenOn: '10월 26일',
    );
    final SitePhotoRecord woodLater = record(
      area: '홀',
      trade: '목공',
      takenOn: '10월 28일',
    );
    final SitePhotoRecord otherArea = record(
      area: '창가',
      trade: '도장',
      takenOn: '10월 25일',
    );
    final List<SitePhotoRecord> timeline = <SitePhotoRecord>[
      older,
      earlierSameDay,
      laterSameDay,
      current,
      next,
      woodLater,
      otherArea,
    ];

    final SitePhotoDateSpan span = sitePhotoDateSpan(current, timeline);
    expect(span.previous?.trade, '전기');
    expect(span.previous?.takenOn, '10월 23일');
    expect(span.next, same(next));

    final SitePhotoDateSpan doneOnly = sitePhotoDateSpan(
      current,
      sitePhotoRecordsForStatus(timeline, SitePhotoStatus.done),
    );
    expect(doneOnly.previous, same(earlierSameDay));
    expect(doneOnly.next, same(next));

    final SitePhotoDateSpan wood = sitePhotoDateSpan(
      earlierSameDay,
      sitePhotoRecordsForTrade(timeline, '목공'),
    );
    expect(wood.previous, isNull);
    expect(wood.next, same(woodLater));
  });

  test('같은 구역 날짜는 과거에서 미래로 이어진다', () {
    SitePhotoRecord record({
      required String area,
      required String trade,
      required String takenOn,
    }) {
      return SitePhotoRecord(
        area: area,
        trade: trade,
        takenOn: takenOn,
        status: SitePhotoStatus.done,
        photos: const <PublicSitePhoto>[
          PublicSitePhoto(imageUrl: 'p', trade: '', takenOn: ''),
        ],
      );
    }

    final SitePhotoRecord later = record(
      area: '홀',
      trade: '도장',
      takenOn: '10월 24일',
    );
    final SitePhotoRecord wood = record(
      area: '홀',
      trade: '목공',
      takenOn: '10월 22일',
    );
    final SitePhotoRecord electric = record(
      area: '홀',
      trade: '전기',
      takenOn: '10월 22일',
    );
    final SitePhotoRecord window = record(
      area: '창가',
      trade: '도장',
      takenOn: '10월 23일',
    );

    expect(
      sitePhotoAreaTimeline(later, <SitePhotoRecord>[
        later,
        wood,
        window,
        electric,
      ]).map((SitePhotoRecord record) => record.trade),
      <String>['목공', '전기', '도장'],
    );
  });
}
