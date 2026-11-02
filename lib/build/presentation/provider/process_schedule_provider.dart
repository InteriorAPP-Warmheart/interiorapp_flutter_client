import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/process_schedule.dart';
import 'package:interiorapp_flutter_client/core/widget/calendar/app_calendar_date.dart';

class ProcessScheduleNotifier extends Notifier<List<ProcessScheduleTask>> {
  int _nextId = 1;

  @override
  List<ProcessScheduleTask> build() {
    final List<ProcessScheduleTask> tasks = sampleProcessSchedule(
      appCalendarDate(DateTime.now()),
    );
    _nextId = tasks.length + 1;
    return tasks;
  }

  void setDay(String id, int dayKey, bool on) {
    state = <ProcessScheduleTask>[
      for (final ProcessScheduleTask task in state)
        if (task.id == id) _withDay(task, dayKey, on) else task,
    ];
  }

  void rename(String id, String name) {
    state = <ProcessScheduleTask>[
      for (final ProcessScheduleTask task in state)
        if (task.id == id) task.copyWith(name: name) else task,
    ];
  }

  void remove(String id) {
    state = state.where((ProcessScheduleTask task) => task.id != id).toList();
  }

  void add() {
    final int color = state.length % processSchedulePalette.length;
    state = <ProcessScheduleTask>[
      ...state,
      ProcessScheduleTask(
        id: 'task-$_nextId',
        name: '',
        days: <int>{},
        color: processSchedulePalette[color],
      ),
    ];
    _nextId += 1;
  }

  ProcessScheduleTask _withDay(ProcessScheduleTask task, int dayKey, bool on) {
    final Set<int> days = <int>{...task.days};
    if (on) {
      days.add(dayKey);
    } else {
      days.remove(dayKey);
    }
    return task.copyWith(days: days);
  }
}

final processScheduleProvider =
    NotifierProvider<ProcessScheduleNotifier, List<ProcessScheduleTask>>(
      ProcessScheduleNotifier.new,
    );
