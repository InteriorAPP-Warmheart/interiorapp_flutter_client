import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/home_tab/data/model/recommend_build_model.dart';
import 'package:interiorapp_flutter_client/home_tab/data/repository/recommend_build_impl.dart';
import 'package:interiorapp_flutter_client/home_tab/data/source/recommend_build_api.dart';
import 'package:interiorapp_flutter_client/home_tab/domain/use_case/recommend_build_case/recommend_build_use_case.dart';
import 'package:interiorapp_flutter_client/home_tab/presentation/vm/recommend_build_vm.dart';

// API -> Repository -> UseCase providers
final recommendBuildApiProvider = Provider((ref) => RecommendBuildApi());

final recommendBuildRepositoryProvider = Provider((ref) {
  return RecommendBuildImpl(ref.read(recommendBuildApiProvider));
});

final recommendBuildUseCaseProvider = Provider((ref) {
  return RecommendBuildUseCase(ref.read(recommendBuildRepositoryProvider));
});

final recommendBuildProvider = FutureProvider<List<RecommendBuildModel>>((ref) async {
  return await ref.read(recommendBuildUseCaseProvider).getRecommendBuild();
});

final recommendBuildVm =
    NotifierProvider<RecommendBuildVmClass, List<RecommendBuildModel>>(
      RecommendBuildVmClass.new,
    );

final recommendBuildIndexProvider =
    NotifierProvider.autoDispose<RecommendBuildIndex, int>(
      RecommendBuildIndex.new,
    );
