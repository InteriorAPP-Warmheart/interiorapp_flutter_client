import 'package:interiorapp_flutter_client/mypage/data/model/saved_content_model.dart';

abstract class SavedContentRepository {
  Future<List<SavedContentModel>> getSavedContents();
  Future<void> removeSavedContent(String id);
}
