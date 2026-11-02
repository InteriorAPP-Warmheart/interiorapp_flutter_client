import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/widget/calendar/app_calendar_span.dart';

/// 공정 한 줄. [days]는 연월일 키이고, 붙어 있는 날은 달력에서 하나의 띠가 된다.
class ProcessScheduleTask {
  const ProcessScheduleTask({
    required this.id,
    required this.name,
    required this.days,
    required this.color,
  });

  final String id;
  final String name;
  final Set<int> days;
  final Color color;

  ProcessScheduleTask copyWith({String? name, Set<int>? days, Color? color}) {
    return ProcessScheduleTask(
      id: id,
      name: name ?? this.name,
      days: days ?? this.days,
      color: color ?? this.color,
    );
  }
}

const List<Color> processSchedulePalette = <Color>[
  Color(0xFF0B1F38),
  Color(0xFF687A5E),
  Color(0xFF3E5C76),
  Color(0xFF8C6A45),
  Color(0xFF6B4C5A),
  Color(0xFF4F6F73),
];

int processDayKey(DateTime day) {
  return day.year * 10000 + day.month * 100 + day.day;
}

DateTime processDayFromKey(int key) {
  return DateTime(key ~/ 10000, (key ~/ 100) % 100, key % 100);
}

List<DateTime> processDaysBetween(DateTime start, DateTime end) {
  final DateTime from = DateTime(start.year, start.month, start.day);
  final DateTime to = DateTime(end.year, end.month, end.day);
  final List<DateTime> days = <DateTime>[];
  for (
    DateTime day = from;
    !day.isAfter(to);
    day = day.add(const Duration(days: 1))
  ) {
    days.add(day);
  }
  return days;
}

/// 진행 화면과 공정표가 함께 보는 예시 일정. 오늘은 목공에 포함된다.
List<ProcessScheduleTask> sampleProcessSchedule(DateTime today) {
  final DateTime anchor = DateTime(today.year, today.month, today.day);
  Set<int> span(int from, int count) {
    return <int>{
      for (int i = 0; i < count; i++)
        processDayKey(anchor.add(Duration(days: from + i))),
    };
  }

  return <ProcessScheduleTask>[
    ProcessScheduleTask(
      id: 'task-1',
      name: '철거',
      days: span(-4, 3),
      color: processSchedulePalette[0],
    ),
    ProcessScheduleTask(
      id: 'task-2',
      name: '목공',
      days: span(0, 5),
      color: processSchedulePalette[1],
    ),
    ProcessScheduleTask(
      id: 'task-3',
      name: '전기',
      days: span(3, 4),
      color: processSchedulePalette[2],
    ),
    ProcessScheduleTask(
      id: 'task-4',
      name: '도장',
      days: span(8, 5),
      color: processSchedulePalette[3],
    ),
  ];
}

List<ProcessScheduleTask> processTasksOn(
  List<ProcessScheduleTask> tasks,
  DateTime day,
) {
  final int key = processDayKey(day);
  return <ProcessScheduleTask>[
    for (final ProcessScheduleTask task in tasks)
      if (task.days.contains(key)) task,
  ];
}

String processTaskLabel(ProcessScheduleTask task) {
  final String name = task.name.trim();
  return name.isEmpty ? '공정' : name;
}

List<AppCalendarSpan> processTaskSpans(List<ProcessScheduleTask> tasks) {
  final List<AppCalendarSpan> spans = <AppCalendarSpan>[];
  for (final ProcessScheduleTask task in tasks) {
    final List<DateTime> days =
        task.days.map(processDayFromKey).toList()..sort();
    if (days.isEmpty) continue;
    DateTime runStart = days.first;
    DateTime previous = days.first;
    int run = 0;
    void close(DateTime end) {
      final String name = task.name.trim().isEmpty ? '공정' : task.name.trim();
      spans.add(
        AppCalendarSpan(
          id: '${task.id}-$run',
          start: runStart,
          end: end,
          color: task.color,
          label: name,
        ),
      );
      run += 1;
    }

    for (int i = 1; i < days.length; i++) {
      final DateTime day = days[i];
      if (day.difference(previous).inDays == 1) {
        previous = day;
        continue;
      }
      close(previous);
      runStart = day;
      previous = day;
    }
    close(previous);
  }
  return spans;
}
