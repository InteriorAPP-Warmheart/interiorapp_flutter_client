import 'package:interiorapp_flutter_client/home_tab/data/model/hot_showroom_model.dart';
import 'package:interiorapp_flutter_client/home_tab/domain/repository/hot_showroom_abst.dart';

class HotShowroomUseCase {
  final HotShowroomRepository _hotShowroomRepository;

  HotShowroomUseCase(this._hotShowroomRepository);

  Future<List<HotShowroomModel>> getHotShowroom() async {
    return _hotShowroomRepository.getHotShowroom();
  }
}