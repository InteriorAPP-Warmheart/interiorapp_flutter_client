import 'package:interiorapp_flutter_client/home/data/model/recommend_build_model.dart';
import 'package:interiorapp_flutter_client/home/data/source/recommend_build_api.dart';
import 'package:interiorapp_flutter_client/home/domain/repository/recommend_build_repository.dart';

class RecommendBuildImpl implements RecommendBuildRepository {
  final RecommendBuildApi _api;
  RecommendBuildImpl(this._api);

  @override
  Future<List<RecommendBuildModel>> getRecommendBuild() async {
    return await _api.getRecommendBuildApiData();
  }

  @override
  Future<RecommendBuildModel> updateFavoriteStatus(String id) async {
    return await _api.updateFavoriteStatus(id);
  }
}