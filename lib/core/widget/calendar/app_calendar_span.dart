import 'package:flutter/material.dart';

/// 여러 날에 걸친 일정 띠. 끝 날짜를 포함한다.
class AppCalendarSpan {
  const AppCalendarSpan({
    required this.id,
    required this.start,
    required this.end,
    required this.color,
    this.label = '',
  });

  final String id;
  final DateTime start;
  final DateTime end;
  final Color color;
  final String label;

  DateTime get from =>
      start.isBefore(end)
          ? DateTime(start.year, start.month, start.day)
          : DateTime(end.year, end.month, end.day);

  DateTime get to =>
      start.isBefore(end)
          ? DateTime(end.year, end.month, end.day)
          : DateTime(start.year, start.month, start.day);
}

class AppCalendarSpanPiece {
  const AppCalendarSpanPiece({
    required this.span,
    required this.startCol,
    required this.endCol,
    required this.lane,
    required this.continuesBefore,
    required this.continuesAfter,
  });

  final AppCalendarSpan span;
  final int startCol;
  final int endCol;
  final int lane;
  final bool continuesBefore;
  final bool continuesAfter;
}

class AppCalendarWeekLayout {
  const AppCalendarWeekLayout({
    required this.pieces,
    required this.hiddenByColumn,
    required this.laneCount,
  });

  final List<AppCalendarSpanPiece> pieces;

  /// 칸에 다 담지 못한 띠 수.
  final List<int> hiddenByColumn;
  final int laneCount;
}

/// [weekStart]는 월요일. 겹치는 띠는 아래로 쌓고, [maxLanes]를 넘기면 숨긴다.
AppCalendarWeekLayout layoutAppCalendarWeek({
  required DateTime weekStart,
  required List<AppCalendarSpan> spans,
  int maxLanes = 3,
}) {
  final DateTime start = DateTime(
    weekStart.year,
    weekStart.month,
    weekStart.day,
  );
  final DateTime weekEnd = start.add(const Duration(days: 6));
  final List<({AppCalendarSpan span, int startCol, int endCol})> clipped =
      <({AppCalendarSpan span, int startCol, int endCol})>[];

  for (final AppCalendarSpan span in spans) {
    if (span.to.isBefore(start) || span.from.isAfter(weekEnd)) continue;
    final DateTime clipStart = span.from.isBefore(start) ? start : span.from;
    final DateTime clipEnd = span.to.isAfter(weekEnd) ? weekEnd : span.to;
    clipped.add((
      span: span,
      startCol: clipStart.difference(start).inDays,
      endCol: clipEnd.difference(start).inDays,
    ));
  }

  clipped.sort((
    ({AppCalendarSpan span, int startCol, int endCol}) a,
    ({AppCalendarSpan span, int startCol, int endCol}) b,
  ) {
    final int byStart = a.startCol.compareTo(b.startCol);
    if (byStart != 0) return byStart;
    return (b.endCol - b.startCol).compareTo(a.endCol - a.startCol);
  });

  final List<int> laneEnds = <int>[];
  final List<AppCalendarSpanPiece> pieces = <AppCalendarSpanPiece>[];
  final List<int> hidden = List<int>.filled(7, 0);

  for (final ({AppCalendarSpan span, int startCol, int endCol}) item
      in clipped) {
    int lane = 0;
    while (lane < laneEnds.length && laneEnds[lane] >= item.startCol) {
      lane += 1;
    }
    if (lane >= maxLanes) {
      for (int col = item.startCol; col <= item.endCol; col++) {
        hidden[col] += 1;
      }
      continue;
    }
    if (lane == laneEnds.length) {
      laneEnds.add(item.endCol);
    } else {
      laneEnds[lane] = item.endCol;
    }
    pieces.add(
      AppCalendarSpanPiece(
        span: item.span,
        startCol: item.startCol,
        endCol: item.endCol,
        lane: lane,
        continuesBefore: item.span.from.isBefore(start),
        continuesAfter: item.span.to.isAfter(weekEnd),
      ),
    );
  }

  return AppCalendarWeekLayout(
    pieces: pieces,
    hiddenByColumn: hidden,
    laneCount: laneEnds.length,
  );
}
