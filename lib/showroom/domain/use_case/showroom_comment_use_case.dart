import 'package:interiorapp_flutter_client/showroom/domain/entity/showroom_comment.dart';
import 'package:interiorapp_flutter_client/showroom/domain/repository/showroom_comment_repository.dart';

class ShowroomCommentUseCase {
  ShowroomCommentUseCase(this._repository);

  final ShowroomCommentRepository _repository;

  Future<List<ShowroomComment>> comments(String showroomId) {
    return _repository.comments(showroomId);
  }

  Future<ShowroomCommentPosted> add(ShowroomCommentRequest request) {
    return _repository.add(request);
  }

  Future<void> report({
    required String showroomId,
    required String commentId,
    required String reason,
    required String detail,
  }) {
    return _repository.report(
      showroomId: showroomId,
      commentId: commentId,
      reason: reason,
      detail: detail,
    );
  }
}
