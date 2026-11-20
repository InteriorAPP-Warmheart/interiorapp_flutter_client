import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_asset_image.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/showroom_body.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/showroom_comment.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/provider/showroom_comment_provider.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_photo_gallery.dart';

/// 표지처럼 댓글 수를 알아야 하는 머리글.
typedef ShowroomBoardHeader =
    List<Widget> Function(int commentCount, VoidCallback jumpToComments);

/// 전체 보기 본문 아래에는 베스트 댓글만 두고, 전체 목록은 시트로 연다.
class ShowroomBoardWithComments extends ConsumerStatefulWidget {
  const ShowroomBoardWithComments({
    super.key,
    required this.showroomId,
    required this.headerSlivers,
    required this.leading,
    required this.authorName,
    this.likes = '',
    this.favorite = false,
    this.onFavorite,
  });

  final String showroomId;
  final ShowroomBoardHeader headerSlivers;
  final List<Widget> leading;
  final String authorName;
  final String likes;
  final bool favorite;
  final VoidCallback? onFavorite;

  @override
  ConsumerState<ShowroomBoardWithComments> createState() =>
      _ShowroomBoardWithCommentsState();
}

class _ShowroomBoardWithCommentsState
    extends ConsumerState<ShowroomBoardWithComments> {
  final TextEditingController _text = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final ValueNotifier<int> _revision = ValueNotifier<int>(0);
  final Set<String> _expanded = <String>{};
  ShowroomComment? _replyTo;
  bool _emojiOpen = false;
  String? _emoticon;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      if (!mounted) return;
      ref.read(showroomCommentProvider.notifier).load(widget.showroomId);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _text.dispose();
    _revision.dispose();
    super.dispose();
  }

  Future<void> _jumpToEdge(bool top) {
    if (!_scroll.hasClients) return Future<void>.value();
    final ScrollPosition position = _scroll.position;
    // 하단 여백은 캡슐에 가리지 않으려고 넣은 빈 칸이라, 맨 아래는 내용이
    // 화면 아래에 닿는 곳에서 멈춘다.
    final double tail = showroomReadingDockClearance(context) + 20;
    final double end = (position.maxScrollExtent - tail).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    final double goal = top ? position.minScrollExtent : end;
    return _scroll.animateTo(
      goal,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  List<ShowroomComment> get _comments {
    return ref.read(showroomCommentProvider).of(widget.showroomId);
  }

  bool get _ready =>
      ref.read(showroomCommentProvider).isReady(widget.showroomId);

  int get _total => showroomCommentCount(_comments);

  List<ShowroomComment> get _best => bestShowroomComments(_comments);

  void _bump() => _revision.value++;

  Future<void> _send() async {
    final String body = _text.text.trim();
    final String? emoticon = _emoticon;
    if (body.isEmpty && emoticon == null) return;
    final ShowroomCommentPosted? posted = await ref
        .read(showroomCommentProvider.notifier)
        .add(
          ShowroomCommentRequest(
            showroomId: widget.showroomId,
            body: body,
            emoticonUrl: emoticon,
            replyToId: _replyTo?.id,
          ),
        );
    if (!mounted || posted == null) return;
    setState(() {
      final String? threadId = posted.threadId;
      if (threadId != null) _expanded.add(threadId);
      _replyTo = null;
      _text.clear();
      _emoticon = null;
      _emojiOpen = false;
    });
    _bump();
  }

  void _toggleEmoji() {
    setState(() => _emojiOpen = !_emojiOpen);
    _bump();
  }

  void _pickEmoji(String url) {
    setState(() {
      _emoticon = url;
      _emojiOpen = false;
    });
    _bump();
  }

  void _clearEmoji() {
    setState(() => _emoticon = null);
    _bump();
  }

  Future<void> _report(ShowroomComment comment) async {
    final _ReportDraft? sent = await showModalBottomSheet<_ReportDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ReportSheet(name: comment.name),
    );
    if (!mounted || sent == null) return;
    await ref
        .read(showroomCommentProvider.notifier)
        .report(
          showroomId: widget.showroomId,
          commentId: comment.id,
          reason: sent.reason,
          detail: sent.detail,
        );
    if (!mounted) return;
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
                  onReply: (ShowroomComment comment) {
                    setState(() => _replyTo = comment);
                    _bump();
                  },
                  onCancelReply: () {
                    setState(() => _replyTo = null);
                    _bump();
                  },
                  onReport: _report,
                  onSend: _send,
                  emojiOpen: _emojiOpen,
                  emoticon: _emoticon,
                  onToggleEmoji: _toggleEmoji,
                  onPickEmoji: _pickEmoji,
                  onClearEmoji: _clearEmoji,
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
    ref.watch(showroomCommentProvider);
    final List<ShowroomComment> best = _best;
    final double clearance = showroomReadingDockClearance(context) + 20;
    return Stack(
      children: [
        Positioned.fill(
          child: CustomScrollView(
            controller: _scroll,
            physics: const ClampingScrollPhysics(),
            slivers: [
              ...widget.headerSlivers(_total, _openAll),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(0, 4, 0, clearance),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    ...widget.leading,
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
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
                              if (!_ready)
                                const SizedBox.shrink()
                              else if (_comments.isEmpty)
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
                                for (final ShowroomComment comment in best)
                                  _ShowroomCommentCard(
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
                                    onReply: (ShowroomComment target) {
                                      setState(() => _replyTo = target);
                                      _openAll();
                                    },
                                    onReport: _report,
                                  ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _ReadingDock(
            likes: widget.likes,
            favorite: widget.favorite,
            commentCount: _total,
            onFavorite: widget.onFavorite,
            onOpenComments: _openAll,
            onTop: () => _jumpToEdge(true),
            onBottom: () => _jumpToEdge(false),
          ),
        ),
      ],
    );
  }
}

const double showroomReadingDockHeight = 46;

/// 게시글에는 탭바가 없어서 홈 표시 바로 위에 붙인다.
/// 하단 여백이 없는 기기는 모서리가 잘리지 않을 만큼만 띄운다.
double showroomReadingDockBottom(BuildContext context) {
  final double safe = MediaQuery.viewPaddingOf(context).bottom;
  if (safe >= 20) return safe + 2;
  return 8;
}

/// 댓글 입력창이 펼쳐졌을 때의 좌우 여백.
double showroomComposerSide(BuildContext context) {
  final double inset = ResponsiveSize.textInset(context).left;
  return inset < 20 ? 20 : inset;
}

double showroomComposerWidth(BuildContext context) {
  return MediaQuery.sizeOf(context).width - showroomComposerSide(context) * 2;
}

/// 좋아요·댓글·스크롤 캡슐. 화면보다 좁게 가운데 둔다.
double showroomReadingDockWidth(BuildContext context) {
  final double screen = MediaQuery.sizeOf(context).width;
  final double full = showroomComposerWidth(context);
  final double side = screen >= 600 ? 200.0 : 80.0;
  final double narrow = screen - side * 2;
  const double minWidth = 248;
  if (narrow < minWidth) return full < minWidth ? full : minWidth;
  if (narrow > full) return full;
  return narrow > 300 ? 300 : narrow;
}

double showroomReadingDockClearance(BuildContext context) {
  return showroomReadingDockHeight + showroomReadingDockBottom(context);
}

BoxDecoration showroomReadingDockDecoration(double height, {double? radius}) {
  return BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.circular(radius ?? height / 2),
    border: Border.all(color: const Color(0xFFD3D8E0)),
    boxShadow: const [
      BoxShadow(color: Color(0x2A0B1F38), blurRadius: 22, offset: Offset(0, 8)),
      BoxShadow(color: Color(0x140B1F38), blurRadius: 3, offset: Offset(0, 1)),
    ],
  );
}

class _AllCommentsSheet extends StatefulWidget {
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
    required this.emojiOpen,
    required this.emoticon,
    required this.onToggleEmoji,
    required this.onPickEmoji,
    required this.onClearEmoji,
  });

  final int total;
  final String authorName;
  final List<ShowroomComment> comments;
  final Set<String> expanded;
  final String? replyName;
  final TextEditingController text;
  final ValueChanged<String> onToggle;
  final ValueChanged<ShowroomComment> onReply;
  final VoidCallback onCancelReply;
  final ValueChanged<ShowroomComment> onReport;
  final VoidCallback onSend;
  final bool emojiOpen;
  final String? emoticon;
  final VoidCallback onToggleEmoji;
  final ValueChanged<String> onPickEmoji;
  final VoidCallback onClearEmoji;

  @override
  State<_AllCommentsSheet> createState() => _AllCommentsSheetState();
}

class _AllCommentsSheetState extends State<_AllCommentsSheet> {
  final ScrollController _scroll = ScrollController();
  double _composerHeight = 0;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onComposerHeight(double next) {
    final double delta = next - _composerHeight;
    if (delta.abs() < 0.5) return;
    final bool first = _composerHeight == 0;
    final double pixels = _scroll.hasClients ? _scroll.position.pixels : 0;
    setState(() => _composerHeight = next);
    if (first || !_scroll.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final ScrollPosition position = _scroll.position;
      final double goal = (pixels + delta).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      if ((goal - position.pixels).abs() < 0.5) return;
      _scroll.jumpTo(goal);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final double composerBottom =
        keyboard > 0 ? 12 : showroomReadingDockBottom(context);
    double estimate = composerBottom + showroomReadingDockHeight + 24;
    if (widget.replyName != null) estimate += 28;
    if (widget.emojiOpen) estimate += 72;
    if (widget.emoticon != null) estimate += showroomEmoticonSize + 36;
    final double listBottom = _composerHeight > 0 ? _composerHeight : estimate;
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
              '댓글 ${widget.total}',
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
          child: Stack(
            children: [
              ListView(
                controller: _scroll,
                padding: EdgeInsets.fromLTRB(16, 4, 16, listBottom),
                children: [
                  for (final ShowroomComment comment in widget.comments)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ShowroomCommentCard(
                        comment: comment,
                        authorName: widget.authorName,
                        expanded: widget.expanded.contains(comment.id),
                        onToggle: () => widget.onToggle(comment.id),
                        onReply: widget.onReply,
                        onReport: widget.onReport,
                      ),
                    ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _MeasureHeight(
                  onChange: _onComposerHeight,
                  child: _ComposerBar(
                    controller: widget.text,
                    replyName: widget.replyName,
                    emojiOpen: widget.emojiOpen,
                    emoticon: widget.emoticon,
                    onToggleEmoji: widget.onToggleEmoji,
                    onPickEmoji: widget.onPickEmoji,
                    onClearEmoji: widget.onClearEmoji,
                    onCancelReply: widget.onCancelReply,
                    onSend: widget.onSend,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MeasureHeight extends SingleChildRenderObjectWidget {
  const _MeasureHeight({required this.onChange, required super.child});

  final ValueChanged<double> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMeasureHeight(onChange);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderMeasureHeight renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class _RenderMeasureHeight extends RenderProxyBox {
  _RenderMeasureHeight(this.onChange);

  ValueChanged<double> onChange;
  double? _reported;

  @override
  void performLayout() {
    super.performLayout();
    final double next = size.height;
    if (_reported != null && (next - _reported!).abs() < 0.5) return;
    _reported = next;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_reported != next) return;
      onChange(next);
    });
  }
}

class _ShowroomCommentCard extends StatelessWidget {
  const _ShowroomCommentCard({
    required this.comment,
    required this.authorName,
    required this.expanded,
    required this.onToggle,
    required this.onReply,
    required this.onReport,
  });

  final ShowroomComment comment;
  final String authorName;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<ShowroomComment> onReply;
  final ValueChanged<ShowroomComment> onReport;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ShowroomCommentRow(
            comment: comment,
            isAuthor: comment.name == authorName,
            onReply: () => onReply(comment),
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
              for (final ShowroomComment reply in comment.replies)
                Padding(
                  padding: const EdgeInsets.only(left: 44, top: 12),
                  child: _ShowroomCommentRow(
                    comment: reply,
                    isAuthor: reply.name == authorName,
                    compact: true,
                    onReply: () => onReply(reply),
                    onReport: () => onReport(reply),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _ShowroomCommentRow extends StatelessWidget {
  const _ShowroomCommentRow({
    required this.comment,
    required this.isAuthor,
    required this.onReply,
    required this.onReport,
    this.compact = false,
  });

  final ShowroomComment comment;
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
                ],
              ),
              const SizedBox(height: 4),
              if (comment.emoticon != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: AppAssetImage(
                    comment.emoticon!,
                    width: showroomEmoticonSize,
                    height: showroomEmoticonSize,
                    fit: BoxFit.contain,
                  ),
                ),
              if (comment.body.isNotEmpty || comment.replyToName != null) ...[
                if (comment.emoticon != null) const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      if (comment.replyToName != null)
                        TextSpan(
                          text: comment.replyToName,
                          style: TextStyle(
                            fontSize: compact ? 14 : 15,
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                            letterSpacing: -0.2,
                            color: AppColors.primary,
                          ),
                        ),
                      if (comment.body.isNotEmpty)
                        TextSpan(
                          text:
                              comment.replyToName == null
                                  ? comment.body
                                  : '  ${comment.body}',
                        ),
                    ],
                  ),
                  style: TextStyle(
                    fontSize: compact ? 14 : 15,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    letterSpacing: -0.2,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
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
        GestureDetector(
          onTap: onReport,
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.only(left: 12, top: 1),
            child: Icon(
              Icons.more_horiz,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReadingDock extends StatelessWidget {
  const _ReadingDock({
    required this.likes,
    required this.favorite,
    required this.commentCount,
    required this.onFavorite,
    required this.onOpenComments,
    required this.onTop,
    required this.onBottom,
  });

  final String likes;
  final bool favorite;
  final int commentCount;
  final VoidCallback? onFavorite;
  final VoidCallback onOpenComments;
  final VoidCallback onTop;
  final VoidCallback onBottom;

  @override
  Widget build(BuildContext context) {
    const Color heart = Color(0xFFFF4D6A);
    final double height = showroomReadingDockHeight;
    return Padding(
      padding: EdgeInsets.only(bottom: showroomReadingDockBottom(context)),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: showroomReadingDockWidth(context),
          child: DecoratedBox(
            decoration: showroomReadingDockDecoration(height),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(height / 2),
              child: Material(
                color: Colors.transparent,
                child: SizedBox(
                  height: height,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: onFavorite,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                favorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 20,
                                color: favorite ? heart : AppColors.textPrimary,
                              ),
                              if (likes.isNotEmpty) ...[
                                const SizedBox(width: 5),
                                Text(
                                  likes,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const _DockDivider(),
                      Expanded(
                        child: InkWell(
                          onTap: onOpenComments,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.mode_comment_outlined,
                                  size: 18,
                                  color: AppColors.textPrimary,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  '댓글',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$commentCount',
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
                      ),
                      const _DockDivider(),
                      _ScrollMark(icon: Icons.keyboard_arrow_up, onTap: onTop),
                      _ScrollMark(
                        icon: Icons.keyboard_arrow_down,
                        onTap: onBottom,
                      ),
                      const SizedBox(width: 2),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockDivider extends StatelessWidget {
  const _DockDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 1,
      height: 18,
      child: ColoredBox(color: AppColors.border),
    );
  }
}

class _ScrollMark extends StatelessWidget {
  const _ScrollMark({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _ComposerBar extends StatefulWidget {
  const _ComposerBar({
    required this.controller,
    required this.replyName,
    required this.emojiOpen,
    required this.emoticon,
    required this.onToggleEmoji,
    required this.onPickEmoji,
    required this.onClearEmoji,
    required this.onCancelReply,
    required this.onSend,
  });

  final TextEditingController controller;
  final String? replyName;
  final bool emojiOpen;
  final String? emoticon;
  final VoidCallback onToggleEmoji;
  final ValueChanged<String> onPickEmoji;
  final VoidCallback onClearEmoji;
  final VoidCallback onCancelReply;
  final VoidCallback onSend;

  @override
  State<_ComposerBar> createState() => _ComposerBarState();
}

class _ComposerBarState extends State<_ComposerBar>
    with SingleTickerProviderStateMixin {
  final FocusNode _focus = FocusNode();
  late final AnimationController _expand;

  @override
  void initState() {
    super.initState();
    _expand = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _focus.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(covariant _ComposerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.emojiOpen != widget.emojiOpen) _syncSpan();
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _expand.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onFocus() {
    if (!_focus.hasFocus && widget.emojiOpen) {
      widget.onToggleEmoji();
      _expand.reverse();
      return;
    }
    _syncSpan();
  }

  void _syncSpan() {
    final bool open = _focus.hasFocus || widget.emojiOpen;
    if (open) {
      _expand.forward();
    } else {
      _expand.reverse();
    }
  }

  void _toggleEmoji() {
    final bool opening = !widget.emojiOpen;
    widget.onToggleEmoji();
    if (opening) _focus.requestFocus();
  }

  void _attachEmoji(String url) {
    widget.onPickEmoji(url);
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final String? replyName = widget.replyName;
    final String? emoticon = widget.emoticon;
    final double keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final double bottom =
        keyboard > 0 ? 12 : showroomReadingDockBottom(context);
    final double narrow = showroomReadingDockWidth(context);
    final double wide = showroomComposerWidth(context);
    final double radius = showroomReadingDockHeight / 2;
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 8, 0, bottom),
      child: AnimatedBuilder(
        animation: _expand,
        builder: (BuildContext context, Widget? child) {
          final double t = Curves.easeInOutCubic.transform(_expand.value);
          final double width = narrow + (wide - narrow) * t;
          return Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(width: width, child: child),
          );
        },
        child: TextFieldTapRegion(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        onTap: widget.onCancelReply,
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
              if (widget.emojiOpen)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0x990B1F38),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          for (final String url in showroomEmojiCatalog)
                            GestureDetector(
                              onTap: () => _attachEmoji(url),
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: AppAssetImage(
                                  url,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              DecoratedBox(
                decoration: showroomReadingDockDecoration(
                  showroomReadingDockHeight,
                  radius: radius,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (emoticon != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                AppAssetImage(
                                  emoticon,
                                  width: showroomEmoticonSize,
                                  height: showroomEmoticonSize,
                                  fit: BoxFit.contain,
                                ),
                                Positioned(
                                  top: -6,
                                  right: -6,
                                  child: GestureDetector(
                                    onTap: widget.onClearEmoji,
                                    behavior: HitTestBehavior.opaque,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFFD3D8E0),
                                        ),
                                      ),
                                      child: const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: Icon(
                                          Icons.close,
                                          size: 14,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight: showroomReadingDockHeight,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: _toggleEmoji,
                                style: IconButton.styleFrom(
                                  fixedSize: const Size(36, 36),
                                  minimumSize: const Size(36, 36),
                                  maximumSize: const Size(36, 36),
                                  padding: EdgeInsets.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  foregroundColor:
                                      widget.emojiOpen
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                ),
                                icon: const Icon(
                                  Icons.emoji_emotions_outlined,
                                  size: 20,
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: widget.controller,
                                  focusNode: _focus,
                                  minLines: 1,
                                  maxLines: 4,
                                  textAlignVertical: TextAlignVertical.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.3,
                                    color: AppColors.textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText:
                                        replyName == null
                                            ? '댓글을 남겨 주세요'
                                            : '답글을 남겨 주세요',
                                    hintStyle: const TextStyle(
                                      fontSize: 14,
                                      height: 1.3,
                                      color: AppColors.textSecondary,
                                    ),
                                    filled: false,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                              ListenableBuilder(
                                listenable: widget.controller,
                                builder: (context, _) {
                                  final bool ready =
                                      widget.controller.text
                                          .trim()
                                          .isNotEmpty ||
                                      emoticon != null;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: IconButton(
                                      onPressed: ready ? widget.onSend : null,
                                      style: IconButton.styleFrom(
                                        fixedSize: const Size(30, 30),
                                        minimumSize: const Size(30, 30),
                                        maximumSize: const Size(30, 30),
                                        padding: EdgeInsets.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        backgroundColor:
                                            ready
                                                ? AppColors.primary
                                                : const Color(0xFFE3E6EB),
                                        foregroundColor:
                                            ready
                                                ? AppColors.white
                                                : AppColors.textSecondary,
                                        disabledBackgroundColor: const Color(
                                          0xFFE3E6EB,
                                        ),
                                        disabledForegroundColor:
                                            AppColors.textSecondary,
                                        shape: const CircleBorder(),
                                      ),
                                      icon: const Icon(
                                        Icons.arrow_upward_rounded,
                                        size: 16,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportDraft {
  const _ReportDraft(this.reason, this.detail);

  final String reason;
  final String detail;
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

  bool get _canSend => _selected != null && _detail.text.trim().isNotEmpty;

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
                onPressed:
                    _canSend
                        ? () => Navigator.pop(
                          context,
                          _ReportDraft(_selected!, _detail.text.trim()),
                        )
                        : null,
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
