import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/process_schedule.dart';
import 'package:interiorapp_flutter_client/build/presentation/provider/process_schedule_provider.dart';
import 'package:interiorapp_flutter_client/build/ui/space_routes.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/calendar/app_calendar_date.dart';

/// 공사 진행 화면의 일주일. 넘기면 주가 바뀌고, 날짜를 고르면 아래 내용이 따라간다.
class ProcessWeekStrip extends ConsumerStatefulWidget {
  const ProcessWeekStrip({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  @override
  ConsumerState<ProcessWeekStrip> createState() => _ProcessWeekStripState();
}

class _ProcessWeekStripState extends ConsumerState<ProcessWeekStrip> {
  static final DateTime _origin = DateTime(2016, 1, 4);
  static const int _weekCount = 52 * 20;

  late final PageController _pages;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = _indexOf(_mondayOf(DateTime.now()));
    _pages = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  DateTime _mondayOf(DateTime day) {
    final DateTime date = appCalendarDate(day);
    return date.subtract(Duration(days: date.weekday - DateTime.monday));
  }

  int _indexOf(DateTime monday) {
    final int index = monday.difference(_origin).inDays ~/ 7;
    if (index < 0) return 0;
    if (index >= _weekCount) return _weekCount - 1;
    return index;
  }

  DateTime _weekOf(int index) {
    return _origin.add(Duration(days: index * 7));
  }

  String _rangeLabel(DateTime start) {
    final DateTime end = start.add(const Duration(days: 6));
    if (start.year == end.year && start.month == end.month) {
      return '${start.month}월 ${start.day}일 – ${end.day}일';
    }
    if (start.year == end.year) {
      return '${start.month}월 ${start.day}일 – ${end.month}월 ${end.day}일';
    }
    return '${start.year}년 ${start.month}월 ${start.day}일 – ${end.month}월 ${end.day}일';
  }

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final List<ProcessScheduleTask> tasks = ref.watch(processScheduleProvider);
    final DateTime weekStart = _weekOf(_index);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _rangeLabel(weekStart),
                  style: TextStyle(
                    fontSize: 14 * fontScale,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.push(SpaceRoutes.schedule),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Text(
                    '공정표',
                    style: TextStyle(
                      fontSize: 13 * fontScale,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 108 * fontScale,
          child: PageView.builder(
            controller: _pages,
            itemCount: _weekCount,
            onPageChanged: (int index) => setState(() => _index = index),
            itemBuilder: (BuildContext context, int index) {
              final DateTime start = _weekOf(index);
              return Row(
                children: [
                  for (int column = 0; column < 7; column++)
                    Expanded(
                      child: _WeekDay(
                        day: start.add(Duration(days: column)),
                        tasks: processTasksOn(
                          tasks,
                          start.add(Duration(days: column)),
                        ),
                        selected: appCalendarSameDay(
                          start.add(Duration(days: column)),
                          widget.selected,
                        ),
                        fontScale: fontScale,
                        onTap: widget.onSelected,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WeekDay extends StatelessWidget {
  const _WeekDay({
    required this.day,
    required this.tasks,
    required this.selected,
    required this.fontScale,
    required this.onTap,
  });

  final DateTime day;
  final List<ProcessScheduleTask> tasks;
  final bool selected;
  final double fontScale;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final bool today = appCalendarSameDay(day, DateTime.now());
    final int weekday = day.weekday - DateTime.monday;
    final Color labelColor =
        weekday == 6
            ? AppColors.error
            : weekday == 5
            ? AppColors.primary
            : AppColors.textSecondary;
    final Color numberColor =
        today
            ? AppColors.white
            : weekday == 6
            ? AppColors.error
            : weekday == 5
            ? AppColors.primary
            : AppColors.textPrimary;
    return GestureDetector(
      onTap: () => onTap(appCalendarDate(day)),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        padding: const EdgeInsets.fromLTRB(1, 2, 1, 2),
        decoration: BoxDecoration(
          color: selected ? const Color(0x140B1F38) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              appCalendarWeekdays[weekday],
              style: TextStyle(
                fontSize: 11 * fontScale,
                fontWeight: FontWeight.w600,
                height: 1,
                color: labelColor,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 28 * fontScale,
              height: 28 * fontScale,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: today ? AppColors.primary : null,
                shape: BoxShape.circle,
                border:
                    selected && !today
                        ? Border.all(color: AppColors.primary, width: 1.5)
                        : null,
              ),
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 14 * fontScale,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  color: numberColor,
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 44 * fontScale,
              child: Align(
                alignment: Alignment.topCenter,
                child: _DayMarks(tasks: tasks, fontScale: fontScale),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayMarks extends StatelessWidget {
  const _DayMarks({required this.tasks, required this.fontScale});

  final List<ProcessScheduleTask> tasks;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const SizedBox.shrink();
    final List<ProcessScheduleTask> shown = tasks.take(2).toList();
    return Column(
      children: [
        for (final ProcessScheduleTask task in shown)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Column(
              children: [
                Container(
                  width: 18,
                  height: 3,
                  decoration: BoxDecoration(
                    color: task.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  processTaskLabel(task),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10 * fontScale,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        if (tasks.length > shown.length)
          Text(
            '+${tasks.length - shown.length}',
            style: TextStyle(
              fontSize: 9 * fontScale,
              height: 1,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }
}

/// 고른 날의 제목과, 그 날짜를 따라가는 아래 내용을 한 면에 둔다.
class ProcessDayPanel extends StatelessWidget {
  const ProcessDayPanel({
    super.key,
    required this.day,
    required this.fontScale,
    required this.isToday,
    required this.todayLabel,
    this.detail,
  });

  final DateTime day;
  final double fontScale;
  final bool isToday;
  final String todayLabel;
  final Widget? detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isToday ? '오늘' : '${'월화수목금토일'[day.weekday - 1]}요일',
          style: TextStyle(
            fontSize: 12 * fontScale,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          isToday ? todayLabel : '${day.month}월 ${day.day}일',
          style: TextStyle(
            fontSize: 20 * fontScale,
            fontWeight: FontWeight.w700,
            height: 1.25,
            letterSpacing: -0.4,
            color: AppColors.textPrimary,
          ),
        ),
        if (detail != null) ...[const SizedBox(height: 16), detail!],
      ],
    );
  }
}
