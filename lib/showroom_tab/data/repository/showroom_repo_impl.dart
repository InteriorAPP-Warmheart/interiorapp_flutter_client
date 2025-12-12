import 'package:interiorapp_flutter_client/showroom_tab/data/source/showroom_api.dart';
import 'package:interiorapp_flutter_client/showroom_tab/domain/repository/showroom_repository.dart';

class ShowroomRepoImpl implements ShowroomRepository {
  final ShowroomApi _api;
  ShowroomRepoImpl(this._api);

  @override
  Future<List<Map<String, dynamic>>> getRecentBuildings(bool hasData) async {
    return _api.getRecentBuildingsApi(hasData);
  }

  @override
  Future<Map<String, dynamic>?> getBuildingDetail(String buildId) async {
    return _api.getBuildingDetail(buildId);
  }
}