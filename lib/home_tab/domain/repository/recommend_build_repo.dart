import 'package:interiorapp_flutter_client/home_tab/data/model/recommend_build_model.dart';

abstract class RecommendBuildRepository {
  Future<List<RecommendBuildModel>> getRecommendBuild();
}