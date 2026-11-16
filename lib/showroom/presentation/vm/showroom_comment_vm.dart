import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/showroom_comment.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/provider/showroom_comment_provider.dart';

class ShowroomCommentBoard {
  const ShowroomCommentBoard({
    this.comments = const <String, List<ShowroomComment>>{},
    this.ready = const <String>{},
  });

  final Map<String, List<ShowroomComment>> comments;
  final Set<String> ready;

  List<ShowroomComment> of(String showroomId) {
    return comments[showroomId] ?? const <ShowroomComment>[];
  }

  bool isReady(String showroomId) => ready.contains(showroomId);

  ShowroomCommentBoard copyWith({
    Map<String, List<ShowroomComment>>? comments,
    Set<String>? ready,
  }) {
    return ShowroomCommentBoard(
      comments: comments ?? this.comments,
      ready: ready ?? this.ready,
    );
  }
}

class ShowroomCommentVm extends Notifier<ShowroomCommentBoard> {
  final Set<String> _loading = <String>{};

  @override
  ShowroomCommentBoard build() => const ShowroomCommentBoard();

  Future<void> load(String showroomId) async {
    if (showroomId.isEmpty || state.isReady(showroomId)) return;
    if (_loading.contains(showroomId)) return;
    _loading.add(showroomId);
    final List<ShowroomComment> comments = await ref
        .read(showroomCommentUseCaseProvider)
        .comments(showroomId);
    if (!ref.mounted) return;
    state = state.copyWith(
      comments: <String, List<ShowroomComment>>{
        ...state.comments,
        showroomId: comments,
      },
      ready: <String>{...state.ready, showroomId},
    );
    _loading.remove(showroomId);
  }

  Future<ShowroomCommentPosted?> add(ShowroomCommentRequest request) async {
    final String body = request.body.trim();
    if (body.isEmpty &&
        (request.emoticonUrl == null || request.emoticonUrl!.isEmpty)) {
      return null;
    }
    final ShowroomCommentPosted posted = await ref
        .read(showroomCommentUseCaseProvider)
        .add(
          ShowroomCommentRequest(
            showroomId: request.showroomId,
            body: body,
            emoticonUrl: request.emoticonUrl,
            replyToId: request.replyToId,
          ),
        );
    if (!ref.mounted) return posted;
    state = state.copyWith(
      comments: <String, List<ShowroomComment>>{
        ...state.comments,
        request.showroomId: posted.comments,
      },
      ready: <String>{...state.ready, request.showroomId},
    );
    return posted;
  }

  Future<void> report({
    required String showroomId,
    required String commentId,
    required String reason,
    required String detail,
  }) {
    return ref
        .read(showroomCommentUseCaseProvider)
        .report(
          showroomId: showroomId,
          commentId: commentId,
          reason: reason,
          detail: detail,
        );
  }
}
