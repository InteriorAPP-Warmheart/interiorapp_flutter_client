import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/mascot/showroom_mascot_motion.dart';

/// 쇼룸 마스코트의 포즈와 위치.
///
/// 시계는 하나다. 앉아 있으면 멈춰 두고, 화면이 사라지면 예약된 다음 동작도
/// 시작하지 않는다.
class ShowroomMascotController extends ChangeNotifier {
  ShowroomMascotController({required TickerProvider vsync, math.Random? random})
    : _random = random ?? math.Random() {
    _openingRight = _random.nextBool();
    _clock = AnimationController(vsync: vsync)..addListener(_onTick);
  }

  static const Duration entranceDelay = Duration(seconds: 3);
  static const Duration _fallDuration = Duration(milliseconds: 560);
  static const Duration _lookDuration = Duration(milliseconds: 900);
  static const Duration _glanceLookDuration = Duration(milliseconds: 600);
  static const Duration _startleDuration = Duration(milliseconds: 220);
  static const Duration _reliefDuration = Duration(milliseconds: 450);
  static const Duration _settleDuration = Duration(milliseconds: 450);
  static const int _runFrameMs = 110;

  final math.Random _random;
  late final AnimationController _clock;

  Timer? _wait;
  ShowroomMascotLayout? _layout;
  List<ShowroomMascotSpan> _blocked = const <ShowroomMascotSpan>[];
  ShowroomMascotPose? _pose;
  double _x = 0;
  double _fromX = 0;
  double _toX = 0;
  bool? _headingRight;
  bool _faceRight = true;
  bool _openingRight = false;
  bool _relieveAfterLook = false;
  bool _animationsEnabled = true;
  bool _entranceReady = false;
  bool _disposed = false;
  int _motion = 0;
  int? _paintedLookFrame;

  ShowroomMascotPose? get pose => _pose;
  bool get faceRight => _faceRight;
  bool get entranceReady => _entranceReady && _pose == null && _layout != null;

  /// 앉아 있고 시계가 멈춰 있으면 프레임을 더 그리지 않는다.
  bool get isIdle => _pose == ShowroomMascotPose.sitting && !_clock.isAnimating;

  double get x {
    if (_pose != ShowroomMascotPose.running) return _x;
    final double t = Curves.easeOutCubic.transform(_clock.value.clamp(0, 1));
    return _fromX + (_toX - _fromX) * t;
  }

  double get y {
    final ShowroomMascotLayout? layout = _layout;
    if (layout == null) return 0;
    return switch (_pose) {
      ShowroomMascotPose.falling =>
        -layout.figure +
            (layout.restY + layout.figure) *
                Curves.easeOutCubic.transform(_clock.value.clamp(0, 1)),
      ShowroomMascotPose.startled =>
        layout.restY - 4 * math.sin(_clock.value * math.pi),
      _ => layout.restY,
    };
  }

  /// 달리기만 경과 시간으로 프레임을 고르고, 나머지는 시계 값을 쓴다.
  double get cycle {
    if (_pose != ShowroomMascotPose.running) return _clock.value;
    final int ms = _clock.duration?.inMilliseconds ?? _runFrameMs;
    final int elapsed = (_clock.value * ms).floor();
    final int index = (elapsed ~/ _runFrameMs) % 4;
    return index / 4;
  }

  void start() {
    _wait?.cancel();
    _wait = Timer(entranceDelay, () {
      if (_disposed) return;
      if (_layout == null) {
        _entranceReady = true;
        return;
      }
      beginFall();
    });
  }

  /// 빌드 중에 호출된다. 여기서는 알리지 않고 값만 맞춘다.
  void syncLayout({
    required ShowroomMascotLayout layout,
    required List<ShowroomMascotSpan> blocked,
    required bool animationsEnabled,
  }) {
    _layout = layout;
    _blocked = blocked;
    _animationsEnabled = animationsEnabled;
    _clamp();
    if (!animationsEnabled &&
        _pose != null &&
        _pose != ShowroomMascotPose.sitting) {
      _motion++;
      _pose = ShowroomMascotPose.sitting;
      _clock.stop();
    }
  }

  void beginFall() {
    if (_disposed || _pose != null) return;
    final ShowroomMascotLayout? layout = _layout;
    if (layout == null) {
      _entranceReady = true;
      return;
    }
    _entranceReady = false;
    _x = layout.center;
    if (!_animationsEnabled) {
      _pose = ShowroomMascotPose.sitting;
      _clock.stop();
      _notify();
      return;
    }
    _animate(_fallDuration, ShowroomMascotPose.falling, () {
      _beginLook(relieveAfter: false);
    });
  }

  void tap() {
    if (_disposed || _pose == null || _layout == null) return;
    if (!_animationsEnabled) return;
    _x = x;
    _headingRight = showroomMascotFleeRight(
      headingRight: _headingRight,
      openingRight: _openingRight,
    );
    _animate(_startleDuration, ShowroomMascotPose.startled, _beginRun);
  }

  @override
  void dispose() {
    _disposed = true;
    _motion++;
    _wait?.cancel();
    _clock.removeListener(_onTick);
    _clock.dispose();
    super.dispose();
  }

  void _beginLook({required bool relieveAfter}) {
    _relieveAfterLook = relieveAfter;
    _animate(
      relieveAfter ? _glanceLookDuration : _lookDuration,
      ShowroomMascotPose.looking,
      _finishLook,
    );
  }

  void _finishLook() {
    if (_disposed || _pose != ShowroomMascotPose.looking) return;
    if (!_relieveAfterLook) {
      _beginSit();
      return;
    }
    _animate(
      ShowroomMascotController._reliefDuration,
      ShowroomMascotPose.relief,
      () {
        _animate(_settleDuration, ShowroomMascotPose.settling, _beginSit);
      },
    );
  }

  void _beginSit() {
    if (_disposed) return;
    if (_pose != ShowroomMascotPose.looking &&
        _pose != ShowroomMascotPose.settling) {
      return;
    }
    _motion++;
    _pose = ShowroomMascotPose.sitting;
    _clock.stop();
    _notify();
  }

  void _beginRun() {
    if (_disposed || _pose != ShowroomMascotPose.startled) return;
    final ShowroomMascotLayout? layout = _layout;
    if (layout == null) return;
    final bool toRight = _headingRight ?? _openingRight;
    final double target = showroomMascotAvoidSpans(
      target: showroomMascotFleeTarget(
        from: _x,
        toRight: toRight,
        left: layout.left,
        right: layout.right,
        roll: _random.nextDouble(),
        minTravel: layout.minTravel,
        edgeBand: layout.edgeBand,
      ),
      figure: layout.figure,
      left: layout.left,
      right: layout.right,
      toRight: toRight,
      blocked: _blocked,
    );
    _fromX = _x;
    _toX = target;
    _faceRight = toRight;
    final int distanceMs = _runMilliseconds((_toX - _fromX).abs());
    _animate(
      Duration(milliseconds: distanceMs),
      ShowroomMascotPose.running,
      () {
        _x = _toX;
        _beginLook(relieveAfter: true);
      },
    );
  }

  void _animate(
    Duration duration,
    ShowroomMascotPose next,
    VoidCallback onDone,
  ) {
    if (_disposed) return;
    final int motion = ++_motion;
    _pose = next;
    _paintedLookFrame = null;
    _clock
      ..stop()
      ..duration = duration;
    _notify();
    _clock.forward(from: 0).whenComplete(() {
      if (!_alive(motion) || _pose != next) return;
      onDone();
    });
  }

  void _onTick() {
    if (_disposed) return;
    if (_pose == ShowroomMascotPose.looking) {
      final int frame = (_clock.value.clamp(0, 1).toDouble() * 3).floor();
      final int lookFrame = frame > 2 ? 2 : frame;
      if (lookFrame == _paintedLookFrame) return;
      _paintedLookFrame = lookFrame;
      _notify();
      return;
    }
    if (_pose == ShowroomMascotPose.falling ||
        _pose == ShowroomMascotPose.startled ||
        _pose == ShowroomMascotPose.running) {
      _notify();
    }
  }

  void _clamp() {
    final ShowroomMascotLayout? layout = _layout;
    if (layout == null || _pose == null) return;
    _x = _x.clamp(layout.left, layout.right);
    _fromX = _fromX.clamp(layout.left, layout.right);
    _toX = _toX.clamp(layout.left, layout.right);
  }

  int _runMilliseconds(double distance) {
    final int milliseconds = (distance / showroomMascotRunSpeed * 1000).round();
    return milliseconds.clamp(280, 900).toInt();
  }

  bool _alive(int motion) => !_disposed && _motion == motion;

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }
}
