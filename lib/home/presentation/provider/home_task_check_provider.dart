import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/home/domain/home_agenda.dart';

/// 이번 세션에서 고객이 직접 체크한 할 일.
///
/// 서버가 일을 마쳤다고 보내면 [HomePiece.settled]가 켜지고, 그때도 같은
/// 칸이 체크된다. 그 연동이 붙기 전에는 이 기록만 체크를 남긴다.
class HomeTaskCheckNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void toggle(String id) {
    final Set<String> next = <String>{...state};
    if (!next.add(id)) next.remove(id);
    state = next;
  }
}

final homeTaskCheckProvider =
    NotifierProvider<HomeTaskCheckNotifier, Set<String>>(
      HomeTaskCheckNotifier.new,
    );

bool homeTaskDone(HomePiece piece, Set<String> checked) {
  return piece.settled || checked.contains(piece.id);
}
