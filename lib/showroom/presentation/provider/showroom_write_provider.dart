import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/showroom/data/repository/showroom_repository_impl.dart';
import 'package:interiorapp_flutter_client/showroom/data/source/showroom_api.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/filter_entity.dart';
import 'package:interiorapp_flutter_client/showroom/domain/use_case/showroom_use_case.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/vm/filter_vm.dart';

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

// 선택된 buildId로 상세 데이터 조회
final showroomSelectedBuildProvider = FutureProvider.family.autoDispose<Map<String, dynamic>?, String>((ref, buildId) async {
  // 상세 화면은 항상 buildId만 받아 스스로 fetch 한다.
  // - 딥링크/알림 등 리스트 없이도 동작 가능
  // - 리스트가 오래된 경우에도 최신 데이터 재조회 가능
  // 필요 시: 여기서 먼저 캐시된 리스트(showroomWriteProvider)에서 찾고, 없을 때만 API 호출하도록 확장 가능.
  // 정리하자면 이미 캐시된 리스트(showroomWriteProvider)에서 찾는 것이라 좋음
  return await ref.read(showroomUsecaseProvider).getBuildingDetail(buildId);
});

// 면적 단위 관리 (true = 평, false = 제곱미터)
class AreaUnit extends Notifier<bool> {
  @override
  bool build() => true; // 기본값: 평
  
  void toggle() => state = !state;
  void setUnit(bool isPyeong) => state = isPyeong;
  
  String get unitText => state ? '평' : 'm²';
}

final areaUnitProvider = NotifierProvider.autoDispose<AreaUnit, bool>(
  AreaUnit.new,
);

// 면적 값 관리 TextEditingController
final areaTextControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(() {
    controller.dispose();
  });
  return controller;
});

// 비용 값 관리 TextEditingController
final totalCostTextControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(() {
    controller.dispose();
  });
  return controller;
});

// 비용 단위 관리 (만원, 억원, 조원)
class CostUnit extends Notifier<String> {
  @override
  String build() => '만원'; // 기본값: 만원
  
  void setUnit(String unit) => state = unit;
}

final costUnitProvider = NotifierProvider.autoDispose<CostUnit, String>(
  CostUnit.new,
);

// 글쓰기 화면용 필터 상태 관리 Provider (쇼룸 스크린과 독립적으로 동작)
final showroomWriteFilterProvider = NotifierProvider.autoDispose<FilterVm, FilterState>(
  () => FilterVm(),
);