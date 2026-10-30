import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
// flutter_quill가 시뮬레이터 판별에 쓰는 교체 지점이다.
// ignore: experimental_member_use
import 'package:flutter_quill/internal.dart';

/// 시뮬레이터 판별 채널이 아직 없을 때도 에디터 시작이 예외로 끝나지 않게 한다.
void installQuillSimulatorGuard() {
  if (QuillNativeProvider.instance is _GuardedQuillNativeBridge) return;
  // ignore: invalid_use_of_visible_for_testing_member
  QuillNativeProvider.instance = _GuardedQuillNativeBridge();
}

Future<bool> quillReportsIosSimulator() {
  installQuillSimulatorGuard();
  return QuillNativeProvider.instance.isIOSSimulator();
}

class _GuardedQuillNativeBridge extends QuillNativeBridge {
  @override
  Future<bool> isIOSSimulator() async {
    try {
      return await super.isIOSSimulator();
    } on PlatformException {
      return _assumeIosSimulator();
    } on MissingPluginException {
      return _assumeIosSimulator();
    } on UnimplementedError {
      return _assumeIosSimulator();
    }
  }
}

/// 채널이 없으면 키보드 표시 플러그인을 구독하지 않도록 시뮬레이터로 본다.
/// 그 구독이 또 없는 플러그인을 찾아 같은 예외를 낸다.
bool _assumeIosSimulator() {
  if (kIsWeb || !Platform.isIOS) return false;
  return true;
}
