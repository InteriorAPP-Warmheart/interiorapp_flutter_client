import 'package:interiorapp_flutter_client/home/data/model/hot_showroom_model.dart';
import 'package:interiorapp_flutter_client/home/domain/repository/hot_showroom_repository.dart';

class HotShowroomUseCase {
  final HotShowroomRepository _hotShowroomRepository;

  HotShowroomUseCase(this._hotShowroomRepository);

  Future<List<HotShowroomModel>> getHotShowroom() async {
    return _hotShowroomRepository.getHotShowroom();
  }

  Future<HotShowroomModel> updateFavoriteStatus(String id) async {
    return _hotShowroomRepository.updateFavoriteStatus(id);
  }
}