import 'package:interiorapp_flutter_client/home/data/model/recommend_build_model.dart';

abstract class RecommendBuildRepository {
  Future<List<RecommendBuildModel>> getRecommendBuild();
  Future<RecommendBuildModel> updateFavoriteStatus(String id);
}