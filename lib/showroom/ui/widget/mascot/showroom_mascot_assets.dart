import 'package:interiorapp_flutter_client/showroom/ui/widget/mascot/showroom_mascot_motion.dart';

const String showroomMascotAssetDir =
    'assets/mascot/showroom/wapll_mascot_assets';

const String showroomMascotFall = '$showroomMascotAssetDir/01_fall.png';
const String showroomMascotLookLeft =
    '$showroomMascotAssetDir/02_look_left.png';
const String showroomMascotLookFront =
    '$showroomMascotAssetDir/03_look_front.png';
const String showroomMascotLookRight =
    '$showroomMascotAssetDir/04_look_right.png';
const String showroomMascotHappySit =
    '$showroomMascotAssetDir/05_happy_sit_loop.png';
const String showroomMascotSurprise = '$showroomMascotAssetDir/06_surprise.png';
const String showroomMascotRelief = '$showroomMascotAssetDir/11_relief_sit.png';
const String showroomMascotHappyTransition =
    '$showroomMascotAssetDir/12_happy_transition.png';

const List<String> showroomMascotLookFrames = <String>[
  showroomMascotLookLeft,
  showroomMascotLookFront,
  showroomMascotLookRight,
];

const List<String> showroomMascotRunFrames = <String>[
  '$showroomMascotAssetDir/07_run_01.png',
  '$showroomMascotAssetDir/08_run_02.png',
  '$showroomMascotAssetDir/09_run_03.png',
  '$showroomMascotAssetDir/10_run_04.png',
];

const List<String> showroomMascotAssetPaths = <String>[
  showroomMascotFall,
  ...showroomMascotLookFrames,
  showroomMascotHappySit,
  showroomMascotSurprise,
  ...showroomMascotRunFrames,
  showroomMascotRelief,
  showroomMascotHappyTransition,
];

/// 포즈와 0~1 진행도로 보여줄 PNG를 고른다.
String showroomMascotFrame(ShowroomMascotPose pose, double cycle) {
  return switch (pose) {
    ShowroomMascotPose.falling => showroomMascotFall,
    ShowroomMascotPose.looking =>
      showroomMascotLookFrames[_frameIndex(
        cycle,
        showroomMascotLookFrames.length,
      )],
    ShowroomMascotPose.sitting => showroomMascotHappySit,
    ShowroomMascotPose.startled => showroomMascotSurprise,
    ShowroomMascotPose.running =>
      showroomMascotRunFrames[_frameIndex(
        cycle,
        showroomMascotRunFrames.length,
      )],
    ShowroomMascotPose.relief => showroomMascotRelief,
    ShowroomMascotPose.settling => showroomMascotHappyTransition,
  };
}

int _frameIndex(double cycle, int count) {
  final int index = (cycle.clamp(0, 1) * count).floor();
  if (index >= count) return count - 1;
  return index;
}
