import 'package:interiorapp_flutter_client/home_tab/data/model/recommend_build_model.dart';
import 'package:interiorapp_flutter_client/home_tab/data/source/recommend_build_api.dart';
import 'package:interiorapp_flutter_client/home_tab/domain/repository/recommend_build_repo.dart';

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