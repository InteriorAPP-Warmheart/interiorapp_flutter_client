import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/process_schedule.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/calendar/app_calendar_date.dart';

/// 날짜가 가로로 늘어선 공정표. 칸을 누르면 일정이 생기고, 길게 눌러 끌면 이어 칠한다.
class ProcessScheduleGrid extends StatefulWidget {
  const ProcessScheduleGrid({
    super.key,
    required this.start,
    required this.end,
    required this.tasks,
    required this.onDaySet,
    required this.onRename,
    required this.onRemove,
    required this.onAdd,
  });

  final DateTime start;
  final DateTime end;
  final List<ProcessScheduleTask> tasks;
  final void Function(String id, int dayKey, bool on) onDaySet;
  final void Function(String id, String name) onRename;
  final ValueChanged<String> onRemove;
  final VoidCallback onAdd;

  @override
  State<ProcessScheduleGrid> createState() => _ProcessScheduleGridState();
}

class _ProcessScheduleGridState extends State<ProcessScheduleGrid> {
  final ScrollController _headerX = ScrollController();
  final ScrollController _bodyX = ScrollController();
  final ScrollController _labelY = ScrollController();
  final ScrollController _bodyY = ScrollController();
  bool _syncing = false;
  bool _painting = false;
  int? _lastRow;
  int? _lastCol;

  @override
  void initState() {
    super.initState();
    _bind(_headerX, _bodyX);
    _bind(_bodyX, _headerX);
    _bind(_labelY, _bodyY);
    _bind(_bodyY, _labelY);
  }

  void _bind(ScrollController leader, ScrollController follower) {
    leader.addListener(() {
      if (_syncing || !leader.hasClients || !follower.hasClients) return;
      if ((follower.offset - leader.offset).abs() < 0.5) return;
      _syncing = true;
      final double next = leader.offset.clamp(
        follower.position.minScrollExtent,
        follower.position.maxScrollExtent,
      );
      follower.jumpTo(next);
      _syncing = false;
    });
  }

  @override
  void dispose() {
    _headerX.dispose();
    _bodyX.dispose();
    _labelY.dispose();
    _bodyY.dispose();
    super.dispose();
  }

  List<DateTime> get _days => processDaysBetween(widget.start, widget.end);

  void _apply(int row, int col, {required bool start}) {
    final List<DateTime> days = _days;
    if (row < 0 || row >= widget.tasks.length) return;
    if (col < 0 || col >= days.length) return;
    if (!start && _lastRow == row && _lastCol == col) return;
    final ProcessScheduleTask task = widget.tasks[row];
    final int key = processDayKey(days[col]);
    final bool turnOn = start ? !task.days.contains(key) : _painting;
    if (start) _painting = turnOn;
    _lastRow = row;
    _lastCol = col;
    if (task.days.contains(key) == turnOn) return;
    widget.onDaySet(task.id, key, turnOn);
  }

  void _fromLocal(
    Offset local,
    double cellW,
    double cellH, {
    required bool start,
  }) {
    _apply(
      (local.dy / cellH).floor(),
      (local.dx / cellW).floor(),
      start: start,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppWindow window = AppWindow.of(context);
    final double fontScale = ResponsiveSize.fontScale(context);
    final double left =
        window.isExpanded
            ? 140
            : window.isMedium
            ? 118
            : 100;
    final double cellW = window.isExpanded ? 52 : 46;
    final double cellH = 42 * fontScale;
    final double headerH = 46 * fontScale;
    final List<DateTime> days = _days;
    final double gridWidth = days.length * cellW;
    final double gridHeight = widget.tasks.length * cellH;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            _periodLabel(widget.start, widget.end, days.length),
            style: TextStyle(
              fontSize: 12 * fontScale,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: left,
                  child: Column(
                    children: [
                      _Corner(height: headerH, fontScale: fontScale),
                      Expanded(
                        child: ListView.builder(
                          controller: _labelY,
                          padding: EdgeInsets.zero,
                          itemCount: widget.tasks.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == widget.tasks.length) {
                              return _AddTask(
                                height: cellH,
                                fontScale: fontScale,
                                onTap: widget.onAdd,
                              );
                            }
                            final ProcessScheduleTask task =
                                widget.tasks[index];
                            return SizedBox(
                              height: cellH,
                              child: _TaskLabel(
                                task: task,
                                fontScale: fontScale,
                                onRename:
                                    (String name) =>
                                        widget.onRename(task.id, name),
                                onRemove: () => widget.onRemove(task.id),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: headerH,
                        child: ListView.builder(
                          controller: _headerX,
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.zero,
                          itemCount: days.length,
                          itemBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              width: cellW,
                              height: headerH,
                              child: _DateHead(
                                day: days[index],
                                fontScale: fontScale,
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _bodyY,
                          child: SingleChildScrollView(
                            controller: _bodyX,
                            scrollDirection: Axis.horizontal,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapUp: (TapUpDetails details) {
                                _fromLocal(
                                  details.localPosition,
                                  cellW,
                                  cellH,
                                  start: true,
                                );
                              },
                              onLongPressStart: (
                                LongPressStartDetails details,
                              ) {
                                _fromLocal(
                                  details.localPosition,
                                  cellW,
                                  cellH,
                                  start: true,
                                );
                              },
                              onLongPressMoveUpdate: (
                                LongPressMoveUpdateDetails details,
                              ) {
                                _fromLocal(
                                  details.localPosition,
                                  cellW,
                                  cellH,
                                  start: false,
                                );
                              },
                              child: SizedBox(
                                width: gridWidth,
                                height: gridHeight,
                                child: Column(
                                  children: [
                                    for (final ProcessScheduleTask task
                                        in widget.tasks)
                                      SizedBox(
                                        height: cellH,
                                        child: Row(
                                          children: [
                                            for (
                                              int index = 0;
                                              index < days.length;
                                              index++
                                            )
                                              _DayCell(
                                                width: cellW,
                                                on: task.days.contains(
                                                  processDayKey(days[index]),
                                                ),
                                                color: task.color,
                                                label:
                                                    _labelAt(task, days, index)
                                                        ? task.name
                                                        : '',
                                              ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _labelAt(ProcessScheduleTask task, List<DateTime> days, int index) {
    if (!task.days.contains(processDayKey(days[index]))) return false;
    int start = index;
    while (start > 0 && task.days.contains(processDayKey(days[start - 1]))) {
      start -= 1;
    }
    int end = index;
    while (end + 1 < days.length &&
        task.days.contains(processDayKey(days[end + 1]))) {
      end += 1;
    }
    final int length = end - start + 1;
    if (length < 2) return false;
    return index == start + length ~/ 2;
  }
}

String _periodLabel(DateTime start, DateTime end, int count) {
  String short(DateTime day) {
    final String year = (day.year % 100).toString().padLeft(2, '0');
    final String month = day.month.toString().padLeft(2, '0');
    final String date = day.day.toString().padLeft(2, '0');
    return '$year.$month.$date';
  }

  return '${short(start)} – ${short(end)} · $count일';
}

class _Corner extends StatelessWidget {
  const _Corner({required this.height, required this.fontScale});

  final double height;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Text(
        '구분',
        style: TextStyle(
          fontSize: 12 * fontScale,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _DateHead extends StatelessWidget {
  const _DateHead({required this.day, required this.fontScale});

  final DateTime day;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final bool sunday = day.weekday == DateTime.sunday;
    final bool saturday = day.weekday == DateTime.saturday;
    final Color color =
        sunday
            ? AppColors.error
            : saturday
            ? AppColors.primary
            : AppColors.textPrimary;
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.month}.${day.day}',
            style: TextStyle(
              fontSize: 11 * fontScale,
              height: 1.1,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            '(${appCalendarWeekdays[appCalendarWeekIndex(day)]})',
            style: TextStyle(
              fontSize: 10 * fontScale,
              height: 1.1,
              fontWeight: FontWeight.w600,
              color: sunday || saturday ? color : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.width,
    required this.on,
    required this.color,
    required this.label,
  });

  final double width;
  final bool on;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final Color foreground =
        color.computeLuminance() > 0.55
            ? AppColors.textPrimary
            : AppColors.white;
    return Container(
      width: width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: on ? color : AppColors.surface,
        border: const Border(
          right: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child:
          label.isEmpty
              ? null
              : Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
    );
  }
}

class _TaskLabel extends StatefulWidget {
  const _TaskLabel({
    required this.task,
    required this.fontScale,
    required this.onRename,
    required this.onRemove,
  });

  final ProcessScheduleTask task;
  final double fontScale;
  final ValueChanged<String> onRename;
  final VoidCallback onRemove;

  @override
  State<_TaskLabel> createState() => _TaskLabelState();
}

class _TaskLabelState extends State<_TaskLabel> {
  bool _editing = false;
  late final TextEditingController _controller;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.task.name);
    _focus = FocusNode()..addListener(_onFocus);
  }

  @override
  void didUpdateWidget(_TaskLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing && oldWidget.task.name != widget.task.name) {
      _controller.text = widget.task.name;
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocus() {
    if (!_focus.hasFocus && _editing) _commit();
  }

  void _commit() {
    setState(() => _editing = false);
    widget.onRename(_controller.text.trim());
  }

  void _begin() {
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focus.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.task.name.trim();
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Container(width: 4, color: widget.task.color),
          const SizedBox(width: 8),
          Expanded(
            child:
                _editing
                    ? TextField(
                      controller: _controller,
                      focusNode: _focus,
                      style: TextStyle(
                        fontSize: 13 * widget.fontScale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: '공정 이름',
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _commit(),
                    )
                    : GestureDetector(
                      onTap: _begin,
                      onLongPress: widget.onRemove,
                      behavior: HitTestBehavior.opaque,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          name.isEmpty ? '공정 이름' : name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13 * widget.fontScale,
                            fontWeight: FontWeight.w700,
                            color:
                                name.isEmpty
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

class _AddTask extends StatelessWidget {
  const _AddTask({
    required this.height,
    required this.fontScale,
    required this.onTap,
  });

  final double height;
  final double fontScale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: height,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: AppColors.border)),
        ),
        child: Text(
          '+ 공정',
          style: TextStyle(
            fontSize: 13 * fontScale,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
