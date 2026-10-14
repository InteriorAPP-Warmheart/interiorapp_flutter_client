import 'package:interiorapp_flutter_client/mypage/data/model/completed_project_model.dart';
import 'package:interiorapp_flutter_client/mypage/data/source/completed_project_api.dart';
import 'package:interiorapp_flutter_client/mypage/domain/repository/completed_project_repository.dart';

class CompletedProjectRepositoryImpl implements CompletedProjectRepository {
  final CompletedProjectApi _api;
  CompletedProjectRepositoryImpl(this._api);

  @override
  Future<List<CompletedProjectModel>> getCompletedProjects() =>
      _api.getCompletedProjects();
}
