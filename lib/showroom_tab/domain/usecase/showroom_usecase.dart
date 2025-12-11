import 'package:interiorapp_flutter_client/showroom_tab/domain/repository/showroom_repository.dart';

class ShowroomUsecase {
  final ShowroomRepository _repository;
  ShowroomUsecase(this._repository);

  Future<List<Map<String, dynamic>>> getRecentBuildings(bool hasData) async {
    return _repository.getRecentBuildings(hasData);
  }
}