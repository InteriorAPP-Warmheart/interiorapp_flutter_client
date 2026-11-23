import 'dart:math' as math;

/// 쇼룸 게시글 앱바에서 마스코트가 움직이는 거리 규칙.
///
/// 그림은 320px 정사각 스프라이트다. 앱바 칸에 맞춰 크기를 줄인다.
const double showroomMascotMinTravel = 64;

/// 선택한 끝에서 이 거리 안에서만 멈춘다.
const double showroomMascotEdgeBand = 56;

/// 앱바 오른쪽 아이콘 버튼 한 칸. 마스코트는 이 폭 안으로 들어가지 않는다.
const double showroomMascotActionSlot = 56;

/// 접힘선처럼 마스코트가 멈추면 안 되는 가로 구간.
class ShowroomMascotSpan {
  const ShowroomMascotSpan(this.start, this.end);

  final double start;
  final double end;
}

/// 화면 폭, 앱바 높이, 글자 크기, 안전 영역에 맞춘 이동 범위.
class ShowroomMascotLayout {
  const ShowroomMascotLayout({
    required this.figure,
    required this.left,
    required this.right,
    required this.minTravel,
    required this.edgeBand,
    required this.overlayHeight,
    required this.restY,
  });

  final double figure;
  final double left;
  final double right;
  final double minTravel;
  final double edgeBand;
  final double overlayHeight;
  final double restY;

  double get center => (left + right) / 2;
}

ShowroomMascotLayout showroomMascotLayout({
  required double width,
  required double topInset,
  required double toolbarHeight,
  required double textScale,
  double safeLeft = 0,
  double safeRight = 0,
  double reservedRight = 0,
}) {
  final double scale = textScale.clamp(1, 1.6).toDouble();
  final double bar = math.max(toolbarHeight, 1);
  final double figure = (bar * 0.92).clamp(math.min(36, bar), bar).toDouble();
  final double left = math.max(bar, math.max(48 * scale, safeLeft));
  final double tail = math.max(reservedRight, math.max(8, safeRight));
  final double rightLimit = width - tail - figure;
  final double right = rightLimit < left ? left : rightLimit;
  final double runway = right - left;
  return ShowroomMascotLayout(
    figure: figure,
    left: left,
    right: right,
    minTravel: math.min(runway, math.max(48, runway * 0.22)),
    edgeBand: math.min(runway, math.max(figure, runway * 0.28)),
    overlayHeight: topInset + bar,
    restY: topInset + (bar - figure) / 2,
  );
}

/// 초당 이동 거리.
const double showroomMascotRunSpeed = 220;

enum ShowroomMascotPose {
  falling,
  looking,
  sitting,
  startled,
  running,
  relief,
  settling,
}

/// 아직 방향이 없으면 첫 도주고, 있으면 진행 방향의 반대다.
bool showroomMascotFleeRight({
  required bool? headingRight,
  required bool openingRight,
}) {
  if (headingRight == null) return openingRight;
  return !headingRight;
}

/// 접힘선 위에 멈추지 않게 진행 방향 바깥으로 밀어 낸다.
double showroomMascotAvoidSpans({
  required double target,
  required double figure,
  required double left,
  required double right,
  required bool toRight,
  required List<ShowroomMascotSpan> blocked,
}) {
  double x = target;
  for (final ShowroomMascotSpan span in blocked) {
    final bool overlaps = x + figure > span.start && x < span.end;
    if (!overlaps) continue;
    x = toRight ? span.end : span.start - figure;
  }
  if (x < left) return left;
  if (x > right) return right;
  return x;
}

/// 끝으로 달리다가, 끝 여백과 최소 이동을 지킨 랜덤 위치에서 멈춘다.
///
/// [roll]은 0이면 끝에서 더 먼 쪽, 1이면 끝에 붙는다.
double showroomMascotFleeTarget({
  required double from,
  required bool toRight,
  required double left,
  required double right,
  required double roll,
  double minTravel = showroomMascotMinTravel,
  double edgeBand = showroomMascotEdgeBand,
}) {
  final double unit = roll.clamp(0, 1).toDouble();
  if (toRight) {
    final double nearest = math.min(right, from + minTravel);
    final double bandNear = math.max(nearest, right - edgeBand);
    if (bandNear >= right) return right;
    return bandNear + unit * (right - bandNear);
  }
  final double nearest = math.max(left, from - minTravel);
  final double bandNear = math.min(nearest, left + edgeBand);
  if (bandNear <= left) return left;
  return left + unit * (bandNear - left);
}
