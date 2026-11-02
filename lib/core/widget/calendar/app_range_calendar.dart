import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/calendar/app_calendar_date.dart';
import 'package:interiorapp_flutter_client/core/widget/calendar/app_month_calendar.dart';

/// 여러 달을 이어서 스크롤하며 기간을 고른다.
///
/// 처음 누른 날이 시작이고, 다음 날이 끝이다. 기간이 잡힌 뒤 다시 누르면 새로 시작한다.
/// 연월을 달력 위에 같이 적고, 옆 달 날짜는 비워 둔다.
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
  final ScrollController _scroll = ScrollController();
  final GlobalKey _anchorKey = GlobalKey();
  bool _anchored = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _tap(DateTime day) {
    final (DateTime start, DateTime end) = appCalendarNextRange(
      widget.start,
      widget.end,
      day,
    );
    widget.onChanged?.call(start, end);
  }

  List<DateTime> _months() {
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

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final List<DateTime> months = _months();
    final DateTime? focus = widget.start ?? widget.end;
    final bool wide = MediaQuery.sizeOf(context).width >= 720;
    if (!_anchored) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_anchored || !mounted) return;
        _anchored = true;
        final BuildContext? anchor = _anchorKey.currentContext;
        if (anchor == null) return;
        Scrollable.ensureVisible(anchor, alignment: 0.02);
      });
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Widget content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _sections(
            months: months,
            wide: wide,
            fontScale: fontScale,
            focus: focus,
          ),
        );
        if (!constraints.maxHeight.isFinite) return content;
        return SingleChildScrollView(
          controller: _scroll,
          padding: const EdgeInsets.only(bottom: 12),
          child: content,
        );
      },
    );
  }

  List<Widget> _sections({
    required List<DateTime> months,
    required bool wide,
    required double fontScale,
    required DateTime? focus,
  }) {
    final List<Widget> children = <Widget>[];
    if (!wide) {
      children.addAll(
        months.map((DateTime month) => _month(month, fontScale, focus)),
      );
      return children;
    }
    for (int slot = 0; slot < months.length; slot += 2) {
      final DateTime left = months[slot];
      final DateTime? right =
          slot + 1 < months.length ? months[slot + 1] : null;
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _month(left, fontScale, focus)),
              const SizedBox(width: 20),
              Expanded(
                child:
                    right == null
                        ? const SizedBox()
                        : _month(right, fontScale, focus),
              ),
            ],
          ),
        ),
      );
    }
    return children;
  }

  Widget _month(DateTime month, double fontScale, DateTime? focus) {
    return _MonthBlock(
      key:
          focus != null && appCalendarSameMonth(month, focus)
              ? _anchorKey
              : ValueKey<DateTime>(month),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 4, 8),
            child: Text(
              '${month.year}년 ${month.month}월',
              style: TextStyle(
                fontSize: 17 * fontScale,
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
