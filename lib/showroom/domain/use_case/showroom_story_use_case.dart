import 'package:interiorapp_flutter_client/showroom/data/model/showroom_story_model.dart';
import 'package:interiorapp_flutter_client/showroom/domain/repository/showroom_story_repository.dart';

class ShowroomStoryUseCase {
  ShowroomStoryUseCase(this._repository);

  final ShowroomStoryRepository _repository;

  Future<ShowroomStoryModel?> getStory(String id) {
    return _repository.getStory(id);
  }
}
