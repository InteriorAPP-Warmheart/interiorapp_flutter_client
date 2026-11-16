import 'package:interiorapp_flutter_client/showroom/data/model/showroom_comment_model.dart';

/// 댓글 목 서버. 실제 연동 때는 이 클래스의 요청만 HTTP로 바꾼다.
class ShowroomCommentApi {
  final Map<String, List<ShowroomCommentModel>> _byShowroom =
      <String, List<ShowroomCommentModel>>{};
  final List<Map<String, String>> _reports = <Map<String, String>>[];

  Future<List<ShowroomCommentModel>> fetch(String showroomId) async {
    return List<ShowroomCommentModel>.of(
      _byShowroom.putIfAbsent(showroomId, _seed),
    );
  }

  Future<({List<ShowroomCommentModel> comments, String? threadId})> create({
    required String showroomId,
    required String body,
    String? emoticonUrl,
    String? replyToId,
  }) async {
    final List<ShowroomCommentModel> current = await fetch(showroomId);
    final ShowroomCommentModel? target =
        replyToId == null ? null : _find(current, replyToId);
    final ShowroomCommentModel created = ShowroomCommentModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      authorName: '나',
      profileUrl: 'https://i.pravatar.cc/150?img=3',
      body: body,
      emoticonUrl: emoticonUrl,
      replyToId: replyToId,
      replyToName: target?.authorName,
      createdAt: DateTime.now(),
    );
    final String? threadId =
        replyToId == null ? null : _rootId(current, replyToId);
    final List<ShowroomCommentModel> next =
        threadId == null
            ? <ShowroomCommentModel>[created, ...current]
            : <ShowroomCommentModel>[
              for (final ShowroomCommentModel comment in current)
                comment.id == threadId
                    ? comment.copyWith(
                      replies: <ShowroomCommentModel>[
                        ...comment.replies,
                        created,
                      ],
                    )
                    : comment,
            ];
    _byShowroom[showroomId] = next;
    return (comments: next, threadId: threadId);
  }

  Future<void> report({
    required String showroomId,
    required String commentId,
    required String reason,
    required String detail,
  }) async {
    _reports.add(<String, String>{
      'showroomId': showroomId,
      'commentId': commentId,
      'reason': reason,
      'detail': detail,
    });
  }

  List<ShowroomCommentModel> _seed() {
    final DateTime now = DateTime.now();
    return ShowroomCommentModel.listFromJson(<Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'c1',
        'authorName': '김서연',
        'profileUrl': 'https://i.pravatar.cc/150?img=5',
        'body': '홀 조명이 음식 색을 해치지 않아서 좋네요. 수조 쪽도 같은 톤인가요?',
        'createdAt': now.subtract(const Duration(hours: 2)).toIso8601String(),
        'replies': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'c1-r1',
            'authorName': '신짱구',
            'profileUrl': 'https://i.pravatar.cc/150?img=1',
            'replyToId': 'c1',
            'replyToName': '김서연',
            'body': '진열등만 4000K 아래로 맞췄어요. 수조는 조금 더 차갑게 뒀습니다.',
            'createdAt':
                now.subtract(const Duration(hours: 1)).toIso8601String(),
          },
          <String, dynamic>{
            'id': 'c1-r2',
            'authorName': '박도윤',
            'profileUrl': 'https://i.pravatar.cc/150?img=12',
            'replyToId': 'c1',
            'replyToName': '김서연',
            'body': '자리에서도 수조가 노랗게 안 보이더라고요.',
            'createdAt':
                now.subtract(const Duration(minutes: 40)).toIso8601String(),
          },
        ],
      },
      <String, dynamic>{
        'id': 'c2',
        'authorName': '이하린',
        'profileUrl': 'https://i.pravatar.cc/150?img=9',
        'body': '평수 대비 예산이 어느 정도인지 감이 옵니다.',
        'createdAt': now.subtract(const Duration(days: 1)).toIso8601String(),
      },
      <String, dynamic>{
        'id': 'c3',
        'authorName': '최민재',
        'profileUrl': 'https://i.pravatar.cc/150?img=15',
        'body': '객석 간격 참고해서 저희 가게도 다시 재보려고요.',
        'createdAt': now.subtract(const Duration(days: 3)).toIso8601String(),
        'replies': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'c3-r1',
            'authorName': '신짱구',
            'profileUrl': 'https://i.pravatar.cc/150?img=1',
            'replyToId': 'c3',
            'replyToName': '최민재',
            'body': '의자를 뺀 뒤의 통로로 계산하면 됩니다.',
            'createdAt':
                now.subtract(const Duration(days: 2)).toIso8601String(),
          },
        ],
      },
      <String, dynamic>{
        'id': 'c4',
        'authorName': '정하늘',
        'profileUrl': 'https://i.pravatar.cc/150?img=20',
        'body': '바닥 마감이 기름에 강해 보여서 업종에 잘 맞는 것 같아요.',
        'createdAt': now.subtract(const Duration(days: 5)).toIso8601String(),
      },
    ]);
  }

  ShowroomCommentModel? _find(List<ShowroomCommentModel> comments, String id) {
    for (final ShowroomCommentModel comment in comments) {
      if (comment.id == id) return comment;
      final ShowroomCommentModel? nested = _find(comment.replies, id);
      if (nested != null) return nested;
    }
    return null;
  }

  String? _rootId(List<ShowroomCommentModel> comments, String id) {
    for (final ShowroomCommentModel comment in comments) {
      if (comment.id == id || _find(comment.replies, id) != null) {
        return comment.id;
      }
    }
    return null;
  }
}
