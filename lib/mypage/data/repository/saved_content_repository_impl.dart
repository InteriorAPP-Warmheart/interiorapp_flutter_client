import 'package:interiorapp_flutter_client/mypage/data/model/saved_content_model.dart';
import 'package:interiorapp_flutter_client/mypage/data/source/saved_content_api.dart';
import 'package:interiorapp_flutter_client/mypage/domain/repository/saved_content_repository.dart';

class SavedContentRepositoryImpl implements SavedContentRepository {
  final SavedContentApi _api;
  SavedContentRepositoryImpl(this._api);

  @override
  Future<List<SavedContentModel>> getSavedContents() =>
      _api.getSavedContents();

  @override
  Future<void> removeSavedContent(String id) => _api.removeSavedContent(id);
}
