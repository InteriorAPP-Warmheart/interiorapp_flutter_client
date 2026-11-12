import 'package:interiorapp_flutter_client/mypage/presentation/vm/mypage_vm.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/provider/showroom_story_provider.dart';

/// 쇼룸을 연 순간을 최근 본 기록으로 남긴다.
/// 메모리 순서와 기기 저장이 같은 쇼룸을 가리키게 한다.
void recordShowroomView({
  required RecentContentVm recent,
  required RecentShowroom memory,
  required String id,
  required String thumbnailUrl,
  required String title,
  required String category,
  String authorName = '',
  String place = '',
}) {
  if (id.isEmpty) return;
  memory.remember(id);
  recent.record(
    id: id,
    thumbnailUrl: thumbnailUrl,
    title: title,
    category: category,
    authorName: authorName,
    place: place,
  );
}
