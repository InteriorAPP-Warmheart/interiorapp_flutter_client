import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/home_tab/data/model/showroom_slider_model.dart';
import 'package:interiorapp_flutter_client/home_tab/data/repository/showroom_slider_impl.dart';
import 'package:interiorapp_flutter_client/home_tab/domain/use_case/showroom_slider/showroom_slider_use_case.dart';
import 'package:interiorapp_flutter_client/home_tab/presentation/vm/showroom_slider_vm.dart';

// final showroomSliderProvider = Provider<ShowroomSliderUseCase>((ref) {
// });

  final showroomSliderProvider = FutureProvider<List<ShowroomSliderModel>>((ref) async {
  final showroomSliderRepository = ShowroomSliderImpl();
  return await ShowroomSliderUseCase(showroomSliderRepository).getShowroomSlider();
    });

final showroomSliderVm =
    NotifierProvider<ShowroomSliderVmClass, List<ShowroomSliderModel>>(
      ShowroomSliderVmClass.new,
    );

final showroomSliderIndexProvider =
  NotifierProvider.autoDispose<ShowroomIndex, int>(ShowroomIndex.new);