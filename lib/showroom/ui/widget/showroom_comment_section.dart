import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';

class _Comment {
  _Comment({
    required this.id,
    required this.name,
    required this.profileUrl,
    required this.body,
    required this.createdAt,
    List<_Comment>? replies,
  }) : replies = replies ?? <_Comment>[];

  final String id;
  final String name;
  final String profileUrl;
  final String body;
  final DateTime createdAt;
  final List<_Comment> replies;
}

/// 전체 보기 본문 아래에는 베스트 댓글만 두고, 전체 목록은 시트로 연다.
class ShowroomBoardWithComments extends StatefulWidget {
  const ShowroomBoardWithComments({
    super.key,
    required this.leading,
    required this.authorName,
  });

  final List<Widget> leading;
  final String authorName;

  @override
  State<ShowroomBoardWithComments> createState() =>
      _ShowroomBoardWithCommentsState();
}

class _ShowroomBoardWithCommentsState extends State<ShowroomBoardWithComments> {
  final TextEditingController _text = TextEditingController();
  final ValueNotifier<int> _revision = ValueNotifier<int>(0);
  final Set<String> _expanded = <String>{};
  _Comment? _replyTo;

  late final List<_Comment> _comments = <_Comment>[
    _Comment(
      id: 'c1',
      name: '김서연',
      profileUrl: 'https://i.pravatar.cc/150?img=5',
      body: '홀 조명이 음식 색을 해치지 않아서 좋네요. 수조 쪽도 같은 톤인가요?',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      replies: <_Comment>[
        _Comment(
          id: 'c1-r1',
          name: '신짱구',
          profileUrl: 'https://i.pravatar.cc/150?img=1',
          body: '진열등만 4000K 아래로 맞췄어요. 수조는 조금 더 차갑게 뒀습니다.',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        _Comment(
          id: 'c1-r2',
          name: '박도윤',
          profileUrl: 'https://i.pravatar.cc/150?img=12',
          body: '자리에서도 수조가 노랗게 안 보이더라고요.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
        ),
      ],
    ),
    _Comment(
      id: 'c2',
      name: '이하린',
      profileUrl: 'https://i.pravatar.cc/150?img=9',
      body: '평수 대비 예산이 어느 정도인지 감이 옵니다.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    _Comment(
      id: 'c3',
      name: '최민재',
      profileUrl: 'https://i.pravatar.cc/150?img=15',
      body: '객석 간격 참고해서 저희 가게도 다시 재보려고요.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      replies: <_Comment>[
        _Comment(
          id: 'c3-r1',
          name: '신짱구',
          profileUrl: 'https://i.pravatar.cc/150?img=1',
          body: '의자를 뺀 뒤의 통로로 계산하면 됩니다.',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ],
    ),
    _Comment(
      id: 'c4',
      name: '정하늘',
      profileUrl: 'https://i.pravatar.cc/150?img=20',
      body: '바닥 마감이 기름에 강해 보여서 업종에 잘 맞는 것 같아요.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  @override
  void dispose() {
    _text.dispose();
    _revision.dispose();
    super.dispose();
  }

  int get _total {
    var count = _comments.length;
    for (final _Comment comment in _comments) {
      count += comment.replies.length;
    }
    return count;
  }

  List<_Comment> get _best {
    final List<_Comment> sorted = List<_Comment>.of(_comments)..sort((
      _Comment a,
      _Comment b,
    ) {
      final int byReplies = b.replies.length.compareTo(a.replies.length);
      if (byReplies != 0) return byReplies;
      return b.createdAt.compareTo(a.createdAt);
    });
    return sorted.take(2).toList();
  }

  void _bump() => _revision.value++;

  void _send() {
    final String body = _text.text.trim();
    if (body.isEmpty) return;
    setState(() {
      final _Comment next = _Comment(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: '나',
        profileUrl: 'https://i.pravatar.cc/150?img=3',
        body: body,
        createdAt: DateTime.now(),
      );
      final _Comment? parent = _replyTo;
      if (parent == null) {
        _comments.insert(0, next);
      } else {
        parent.replies.add(next);
        _replyTo = null;
      }
      _text.clear();
    });
    _bump();
  }

  Future<void> _report(_Comment comment) async {
    final bool? sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ReportSheet(name: comment.name),
    );
    if (!mounted || sent != true) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${comment.name}님의 댓글을 신고했어요')));
  }

  void _openAll() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final double keyboard = MediaQuery.viewInsetsOf(context).bottom;
        final double height = MediaQuery.sizeOf(context).height * 0.88;
        return Padding(
          padding: EdgeInsets.only(bottom: keyboard),
          child: SizedBox(
            height: height,
            child: ValueListenableBuilder<int>(
              valueListenable: _revision,
              builder: (context, _, __) {
                return _AllCommentsSheet(
                  total: _total,
                  authorName: widget.authorName,
                  comments: _comments,
                  expanded: _expanded,
                  replyName: _replyTo?.name,
                  text: _text,
                  onToggle: (String id) {
                    setState(() {
                      if (!_expanded.add(id)) _expanded.remove(id);
                    });
                    _bump();
                  },
                  onReply: (_Comment comment) {
                    setState(() => _replyTo = comment);
                    _bump();
                  },
                  onCancelReply: () {
                    setState(() => _replyTo = null);
                    _bump();
                  },
                  onReport: _report,
                  onSend: _send,
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.paddingOf(context).bottom;
    final List<_Comment> best = _best;
    return Column(
      children: [
        Expanded(
          child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          children: [
            ...widget.leading,
            const SizedBox(height: 28),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE7E1D8)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '댓글 $_total',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        if (_comments.isNotEmpty)
                          GestureDetector(
                            onTap: _openAll,
                            behavior: HitTestBehavior.opaque,
                            child: const Text(
                              '모두 보기',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (_comments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          '첫 댓글을 남겨 주세요',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      )
                    else
                      for (final _Comment comment in best)
                        _CommentCard(
                          comment: comment,
                          authorName: widget.authorName,
                          expanded: _expanded.contains(comment.id),
                          onToggle: () {
                            setState(() {
                              if (!_expanded.add(comment.id)) {
                                _expanded.remove(comment.id);
                              }
                            });
                          },
                          onReply: () => setState(() => _replyTo = comment),
                          onReport: _report,
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
        _ComposerBar(
          controller: _text,
          replyName: _replyTo?.name,
          bottom: bottom,
          onCancelReply: () => setState(() => _replyTo = null),
          onSend: _send,
        ),
      ],
    );
  }
}

class _AllCommentsSheet extends StatelessWidget {
  const _AllCommentsSheet({
    required this.total,
    required this.authorName,
    required this.comments,
    required this.expanded,
    required this.replyName,
    required this.text,
    required this.onToggle,
    required this.onReply,
    required this.onCancelReply,
    required this.onReport,
    required this.onSend,
  });

  final int total;
  final String authorName;
  final List<_Comment> comments;
  final Set<String> expanded;
  final String? replyName;
  final TextEditingController text;
  final ValueChanged<String> onToggle;
  final ValueChanged<_Comment> onReply;
  final VoidCallback onCancelReply;
  final ValueChanged<_Comment> onReport;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.paddingOf(context).bottom;
    return Column(
      children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '댓글 $total',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                children: [
                  for (final _Comment comment in comments)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CommentCard(
                        comment: comment,
                        authorName: authorName,
                        expanded: expanded.contains(comment.id),
                        onToggle: () => onToggle(comment.id),
                        onReply: () => onReply(comment),
                        onReport: onReport,
                      ),
                    ),
                ],
              ),
            ),
        _ComposerBar(
          controller: text,
          replyName: replyName,
          bottom: bottom,
          onCancelReply: onCancelReply,
          onSend: onSend,
        ),
      ],
    );
  }
}

class _CommentCard extends StatelessWidget {
  const _CommentCard({
    required this.comment,
    required this.authorName,
    required this.expanded,
    required this.onToggle,
    required this.onReply,
    required this.onReport,
  });

  final _Comment comment;
  final String authorName;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onReply;
  final ValueChanged<_Comment> onReport;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CommentRow(
            comment: comment,
            isAuthor: comment.name == authorName,
            onReply: onReply,
            onReport: () => onReport(comment),
          ),
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: GestureDetector(
                onTap: onToggle,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Container(width: 24, height: 1, color: AppColors.border),
                    const SizedBox(width: 10),
                    Text(
                      expanded ? '답글 숨기기' : '답글 ${comment.replies.length}개 보기',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (expanded)
              for (final _Comment reply in comment.replies)
                Padding(
                  padding: const EdgeInsets.only(left: 44, top: 12),
                  child: _CommentRow(
                    comment: reply,
                    isAuthor: reply.name == authorName,
                    compact: true,
                    onReply: onReply,
                    onReport: () => onReport(reply),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _CommentRow extends StatelessWidget {
  const _CommentRow({
    required this.comment,
    required this.isAuthor,
    required this.onReply,
    required this.onReport,
    this.compact = false,
  });

  final _Comment comment;
  final bool isAuthor;
  final VoidCallback onReply;
  final VoidCallback onReport;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double nameSize = compact ? 13 : 14;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Avatar(url: comment.profileUrl, radius: compact ? 12 : 16),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      comment.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: nameSize,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (isAuthor)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          child: Text(
                            '글쓴이',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onReport,
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.more_horiz,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comment.body,
                style: TextStyle(
                  fontSize: compact ? 14 : 15,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  letterSpacing: -0.2,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    _ago(comment.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: onReply,
                    behavior: HitTestBehavior.opaque,
                    child: const Text(
                      '답글',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ComposerBar extends StatelessWidget {
  const _ComposerBar({
    required this.controller,
    required this.replyName,
    required this.bottom,
    required this.onCancelReply,
    required this.onSend,
  });

  final TextEditingController controller;
  final String? replyName;
  final double bottom;
  final VoidCallback onCancelReply;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 12, bottom + 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (replyName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$replyName님에게 답글',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onCancelReply,
                      behavior: HitTestBehavior.opaque,
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const _Avatar(
                  url: 'https://i.pravatar.cc/150?img=3',
                  radius: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.2,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText:
                          replyName == null ? '댓글을 남겨 주세요' : '답글을 남겨 주세요',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        height: 1.2,
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) {
                    final bool ready = controller.text.trim().isNotEmpty;
                    return IconButton(
                      onPressed: ready ? onSend : null,
                      style: IconButton.styleFrom(
                        fixedSize: const Size(36, 36),
                        minimumSize: const Size(36, 36),
                        maximumSize: const Size(36, 36),
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor: AppColors.background,
                        disabledForegroundColor: AppColors.textSecondary,
                        shape: const CircleBorder(),
                      ),
                      icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({required this.name});

  final String name;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  static const List<String> _reasons = ['스팸', '욕설 · 비방', '광고', '기타'];

  final TextEditingController _detail = TextEditingController();
  String? _selected;

  @override
  void dispose() {
    _detail.dispose();
    super.dispose();
  }

  bool get _canSend =>
      _selected != null && _detail.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final double keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${widget.name}님의 댓글 신고',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final String reason in _reasons)
                    GestureDetector(
                      onTap: () => setState(() => _selected = reason),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color:
                              _selected == reason
                                  ? AppColors.primary
                                  : AppColors.background,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Text(
                            reason,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color:
                                  _selected == reason
                                      ? AppColors.white
                                      : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _detail,
                minLines: 3,
                maxLines: 5,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '신고 이유를 적어 주세요',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _canSend ? () => Navigator.pop(context, true) : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.border,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '신고하기',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, this.radius = 16});

  final String url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final double size = radius * 2;
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: AppNetworkImage(url: url, width: size, height: size),
      ),
    );
  }
}

String _ago(DateTime time) {
  final Duration gap = DateTime.now().difference(time);
  if (gap.inMinutes < 1) return '방금';
  if (gap.inHours < 1) return '${gap.inMinutes}분 전';
  if (gap.inHours < 24) return '${gap.inHours}시간 전';
  if (gap.inDays < 7) return '${gap.inDays}일 전';
  return '${time.month}월 ${time.day}일';
}
