import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/home_tab/data/model/hot_showroom_model.dart';
import 'package:interiorapp_flutter_client/home_tab/data/repository/hot_showroom_impl.dart';
import 'package:interiorapp_flutter_client/home_tab/data/source/hot_showroom_api.dart';
import 'package:interiorapp_flutter_client/home_tab/domain/use_case/hot_showroom/hot_showroom_use_case.dart';
import 'package:interiorapp_flutter_client/home_tab/presentation/vm/hot_showroom_vm.dart';

// API -> Repository -> UseCase providers
final hotShowroomApiProvider = Provider((ref) => HotShowroomApi());

final hotShowroomRepositoryProvider = Provider((ref) {
  return HotShowroomImpl(ref.read(hotShowroomApiProvider));
});

final hotShowroomUseCaseProvider = Provider((ref) {
  return HotShowroomUseCase(ref.read(hotShowroomRepositoryProvider));
});

final hotShowroomSliderProvider = FutureProvider<List<HotShowroomModel>>((ref) async {
  return await ref.read(hotShowroomUseCaseProvider).getHotShowroom();
});

final hotShowroomSliderVm = NotifierProvider<HotShowroomVmClass, List<HotShowroomModel>>(
  HotShowroomVmClass.new,
);

final hotShowroomSliderIndexProvider =
    NotifierProvider.autoDispose<HotShowroomIndex, int>(HotShowroomIndex.new);
