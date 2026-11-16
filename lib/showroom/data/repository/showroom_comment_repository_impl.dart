import 'package:interiorapp_flutter_client/showroom/data/model/showroom_comment_model.dart';
import 'package:interiorapp_flutter_client/showroom/data/source/showroom_comment_api.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/showroom_comment.dart';
import 'package:interiorapp_flutter_client/showroom/domain/repository/showroom_comment_repository.dart';

class ShowroomCommentRepositoryImpl implements ShowroomCommentRepository {
  ShowroomCommentRepositoryImpl(this._api);

  final ShowroomCommentApi _api;

  @override
  Future<List<ShowroomComment>> comments(String showroomId) async {
    final List<ShowroomCommentModel> models = await _api.fetch(showroomId);
    return models.map(_toEntity).toList();
  }

  @override
  Future<ShowroomCommentPosted> add(ShowroomCommentRequest request) async {
    final ({List<ShowroomCommentModel> comments, String? threadId}) result =
        await _api.create(
          showroomId: request.showroomId,
          body: request.body,
          emoticonUrl: request.emoticonUrl,
          replyToId: request.replyToId,
        );
    return ShowroomCommentPosted(
      comments: result.comments.map(_toEntity).toList(),
      threadId: result.threadId,
    );
  }

  @override
  Future<void> report({
    required String showroomId,
    required String commentId,
    required String reason,
    required String detail,
  }) {
    return _api.report(
      showroomId: showroomId,
      commentId: commentId,
      reason: reason,
      detail: detail,
    );
  }

  ShowroomComment _toEntity(ShowroomCommentModel model) {
    return ShowroomComment(
      id: model.id,
      name: model.authorName,
      profileUrl: model.profileUrl,
      body: model.body,
      emoticon: model.emoticonUrl,
      replyToId: model.replyToId,
      replyToName: model.replyToName,
      createdAt: model.createdAt,
      replies: model.replies.map(_toEntity).toList(),
    );
  }
}
