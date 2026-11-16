import 'package:flutter_test/flutter_test.dart';
import 'package:interiorapp_flutter_client/showroom/data/source/showroom_story_api.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_reference_pick.dart';

void main() {
  final ShowroomStoryApi api = ShowroomStoryApi();

  test('웜하트 참고에는 본문 사진이 있고 이모티콘과 대표 사진은 빠진다', () async {
    final story = await api.getStory('showroom-warmheart');
    final shots = showroomBlockReferencePhotos(story!);
    final List<String> urls = [for (final shot in shots) shot.imageUrl];

    expect(urls, contains('assets/images/showroom_real/wh/wh_03.webp'));
    expect(urls, contains('assets/images/showroom_real/wh/wh_11.webp'));
    expect(urls, contains('assets/images/showroom_real/wh/wh_12.webp'));
    expect(urls, isNot(contains(story.thumbnailUrl)));
    expect(urls.any((String url) => url.contains('/app_icons/')), isFalse);
  });

  test('뚱아농장 참고에는 시공 전후와 본문 사진이 있다', () async {
    final story = await api.getStory('showroom-ddonga');
    final shots = showroomBlockReferencePhotos(story!);

    expect(
      shots.map((shot) => shot.label),
      containsAll(<String>['외관 시공 전', '외관 시공 후', '2층 계단 시공 전']),
    );
    expect(
      shots.map((shot) => shot.imageUrl),
      contains('assets/images/showroom_real/ddonga/ddonga_main01.webp'),
    );
    expect(
      shots.map((shot) => shot.imageUrl),
      isNot(contains(story.thumbnailUrl)),
    );
  });
}
