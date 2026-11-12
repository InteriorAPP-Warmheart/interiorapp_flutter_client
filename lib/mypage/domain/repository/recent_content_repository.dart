import 'package:interiorapp_flutter_client/mypage/data/model/recent_content_model.dart';

abstract class RecentContentRepository {
  Future<List<RecentContentModel>> getRecentContents();
  Future<List<RecentContentModel>> record(RecentContentModel item);
  Future<List<RecentContentModel>> removeRecentContent(String id);
  Future<List<RecentContentModel>> clearAllRecentContents();
}
