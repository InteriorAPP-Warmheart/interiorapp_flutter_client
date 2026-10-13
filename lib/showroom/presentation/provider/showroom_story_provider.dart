import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/showroom_story_model.dart';
import 'package:interiorapp_flutter_client/showroom/data/repository/showroom_story_repository_impl.dart';
import 'package:interiorapp_flutter_client/showroom/data/source/showroom_story_api.dart';
import 'package:interiorapp_flutter_client/showroom/domain/use_case/showroom_story_use_case.dart';

final showroomStoryApiProvider = Provider((ref) => ShowroomStoryApi());

final showroomStoryRepositoryProvider = Provider((ref) {
  return ShowroomStoryImpl(ref.read(showroomStoryApiProvider));
});

final showroomStoryUseCaseProvider = Provider((ref) {
  return ShowroomStoryUseCase(ref.read(showroomStoryRepositoryProvider));
});

final showroomStoryProvider = FutureProvider.autoDispose
    .family<ShowroomStoryModel?, String>((ref, id) {
      return ref.read(showroomStoryUseCaseProvider).getStory(id);
    });

/// 디테일을 연 순서. 쇼룸 탭과 마이에서 같은 목록을 읽는다.
final recentShowroomProvider = NotifierProvider<RecentShowroom, List<String>>(
  RecentShowroom.new,
);

class RecentShowroom extends Notifier<List<String>> {
  @override
  List<String> build() => const <String>[];

  void remember(String id) {
    if (id.isEmpty) return;
    if (state.isNotEmpty && state.first == id) return;
    state = <String>[
      id,
      ...state.where((String item) => item != id),
    ].take(12).toList(growable: false);
  }
}
