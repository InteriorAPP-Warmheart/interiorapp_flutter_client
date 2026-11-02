import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/process_schedule.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/calendar/app_calendar.dart';

/// 월 달력 위에 공정 기간을 띠로 올린다. 좌우로 넘기면 달이 바뀐다.
class ProcessScheduleCalendar extends StatefulWidget {
  const ProcessScheduleCalendar({
    super.key,
    required this.month,
    required this.tasks,
    required this.onMonthChanged,
  });

  final DateTime month;
  final List<ProcessScheduleTask> tasks;
  final ValueChanged<DateTime> onMonthChanged;

  @override
  State<ProcessScheduleCalendar> createState() =>
      _ProcessScheduleCalendarState();
}

class _ProcessScheduleCalendarState extends State<ProcessScheduleCalendar> {
  static final DateTime _origin = DateTime(2016, 1, 1);
  static const int _monthCount = 12 * 40;

  late final PageController _pages;
  bool _fromPager = false;

  @override
  void initState() {
    super.initState();
    _pages = PageController(initialPage: _indexOf(widget.month));
  }

  @override
  void didUpdateWidget(ProcessScheduleCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (appCalendarSameMonth(oldWidget.month, widget.month)) return;
    if (_fromPager) {
      _fromPager = false;
      return;
    }
    final int page = _indexOf(widget.month);
    if (!_pages.hasClients) return;
    final int current = _pages.page?.round() ?? _pages.initialPage;
    if (current == page) return;
    _pages.animateToPage(
      page,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  int _indexOf(DateTime month) {
    final int index =
        (month.year - _origin.year) * 12 + month.month - _origin.month;
    if (index < 0) return 0;
    if (index >= _monthCount) return _monthCount - 1;
    return index;
  }

  DateTime _monthOf(int index) {
    return DateTime(_origin.year, _origin.month + index, 1);
  }

  void _onPageChanged(int index) {
    final DateTime next = _monthOf(index);
    if (appCalendarSameMonth(next, widget.month)) return;
    _fromPager = true;
    widget.onMonthChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final List<AppCalendarSpan> spans = processTaskSpans(widget.tasks);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed:
                  () => widget.onMonthChanged(
                    appCalendarAddMonths(widget.month, -1),
                  ),
              icon: const Icon(Icons.chevron_left),
              color: AppColors.textPrimary,
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: Text(
                '${widget.month.year}년 ${widget.month.month}월',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16 * fontScale,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            IconButton(
              onPressed:
                  () => widget.onMonthChanged(
                    appCalendarAddMonths(widget.month, 1),
                  ),
              icon: const Icon(Icons.chevron_right),
              color: AppColors.textPrimary,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: PageView.builder(
            controller: _pages,
            itemCount: _monthCount,
            onPageChanged: _onPageChanged,
            itemBuilder: (BuildContext context, int index) {
              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Material(
                  color: AppColors.surface,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: AppMonthCalendar(
                    month: _monthOf(index),
                    spans: spans,
                    showAdjacentDays: false,
                    showDayGrid: true,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
