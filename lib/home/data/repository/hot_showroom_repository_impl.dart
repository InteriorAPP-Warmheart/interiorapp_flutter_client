import 'package:interiorapp_flutter_client/home/data/model/hot_showroom_model.dart';
import 'package:interiorapp_flutter_client/home/data/source/hot_showroom_api.dart';
import 'package:interiorapp_flutter_client/home/domain/repository/hot_showroom_repository.dart';

class HotShowroomImpl implements HotShowroomRepository {
  final HotShowroomApi _api;
  HotShowroomImpl(this._api);

  @override
  Future<List<HotShowroomModel>> getHotShowroom() async {
    return _api.getHotShowroomApiData();
  }

  @override
  Future<HotShowroomModel> updateFavoriteStatus(String id) async {
    return _api.updateFavoriteStatus(id);
  }
}