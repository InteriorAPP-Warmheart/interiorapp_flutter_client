import 'package:interiorapp_flutter_client/build/domain/entity/construction_progress.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/process_schedule.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/core/widget/calendar/app_calendar_date.dart';

/// 오늘 또는 내일 한 칸. 공정 이름과 그 칸에서만 보이는 한 줄이다.
class HomeMoment {
  const HomeMoment({
    required this.label,
    required this.trade,
    this.caption = '',
    this.more = const <String>[],
  });

  final String label;
  final String trade;
  final String caption;

  /// 같은 날의 다른 공정. 칸 높이를 늘리지 않고 한 줄로만 쓴다.
  final List<String> more;
}

/// 홈 일정 카드. 사진과 오늘·내일 칸으로 보여 준다.
class HomeBrief {
  const HomeBrief({
    required this.projectId,
    required this.placeName,
    required this.imageUrl,
    required this.today,
    required this.tomorrow,
  });

  final String projectId;
  final String placeName;
  final String imageUrl;
  final HomeMoment today;
  final HomeMoment tomorrow;
}

/// 고객이 홈에서 봐야 하는 알림. 사진, 종류, 상태 칩으로 나눈다.
class HomeNotice {
  const HomeNotice({
    required this.projectId,
    required this.placeName,
    required this.imageUrl,
    required this.kind,
    this.mark = '',
    this.title = '',
  });

  final String projectId;
  final String placeName;
  final String imageUrl;
  final String kind;
  final String mark;
  final String title;
}

/// 공사 중인 대표 공간의 하루.
class HomeDayGlance {
  const HomeDayGlance({
    required this.label,
    required this.title,
    this.note = '',
  });

  final String label;
  final String title;
  final String note;
}

/// 대표가 아닌 진행 공간.
class HomeSpaceRow {
  const HomeSpaceRow({
    required this.projectId,
    required this.placeName,
    required this.phaseLabel,
    required this.detail,
    required this.imageUrl,
  });

  final String projectId;
  final String placeName;
  final String phaseLabel;
  final String detail;
  final String imageUrl;
}

/// 홈 대시보드가 그리는 진행 공간. 대표 하나와 나머지 줄이다.
class HomeSpaceGlance {
  const HomeSpaceGlance({
    required this.heroId,
    required this.placeName,
    required this.phaseLabel,
    required this.imageUrl,
    required this.notices,
    required this.others,
    this.brief,
    this.days = const <HomeDayGlance>[],
    this.headline = '',
    this.detail = '',
    this.spanLabel = '',
  });

  final String heroId;
  final String placeName;
  final String phaseLabel;
  final String imageUrl;
  final List<HomeNotice> notices;
  final List<HomeSpaceRow> others;

  /// 공사 진행을 문장으로 요약한 것. 없으면 알림만 보여 준다.
  final HomeBrief? brief;

  /// 공사 중일 때만 오늘, 내일, 모레를 채운다.
  final List<HomeDayGlance> days;

  /// 공사 전이거나 마감 단계일 때 보여주는 한 줄.
  final String headline;
  final String detail;

  /// 오늘 공정이 끝나는 날. 비어 있으면 공정표 줄을 그리지 않는다.
  final String spanLabel;

  bool get showsDays => days.length == 3;
  bool get showsSpan => spanLabel.isNotEmpty;
}

/// 진행 공간을 홈에서 볼 분량으로 고른다.
///
/// 공사 중인 공간을 대표로 둔다. 공정표는 그 대표 공간의 오늘 이후에만 쓰고,
/// 표에 없는 모레 공정은 만들지 않는다.
HomeSpaceGlance homeSpaceGlance({
  required List<SpaceProject> projects,
  required ConstructionProgress? Function(String id) progressOf,
  required List<ProcessScheduleTask> schedule,
  required DateTime now,
}) {
  final DateTime today = DateTime(now.year, now.month, now.day);
  final SpaceProject hero = _pickHero(projects, progressOf);
  final ConstructionProgress? progress = progressOf(hero.id);
  final List<HomeDayGlance> days = _constructionDays(
    project: hero,
    progress: progress,
    schedule: schedule,
    today: today,
  );
  final List<HomeNotice> notices = _notices(projects, progressOf, today);
  final _StatusCopy status =
      days.isEmpty ? _statusCopy(hero, progress, today) : const _StatusCopy();
  final HomeBrief? built = _brief(
    project: hero,
    progress: progress,
    schedule: schedule,
    today: today,
  );
  final HomeBrief? brief =
      built ??
      (notices.isEmpty && status.headline.isNotEmpty
          ? HomeBrief(
            projectId: hero.id,
            placeName: hero.placeName,
            imageUrl: hero.imageUrl,
            today: HomeMoment(label: hero.phase.label, trade: status.headline),
            tomorrow: HomeMoment(label: '다음', trade: status.detail),
          )
          : null);

  return HomeSpaceGlance(
    heroId: hero.id,
    placeName: hero.placeName,
    phaseLabel: hero.phase.label,
    imageUrl: hero.imageUrl,
    notices: <HomeNotice>[
      for (final HomeNotice notice in notices)
        if (brief == null || notice.projectId != hero.id || notice.kind == '방문')
          notice,
    ],
    brief: brief,
    others: <HomeSpaceRow>[
      for (final SpaceProject project in projects)
        if (project.id != hero.id)
          HomeSpaceRow(
            projectId: project.id,
            placeName: project.placeName,
            phaseLabel: project.phase.label,
            detail: _rowDetail(project),
            imageUrl: project.imageUrl,
          ),
    ],
    days: days,
    headline: status.headline,
    detail: status.detail,
    spanLabel:
        days.isEmpty
            ? ''
            : _spanLabel(schedule, today, progress?.todayTrade ?? ''),
  );
}

SpaceProject _pickHero(
  List<SpaceProject> projects,
  ConstructionProgress? Function(String id) progressOf,
) {
  SpaceProject hero = projects.first;
  for (final SpaceProject project in projects.skip(1)) {
    final int phase = _phaseRank(
      project.phase,
    ).compareTo(_phaseRank(hero.phase));
    if (phase < 0) {
      hero = project;
      continue;
    }
    if (phase > 0) continue;
    final int today = _todayRank(
      progressOf(project.id)?.today,
    ).compareTo(_todayRank(progressOf(hero.id)?.today));
    if (today < 0) hero = project;
  }
  return hero;
}

int _phaseRank(SpacePhase phase) {
  return switch (phase) {
    SpacePhase.construction => 0,
    SpacePhase.consult => 1,
    SpacePhase.estimate => 2,
    SpacePhase.design => 3,
    SpacePhase.handover => 4,
    SpacePhase.afterCare => 5,
  };
}

int _todayRank(TodayWorkState? state) {
  return switch (state) {
    TodayWorkState.underway => 0,
    TodayWorkState.checking => 1,
    TodayWorkState.idle => 2,
    TodayWorkState.closing => 3,
    null => 4,
  };
}

List<HomeDayGlance> _constructionDays({
  required SpaceProject project,
  required ConstructionProgress? progress,
  required List<ProcessScheduleTask> schedule,
  required DateTime today,
}) {
  if (project.phase != SpacePhase.construction || progress == null) {
    return const <HomeDayGlance>[];
  }
  final DateTime tomorrow = today.add(const Duration(days: 1));
  final DateTime dayAfter = today.add(const Duration(days: 2));
  final String todayTrade = progress.todayTrade;
  return <HomeDayGlance>[
    HomeDayGlance(
      label: '오늘',
      title: progress.todayTitle,
      note: _firstLine(progress.todayNote),
    ),
    _tomorrow(progress, schedule, tomorrow, todayTrade),
    _dayFromSchedule(
      schedule,
      dayAfter,
      '모레',
      todayTrade,
      continuingNote: true,
    ),
  ];
}

HomeBrief? _brief({
  required SpaceProject project,
  required ConstructionProgress? progress,
  required List<ProcessScheduleTask> schedule,
  required DateTime today,
}) {
  if (project.phase != SpacePhase.construction || progress == null) return null;
  return HomeBrief(
    projectId: project.id,
    placeName: project.placeName,
    imageUrl: project.imageUrl,
    today: _todayMoment(progress, schedule, today),
    tomorrow: _tomorrowMoment(
      progress,
      schedule,
      today.add(const Duration(days: 1)),
      progress.todayTrade,
    ),
  );
}

HomeMoment _todayMoment(
  ConstructionProgress progress,
  List<ProcessScheduleTask> schedule,
  DateTime today,
) {
  final String summary = _firstLine(progress.todayNote);
  switch (progress.today) {
    case TodayWorkState.underway:
      final String trade = _shortTrade(
        progress.todayTrade.isEmpty ? progress.todayTitle : progress.todayTrade,
      );
      return HomeMoment(
        label: '오늘',
        trade: trade,
        caption: _caption(summary, trade),
        more: _moreNames(
          lead: trade,
          names: <String>[
            for (final SideTrade side in progress.sideTrades)
              if (_isWhen(side.when, '오늘')) side.name,
            for (final ProcessScheduleTask task in processTasksOn(
              schedule,
              today,
            ))
              task.name,
          ],
        ),
      );
    case TodayWorkState.checking:
      return HomeMoment(
        label: '오늘',
        trade: '확인중',
        caption: _caption(summary, '확인중'),
      );
    case TodayWorkState.idle:
      return HomeMoment(
        label: '오늘',
        trade: '작업 없음',
        caption: progress.idleReason.trim(),
      );
    case TodayWorkState.closing:
      return HomeMoment(
        label: '오늘',
        trade: '마감',
        caption: _caption(summary, '마감'),
      );
  }
}

HomeMoment _tomorrowMoment(
  ConstructionProgress progress,
  List<ProcessScheduleTask> schedule,
  DateTime tomorrow,
  String todayTrade,
) {
  final String when = progress.nextWhen.trim();
  if (when.startsWith('내일')) {
    final String trade = _shortTrade(
      progress.nextTrade.isEmpty ? progress.nextTitle : progress.nextTrade,
    );
    return HomeMoment(
      label: '내일',
      trade: trade,
      caption: _caption(progress.nextSummary.trim(), trade),
      more: _moreNames(
        lead: trade,
        names: <String>[
          for (final SideTrade side in progress.sideTrades)
            if (_isWhen(side.when, '내일')) side.name,
        ],
      ),
    );
  }
  final List<ProcessScheduleTask> tasks = processTasksOn(schedule, tomorrow);
  if (tasks.isEmpty) {
    return const HomeMoment(label: '내일', trade: '예정 없음');
  }
  final String lead = processTaskLabel(tasks.first);
  final bool continues = tasks.every(
    (ProcessScheduleTask task) => _sameTrade(task.name, todayTrade),
  );
  return HomeMoment(
    label: '내일',
    trade: lead,
    caption: continues ? '이어지는 공정' : '',
    more: _moreNames(
      lead: lead,
      names: <String>[
        for (final ProcessScheduleTask task in tasks.skip(1)) task.name,
      ],
    ),
  );
}

bool _isWhen(String when, String day) {
  final String trimmed = when.trim();
  return trimmed.isEmpty || trimmed.startsWith(day);
}

List<String> _moreNames({required String lead, required List<String> names}) {
  final List<String> more = <String>[];
  final Set<String> seen = <String>{_tradeKey(lead)};
  for (final String name in names) {
    final String short = _shortTrade(name);
    final String key = _tradeKey(short);
    if (short.isEmpty || seen.contains(key)) continue;
    seen.add(key);
    more.add(short);
  }
  return more;
}

String _caption(String summary, String trade) {
  if (summary.isEmpty || summary == trade || _sameTrade(summary, trade)) {
    return '';
  }
  return summary;
}

String _shortTrade(String title) {
  final String trimmed = title.trim();
  if (trimmed.endsWith(' 공사')) {
    return trimmed.substring(0, trimmed.length - 3).trim();
  }
  return trimmed;
}

HomeDayGlance _tomorrow(
  ConstructionProgress progress,
  List<ProcessScheduleTask> schedule,
  DateTime tomorrow,
  String todayTrade,
) {
  final String when = progress.nextWhen.trim();
  if (when.startsWith('내일')) {
    return HomeDayGlance(
      label: '내일',
      title: progress.nextTitle,
      note: progress.nextSummary.trim(),
    );
  }
  return _dayFromSchedule(schedule, tomorrow, '내일', todayTrade);
}

HomeDayGlance _dayFromSchedule(
  List<ProcessScheduleTask> schedule,
  DateTime day,
  String label,
  String todayTrade, {
  bool continuingNote = false,
}) {
  final List<ProcessScheduleTask> tasks = processTasksOn(schedule, day);
  if (tasks.isEmpty) {
    return HomeDayGlance(label: label, title: '예정 없음');
  }
  final bool continues = tasks.every(
    (ProcessScheduleTask task) => _sameTrade(task.name, todayTrade),
  );
  return HomeDayGlance(
    label: label,
    title: tasks.map(processTaskLabel).join(', '),
    note: continuingNote && continues ? '이어지는 공정' : '',
  );
}

String _spanLabel(
  List<ProcessScheduleTask> schedule,
  DateTime today,
  String todayTrade,
) {
  final int key = processDayKey(today);
  ProcessScheduleTask? match;
  for (final ProcessScheduleTask task in schedule) {
    if (!task.days.contains(key)) continue;
    match = task;
    if (_sameTrade(task.name, todayTrade)) break;
  }
  if (match == null) return '';

  DateTime end = today;
  DateTime cursor = today.add(const Duration(days: 1));
  while (match.days.contains(processDayKey(cursor))) {
    end = cursor;
    cursor = cursor.add(const Duration(days: 1));
  }

  final String name = processTaskLabel(match);
  if (appCalendarSameDay(today, end)) return '$name · 오늘까지';
  final int ahead = end.difference(today).inDays;
  if (ahead > 0 && ahead < 7) {
    final String week = appCalendarWeekdays[end.weekday % 7];
    return '$name · $week요일까지';
  }
  return '$name · ${end.month}월 ${end.day}일까지';
}

class _StatusCopy {
  const _StatusCopy({this.headline = '', this.detail = ''});

  final String headline;
  final String detail;
}

_StatusCopy _statusCopy(
  SpaceProject project,
  ConstructionProgress? progress,
  DateTime today,
) {
  final VisitAppointment? visit = project.visitAppointment;
  if (project.phase == SpacePhase.consult && visit != null) {
    final DateTime day = DateTime(
      visit.when.year,
      visit.when.month,
      visit.when.day,
    );
    if (!day.isBefore(today)) {
      return _StatusCopy(
        headline: _visitHeadline(visit, today),
        detail: visit.place,
      );
    }
  }

  if (project.phase == SpacePhase.handover ||
      project.phase == SpacePhase.afterCare) {
    final String summary = progress?.todaySummary.trim() ?? '';
    return _StatusCopy(
      headline: project.statusLabel,
      detail: summary.isEmpty ? project.nextAction : summary,
    );
  }

  final String action = project.nextAction.trim();
  if (action.isEmpty) {
    return _StatusCopy(headline: project.statusLabel);
  }
  final String status = project.statusLabel.trim();
  return _StatusCopy(headline: action, detail: status == action ? '' : status);
}

String _rowDetail(SpaceProject project) {
  final String action = project.nextAction.trim();
  if (action.isEmpty) return project.statusLabel;
  return action;
}

List<HomeNotice> _notices(
  List<SpaceProject> projects,
  ConstructionProgress? Function(String id) progressOf,
  DateTime today,
) {
  final List<({int rank, int order, HomeNotice notice})> ranked =
      <({int rank, int order, HomeNotice notice})>[];
  for (var i = 0; i < projects.length; i++) {
    final SpaceProject project = projects[i];
    final HomeNotice? notice = _noticeFor(
      project,
      progressOf(project.id),
      today,
    );
    if (notice == null) continue;
    ranked.add((
      rank: _noticeRank(project, progressOf(project.id), today),
      order: i,
      notice: notice,
    ));
  }
  ranked.sort((a, b) {
    final int byRank = a.rank.compareTo(b.rank);
    if (byRank != 0) return byRank;
    return a.order.compareTo(b.order);
  });
  return <HomeNotice>[for (final item in ranked) item.notice];
}

int _noticeRank(
  SpaceProject project,
  ConstructionProgress? progress,
  DateTime today,
) {
  final VisitAppointment? visit = project.visitAppointment;
  if (visit != null && _isTodayOrTomorrow(visit.when, today)) return 0;
  if (project.phase == SpacePhase.estimate ||
      project.phase == SpacePhase.design) {
    return 1;
  }
  if (progress?.today == TodayWorkState.checking ||
      progress?.today == TodayWorkState.idle) {
    return 2;
  }
  return 3;
}

HomeNotice? _noticeFor(
  SpaceProject project,
  ConstructionProgress? progress,
  DateTime today,
) {
  final VisitAppointment? visit = project.visitAppointment;
  if (visit != null && _isTodayOrTomorrow(visit.when, today)) {
    final String when = _isSameDay(visit.when, today) ? '오늘' : '내일';
    final String who = [
      visit.visitorName.trim(),
      visit.visitorRole.trim(),
    ].where((String part) => part.isNotEmpty).join(' ');
    return HomeNotice(
      projectId: project.id,
      placeName: project.placeName,
      imageUrl: project.imageUrl,
      kind: '방문',
      mark: '$when ${_clock(visit.when)}',
      title: [
        visit.place.trim(),
        who,
      ].where((String part) => part.isNotEmpty).join(' · '),
    );
  }

  if (project.phase == SpacePhase.estimate ||
      project.phase == SpacePhase.design) {
    final String action = project.nextAction.trim();
    final String status = project.workQuote?.statusLabel.trim() ?? '';
    final String title = action.isEmpty ? project.statusLabel : action;
    if (title.isEmpty) return null;
    return HomeNotice(
      projectId: project.id,
      placeName: project.placeName,
      imageUrl: project.imageUrl,
      kind: project.phase == SpacePhase.design ? '설계' : '견적',
      mark: status,
      title: title,
    );
  }

  if (project.phase == SpacePhase.construction && progress != null) {
    if (progress.today == TodayWorkState.idle) {
      final String reason = progress.idleReason.trim();
      return HomeNotice(
        projectId: project.id,
        placeName: project.placeName,
        imageUrl: project.imageUrl,
        kind: '작업 없음',
        title: reason,
      );
    }
    if (progress.today == TodayWorkState.checking) {
      return HomeNotice(
        projectId: project.id,
        placeName: project.placeName,
        imageUrl: project.imageUrl,
        kind: '확인중',
        title: _firstLine(progress.todaySummary),
      );
    }
  }
  return null;
}

bool _isTodayOrTomorrow(DateTime when, DateTime today) {
  final DateTime day = DateTime(when.year, when.month, when.day);
  final int delta = day.difference(today).inDays;
  return delta == 0 || delta == 1;
}

bool _isSameDay(DateTime when, DateTime today) {
  return when.year == today.year &&
      when.month == today.month &&
      when.day == today.day;
}

String _visitHeadline(VisitAppointment visit, DateTime today) {
  final DateTime day = DateTime(
    visit.when.year,
    visit.when.month,
    visit.when.day,
  );
  final String clock = _clock(visit.when);
  final int delta = day.difference(today).inDays;
  if (delta == 0) return '오늘 $clock 현장방문';
  if (delta == 1) return '내일 $clock 현장방문';
  if (delta > 1 && delta < 7) {
    final String week = appCalendarWeekdays[day.weekday % 7];
    return '$week요일 $clock 현장방문';
  }
  return '${day.month}월 ${day.day}일 $clock 현장방문';
}

String _clock(DateTime when) {
  final int hour = when.hour;
  final String period = hour < 12 ? '오전' : '오후';
  final int shown = hour % 12 == 0 ? 12 : hour % 12;
  final String minute = when.minute.toString().padLeft(2, '0');
  return '$period $shown:$minute';
}

String _firstLine(String value) {
  final String trimmed = value.trim();
  final int breakAt = trimmed.indexOf('\n');
  if (breakAt < 0) return trimmed;
  return trimmed.substring(0, breakAt).trim();
}

bool _sameTrade(String a, String b) {
  final String left = _tradeKey(a);
  final String right = _tradeKey(b);
  if (left.isEmpty || right.isEmpty) return false;
  return left.contains(right) || right.contains(left);
}

String _tradeKey(String value) {
  return value.replaceAll('공사', '').replaceAll(RegExp(r'\s+'), '').trim();
}
