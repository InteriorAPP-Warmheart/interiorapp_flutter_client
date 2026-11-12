import 'package:interiorapp_flutter_client/mypage/data/model/recent_content_model.dart';
import 'package:interiorapp_flutter_client/mypage/data/source/local/showroom_content_history_store.dart';
import 'package:interiorapp_flutter_client/mypage/domain/repository/recent_content_repository.dart';

class RecentContentRepositoryImpl implements RecentContentRepository {
  final ShowroomContentHistoryStore _store;
  RecentContentRepositoryImpl(this._store);

  @override
  Future<List<RecentContentModel>> getRecentContents() => _store.readRecent();

  @override
  Future<List<RecentContentModel>> record(RecentContentModel item) =>
      _store.upsertRecent(item);

  @override
  Future<List<RecentContentModel>> removeRecentContent(String id) =>
      _store.removeRecent(id);

  @override
  Future<List<RecentContentModel>> clearAllRecentContents() =>
      _store.clearRecent();
}
