import 'package:interiorapp_flutter_client/build/domain/entity/construction_progress.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/process_schedule.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/core/widget/calendar/app_calendar_date.dart';

/// 컬렉션 종류. 화면의 칸 순서와 같다.
///
/// 공정은 현장에서 진행되는 일이고, 내 할 일은 고객이 직접 하는 일이다.
/// 견적을 확인하고 넘기는 일도 할 일에 둔다.
enum HomeCollectionKind { trade, task }

/// 칸 하나를 눌렀을 때 여는 자리.
enum HomePieceOpen { project, estimate }

/// 컬렉션 안에 들어가는 한 건.
class HomePiece {
  const HomePiece({
    required this.id,
    required this.day,
    required this.projectId,
    required this.placeName,
    required this.title,
    required this.note,
    required this.kind,
    required this.open,
    this.settled = false,
  });

  final String id;
  final DateTime day;
  final String projectId;
  final String placeName;
  final String title;
  final String note;
  final HomeCollectionKind kind;
  final HomePieceOpen open;

  /// 서버가 이 할 일을 마쳤다고 알려 준 상태.
  /// 고객이 직접 체크한 것은 여기가 아니라 세션 기록에 둔다.
  final bool settled;

  String get subtitle {
    if (note.isEmpty) return placeName;
    if (placeName.isEmpty) return note;
    return '$note · $placeName';
  }
}

/// 늘 같은 자리의 묶음. 개수만 날짜에 따라 바뀐다.
class HomeCollection {
  const HomeCollection({
    required this.kind,
    required this.label,
    required this.pieces,
  });

  final HomeCollectionKind kind;
  final String label;
  final List<HomePiece> pieces;

  int get count => pieces.length;
}

/// 오늘부터 나흘. 칸은 공정과 내 할 일로 고정한다.
class HomeAgenda {
  const HomeAgenda({
    required this.today,
    required this.days,
    required this.pieces,
  });

  final DateTime today;
  final List<DateTime> days;
  final List<HomePiece> pieces;

  int countOn(DateTime day) {
    var count = 0;
    for (final HomePiece piece in pieces) {
      if (appCalendarSameDay(piece.day, day)) count += 1;
    }
    return count;
  }

  List<HomeCollection> collectionsOn(DateTime day) {
    final List<HomePiece> onDay = <HomePiece>[
      for (final HomePiece piece in pieces)
        if (appCalendarSameDay(piece.day, day)) piece,
    ];
    return <HomeCollection>[
      for (final HomeCollectionKind kind in HomeCollectionKind.values)
        HomeCollection(
          kind: kind,
          label: _collectionLabel(kind),
          pieces: <HomePiece>[
            for (final HomePiece piece in onDay)
              if (piece.kind == kind) piece,
          ],
        ),
    ];
  }
}

const int _span = 4;

/// 날짜별 공정과 고객이 해 둘 일.
///
/// 확인이 도착한 알림은 넣지 않는다. 견적을 넘기는 일은 오늘 할 일에 둔다.
HomeAgenda homeAgenda({
  required List<SpaceProject> projects,
  required ConstructionProgress? Function(String id) progressOf,
  required List<ProcessScheduleTask> schedule,
  required DateTime now,
}) {
  final DateTime today = appCalendarDate(now);
  final List<DateTime> days = <DateTime>[
    for (int i = 0; i < _span; i++) today.add(Duration(days: i)),
  ];
  final DateTime tomorrow = today.add(const Duration(days: 1));
  final DateTime last = days.last;
  final List<HomePiece> pieces = <HomePiece>[];

  for (final SpaceProject project in projects) {
    if (_awaitsQuote(project)) {
      pieces.add(
        HomePiece(
          id: 'doc-${project.id}',
          day: today,
          projectId: project.id,
          placeName: project.placeName,
          title: '견적서 넘기기',
          note: '확인 후 제출',
          kind: HomeCollectionKind.task,
          open: HomePieceOpen.estimate,
        ),
      );
    }

    final VisitAppointment? visit = project.visitAppointment;
    if (visit != null) {
      final DateTime day = appCalendarDate(visit.when);
      if (!day.isBefore(today) && !day.isAfter(last)) {
        pieces.add(
          HomePiece(
            id: 'visit-${project.id}',
            day: day,
            projectId: project.id,
            placeName: project.placeName,
            title: '${_clock(visit.when)} 참석',
            note: '방문',
            kind: HomeCollectionKind.task,
            open: HomePieceOpen.project,
          ),
        );
      }
    }

    if (project.phase != SpacePhase.construction) continue;
    final ConstructionProgress? progress = progressOf(project.id);
    if (progress != null) {
      if (progress.todayTrade.trim().isNotEmpty) {
        _addTrade(
          pieces,
          project: project,
          day: today,
          trade: progress.todayTrade,
        );
      }
      if (progress.nextWhen.trim().startsWith('내일') &&
          progress.nextTrade.trim().isNotEmpty) {
        _addTrade(
          pieces,
          project: project,
          day: tomorrow,
          trade: progress.nextTrade,
        );
      }
      for (final SideTrade side in progress.sideTrades) {
        final String when = side.when.trim();
        final DateTime? day =
            when.startsWith('오늘')
                ? today
                : when.startsWith('내일')
                ? tomorrow
                : null;
        if (day == null) continue;
        _addTrade(pieces, project: project, day: day, trade: side.name);
      }
    }

    for (final DateTime day in days) {
      for (final ProcessScheduleTask task in processTasksOn(schedule, day)) {
        if (_startedBefore(task, day)) continue;
        final String kind = _shortTrade(processTaskLabel(task));
        if (_hasTrade(pieces, project.id, kind)) continue;
        _addTrade(pieces, project: project, day: day, trade: kind);
      }
    }
  }

  return HomeAgenda(today: today, days: days, pieces: pieces);
}

/// 오늘·내일은 요일 대신 그 말을 쓴다.
String homeAgendaDayLabel(DateTime day, DateTime today) {
  final int delta = appCalendarDate(day).difference(today).inDays;
  if (delta == 0) return '오늘';
  if (delta == 1) return '내일';
  return appCalendarWeekdays[day.weekday % 7];
}

String _collectionLabel(HomeCollectionKind kind) {
  return switch (kind) {
    HomeCollectionKind.trade => '공정',
    HomeCollectionKind.task => '내 할 일',
  };
}

void _addTrade(
  List<HomePiece> pieces, {
  required SpaceProject project,
  required DateTime day,
  required String trade,
}) {
  final String kind = _shortTrade(trade);
  if (kind.isEmpty || _hasTrade(pieces, project.id, kind, day: day)) return;
  final String id = '${project.id}-${processDayKey(day)}-$kind';
  pieces.add(
    HomePiece(
      id: 'trade-$id',
      day: day,
      projectId: project.id,
      placeName: project.placeName,
      title: kind,
      note: '',
      kind: HomeCollectionKind.trade,
      open: HomePieceOpen.project,
    ),
  );
  pieces.add(
    HomePiece(
      id: 'task-$id',
      day: day,
      projectId: project.id,
      placeName: project.placeName,
      title: _prepare(kind),
      note: kind,
      kind: HomeCollectionKind.task,
      open: HomePieceOpen.project,
    ),
  );
}

bool _hasTrade(
  List<HomePiece> pieces,
  String projectId,
  String kind, {
  DateTime? day,
}) {
  for (final HomePiece piece in pieces) {
    if (piece.kind != HomeCollectionKind.trade) continue;
    if (piece.projectId != projectId || piece.title != kind) continue;
    if (day != null && !appCalendarSameDay(piece.day, day)) continue;
    return true;
  }
  return false;
}

bool _startedBefore(ProcessScheduleTask task, DateTime day) {
  final int key = processDayKey(day);
  return task.days.any((int value) => value < key);
}

/// 공정 전에 고객이 해 둘 일.
String _prepare(String kind) {
  return switch (kind) {
    '목공' => '작업 공간 비우기',
    '설비' => '배수 위치 정하기',
    '필름' => '문틀 주변 비우기',
    '전기' => '조명 위치 정하기',
    '도장' => '도장할 면 비우기',
    '철거' => '철거할 곳 비우기',
    '실사' => '실사 자리 비우기',
    _ => '$kind 자리 확인',
  };
}

bool _awaitsQuote(SpaceProject project) {
  if (project.workQuote == null) return false;
  if (project.phase != SpacePhase.estimate &&
      project.phase != SpacePhase.design) {
    return false;
  }
  return project.nextAction.contains('확인');
}

String _shortTrade(String title) {
  final String trimmed = title.trim();
  if (trimmed.endsWith(' 공사')) {
    return trimmed.substring(0, trimmed.length - 3).trim();
  }
  return trimmed;
}

String _clock(DateTime when) {
  final int hour = when.hour;
  final String period = hour < 12 ? '오전' : '오후';
  final int shown = hour % 12 == 0 ? 12 : hour % 12;
  final String minute = when.minute.toString().padLeft(2, '0');
  return '$period $shown:$minute';
}
