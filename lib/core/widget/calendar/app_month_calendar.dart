import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/calendar/app_calendar_date.dart';
import 'package:interiorapp_flutter_client/core/widget/calendar/app_calendar_span.dart';

/// 한 달 달력. 날짜를 고르거나, [spans]로 여러 날에 걸친 띠를 그린다.
class AppMonthCalendar extends StatelessWidget {
  const AppMonthCalendar({
    super.key,
    required this.month,
    this.selected,
    this.selectedDays = const <DateTime>{},
    this.rangeStart,
    this.rangeEnd,
    this.spans = const <AppCalendarSpan>[],
    this.onDayTap,
    this.onSpanTap,
    this.firstDate,
    this.lastDate,
    this.showAdjacentDays = true,
    this.showDayGrid = false,
    this.maxSpanLanes = 3,
  });

  final DateTime month;
  final DateTime? selected;
  final Set<DateTime> selectedDays;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final List<AppCalendarSpan> spans;
  final ValueChanged<DateTime>? onDayTap;
  final ValueChanged<AppCalendarSpan>? onSpanTap;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool showAdjacentDays;

  /// 요일과 날짜, 공정 띠 위를 칸으로 나눈다.
  final bool showDayGrid;
  final int maxSpanLanes;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final DateTime gridStart = appCalendarGridStart(month);
    final List<DateTime> weeks = <DateTime>[
      for (int week = 0; week < 6; week++)
        gridStart.add(Duration(days: week * 7)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WeekdayHeader(fontScale: fontScale, showDayGrid: showDayGrid),
        for (final DateTime weekStart in weeks)
          if (showAdjacentDays || _weekHasMonthDay(weekStart, month))
            _WeekRow(
              weekStart: weekStart,
              month: month,
              selected: selected,
              selectedDays: selectedDays,
              rangeStart: rangeStart,
              rangeEnd: rangeEnd,
              spans: spans,
              onDayTap: onDayTap,
              onSpanTap: onSpanTap,
              firstDate: firstDate,
              lastDate: lastDate,
              showAdjacentDays: showAdjacentDays,
              showDayGrid: showDayGrid,
              maxSpanLanes: maxSpanLanes,
              fontScale: fontScale,
            ),
      ],
    );
  }
}

bool _weekHasMonthDay(DateTime weekStart, DateTime month) {
  for (int day = 0; day < 7; day++) {
    if (appCalendarSameMonth(weekStart.add(Duration(days: day)), month)) {
      return true;
    }
  }
  return false;
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader({required this.fontScale, required this.showDayGrid});

  final double fontScale;
  final bool showDayGrid;

  @override
  Widget build(BuildContext context) {
    final Widget labels = Row(
      children: [
        for (int i = 0; i < appCalendarWeekdays.length; i++)
          Expanded(
            child: Text(
              appCalendarWeekdays[i],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: (showDayGrid ? 12 : 13) * fontScale,
                fontWeight: FontWeight.w600,
                height: 1,
                letterSpacing: showDayGrid ? 0.4 : 0,
                color:
                    i == 0
                        ? AppColors.error
                        : i == 6
                        ? AppColors.primary
                        : AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
    if (!showDayGrid) {
      return Padding(padding: const EdgeInsets.only(bottom: 4), child: labels);
    }
    return SizedBox(
      height: 36 * fontScale,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: labels,
      ),
    );
  }
}

class _WeekRow extends StatelessWidget {
  const _WeekRow({
    required this.weekStart,
    required this.month,
    required this.selected,
    required this.selectedDays,
    required this.rangeStart,
    required this.rangeEnd,
    required this.spans,
    required this.onDayTap,
    required this.onSpanTap,
    required this.firstDate,
    required this.lastDate,
    required this.showAdjacentDays,
    required this.showDayGrid,
    required this.maxSpanLanes,
    required this.fontScale,
  });

  final DateTime weekStart;
  final DateTime month;
  final DateTime? selected;
  final Set<DateTime> selectedDays;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final List<AppCalendarSpan> spans;
  final ValueChanged<DateTime>? onDayTap;
  final ValueChanged<AppCalendarSpan>? onSpanTap;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool showAdjacentDays;
  final bool showDayGrid;
  final int maxSpanLanes;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    if (showDayGrid) {
      return _ScheduleWeek(
        weekStart: weekStart,
        month: month,
        spans: spans,
        onSpanTap: onSpanTap,
        fontScale: fontScale,
      );
    }
    final AppCalendarWeekLayout layout = layoutAppCalendarWeek(
      weekStart: weekStart,
      spans: spans,
      maxLanes: maxSpanLanes,
    );
    final double barHeight = 15 * fontScale;
    final double barGap = 2;
    final int lanes = layout.laneCount;
    final double bandHeight =
        lanes == 0 ? 0 : lanes * barHeight + (lanes - 1) * barGap;
    final bool overflow = layout.hiddenByColumn.any((int count) => count > 0);
    final int firstInMonth = _firstInMonthColumn(weekStart, month);
    final int lastInMonth = _lastInMonthColumn(weekStart, month);

    final double bandBlock = bandHeight + (overflow ? barHeight + barGap : 0);
    final double dayRowHeight = 40 * fontScale;
    final Widget days = SizedBox(
      height: dayRowHeight,
      child: Row(
        children: [
          for (int col = 0; col < 7; col++)
            Expanded(
              child: DecoratedBox(
                decoration: _cellBorder(
                  showDayGrid: showDayGrid,
                  inMonth: _columnInMonth(weekStart, month, col),
                  edge: _GridEdge.day,
                ),
                child: _DayCell(
                  day: weekStart.add(Duration(days: col)),
                  month: month,
                  selected: selected,
                  selectedDays: selectedDays,
                  rangeStart: rangeStart,
                  rangeEnd: rangeEnd,
                  onDayTap: onDayTap,
                  firstDate: firstDate,
                  lastDate: lastDate,
                  showAdjacentDays: showAdjacentDays,
                  fontScale: fontScale,
                ),
              ),
            ),
        ],
      ),
    );
    final Widget bands =
        bandBlock == 0
            ? const SizedBox.shrink()
            : LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double colWidth = constraints.maxWidth / 7;
                return SizedBox(
                  height: bandBlock,
                  child: Stack(
                    children: [
                      for (final AppCalendarSpanPiece piece in layout.pieces)
                        if (_overlapsMonth(
                          piece.startCol,
                          piece.endCol,
                          firstInMonth,
                          lastInMonth,
                        ))
                          Positioned(
                            left:
                                _clampedStart(piece.startCol, firstInMonth) *
                                    colWidth +
                                1,
                            width:
                                (_clampedEnd(piece.endCol, lastInMonth) -
                                        _clampedStart(
                                          piece.startCol,
                                          firstInMonth,
                                        ) +
                                        1) *
                                    colWidth -
                                2,
                            top: piece.lane * (barHeight + barGap),
                            height: barHeight,
                            child: _SpanBar(
                              piece: piece,
                              fontScale: fontScale,
                              onTap:
                                  onSpanTap == null
                                      ? null
                                      : () => onSpanTap!(piece.span),
                            ),
                          ),
                      if (overflow)
                        for (int col = 0; col < 7; col++)
                          if (layout.hiddenByColumn[col] > 0)
                            Positioned(
                              left: col * colWidth,
                              width: colWidth,
                              top: layout.laneCount * (barHeight + barGap),
                              height: barHeight,
                              child: Text(
                                '+${layout.hiddenByColumn[col]}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10 * fontScale,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                      if (showDayGrid)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Row(
                              children: [
                                for (int col = 0; col < 7; col++)
                                  Expanded(
                                    child: DecoratedBox(
                                      decoration: _cellBorder(
                                        showDayGrid: true,
                                        inMonth: _columnInMonth(
                                          weekStart,
                                          month,
                                          col,
                                        ),
                                        edge: _GridEdge.band,
                                      ),
                                      child: const SizedBox.expand(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );

    final Widget week = Column(children: [days, if (bandBlock > 0) bands]);
    return Padding(
      padding: EdgeInsets.only(bottom: showDayGrid ? 10 : 4),
      child: week,
    );
  }
}

enum _GridEdge { day, band }

BoxDecoration _cellBorder({
  required bool showDayGrid,
  required bool inMonth,
  required _GridEdge edge,
}) {
  if (!showDayGrid || !inMonth) return const BoxDecoration();
  const BorderSide side = BorderSide(color: AppColors.border);
  return BoxDecoration(
    border: Border(
      left: side,
      right: side,
      top: edge == _GridEdge.day ? side : BorderSide.none,
      bottom: side,
    ),
  );
}

bool _columnInMonth(DateTime weekStart, DateTime month, int column) {
  return appCalendarSameMonth(weekStart.add(Duration(days: column)), month);
}

int _firstInMonthColumn(DateTime weekStart, DateTime month) {
  for (int column = 0; column < 7; column++) {
    if (_columnInMonth(weekStart, month, column)) return column;
  }
  return 0;
}

int _lastInMonthColumn(DateTime weekStart, DateTime month) {
  for (int column = 6; column >= 0; column--) {
    if (_columnInMonth(weekStart, month, column)) return column;
  }
  return 6;
}

bool _overlapsMonth(int start, int end, int first, int last) {
  return end >= first && start <= last;
}

int _clampedStart(int start, int first) => start < first ? first : start;

int _clampedEnd(int end, int last) => end > last ? last : end;

/// 공정표용 한 주. 날짜와 공정 칸이 한 격자로 이어지고, 다른 달 날짜는 흐리게 둔다.
class _ScheduleWeek extends StatelessWidget {
  const _ScheduleWeek({
    required this.weekStart,
    required this.month,
    required this.spans,
    required this.onSpanTap,
    required this.fontScale,
  });

  final DateTime weekStart;
  final DateTime month;
  final List<AppCalendarSpan> spans;
  final ValueChanged<AppCalendarSpan>? onSpanTap;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final AppCalendarWeekLayout layout = layoutAppCalendarWeek(
      weekStart: weekStart,
      spans: spans,
    );
    final double dateHeight = 32 * fontScale;
    final double barHeight = 14 * fontScale;
    final double laneGap = 8 * fontScale;
    final double bandPad = 14 * fontScale;
    final int lanes = layout.laneCount == 0 ? 1 : layout.laneCount;
    final double bandHeight =
        bandPad * 2 + lanes * barHeight + (lanes - 1) * laneGap;
    final bool overflow = layout.hiddenByColumn.any((int count) => count > 0);
    final bool hasNextWeek = _weekHasMonthDay(
      weekStart.add(const Duration(days: 7)),
      month,
    );

    return SizedBox(
      height: dateHeight + bandHeight,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double columnWidth = constraints.maxWidth / 7;
          return Stack(
            children: [
              Positioned.fill(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int column = 0; column < 7; column++)
                      Expanded(
                        child: _ScheduleDayColumn(
                          day: weekStart.add(Duration(days: column)),
                          inMonth: _columnInMonth(weekStart, month, column),
                          fontScale: fontScale,
                          dateHeight: dateHeight,
                          drawRight: column < 6,
                          drawBottom: hasNextWeek,
                        ),
                      ),
                  ],
                ),
              ),
              for (final AppCalendarSpanPiece piece in layout.pieces)
                Positioned(
                  left:
                      piece.startCol * columnWidth +
                      (piece.continuesBefore ? 0 : 5),
                  width:
                      (piece.endCol - piece.startCol + 1) * columnWidth -
                      (piece.continuesBefore ? 0 : 5) -
                      (piece.continuesAfter ? 0 : 5),
                  top:
                      dateHeight + bandPad + piece.lane * (barHeight + laneGap),
                  height: barHeight,
                  child: _SpanBar(
                    piece: piece,
                    fontScale: fontScale,
                    onTap:
                        onSpanTap == null ? null : () => onSpanTap!(piece.span),
                  ),
                ),
              if (overflow)
                for (int column = 0; column < 7; column++)
                  if (layout.hiddenByColumn[column] > 0)
                    Positioned(
                      left: column * columnWidth,
                      width: columnWidth,
                      top: dateHeight + bandHeight - bandPad,
                      height: bandPad,
                      child: Text(
                        '+${layout.hiddenByColumn[column]}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10 * fontScale,
                          height: 1,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}

class _ScheduleDayColumn extends StatelessWidget {
  const _ScheduleDayColumn({
    required this.day,
    required this.inMonth,
    required this.fontScale,
    required this.dateHeight,
    required this.drawRight,
    required this.drawBottom,
  });

  final DateTime day;
  final bool inMonth;
  final double fontScale;
  final double dateHeight;
  final bool drawRight;
  final bool drawBottom;

  static const BorderSide _line = BorderSide(color: AppColors.border);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: inMonth ? AppColors.surface : const Color(0xFFF7F8FA),
        border: Border(
          right: drawRight ? _line : BorderSide.none,
          bottom: drawBottom ? _line : BorderSide.none,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: dateHeight,
            child: DecoratedBox(
              decoration: const BoxDecoration(border: Border(bottom: _line)),
              child: _ScheduleDate(
                day: day,
                inMonth: inMonth,
                fontScale: fontScale,
              ),
            ),
          ),
          const Expanded(child: SizedBox.expand()),
        ],
      ),
    );
  }
}

class _ScheduleDate extends StatelessWidget {
  const _ScheduleDate({
    required this.day,
    required this.inMonth,
    required this.fontScale,
  });

  final DateTime day;
  final bool inMonth;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final bool today = inMonth && appCalendarSameDay(day, DateTime.now());
    final Color base =
        day.weekday == DateTime.sunday
            ? AppColors.error
            : day.weekday == DateTime.saturday
            ? AppColors.primary
            : AppColors.textPrimary;
    final Color color = inMonth ? base : base.withValues(alpha: 0.35);
    return Center(
      child: Container(
        width: 24 * fontScale,
        height: 24 * fontScale,
        alignment: Alignment.center,
        decoration:
            today
                ? const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                )
                : null,
        child: Text(
          '${day.day}',
          style: TextStyle(
            fontSize: 13 * fontScale,
            height: 1,
            fontWeight: today ? FontWeight.w700 : FontWeight.w600,
            color: today ? AppColors.white : color,
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.month,
    required this.selected,
    required this.selectedDays,
    required this.rangeStart,
    required this.rangeEnd,
    required this.onDayTap,
    required this.firstDate,
    required this.lastDate,
    required this.showAdjacentDays,
    required this.fontScale,
  });

  final DateTime day;
  final DateTime month;
  final DateTime? selected;
  final Set<DateTime> selectedDays;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final ValueChanged<DateTime>? onDayTap;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool showAdjacentDays;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final bool inMonth = appCalendarSameMonth(day, month);
    if (!inMonth && !showAdjacentDays) return const SizedBox.expand();

    final bool enabled =
        onDayTap != null && appCalendarWithin(day, firstDate, lastDate);
    final bool isSelected =
        (selected != null && appCalendarSameDay(day, selected!)) ||
        selectedDays.any((DateTime item) => appCalendarSameDay(day, item));
    final bool isStart =
        rangeStart != null && appCalendarSameDay(day, rangeStart!);
    final bool isEnd = rangeEnd != null && appCalendarSameDay(day, rangeEnd!);
    final bool inRange = appCalendarInRange(day, rangeStart, rangeEnd);
    final bool endpoint = isStart || isEnd || isSelected;
    final bool today = appCalendarSameDay(day, DateTime.now());

    final Color numberColor =
        endpoint
            ? AppColors.white
            : _numberColor(
              day,
              inMonth: inMonth,
              enabled: enabled || onDayTap == null,
            );

    return GestureDetector(
      onTap: enabled ? () => onDayTap!(appCalendarDate(day)) : null,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (inRange && !endpoint)
            const Positioned.fill(child: ColoredBox(color: Color(0x140B1F38))),
          Container(
            width: 32 * fontScale,
            height: 32 * fontScale,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: endpoint ? AppColors.primary : null,
              shape: BoxShape.circle,
              border:
                  today && !endpoint
                      ? Border.all(color: AppColors.primary, width: 1)
                      : null,
            ),
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 15 * fontScale,
                height: 1,
                fontWeight:
                    endpoint || today ? FontWeight.w700 : FontWeight.w500,
                color: numberColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _numberColor(
    DateTime day, {
    required bool inMonth,
    required bool enabled,
  }) {
    final Color base =
        day.weekday == DateTime.sunday
            ? AppColors.error
            : day.weekday == DateTime.saturday
            ? AppColors.primary
            : AppColors.textPrimary;
    if (!inMonth || !enabled) return base.withValues(alpha: 0.35);
    return base;
  }
}

class _SpanBar extends StatelessWidget {
  const _SpanBar({
    required this.piece,
    required this.fontScale,
    required this.onTap,
  });

  final AppCalendarSpanPiece piece;
  final double fontScale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color label =
        piece.span.color.computeLuminance() > 0.55
            ? AppColors.textPrimary
            : AppColors.white;
    final BorderRadius radius = BorderRadius.horizontal(
      left: Radius.circular(piece.continuesBefore ? 3 : 7 * fontScale),
      right: Radius.circular(piece.continuesAfter ? 3 : 7 * fontScale),
    );
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: piece.span.color,
          borderRadius: radius,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              piece.span.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11 * fontScale,
                height: 1,
                fontWeight: FontWeight.w600,
                color: label,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
