import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/presentation/provider/build_provider.dart';
import 'package:interiorapp_flutter_client/build/presentation/provider/space_confirm_provider.dart';
import 'package:interiorapp_flutter_client/notification/domain/app_notice.dart';
import 'package:interiorapp_flutter_client/notification/domain/notice_feed.dart';

/// 이번 세션에서 연 알림. 서버 읽음은 아직 없다.
class NoticeReadNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void mark(String id) {
    if (state.contains(id)) return;
    state = <String>{...state, id};
  }

  void markAll(Iterable<String> ids) {
    state = <String>{...state, ...ids};
  }
}

final noticeReadProvider = NotifierProvider<NoticeReadNotifier, Set<String>>(
  NoticeReadNotifier.new,
);

/// 이번 세션에서 지운 알림.
class NoticeDismissNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void dismiss(String id) {
    if (state.contains(id)) return;
    state = <String>{...state, id};
  }
}

final noticeDismissProvider =
    NotifierProvider<NoticeDismissNotifier, Set<String>>(
      NoticeDismissNotifier.new,
    );

final noticeFeedProvider = Provider<List<AppNotice>>((ref) {
  final board = ref.watch(spaceBoardProvider);
  final List<SpaceConfirm> confirms = ref.watch(spaceConfirmProvider);
  return buildNoticeFeed(
    projects: <SpaceProject>[
      ...board.received,
      ...board.ongoing,
      ...board.finished,
    ],
    progressOf: board.constructionFor,
    confirms: <NoticeConfirm>[
      for (final SpaceConfirm confirm in confirms)
        NoticeConfirm(
          id: confirm.id,
          projectId: confirm.projectId,
          title: confirm.title,
          summary: confirm.summary,
        ),
    ],
    now: DateTime.now(),
  );
});

class NoticeUnread {
  const NoticeUnread({required this.total, required this.confirm});

  final int total;
  final int confirm;

  bool get isEmpty => total == 0;
}

final noticeUnreadProvider = Provider<NoticeUnread>((ref) {
  final List<AppNotice> feed = ref.watch(noticeFeedProvider);
  final Set<String> read = ref.watch(noticeReadProvider);
  final Set<String> dismissed = ref.watch(noticeDismissProvider);
  var total = 0;
  var confirm = 0;
  for (final AppNotice notice in feed) {
    if (dismissed.contains(notice.id) || read.contains(notice.id)) continue;
    total += 1;
    if (notice.grade == NoticeGrade.confirm) confirm += 1;
  }
  return NoticeUnread(total: total, confirm: confirm);
});
