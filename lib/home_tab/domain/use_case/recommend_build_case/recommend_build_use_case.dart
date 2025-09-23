import 'package:interiorapp_flutter_client/home_tab/data/model/recommend_build_model.dart';
import 'package:interiorapp_flutter_client/home_tab/domain/repository/recommend_build_repo.dart';

class RecommendBuildUseCase {
  final RecommendBuildRepository _recommendBuildRepository;

  RecommendBuildUseCase(this._recommendBuildRepository);

  Future<List<RecommendBuildModel>> getRecommendBuild() async {
    return _recommendBuildRepository.getRecommendBuild();
  }
}