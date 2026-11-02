import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interiorapp_flutter_client/core/widget/calendar/app_calendar_date.dart';
import 'package:interiorapp_flutter_client/core/widget/calendar/app_calendar_span.dart';

void main() {
  test('기간 선택은 한 점 다음 기간, 그 다음엔 다시 시작한다', () {
    final DateTime first = DateTime(2026, 11, 2);
    final (DateTime a, DateTime b) = appCalendarNextRange(null, null, first);
    expect(a, first);
    expect(b, first);

    final (DateTime c, DateTime d) = appCalendarNextRange(
      a,
      b,
      DateTime(2026, 11, 8),
    );
    expect(c, DateTime(2026, 11, 2));
    expect(d, DateTime(2026, 11, 8));

    final (DateTime e, DateTime f) = appCalendarNextRange(
      a,
      b,
      DateTime(2026, 10, 28),
    );
    expect(e, DateTime(2026, 10, 28));
    expect(f, DateTime(2026, 11, 2));

    final (DateTime g, DateTime h) = appCalendarNextRange(
      c,
      d,
      DateTime(2026, 12, 1),
    );
    expect(g, DateTime(2026, 12, 1));
    expect(h, DateTime(2026, 12, 1));
  });

  test('한 주 안에서 겹치는 띠는 다른 줄에 놓인다', () {
    final DateTime monday = DateTime(2026, 11, 2);
    final AppCalendarWeekLayout layout = layoutAppCalendarWeek(
      weekStart: monday,
      spans: <AppCalendarSpan>[
        AppCalendarSpan(
          id: 'a',
          start: DateTime(2026, 11, 2),
          end: DateTime(2026, 11, 4),
          color: const Color(0xFF0B1F38),
          label: '철거',
        ),
        AppCalendarSpan(
          id: 'b',
          start: DateTime(2026, 11, 3),
          end: DateTime(2026, 11, 6),
          color: const Color(0xFF687A5E),
          label: '전기',
        ),
        AppCalendarSpan(
          id: 'c',
          start: DateTime(2026, 10, 30),
          end: DateTime(2026, 11, 3),
          color: const Color(0xFF3E5C76),
          label: '목공',
        ),
      ],
    );

    expect(layout.laneCount, 3);
    final AppCalendarSpanPiece continued = layout.pieces.firstWhere(
      (AppCalendarSpanPiece piece) => piece.span.id == 'c',
    );
    expect(continued.continuesBefore, isTrue);
    expect(continued.startCol, 0);
    expect(continued.endCol, 1);
    expect(
      layout.pieces.map((AppCalendarSpanPiece piece) => piece.lane).toSet(),
      <int>{0, 1, 2},
    );
  });
}
