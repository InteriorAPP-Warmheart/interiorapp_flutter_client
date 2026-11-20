import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 내공간 채팅에서 고객 확인을 기다리는 한 건.
class SpaceConfirm {
  const SpaceConfirm({
    required this.id,
    required this.projectId,
    required this.title,
    required this.summary,
  });

  final String id;
  final String projectId;
  final String title;
  final String summary;
}

class SpaceConfirmNotifier extends Notifier<List<SpaceConfirm>> {
  @override
  List<SpaceConfirm> build() {
    return const <SpaceConfirm>[
      SpaceConfirm(
        id: 'confirm-seongsu-light',
        projectId: 'project-seongsu-cafe',
        title: '조명 위치 수정',
        summary: '홀 조명을 창가 쪽으로 옮겨요',
      ),
    ];
  }

  void confirm(String id) {
    state = <SpaceConfirm>[
      for (final SpaceConfirm item in state)
        if (item.id != id) item,
    ];
  }
}

final spaceConfirmProvider =
    NotifierProvider<SpaceConfirmNotifier, List<SpaceConfirm>>(
      SpaceConfirmNotifier.new,
    );
