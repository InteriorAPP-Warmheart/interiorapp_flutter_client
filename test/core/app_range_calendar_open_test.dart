import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interiorapp_flutter_client/core/widget/calendar/app_range_calendar.dart';

void main() {
  Future<void> pumpCalendar(
    WidgetTester tester, {
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: AppRangeCalendar(firstDate: firstDate, lastDate: lastDate),
      ),
    );
  }

  testWidgets('기록용 과거 기간은 이번 달만 먼저 그린다', (WidgetTester tester) async {
    final DateTime today = DateTime.now();
    final DateTime oldest = DateTime(today.year - 2, today.month, 1);
    await pumpCalendar(
      tester,
      firstDate: DateTime(today.year - 2, today.month, today.day),
      lastDate: today,
    );

    expect(find.text('${today.year}년 ${today.month}월'), findsOneWidget);
    expect(find.text('${oldest.year}년 ${oldest.month}월'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, 500));
    await tester.pumpAndSettle();

    final DateTime previous = DateTime(today.year, today.month - 1, 1);
    expect(find.text('${previous.year}년 ${previous.month}월'), findsOneWidget);
    expect(find.text('${oldest.year}년 ${oldest.month}월'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('상담준비용 미래 기간은 오늘 이후만 있고 맨 끝 달은 아직 그리지 않는다', (
    WidgetTester tester,
  ) async {
    final DateTime today = DateTime.now();
    final DateTime last = DateTime(today.year, today.month + 12, today.day);
    await pumpCalendar(tester, firstDate: today, lastDate: last);

    expect(find.text('${today.year}년 ${today.month}월'), findsOneWidget);
    expect(find.text('${last.year}년 ${last.month}월'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
