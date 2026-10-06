import 'package:interiorapp_flutter_client/home/data/model/recommend_build_model.dart';
import 'package:interiorapp_flutter_client/home/domain/repository/recommend_build_repository.dart';

class RecommendBuildUseCase {
  final RecommendBuildRepository _recommendBuildRepository;

  RecommendBuildUseCase(this._recommendBuildRepository);

  Future<List<RecommendBuildModel>> getRecommendBuild() async {
    return _recommendBuildRepository.getRecommendBuild();
  }

  Future<RecommendBuildModel> updateFavoriteStatus(String id) async {
    return _recommendBuildRepository.updateFavoriteStatus(id);
  }
}