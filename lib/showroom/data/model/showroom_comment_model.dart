/// 댓글 API JSON. 서버 연동 때는 이 파싱만 맞추면 된다.
class ShowroomCommentModel {
  const ShowroomCommentModel({
    required this.id,
    required this.authorName,
    required this.profileUrl,
    required this.body,
    required this.createdAt,
    this.emoticonUrl,
    this.replyToId,
    this.replyToName,
    this.replies = const <ShowroomCommentModel>[],
  });

  final String id;
  final String authorName;
  final String profileUrl;
  final String body;
  final String? emoticonUrl;
  final String? replyToId;
  final String? replyToName;
  final DateTime createdAt;
  final List<ShowroomCommentModel> replies;

  factory ShowroomCommentModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawReplies =
        json['replies'] is List<dynamic>
            ? json['replies'] as List<dynamic>
            : const <dynamic>[];
    return ShowroomCommentModel(
      id: json['id']?.toString() ?? '',
      authorName: json['authorName']?.toString() ?? '',
      profileUrl: json['profileUrl']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      emoticonUrl: json['emoticonUrl']?.toString(),
      replyToId: json['replyToId']?.toString(),
      replyToName: json['replyToName']?.toString(),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      replies: <ShowroomCommentModel>[
        for (final dynamic item in rawReplies)
          if (item is Map<String, dynamic>) ShowroomCommentModel.fromJson(item),
      ],
    );
  }

  static List<ShowroomCommentModel> listFromJson(List<dynamic> raw) {
    return <ShowroomCommentModel>[
      for (final dynamic item in raw)
        if (item is Map<String, dynamic>) ShowroomCommentModel.fromJson(item),
    ];
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'authorName': authorName,
      'profileUrl': profileUrl,
      'body': body,
      if (emoticonUrl != null) 'emoticonUrl': emoticonUrl,
      if (replyToId != null) 'replyToId': replyToId,
      if (replyToName != null) 'replyToName': replyToName,
      'createdAt': createdAt.toIso8601String(),
      'replies':
          replies.map((ShowroomCommentModel reply) => reply.toJson()).toList(),
    };
  }

  ShowroomCommentModel copyWith({List<ShowroomCommentModel>? replies}) {
    return ShowroomCommentModel(
      id: id,
      authorName: authorName,
      profileUrl: profileUrl,
      body: body,
      createdAt: createdAt,
      emoticonUrl: emoticonUrl,
      replyToId: replyToId,
      replyToName: replyToName,
      replies: replies ?? this.replies,
    );
  }
}
