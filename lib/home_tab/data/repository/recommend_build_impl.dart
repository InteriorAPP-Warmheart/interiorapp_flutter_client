import 'package:interiorapp_flutter_client/home_tab/data/model/recommend_build_model.dart';
import 'package:interiorapp_flutter_client/home_tab/data/source/recommend_build_api.dart';
import 'package:interiorapp_flutter_client/home_tab/domain/repository/recommend_build_repo.dart';

class RecommendBuildImpl implements RecommendBuildRepository {
  final RecommendBuildApi _recommendBuildApi = RecommendBuildApi();
  @override
  Future<List<RecommendBuildModel>> getRecommendBuild() async {
    return await _recommendBuildApi.getRecommendBuildApiData();
  }
}