import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/home_tab/data/model/recommend_build_model.dart';
import 'package:interiorapp_flutter_client/home_tab/presentation/provider/recommend_build_provider.dart';

class RecommendBuildVmClass extends Notifier<List<RecommendBuildModel>> {

  @override List<RecommendBuildModel> build() {
    return [];
  }

  Future<void> getRecommendBuild() async {
    final recommendBuild = ref.read(recommendBuildVm);
    state = recommendBuild;
  }
}

class RecommendBuildIndex extends Notifier<int> {
  @override int build() => 0;
  void changeIndex(int value) => state = value;
}


