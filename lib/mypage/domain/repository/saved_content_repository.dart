import 'package:interiorapp_flutter_client/mypage/data/model/saved_content_model.dart';

abstract class SavedContentRepository {
  Future<List<SavedContentModel>> getSavedContents();
  Future<List<SavedContentModel>> save(SavedContentModel item);
  Future<List<SavedContentModel>> removeSavedContent(String id);
}
