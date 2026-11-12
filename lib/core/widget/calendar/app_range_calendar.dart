import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/calendar/app_calendar_date.dart';
import 'package:interiorapp_flutter_client/core/widget/calendar/app_month_calendar.dart';

/// 여러 달을 이어서 스크롤하며 기간을 고른다.
///
/// 처음 누른 날이 시작이고, 다음 날이 끝이다. 기간이 잡힌 뒤 다시 누르면 새로 시작한다.
/// 연월을 달력 위에 같이 적고, 옆 달 날짜는 비워 둔다.
/// 화면에 보이는 달만 만들고, 그 이전 달은 위로 스크롤할 때 만든다.
class AppRangeCalendar extends StatefulWidget {
  const AppRangeCalendar({
    super.key,
    this.firstMonth,
    this.monthCount,
    this.start,
    this.end,
    this.onChanged,
    this.firstDate,
    this.lastDate,
  });

  final DateTime? firstMonth;

  /// 시작·끝 날짜가 없을 때만 쓴다. 비우면 1년을 이어서 보여 준다.
  final int? monthCount;
  final DateTime? start;
  final DateTime? end;
  final void Function(DateTime start, DateTime end)? onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  State<AppRangeCalendar> createState() => _AppRangeCalendarState();
}

class _AppRangeCalendarState extends State<AppRangeCalendar> {
  static const Key _centerKey = ValueKey<String>('range-calendar-anchor');

  late final List<DateTime> _months;
  late final int _anchorMonthIndex;

  @override
  void initState() {
    super.initState();
    _months = _monthList();
    _anchorMonthIndex = _resolveAnchor();
  }

  void _tap(DateTime day) {
    final (DateTime start, DateTime end) = appCalendarNextRange(
      widget.start,
      widget.end,
      day,
    );
    widget.onChanged?.call(start, end);
  }

  List<DateTime> _monthList() {
    final DateTime start = appCalendarMonth(
      widget.firstDate ?? widget.firstMonth ?? DateTime.now(),
    );
    final DateTime? lastBound = widget.lastDate;
    final DateTime end =
        lastBound == null
            ? appCalendarAddMonths(start, (widget.monthCount ?? 13) - 1)
            : appCalendarMonth(lastBound);
    final List<DateTime> months = <DateTime>[];
    for (
      DateTime month = start;
      !month.isAfter(end);
      month = appCalendarAddMonths(month, 1)
    ) {
      months.add(month);
    }
    return months;
  }

  /// 고른 달이 있으면 그 달, 없으면 오늘에 가장 가까운 달에서 스크롤이 시작한다.
  int _resolveAnchor() {
    if (_months.isEmpty) return 0;
    final DateTime focus = appCalendarMonth(
      widget.start ?? widget.end ?? DateTime.now(),
    );
    final int index = _months.indexWhere(
      (DateTime month) => appCalendarSameMonth(month, focus),
    );
    if (index >= 0) return index;
    if (focus.isBefore(_months.first)) return 0;
    return _months.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final bool wide = MediaQuery.sizeOf(context).width >= 720;
    final int rowSize = wide ? 2 : 1;
    final int rowCount = (_months.length / rowSize).ceil();
    final int anchorRow = _anchorMonthIndex ~/ rowSize;
    final int olderCount = anchorRow;
    final int newerCount = rowCount - anchorRow;
    return CustomScrollView(
      center: _centerKey,
      slivers: [
        if (olderCount > 0)
          SliverList.builder(
            itemCount: olderCount,
            itemBuilder: (BuildContext context, int index) {
              return _row(anchorRow - 1 - index, fontScale, wide);
            },
          ),
        SliverPadding(
          key: _centerKey,
          padding: const EdgeInsets.only(bottom: 12),
          sliver: SliverList.builder(
            itemCount: newerCount,
            itemBuilder: (BuildContext context, int index) {
              return _row(anchorRow + index, fontScale, wide);
            },
          ),
        ),
      ],
    );
  }

  Widget _row(int row, double fontScale, bool wide) {
    if (!wide) return _month(_months[row], fontScale);
    final int left = row * 2;
    final int right = left + 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _month(_months[left], fontScale)),
          const SizedBox(width: 20),
          Expanded(
            child:
                right < _months.length
                    ? _month(_months[right], fontScale)
                    : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _month(DateTime month, double fontScale) {
    return _MonthBlock(
      key: ValueKey<DateTime>(month),
      month: month,
      fontScale: fontScale,
      start: widget.start,
      end: widget.end,
      onDayTap: widget.onChanged == null ? null : _tap,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );
  }
}

class _MonthBlock extends StatelessWidget {
  const _MonthBlock({
    super.key,
    required this.month,
    required this.fontScale,
    required this.start,
    required this.end,
    required this.onDayTap,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime month;
  final double fontScale;
  final DateTime? start;
  final DateTime? end;
  final ValueChanged<DateTime>? onDayTap;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 4, 8),
            child: Text(
              '${month.year}년 ${month.month}월',
              style: TextStyle(
                fontSize: 17 * fontScale,
                height: 1,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          AppMonthCalendar(
            month: month,
            rangeStart: start,
            rangeEnd: end,
            onDayTap: onDayTap,
            firstDate: firstDate,
            lastDate: lastDate,
            showAdjacentDays: false,
          ),
        ],
      ),
    );
  }
}
