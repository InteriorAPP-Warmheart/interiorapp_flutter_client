const List<String> appCalendarWeekdays = <String>[
  '월',
  '화',
  '수',
  '목',
  '금',
  '토',
  '일',
];

DateTime appCalendarDate(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

bool appCalendarSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool appCalendarSameMonth(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month;
}

DateTime appCalendarMonth(DateTime value) {
  return DateTime(value.year, value.month);
}

DateTime appCalendarAddMonths(DateTime month, int count) {
  return DateTime(month.year, month.month + count);
}

/// 그 달 1일이 속한 주의 월요일.
DateTime appCalendarGridStart(DateTime month) {
  final DateTime first = DateTime(month.year, month.month, 1);
  return first.subtract(Duration(days: first.weekday - DateTime.monday));
}

bool appCalendarWithin(DateTime day, DateTime? first, DateTime? last) {
  final DateTime date = appCalendarDate(day);
  if (first != null && date.isBefore(appCalendarDate(first))) return false;
  if (last != null && date.isAfter(appCalendarDate(last))) return false;
  return true;
}

bool appCalendarInRange(DateTime day, DateTime? start, DateTime? end) {
  if (start == null || end == null) return false;
  final DateTime date = appCalendarDate(day);
  final DateTime from = appCalendarDate(start);
  final DateTime to = appCalendarDate(end);
  final DateTime first = from.isBefore(to) ? from : to;
  final DateTime last = from.isBefore(to) ? to : from;
  return !date.isBefore(first) && !date.isAfter(last);
}

/// 한 점만 고른 뒤 두 번째 날짜로 기간을 닫고, 기간이 있으면 다시 시작한다.
(DateTime, DateTime) appCalendarNextRange(
  DateTime? start,
  DateTime? end,
  DateTime tapped,
) {
  final DateTime day = appCalendarDate(tapped);
  if (start == null || end == null || !appCalendarSameDay(start, end)) {
    return (day, day);
  }
  final DateTime anchor = appCalendarDate(start);
  if (day.isBefore(anchor)) return (day, anchor);
  return (anchor, day);
}
