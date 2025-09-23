import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/home_tab/data/model/hot_showroom_model.dart';
import 'package:interiorapp_flutter_client/home_tab/presentation/provider/hot_showroom_provider.dart';



class HotShowroomVmClass extends Notifier<List<HotShowroomModel>> {
  @override
  List<HotShowroomModel> build() {
    // 자동 초기 로드 (한 번만). build에서는 초기값을 직접 반환해야 합니다.
    Future.microtask(() async {
      if (state.isEmpty) {
        state = await ref.read(hotShowroomUseCaseProvider).getHotShowroom();
      }
    });
    return <HotShowroomModel>[];
  }

  Future<void> getHotShowroom() async {
    state = await ref.read(hotShowroomUseCaseProvider).getHotShowroom();
  }

  Future<void> toggleFavoriteByIndex(String id) async {
    if (id.isEmpty) return;
    // 낙관적 업데이트
    final prevList = state;
    final optimistic = [
      for (final it in prevList)
        it.id == id ? it.copyWith(favoriteStatus: !it.favoriteStatus) : it
    ];
    state = optimistic;
    try {
      final data = await ref.read(hotShowroomUseCaseProvider).updateFavoriteStatus(id);
      // 서버 결과를 기존 스냅샷(prevList)을 기준으로 반영하여 중간 리프레시로 인한 되돌림 방지
      state = [for (final it in prevList) it.id == id ? data : it];
    } catch (_) {
      state = prevList;
    }
  }
}


class HotShowroomIndex extends Notifier<int> {
  @override int build() => 0;
  void changeIndex(int value) => state = value;
}
