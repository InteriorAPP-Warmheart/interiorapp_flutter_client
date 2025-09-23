import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/home_tab/data/model/showroom_slider_model.dart';
import 'package:interiorapp_flutter_client/home_tab/presentation/provider/showroom_slider_provider.dart';



class ShowroomSliderVmClass extends Notifier<List<ShowroomSliderModel>> {
  @override
  List<ShowroomSliderModel> build() {
    return [];
  }

  Future<void> getShowroomSlider() async {
    final showroomSlider = ref.read(showroomSliderVm);
    state = showroomSlider;
  }
}


class ShowroomIndex extends Notifier<int> {
  @override int build() => 0;
  void changeIndex(int value) => state = value;
}
