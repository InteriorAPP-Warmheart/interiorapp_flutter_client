import 'package:interiorapp_flutter_client/showroom/data/model/showroom_story_model.dart';
import 'package:interiorapp_flutter_client/showroom/data/source/showroom_story_api.dart';
import 'package:interiorapp_flutter_client/showroom/domain/repository/showroom_story_repository.dart';

class ShowroomStoryImpl implements ShowroomStoryRepository {
  ShowroomStoryImpl(this._api);

  final ShowroomStoryApi _api;

  @override
  Future<ShowroomStoryModel?> getStory(String id) {
    return _api.getStory(id);
  }
}
