import 'package:interiorapp_flutter_client/showroom/data/model/showroom_story_model.dart';

abstract class ShowroomStoryRepository {
  Future<ShowroomStoryModel?> getStory(String id);
}
