import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/showroom_tab/data/repository/showroom_repo_impl.dart';
import 'package:interiorapp_flutter_client/showroom_tab/data/source/showroom_api.dart';
import 'package:interiorapp_flutter_client/showroom_tab/domain/usecase/showroom_usecase.dart';

// ScrollController Provider
final showroomScrollControllerProvider = Provider.autoDispose<ScrollController>((ref) {
  final controller = ScrollController();
  ref.onDispose(() {
    controller.dispose();
  });
  return controller;
});

// 데이터 표시 상태 관리 Notifier (true = 데이터 있음, false = 데이터 없음)
class ShowroomDataToggle extends Notifier<bool> {
  @override
  bool build() => true;
  
  void toggle() => state = !state;
  
  void setValue(bool value) => state = value;
}

final showroomDataToggleProvider = NotifierProvider.autoDispose<ShowroomDataToggle, bool>(
  ShowroomDataToggle.new,
);

// 선택된 buildId 관리 Notifier
class SelectedBuildId extends Notifier<String?> {
  @override
  String? build() => null;
  
  void select(String? buildId) => state = buildId;
  
  void clear() => state = null;
}

final selectedBuildIdProvider = NotifierProvider.autoDispose<SelectedBuildId, String?>(
  SelectedBuildId.new,
);

final showroomUsecaseProvider = Provider.autoDispose<ShowroomUsecase>((ref) {
  return ShowroomUsecase(ShowroomRepoImpl(ShowroomApi()));
});

final showroomWriteProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final hasData = ref.watch(showroomDataToggleProvider);
  // 스위치 상태를 API에 전달하여 데이터 반환
  return await ref.read(showroomUsecaseProvider).getRecentBuildings(hasData);
});