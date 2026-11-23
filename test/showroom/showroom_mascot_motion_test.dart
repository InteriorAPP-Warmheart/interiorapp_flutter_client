import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/mascot/showroom_mascot.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/mascot/showroom_mascot_assets.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/mascot/showroom_mascot_figure.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/mascot/showroom_mascot_motion.dart';

void main() {
  test('끝 구간 안에서 멈추고 최소 이동을 지킨다', () {
    const double left = 56;
    const double right = 320;
    const double from = 188;

    final double near = showroomMascotFleeTarget(
      from: from,
      toRight: true,
      left: left,
      right: right,
      roll: 0,
    );
    final double edge = showroomMascotFleeTarget(
      from: from,
      toRight: true,
      left: left,
      right: right,
      roll: 1,
    );

    expect(near, greaterThanOrEqualTo(from + showroomMascotMinTravel));
    expect(right - near, lessThanOrEqualTo(showroomMascotEdgeBand));
    expect(edge, right);
    expect(near, lessThanOrEqualTo(edge));
  });

  test('왼쪽 끝도 여백 안에서 랜덤하게 멈춘다', () {
    const double left = 56;
    const double right = 320;
    const double from = 188;

    final double far = showroomMascotFleeTarget(
      from: from,
      toRight: false,
      left: left,
      right: right,
      roll: 1,
    );
    final double edge = showroomMascotFleeTarget(
      from: from,
      toRight: false,
      left: left,
      right: right,
      roll: 0,
    );

    expect(from - far, greaterThanOrEqualTo(showroomMascotMinTravel));
    expect(far - left, lessThanOrEqualTo(showroomMascotEdgeBand));
    expect(edge, left);
  });

  test('이미 끝 근처면 더 나가지 않는다', () {
    expect(
      showroomMascotFleeTarget(
        from: 300,
        toRight: true,
        left: 56,
        right: 310,
        roll: 0.2,
      ),
      310,
    );
    expect(
      showroomMascotFleeTarget(
        from: 70,
        toRight: false,
        left: 56,
        right: 320,
        roll: 0.8,
      ),
      56,
    );
  });

  test('두리번은 왼쪽, 정면, 오른쪽 순이다', () {
    expect(
      showroomMascotFrame(ShowroomMascotPose.looking, 0),
      showroomMascotLookLeft,
    );
    expect(
      showroomMascotFrame(ShowroomMascotPose.looking, 0.34),
      showroomMascotLookFront,
    );
    expect(
      showroomMascotFrame(ShowroomMascotPose.looking, 0.7),
      showroomMascotLookRight,
    );
    expect(
      showroomMascotFrame(ShowroomMascotPose.looking, 1),
      showroomMascotLookRight,
    );
  });

  test('달리기는 네 프레임을 순서대로 돈다', () {
    expect(
      showroomMascotFrame(ShowroomMascotPose.running, 0),
      showroomMascotRunFrames[0],
    );
    expect(
      showroomMascotFrame(ShowroomMascotPose.running, 0.25),
      showroomMascotRunFrames[1],
    );
    expect(
      showroomMascotFrame(ShowroomMascotPose.running, 0.5),
      showroomMascotRunFrames[2],
    );
    expect(
      showroomMascotFrame(ShowroomMascotPose.running, 0.75),
      showroomMascotRunFrames[3],
    );
  });

  test('안심 뒤에는 행복으로 넘어가는 프레임을 쓴다', () {
    expect(
      showroomMascotFrame(ShowroomMascotPose.relief, 0),
      showroomMascotRelief,
    );
    expect(
      showroomMascotFrame(ShowroomMascotPose.settling, 0),
      showroomMascotHappyTransition,
    );
    expect(
      showroomMascotFrame(ShowroomMascotPose.sitting, 0),
      showroomMascotHappySit,
    );
  });

  test('첫 도주는 랜덤이고 다음부터는 진행 방향의 반대다', () {
    expect(
      showroomMascotFleeRight(headingRight: null, openingRight: true),
      isTrue,
    );
    expect(
      showroomMascotFleeRight(headingRight: null, openingRight: false),
      isFalse,
    );
    expect(
      showroomMascotFleeRight(headingRight: true, openingRight: false),
      isFalse,
    );
    expect(
      showroomMascotFleeRight(headingRight: false, openingRight: true),
      isTrue,
    );
  });

  test('폰은 뒤로가기를 비우고 태블릿은 더 멀리 달린다', () {
    final ShowroomMascotLayout phone = showroomMascotLayout(
      width: 360,
      topInset: 47,
      toolbarHeight: 56,
      textScale: 1,
    );
    final ShowroomMascotLayout tablet = showroomMascotLayout(
      width: 900,
      topInset: 24,
      toolbarHeight: 64,
      textScale: 1,
    );
    final ShowroomMascotLayout largeText = showroomMascotLayout(
      width: 390,
      topInset: 47,
      toolbarHeight: 56,
      textScale: 2,
    );

    expect(phone.figure, lessThanOrEqualTo(56));
    expect(phone.left, greaterThanOrEqualTo(56));
    expect(phone.right, greaterThan(phone.left));
    expect(phone.overlayHeight, 47 + 56);
    expect(tablet.minTravel, greaterThan(phone.minTravel));
    expect(tablet.figure, lessThanOrEqualTo(64));
    expect(largeText.left, greaterThan(phone.left));

    final ShowroomMascotLayout reserved = showroomMascotLayout(
      width: 360,
      topInset: 47,
      toolbarHeight: 56,
      textScale: 1,
      reservedRight: showroomMascotActionSlot,
    );
    expect(reserved.right, lessThan(phone.right));
    expect(reserved.right + reserved.figure, lessThanOrEqualTo(360 - 56));
  });

  test('접힘선 위에는 멈추지 않는다', () {
    expect(
      showroomMascotAvoidSpans(
        target: 400,
        figure: 50,
        left: 56,
        right: 700,
        toRight: true,
        blocked: const <ShowroomMascotSpan>[ShowroomMascotSpan(390, 410)],
      ),
      410,
    );
    expect(
      showroomMascotAvoidSpans(
        target: 400,
        figure: 50,
        left: 56,
        right: 700,
        toRight: false,
        blocked: const <ShowroomMascotSpan>[ShowroomMascotSpan(390, 410)],
      ),
      340,
    );
  });

  testWidgets('3초 뒤 나타나 앉고, 누르면 달렸다가 다시 앉는다', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ShowroomMascot())),
    );
    expect(find.byType(ShowroomMascotFigure), findsNothing);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 560));
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.byType(ShowroomMascotFigure), findsOneWidget);

    await tester.tap(find.byType(ShowroomMascotFigure));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 180));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 720));
    expect(find.byType(ShowroomMascotFigure), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('떨어지거나 달리는 중에 눌러도 다시 놀란다', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ShowroomMascot())),
    );

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ShowroomMascotFigure), findsOneWidget);
    await tester.tap(find.byType(ShowroomMascotFigure));
    await tester.pump();
    await tester.tap(find.byType(ShowroomMascotFigure));
    await tester.pump(const Duration(milliseconds: 220));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byType(ShowroomMascotFigure));
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.byType(ShowroomMascotFigure), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('앉으면 시계가 멈추고, 화면을 나가면 틱이 남지 않는다', (WidgetTester tester) async {
    final int baseline = SchedulerBinding.instance.transientCallbackCount;
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ShowroomMascot())),
    );
    await tester.pump();
    expect(SchedulerBinding.instance.transientCallbackCount, baseline);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump();
    expect(SchedulerBinding.instance.transientCallbackCount, baseline);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(ShowroomMascotFigure));
    await tester.pump();
    expect(
      SchedulerBinding.instance.transientCallbackCount,
      greaterThan(baseline),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(SchedulerBinding.instance.transientCallbackCount, baseline);
    expect(tester.takeException(), isNull);
  });
}
