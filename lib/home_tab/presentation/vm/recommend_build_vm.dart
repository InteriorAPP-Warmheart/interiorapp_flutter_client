import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/home_tab/data/model/recommend_build_model.dart';
import 'package:interiorapp_flutter_client/home_tab/presentation/provider/recommend_build_provider.dart';

class RecommendBuildVmClass extends Notifier<List<RecommendBuildModel>> {

  @override List<RecommendBuildModel> build() {
    // 초기 한 번만 자동 로드
    Future.microtask(() async {
      if (state.isEmpty) {
        state = await ref.read(recommendBuildUseCaseProvider).getRecommendBuild();
      }
    });
    return <RecommendBuildModel>[];
  }

  Future<void> getRecommendBuild() async {
    state = await ref.read(recommendBuildUseCaseProvider).getRecommendBuild();
  }

  Future<void> toggleFavoriteByIndex(String id) async {
    if (id.isEmpty) return;
    // 필요 시 동일한 낙관적 업데이트 패턴으로 변경 가능
    final data = await ref.read(recommendBuildUseCaseProvider).updateFavoriteStatus(id);
    state = state.map((e) => e.id == id ? data : e).toList();
  }
}

class RecommendBuildIndex extends Notifier<int> {
  @override int build() => 0;
  void changeIndex(int value) => state = value;
}


