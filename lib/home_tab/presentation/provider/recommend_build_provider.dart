import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/home_tab/data/model/recommend_build_model.dart';
import 'package:interiorapp_flutter_client/home_tab/data/repository/recommend_build_impl.dart';
import 'package:interiorapp_flutter_client/home_tab/domain/use_case/recommend_build_case/recommend_build_use_case.dart';
import 'package:interiorapp_flutter_client/home_tab/presentation/vm/recommend_build_vm.dart';

final recommendBuildProvider = FutureProvider<List<RecommendBuildModel>>((
  ref,
) async {
  final recommendBuildRepository = RecommendBuildImpl();
  return await RecommendBuildUseCase(
    recommendBuildRepository,
  ).getRecommendBuild();
});

final recommendBuildVm =
    NotifierProvider<RecommendBuildVmClass, List<RecommendBuildModel>>(
      RecommendBuildVmClass.new,
    );

final recommendBuildIndexProvider =
    NotifierProvider.autoDispose<RecommendBuildIndex, int>(
      RecommendBuildIndex.new,
    );
