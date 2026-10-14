import 'package:interiorapp_flutter_client/mypage/data/model/completed_project_model.dart';
import 'package:interiorapp_flutter_client/mypage/domain/repository/completed_project_repository.dart';

class CompletedProjectUseCase {
  final CompletedProjectRepository _repository;
  CompletedProjectUseCase(this._repository);

  Future<List<CompletedProjectModel>> getCompletedProjects() =>
      _repository.getCompletedProjects();
}
