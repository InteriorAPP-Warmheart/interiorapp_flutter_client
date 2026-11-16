import 'package:interiorapp_flutter_client/showroom/domain/entity/showroom_comment.dart';

abstract class ShowroomCommentRepository {
  Future<List<ShowroomComment>> comments(String showroomId);

  Future<ShowroomCommentPosted> add(ShowroomCommentRequest request);

  Future<void> report({
    required String showroomId,
    required String commentId,
    required String reason,
    required String detail,
  });
}
