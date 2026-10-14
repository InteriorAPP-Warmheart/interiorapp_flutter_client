import 'package:interiorapp_flutter_client/mypage/data/model/completed_project_model.dart';

abstract class CompletedProjectRepository {
  Future<List<CompletedProjectModel>> getCompletedProjects();
}
