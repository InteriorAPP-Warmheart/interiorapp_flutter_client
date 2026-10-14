import 'package:interiorapp_flutter_client/mypage/data/model/recent_content_model.dart';
import 'package:interiorapp_flutter_client/mypage/domain/repository/recent_content_repository.dart';

class RecentContentUseCase {
  final RecentContentRepository _repository;
  RecentContentUseCase(this._repository);

  Future<List<RecentContentModel>> getRecentContents() =>
      _repository.getRecentContents();

  Future<void> clearAllRecentContents() =>
      _repository.clearAllRecentContents();
}
