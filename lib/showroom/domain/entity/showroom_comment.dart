/// 쇼룸 게시글의 댓글. 서버 응답 모양과 분리된 화면용 모델이다.
class ShowroomComment {
  const ShowroomComment({
    required this.id,
    required this.name,
    required this.profileUrl,
    required this.body,
    required this.createdAt,
    this.emoticon,
    this.replyToId,
    this.replyToName,
    this.replies = const <ShowroomComment>[],
  });

  final String id;
  final String name;
  final String profileUrl;
  final String body;
  final String? emoticon;
  final String? replyToId;
  final String? replyToName;
  final DateTime createdAt;
  final List<ShowroomComment> replies;
}

/// 댓글을 새로 달 때 화면이 넘기는 내용. 작성자 정보는 서버가 채운다.
class ShowroomCommentRequest {
  const ShowroomCommentRequest({
    required this.showroomId,
    required this.body,
    this.emoticonUrl,
    this.replyToId,
  });

  final String showroomId;
  final String body;
  final String? emoticonUrl;
  final String? replyToId;
}

/// 댓글 작성 결과. [threadId]가 있으면 그 댓글의 답글을 펼친다.
class ShowroomCommentPosted {
  const ShowroomCommentPosted({required this.comments, this.threadId});

  final List<ShowroomComment> comments;
  final String? threadId;
}

int showroomCommentCount(List<ShowroomComment> comments) {
  var count = comments.length;
  for (final ShowroomComment comment in comments) {
    count += comment.replies.length;
  }
  return count;
}

/// 답글이 많은 순, 같으면 최근 순으로 [limit]개.
List<ShowroomComment> bestShowroomComments(
  List<ShowroomComment> comments, {
  int limit = 2,
}) {
  final List<ShowroomComment> sorted = List<ShowroomComment>.of(comments)
    ..sort((ShowroomComment a, ShowroomComment b) {
      final int byReplies = b.replies.length.compareTo(a.replies.length);
      if (byReplies != 0) return byReplies;
      return b.createdAt.compareTo(a.createdAt);
    });
  return sorted.take(limit).toList();
}
