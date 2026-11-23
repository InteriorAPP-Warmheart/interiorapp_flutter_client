import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/construction_progress.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/work_quote.dart';
import 'package:interiorapp_flutter_client/build/presentation/provider/build_provider.dart';
import 'package:interiorapp_flutter_client/build/presentation/vm/space_board_vm.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/estimate_reader_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/site_photo_library_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/space_routes.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/widget/confirm_glow.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/notification/domain/app_notice.dart';
import 'package:interiorapp_flutter_client/notification/presentation/notice_inbox_provider.dart';

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState
    extends ConsumerState<NotificationCenterScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() {
      if (_tabs.indexIsChanging) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<AppNotice> feed = ref.watch(noticeFeedProvider);
    final Set<String> read = ref.watch(noticeReadProvider);
    final Set<String> dismissed = ref.watch(noticeDismissProvider);
    final List<AppNotice> visible = <AppNotice>[
      for (final AppNotice notice in feed)
        if (!dismissed.contains(notice.id)) notice,
    ];
    final List<AppNotice> chats =
        visible.where((AppNotice notice) => notice.isChatRoom).toList();
    final List<AppNotice> notices =
        visible.where((AppNotice notice) => !notice.isChatRoom).toList();
    final int chatUnread = _messageUnread(chats, read);
    final int noticeUnread = _unreadCount(notices, read);
    final List<AppNotice> current = _tabs.index == 1 ? chats : notices;
    final int currentUnread = _tabs.index == 1 ? chatUnread : noticeUnread;
    final double fontScale = ResponsiveSize.fontScale(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: ResponsiveSize.appBarHeight(context),
        title: const Text('알림'),
        actions: [
          if (currentUnread > 0)
            TextButton(
              onPressed:
                  () => ref
                      .read(noticeReadProvider.notifier)
                      .markAll(current.map((AppNotice notice) => notice.id)),
              child: Text(
                '모두 읽음',
                style: TextStyle(
                  fontSize: 14 * fontScale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(42),
          child: TabBar(
            controller: _tabs,
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            dividerColor: AppColors.border,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: TextStyle(
              fontSize: 14 * fontScale,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 14 * fontScale,
              fontWeight: FontWeight.w500,
            ),
            tabs: <Widget>[
              Tab(text: _tabLabel('알림', noticeUnread)),
              Tab(text: _tabLabel('채팅', chatUnread)),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: <Widget>[
          _pane(
            notices: notices,
            read: read,
            fontScale: fontScale,
            emptyTitle: '새 알림이 없어요',
            emptyBody: '변경, 일정, 광고가 오면 여기에 모아요',
          ),
          _pane(
            notices: chats,
            read: read,
            fontScale: fontScale,
            chat: true,
            emptyTitle: '새 대화가 없어요',
            emptyBody: '메시지는 채팅방에 이어서 쌓여요',
          ),
        ],
      ),
    );
  }

  Widget _pane({
    required List<AppNotice> notices,
    required Set<String> read,
    required double fontScale,
    required String emptyTitle,
    required String emptyBody,
    bool chat = false,
  }) {
    if (notices.isEmpty) {
      return _EmptyNotices(title: emptyTitle, body: emptyBody);
    }
    if (chat) {
      return _ChatList(
        notices: notices,
        read: read,
        fontScale: fontScale,
        onOpen: (AppNotice notice) => _open(notice),
        onDelete:
            (AppNotice notice) =>
                ref.read(noticeDismissProvider.notifier).dismiss(notice.id),
      );
    }
    return _NoticeList(
      notices: notices,
      read: read,
      fontScale: fontScale,
      onOpen: (AppNotice notice) => _open(notice),
      onDelete:
          (AppNotice notice) =>
              ref.read(noticeDismissProvider.notifier).dismiss(notice.id),
    );
  }

  void _open(AppNotice notice) {
    ref.read(noticeReadProvider.notifier).mark(notice.id);
    final SpaceBoard board = ref.read(spaceBoardProvider);
    switch (notice.link) {
      case NoticeLink.estimate:
        final WorkQuote? quote = board.find(notice.projectId)?.workQuote;
        if (quote == null) {
          if (notice.projectId.isEmpty) return;
          context.push(SpaceRoutes.detail(notice.projectId));
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder:
                (BuildContext context) => EstimateReaderScreen(quote: quote),
          ),
        );
      case NoticeLink.photos:
        final List<PublicSitePhoto> photos =
            board.constructionFor(notice.projectId)?.recentPhotos ??
            const <PublicSitePhoto>[];
        if (photos.isEmpty) {
          if (notice.projectId.isEmpty) return;
          context.push(SpaceRoutes.detail(notice.projectId));
          return;
        }
        openSitePhotoLibrary(context, photos);
      case NoticeLink.showroom:
        if (notice.showroomId.isEmpty) return;
        context.push('/showroom/${notice.showroomId}');
      case NoticeLink.change:
      case NoticeLink.project:
        if (notice.projectId.isEmpty) return;
        context.push(SpaceRoutes.detail(notice.projectId));
    }
  }
}

int _unreadCount(List<AppNotice> notices, Set<String> read) {
  return notices.where((AppNotice notice) => !read.contains(notice.id)).length;
}

int _messageUnread(List<AppNotice> chats, Set<String> read) {
  var total = 0;
  for (final AppNotice notice in chats) {
    if (read.contains(notice.id)) continue;
    total += notice.messageCount < 1 ? 1 : notice.messageCount;
  }
  return total;
}

String _tabLabel(String name, int unread) {
  if (unread <= 0) return name;
  return '$name $unread';
}

class _ChatList extends StatelessWidget {
  const _ChatList({
    required this.notices,
    required this.read,
    required this.fontScale,
    required this.onOpen,
    required this.onDelete,
  });

  final List<AppNotice> notices;
  final Set<String> read;
  final double fontScale;
  final ValueChanged<AppNotice> onOpen;
  final ValueChanged<AppNotice> onDelete;

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final List<AppNotice> rooms = <AppNotice>[...notices]
      ..sort((AppNotice a, AppNotice b) => b.sentAt.compareTo(a.sentAt));

    return ColoredBox(
      color: AppColors.surface,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 32),
        itemCount: rooms.length,
        separatorBuilder:
            (BuildContext context, int index) => const Divider(
              height: 1,
              thickness: 1,
              indent: 76,
              color: AppColors.border,
            ),
        itemBuilder: (BuildContext context, int index) {
          final AppNotice room = rooms[index];
          final bool unread = !read.contains(room.id);
          return Dismissible(
            key: ValueKey<String>(room.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => onDelete(room),
            background: const SizedBox.shrink(),
            secondaryBackground: const ColoredBox(
              color: AppColors.error,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Text(
                    '삭제',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            child: _ChatRow(
              room: room,
              unread: unread,
              now: now,
              fontScale: fontScale,
              onTap: () => onOpen(room),
            ),
          );
        },
      ),
    );
  }
}

class _ChatRow extends StatelessWidget {
  const _ChatRow({
    required this.room,
    required this.unread,
    required this.now,
    required this.fontScale,
    required this.onTap,
  });

  final AppNotice room;
  final bool unread;
  final DateTime now;
  final double fontScale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String name = _chatName(room);
    final String preview = _chatPreview(room);
    final int count = unread ? room.messageCount : 0;
    final EdgeInsets inset = ResponsiveSize.textInset(context);

    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(inset.left, 12, inset.right, 12),
          child: Row(
            children: [
              _ChatAvatar(name: name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16 * fontScale,
                              fontWeight:
                                  unread ? FontWeight.w700 : FontWeight.w600,
                              letterSpacing: -0.2,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _ago(room.sentAt, now),
                          style: TextStyle(
                            fontSize: 12 * fontScale,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14 * fontScale,
                              fontWeight: FontWeight.w500,
                              color:
                                  unread
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        if (count > 0) ...[
                          const SizedBox(width: 8),
                          _MessageCount(count: count, fontScale: fontScale),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final String letter =
        name.trim().isEmpty ? '담' : name.trim().substring(0, 1);
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
    );
  }
}

String _chatName(AppNotice room) {
  final String who = room.sender.trim();
  if (who.isNotEmpty) return who;
  final String place = room.placeName.trim();
  if (place.isNotEmpty) return place;
  return room.title.trim().isEmpty ? '대화' : room.title.trim();
}

String _chatPreview(AppNotice room) {
  final String place = room.placeName.trim();
  final String message = _preview(room.body, room.sender);
  if (place.isEmpty) return message;
  if (message.isEmpty) return place;
  return '$place · $message';
}

class _NoticeList extends StatelessWidget {
  const _NoticeList({
    required this.notices,
    required this.read,
    required this.fontScale,
    required this.onOpen,
    required this.onDelete,
  });

  final List<AppNotice> notices;
  final Set<String> read;
  final double fontScale;
  final ValueChanged<AppNotice> onOpen;
  final ValueChanged<AppNotice> onDelete;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets inset = ResponsiveSize.textInset(context);
    final DateTime now = DateTime.now();
    final List<AppNotice> mail = <AppNotice>[...notices]
      ..sort((AppNotice a, AppNotice b) => b.sentAt.compareTo(a.sentAt));

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(inset.left, 8, inset.right, 32),
      itemCount: mail.length,
      separatorBuilder:
          (BuildContext context, int index) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        final AppNotice notice = mail[index];
        return _SwipeDelete(
          notice: notice,
          unread: !read.contains(notice.id),
          onDelete: () => onDelete(notice),
          child: _NoticeLine(
            notice: notice,
            unread: !read.contains(notice.id),
            now: now,
            fontScale: fontScale,
            onTap: () => onOpen(notice),
          ),
        );
      },
    );
  }
}

class _SwipeDelete extends StatelessWidget {
  const _SwipeDelete({
    required this.notice,
    required this.unread,
    required this.onDelete,
    required this.child,
  });

  final AppNotice notice;
  final bool unread;
  final VoidCallback onDelete;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bool halo = unread && notice.grade == NoticeGrade.confirm;
    if (!halo) return _shell(0, halo: false);
    return ConfirmPulse(
      active: true,
      builder:
          (BuildContext context, double t) =>
              _shell(confirmGlowAmount(t), halo: true),
    );
  }

  Widget _shell(double glow, {required bool halo}) {
    final Color edge =
        halo
            ? Color.lerp(
              const Color(0xFFD7DCE3),
              AppColors.error,
              0.28 + 0.5 * glow,
            )!
            : const Color(0xFFD7DCE3);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: edge),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          children: [
            Dismissible(
              key: ValueKey<String>(notice.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => onDelete(),
              background: const SizedBox.shrink(),
              secondaryBackground: const ColoredBox(
                color: AppColors.error,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Text(
                      '삭제',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              child: child,
            ),
            if (halo)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: ConfirmRimPainter(glow)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NoticeLine extends StatelessWidget {
  const _NoticeLine({
    required this.notice,
    required this.unread,
    required this.now,
    required this.fontScale,
    required this.onTap,
  });

  final AppNotice notice;
  final bool unread;
  final DateTime now;
  final double fontScale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final _Kind kind = _kindOf(notice);
    final String detail = _noticeDetail(notice);

    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(kind.icon, size: 18, color: kind.color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      kind.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15 * fontScale,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _ago(notice.sentAt, now),
                    style: TextStyle(
                      fontSize: 12 * fontScale,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (detail.isNotEmpty || unread) ...[
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child:
                          detail.isEmpty
                              ? const SizedBox.shrink()
                              : Text(
                                detail,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13 * fontScale,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                    ),
                    if (unread) ...[
                      const SizedBox(width: 8),
                      const _UnreadMark(),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Kind {
  const _Kind(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

_Kind _kindOf(AppNotice notice) {
  final String name = notice.linkLabel.trim();
  final String label = name.isEmpty ? '알림' : '$name 알림';
  return switch (name) {
    '견적' => _Kind(label, Icons.receipt_long_outlined, const Color(0xFF8C6A45)),
    '변경' => _Kind(label, Icons.edit_outlined, AppColors.primary),
    '일정' => _Kind(label, Icons.event_outlined, AppColors.primary),
    'A/S' => _Kind(label, Icons.home_repair_service_outlined, AppColors.accent),
    '사진' => _Kind(label, Icons.photo_outlined, const Color(0xFF3E5C76)),
    '기록' => _Kind(label, Icons.menu_book_outlined, AppColors.accent),
    '채팅' => _Kind(label, Icons.chat_bubble_outline, const Color(0xFF3E5C76)),
    '광고' => _Kind(label, Icons.campaign_outlined, const Color(0xFF8C6A45)),
    _ => _Kind(
      label,
      Icons.notifications_none_rounded,
      AppColors.textSecondary,
    ),
  };
}

class _UnreadMark extends StatelessWidget {
  const _UnreadMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.error,
        shape: BoxShape.circle,
      ),
      child: const Text(
        'N',
        style: TextStyle(
          fontSize: 10,
          height: 1,
          fontWeight: FontWeight.w800,
          color: AppColors.white,
        ),
      ),
    );
  }
}

String _noticeDetail(AppNotice notice) {
  final String place = notice.placeName.trim();
  final String who = notice.sender.trim();
  final String topic = notice.title.trim();
  final String preview = _preview(notice.body, who);
  if (notice.isChatRoom) {
    final String head = <String>[
      place,
      if (who.isNotEmpty && who != place) who,
    ].where((String line) => line.isNotEmpty).join(' · ');
    return <String>[
      head,
      preview,
    ].where((String line) => line.isNotEmpty).join('\n');
  }
  final String rest = <String>[
    if (topic.isNotEmpty && topic != place) topic,
    if (preview.isNotEmpty && preview != topic) preview,
  ].join(' · ');
  return <String>[
    place,
    rest,
  ].where((String line) => line.isNotEmpty).join('\n');
}

String _preview(String body, String sender) {
  final List<String> lines =
      body
          .split('\n')
          .map((String line) => line.trim())
          .where((String line) => line.isNotEmpty)
          .toList();
  if (lines.isEmpty) return '';
  var line = lines.last;
  final String prefix = '$sender:';
  if (sender.isNotEmpty && line.startsWith(prefix)) {
    line = line.substring(prefix.length).trim();
  }
  return line;
}

class _MessageCount extends StatelessWidget {
  const _MessageCount({required this.count, required this.fontScale});

  final int count;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final String label = count > 99 ? '99+' : '$count';
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11 * fontScale,
          fontWeight: FontWeight.w700,
          height: 1.1,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class _EmptyNotices extends StatelessWidget {
  const _EmptyNotices({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    return Center(
      child: Padding(
        padding: ResponsiveSize.textInset(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16 * fontScale,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13 * fontScale,
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _ago(DateTime sent, DateTime now) {
  final DateTime day = DateTime(sent.year, sent.month, sent.day);
  final DateTime today = DateTime(now.year, now.month, now.day);
  final int days = today.difference(day).inDays;
  if (days <= 0) {
    final int minutes = now.difference(sent).inMinutes;
    if (minutes < 1) return '방금';
    if (minutes < 60) return '$minutes분 전';
    final String hour = sent.hour.toString().padLeft(2, '0');
    final String minute = sent.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  if (days == 1) return '어제';
  if (days < 7) return '$days일';
  return '${sent.month}월 ${sent.day}일';
}
