import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/home_tab/data/model/hot_showroom_model.dart';
import 'package:interiorapp_flutter_client/home_tab/data/repository/hot_showroom_impl.dart';
import 'package:interiorapp_flutter_client/home_tab/domain/use_case/hot_showroom/hot_showroom_use_case.dart';
import 'package:interiorapp_flutter_client/home_tab/presentation/vm/hot_showroom_vm.dart';

final hotShowroomSliderProvider = FutureProvider<List<HotShowroomModel>>((
  ref,
) async {
  final hotShowroomSliderRepository = HotShowroomImpl();
  return await HotShowroomUseCase(hotShowroomSliderRepository).getHotShowroom();
});

final hotShowroomSliderVm =
    NotifierProvider<HotShowroomVmClass, List<HotShowroomModel>>(
      HotShowroomVmClass.new,
    );

final hotShowroomSliderIndexProvider =
    NotifierProvider.autoDispose<HotShowroomIndex, int>(HotShowroomIndex.new);
