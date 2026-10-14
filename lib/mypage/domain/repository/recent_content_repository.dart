import 'package:interiorapp_flutter_client/mypage/data/model/recent_content_model.dart';

abstract class RecentContentRepository {
  Future<List<RecentContentModel>> getRecentContents();
  Future<void> clearAllRecentContents();
}
