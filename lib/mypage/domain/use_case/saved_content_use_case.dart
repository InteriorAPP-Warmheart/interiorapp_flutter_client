import 'package:interiorapp_flutter_client/mypage/data/model/saved_content_model.dart';
import 'package:interiorapp_flutter_client/mypage/domain/repository/saved_content_repository.dart';

class SavedContentUseCase {
  final SavedContentRepository _repository;
  SavedContentUseCase(this._repository);

  Future<List<SavedContentModel>> getSavedContents() =>
      _repository.getSavedContents();

  Future<void> removeSavedContent(String id) =>
      _repository.removeSavedContent(id);
}
