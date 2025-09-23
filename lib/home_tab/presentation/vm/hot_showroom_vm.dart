import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/home_tab/data/model/hot_showroom_model.dart';
import 'package:interiorapp_flutter_client/home_tab/presentation/provider/hot_showroom_provider.dart';



class HotShowroomVmClass extends Notifier<List<HotShowroomModel>> {
  @override
  List<HotShowroomModel> build() {
    return [];
  }

  Future<void> getHotShowroom() async {
    final hotShowroomSlider = ref.read(hotShowroomSliderVm);
    state = hotShowroomSlider;
  }
}


class HotShowroomIndex extends Notifier<int> {
  @override int build() => 0;
  void changeIndex(int value) => state = value;
}
