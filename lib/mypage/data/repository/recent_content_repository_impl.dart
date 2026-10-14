import 'package:interiorapp_flutter_client/mypage/data/model/recent_content_model.dart';
import 'package:interiorapp_flutter_client/mypage/data/source/recent_content_api.dart';
import 'package:interiorapp_flutter_client/mypage/domain/repository/recent_content_repository.dart';

class RecentContentRepositoryImpl implements RecentContentRepository {
  final RecentContentApi _api;
  RecentContentRepositoryImpl(this._api);

  @override
  Future<List<RecentContentModel>> getRecentContents() =>
      _api.getRecentContents();

  @override
  Future<void> clearAllRecentContents() => _api.clearAllRecentContents();
}
