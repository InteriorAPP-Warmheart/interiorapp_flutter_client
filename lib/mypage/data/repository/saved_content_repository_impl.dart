import 'package:interiorapp_flutter_client/mypage/data/model/saved_content_model.dart';
import 'package:interiorapp_flutter_client/mypage/data/source/local/showroom_content_history_store.dart';
import 'package:interiorapp_flutter_client/mypage/domain/repository/saved_content_repository.dart';

class SavedContentRepositoryImpl implements SavedContentRepository {
  final ShowroomContentHistoryStore _store;
  SavedContentRepositoryImpl(this._store);

  @override
  Future<List<SavedContentModel>> getSavedContents() => _store.readSaved();

  @override
  Future<List<SavedContentModel>> save(SavedContentModel item) =>
      _store.upsertSaved(item);

  @override
  Future<List<SavedContentModel>> removeSavedContent(String id) =>
      _store.removeSaved(id);
}
