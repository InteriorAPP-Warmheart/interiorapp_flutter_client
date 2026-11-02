import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_button.dart';
import 'package:interiorapp_flutter_client/core/widget/calendar/app_calendar_date.dart';
import 'package:interiorapp_flutter_client/core/widget/calendar/app_month_calendar.dart';
import 'package:interiorapp_flutter_client/core/widget/calendar/app_range_calendar.dart';

/// 한 달을 넘기며 날짜 하나를 고른다.
Future<DateTime?> showAppCalendarDialog({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  String title = '날짜',
}) {
  final AppWindow window = AppWindow.of(context);
  final double maxWidth = window.isExpanded ? 420 : 360;
  return showDialog<DateTime>(
    context: context,
    builder: (BuildContext context) {
      return _CalendarDialogShell(
        maxWidth: maxWidth,
        child: _SingleDateDialog(
          title: title,
          initialDate: initialDate ?? DateTime.now(),
          firstDate: firstDate,
          lastDate: lastDate,
        ),
      );
    },
  );
}

/// 여러 달을 보면서 기간을 고른다.
Future<DateTimeRange?> showAppDateRangeDialog({
  required BuildContext context,
  DateTimeRange? initialRange,
  DateTime? firstDate,
  DateTime? lastDate,
  String title = '기간',
}) {
  final AppWindow window = AppWindow.of(context);
  final double maxWidth =
      window.isExpanded
          ? 760
          : window.isMedium
          ? 520
          : 400;
  final double height = MediaQuery.sizeOf(context).height * 0.78;
  return showDialog<DateTimeRange>(
    context: context,
    builder: (BuildContext context) {
      return _CalendarDialogShell(
        maxWidth: maxWidth,
        height: height,
        child: _RangeDateDialog(
          title: title,
          initialRange: initialRange,
          firstDate: firstDate,
          lastDate: lastDate,
        ),
      );
    },
  );
}

class _CalendarDialogShell extends StatelessWidget {
  const _CalendarDialogShell({
    required this.maxWidth,
    required this.child,
    this.height,
  });

  final double maxWidth;
  final double? height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(height: height, child: child),
      ),
    );
  }
}

class _SingleDateDialog extends StatefulWidget {
  const _SingleDateDialog({
    required this.title,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final String title;
  final DateTime initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  State<_SingleDateDialog> createState() => _SingleDateDialogState();
}

class _SingleDateDialogState extends State<_SingleDateDialog> {
  late DateTime _month;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = appCalendarDate(widget.initialDate);
    _month = appCalendarMonth(_selected);
  }

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 18 * fontScale,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed:
                    () => setState(() {
                      _month = appCalendarAddMonths(_month, -1);
                    }),
                icon: const Icon(Icons.chevron_left),
                color: AppColors.textPrimary,
              ),
              Expanded(
                child: Text(
                  '${_month.year}년 ${_month.month}월',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15 * fontScale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed:
                    () => setState(() {
                      _month = appCalendarAddMonths(_month, 1);
                    }),
                icon: const Icon(Icons.chevron_right),
                color: AppColors.textPrimary,
              ),
            ],
          ),
          AppMonthCalendar(
            month: _month,
            selected: _selected,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            onDayTap: (DateTime day) => setState(() => _selected = day),
          ),
          const SizedBox(height: 12),
          _DialogActions(
            onCancel: () => Navigator.pop(context),
            onConfirm: () => Navigator.pop(context, _selected),
          ),
        ],
      ),
    );
  }
}

class _RangeDateDialog extends StatefulWidget {
  const _RangeDateDialog({
    required this.title,
    required this.initialRange,
    required this.firstDate,
    required this.lastDate,
  });

  final String title;
  final DateTimeRange? initialRange;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  State<_RangeDateDialog> createState() => _RangeDateDialogState();
}

class _RangeDateDialogState extends State<_RangeDateDialog> {
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    final DateTimeRange? initial = widget.initialRange;
    if (initial != null) {
      _start = appCalendarDate(initial.start);
      _end = appCalendarDate(initial.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final DateTime? start = _start;
    final DateTime? end = _end;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 18 * fontScale,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          start == null || end == null
              ? Text(
                '시작 날짜를 누르고, 이어서 끝나는 날짜를 누르세요.',
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  height: 1.35,
                  color: AppColors.textSecondary,
                ),
              )
              : _SelectedRange(start: start, end: end, fontScale: fontScale),
          const SizedBox(height: 4),
          Expanded(
            child: AppRangeCalendar(
              firstMonth: start ?? DateTime.now(),
              start: start,
              end: end,
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              onChanged: (DateTime nextStart, DateTime nextEnd) {
                setState(() {
                  _start = nextStart;
                  _end = nextEnd;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          _DialogActions(
            onCancel: () => Navigator.pop(context),
            onConfirm:
                start == null || end == null
                    ? null
                    : () => Navigator.pop(
                      context,
                      DateTimeRange(start: start, end: end),
                    ),
          ),
        ],
      ),
    );
  }
}

class _SelectedRange extends StatelessWidget {
  const _SelectedRange({
    required this.start,
    required this.end,
    required this.fontScale,
  });

  final DateTime start;
  final DateTime end;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final bool sameDay = appCalendarSameDay(start, end);
    final int days = end.difference(start).inDays + 1;
    final String length = sameDay ? '하루' : '총 $days일간';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            sameDay ? _dayLabel(start, withYear: true) : _spanLabel(start, end),
            style: TextStyle(
              fontSize: 16 * fontScale,
              height: 1.35,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          length,
          style: TextStyle(
            fontSize: 14 * fontScale,
            height: 1.35,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _spanLabel(DateTime start, DateTime end) {
    final bool sameYear = start.year == end.year;
    final String from = _dayLabel(start, withYear: true);
    final String to = _dayLabel(end, withYear: !sameYear);
    return '$from부터\n$to까지';
  }

  String _dayLabel(DateTime date, {required bool withYear}) {
    final String monthDay = '${date.month}월 ${date.day}일';
    if (!withYear) return monthDay;
    return '${date.year}년 $monthDay';
  }
}

class _DialogActions extends StatelessWidget {
  const _DialogActions({required this.onCancel, required this.onConfirm});

  final VoidCallback onCancel;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: '취소',
            variant: AppButtonVariant.secondary,
            onPressed: onCancel,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: AppButton(label: '적용', onPressed: onConfirm)),
      ],
    );
  }
}
