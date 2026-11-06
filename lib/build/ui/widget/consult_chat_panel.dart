import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/process_schedule.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/original_file_sheet.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/slide_to_confirm.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_button.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';

/// 진행 중인 공간에서 바로 묻는 상담 창.
class ConsultChatPanel extends StatefulWidget {
  const ConsultChatPanel({super.key, required this.placeName});

  final String placeName;

  @override
  State<ConsultChatPanel> createState() => _ConsultChatPanelState();
}

class _ConsultChatPanelState extends State<ConsultChatPanel> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<_ChatMessage> _messages = <_ChatMessage>[];
  final List<String> _pendingImages = <String>[];

  @override
  void initState() {
    super.initState();
    _input.addListener(() => setState(() {}));
    final DateTime sent = DateTime.now().subtract(const Duration(hours: 2));
    _messages.add(
      _ChatMessage(
        text: '',
        mine: false,
        sentAt: sent,
        read: true,
        kind: _ChatKind.confirm,
        title: '조명 위치 수정',
        summary: '홀 조명을 창가 쪽으로 옮겨요.',
        body: '창에 가깝게 조명을 옮겨, 낮의 창빛과 저녁 객석이 같이 보이게 해요.',
        changes: const <_ConfirmChange>[
          _ConfirmChange(label: '기존', value: '카운터 위 중앙, 기구 6개'),
          _ConfirmChange(label: '변경', value: '창가 40cm, 기구 8개'),
        ],
        prices: const <_ConfirmPrice>[
          _ConfirmPrice(name: '기구 2개 추가', amount: '86만원'),
          _ConfirmPrice(name: '배선 이설', amount: '24만원'),
          _ConfirmPrice(name: '기존 타공 마감', amount: '12만원'),
        ],
        priceTotal: '122만원',
        schedule: const <_ConfirmWhen>[
          _ConfirmWhen(
            kind: _ScheduleChangeKind.delay,
            title: '설치',
            before: '11.13',
            after: '11.14',
          ),
          _ConfirmWhen(
            kind: _ScheduleChangeKind.hold,
            title: '준공',
            before: '11.27',
          ),
        ],
        board: const <_ConfirmSpan>[
          _ConfirmSpan(title: '목공', start: '11.8', end: '11.12'),
          _ConfirmSpan(title: '전기', start: '11.10', end: '11.13'),
          _ConfirmSpan(title: '설치', start: '11.13', end: '11.15'),
          _ConfirmSpan(title: '타공', start: '11.17', end: '11.17', added: true),
          _ConfirmSpan(title: '도장', start: '11.16', end: '11.20'),
        ],
        files: const <_ConfirmFile>[
          _ConfirmFile(
            kind: _ConfirmFileKind.image,
            name: '창가 조명 위치',
            url: 'assets/images/showroom/01.jpg',
          ),
          _ConfirmFile(
            kind: _ConfirmFileKind.image,
            name: '기존 천장 조명',
            url: 'assets/images/showroom/06.jpg',
          ),
          _ConfirmFile(kind: _ConfirmFileKind.excel, name: '조명 변경 금액.xlsx'),
          _ConfirmFile(kind: _ConfirmFileKind.pdf, name: '조명 위치 수정안.pdf'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> files;
    try {
      files = await ImagePicker().pickMultiImage(imageQuality: 85);
    } catch (_) {
      return;
    }
    if (!mounted || files.isEmpty) return;
    setState(() {
      _pendingImages.addAll(<String>[
        for (final XFile file in files) file.path,
      ]);
    });
  }

  void _send() {
    final String text = _input.text.trim();
    if (text.isEmpty && _pendingImages.isEmpty) return;
    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          mine: true,
          sentAt: DateTime.now(),
          read: false,
          images: List<String>.from(_pendingImages),
        ),
      );
      _input.clear();
      _pendingImages.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final bool canSend =
        _input.text.trim().isNotEmpty || _pendingImages.isNotEmpty;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0B1F38),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '상담',
                  style: TextStyle(
                    fontSize: 18 * fontScale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.placeName}에 대해 바로 물어보세요.',
                  style: TextStyle(
                    fontSize: 13 * fontScale,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              children: _thread(fontScale),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          if (_pendingImages.isNotEmpty)
            SizedBox(
              height: 76,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                itemCount: _pendingImages.length,
                separatorBuilder:
                    (BuildContext context, int index) =>
                        const SizedBox(width: 8),
                itemBuilder: (BuildContext context, int index) {
                  return _PendingImage(
                    path: _pendingImages[index],
                    onRemove: () {
                      setState(() => _pendingImages.removeAt(index));
                    },
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 8, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: _pickImages,
                  icon: const Icon(
                    Icons.image_outlined,
                    color: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _input,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    style: TextStyle(
                      fontSize: 15 * fontScale,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: '궁금한 점을 적어 주세요',
                      hintStyle: TextStyle(
                        fontSize: 15 * fontScale,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: canSend ? _send : null,
                  icon: Icon(
                    Icons.send,
                    color: canSend ? AppColors.primary : AppColors.border,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _thread(double fontScale) {
    final DateTime now = DateTime.now();
    final List<Widget> children = <Widget>[
      Text(
        '진행 중인 공간에 대해 바로 물어보세요. 담당자가 이어서 답해요.',
        style: TextStyle(
          fontSize: 13 * fontScale,
          height: 1.45,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    ];
    DateTime? lastDay;
    for (var i = 0; i < _messages.length; i++) {
      final _ChatMessage message = _messages[i];
      final DateTime day = DateTime(
        message.sentAt.year,
        message.sentAt.month,
        message.sentAt.day,
      );
      if (lastDay != day) {
        children.add(const SizedBox(height: 16));
        children.add(
          _DayDivider(label: _dayLabel(day, now), fontScale: fontScale),
        );
        children.add(const SizedBox(height: 12));
        lastDay = day;
      } else {
        children.add(const SizedBox(height: 8));
      }
      children.add(
        message.kind == _ChatKind.confirm
            ? _ConfirmCard(
              message: message,
              fontScale: fontScale,
              onConfirm: () {
                setState(
                  () => _messages[i] = message.copyWith(confirmed: true),
                );
              },
            )
            : _Bubble(
              text: message.text,
              images: message.images,
              mine: message.mine,
              sentAt: message.sentAt,
              read: message.read,
              fontScale: fontScale,
            ),
      );
    }
    return children;
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.mine,
    required this.sentAt,
    required this.read,
    this.kind = _ChatKind.text,
    this.confirmed = false,
    this.title = '',
    this.summary = '',
    this.body = '',
    this.changes = const <_ConfirmChange>[],
    this.prices = const <_ConfirmPrice>[],
    this.priceTotal = '',
    this.schedule = const <_ConfirmWhen>[],
    this.board = const <_ConfirmSpan>[],
    this.files = const <_ConfirmFile>[],
    this.images = const <String>[],
  });

  final String text;
  final bool mine;
  final DateTime sentAt;
  final bool read;
  final _ChatKind kind;
  final bool confirmed;
  final String title;
  final String summary;
  final String body;
  final List<_ConfirmChange> changes;
  final List<_ConfirmPrice> prices;
  final String priceTotal;
  final List<_ConfirmWhen> schedule;
  final List<_ConfirmSpan> board;
  final List<_ConfirmFile> files;
  final List<String> images;

  _ChatMessage copyWith({bool? confirmed}) {
    return _ChatMessage(
      text: text,
      mine: mine,
      sentAt: sentAt,
      read: read,
      kind: kind,
      confirmed: confirmed ?? this.confirmed,
      title: title,
      summary: summary,
      body: body,
      changes: changes,
      prices: prices,
      priceTotal: priceTotal,
      schedule: schedule,
      board: board,
      files: files,
      images: images,
    );
  }
}

class _ConfirmChange {
  const _ConfirmChange({required this.label, required this.value});

  final String label;
  final String value;
}

class _ConfirmPrice {
  const _ConfirmPrice({required this.name, required this.amount});

  final String name;
  final String amount;
}

class _ConfirmSpan {
  const _ConfirmSpan({
    required this.title,
    required this.start,
    required this.end,
    this.added = false,
  });

  final String title;
  final String start;
  final String end;

  /// 공정표에 없던 일정. 칸마다 추가로 표시한다.
  final bool added;
}

enum _ScheduleChangeKind { delay, move, replace, swap, hold }

class _ConfirmWhen {
  const _ConfirmWhen({
    required this.kind,
    required this.title,
    required this.before,
    this.after = '',
    // 작업 이름이 바뀌거나 두 일정이 맞바뀌는 확인에서 채운다.
    // ignore: unused_element_parameter
    this.afterTitle = '',
    // ignore: unused_element_parameter
    this.pairTitle = '',
    // ignore: unused_element_parameter
    this.pairBefore = '',
    // ignore: unused_element_parameter
    this.pairAfter = '',
  });

  final _ScheduleChangeKind kind;
  final String title;
  final String before;
  final String after;

  /// 작업 자체가 바뀔 때의 이후 이름.
  final String afterTitle;
  final String pairTitle;
  final String pairBefore;
  final String pairAfter;
}

enum _ConfirmFileKind { image, excel, pdf }

class _ConfirmFile {
  const _ConfirmFile({required this.kind, required this.name, this.url = ''});

  final _ConfirmFileKind kind;
  final String name;
  final String url;
}

enum _ChatKind { text, confirm }

String _dayLabel(DateTime day, DateTime now) {
  final DateTime today = DateTime(now.year, now.month, now.day);
  final int diff = today.difference(day).inDays;
  if (diff == 0) return '오늘';
  if (diff == 1) return '어제';
  return '${day.month}월 ${day.day}일';
}

String _clockLabel(DateTime time) {
  final int hour = time.hour;
  final String period = hour < 12 ? '오전' : '오후';
  final int shown = hour % 12 == 0 ? 12 : hour % 12;
  final String minute = time.minute.toString().padLeft(2, '0');
  return '$period $shown:$minute';
}

class _DayDivider extends StatelessWidget {
  const _DayDivider({required this.label, required this.fontScale});

  final String label;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12 * fontScale,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.text,
    required this.images,
    required this.mine,
    required this.sentAt,
    required this.read,
    required this.fontScale,
  });

  final String text;
  final List<String> images;
  final bool mine;
  final DateTime sentAt;
  final bool read;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final Color metaColor = read ? AppColors.textSecondary : AppColors.accent;
    final Widget meta = Text(
      '${read ? '읽음' : '안읽음'}  ${_clockLabel(sentAt)}',
      style: TextStyle(
        fontSize: 11 * fontScale,
        fontWeight: FontWeight.w600,
        color: metaColor,
      ),
    );
    final bool hasText = text.trim().isNotEmpty;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: mine ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  images.isEmpty ? 14 : 8,
                  images.isEmpty ? 10 : 8,
                  images.isEmpty ? 14 : 8,
                  hasText ? 10 : 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (images.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          children: [
                            for (var i = 0; i < images.length; i++) ...[
                              if (i > 0) const SizedBox(height: 4),
                              AppNetworkImage(
                                url: images[i],
                                height: images.length == 1 ? 180 : 120,
                                width: double.infinity,
                              ),
                            ],
                          ],
                        ),
                      ),
                    if (hasText) ...[
                      if (images.isNotEmpty) const SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: images.isEmpty ? 0 : 6,
                        ),
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 14 * fontScale,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color:
                                mine ? AppColors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          meta,
        ],
      ),
    );
  }
}

class _ConfirmCard extends StatelessWidget {
  const _ConfirmCard({
    required this.message,
    required this.fontScale,
    required this.onConfirm,
  });

  final _ChatMessage message;
  final double fontScale;
  final VoidCallback onConfirm;

  Future<void> _open(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (BuildContext sheetContext) {
        return _ConfirmSheet(message: message, onConfirm: onConfirm);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool confirmed = message.confirmed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '담당자',
          style: TextStyle(
            fontSize: 12 * fontScale,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Material(
          color: AppColors.background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
          child: InkWell(
            onTap: () => _open(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    confirmed ? '확인했어요' : '확인 요청',
                    style: TextStyle(
                      fontSize: 12 * fontScale,
                      fontWeight: FontWeight.w700,
                      color: confirmed ? AppColors.accent : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message.title,
                    style: TextStyle(
                      fontSize: 16 * fontScale,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14 * fontScale,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        confirmed ? '내용 다시 보기' : '자세히 보기',
                        style: TextStyle(
                          fontSize: 13 * fontScale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 18 * fontScale,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _clockLabel(message.sentAt),
          style: TextStyle(
            fontSize: 11 * fontScale,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ConfirmSheet extends StatefulWidget {
  const _ConfirmSheet({required this.message, required this.onConfirm});

  final _ChatMessage message;
  final VoidCallback onConfirm;

  @override
  State<_ConfirmSheet> createState() => _ConfirmSheetState();
}

class _ConfirmSheetState extends State<_ConfirmSheet> {
  late bool _confirmed = widget.message.confirmed;

  Future<bool> _accept() async {
    widget.onConfirm();
    if (!mounted) return false;
    setState(() => _confirmed = true);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final double height = MediaQuery.sizeOf(context).height * 0.88;
    final _ChatMessage message = widget.message;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: height.clamp(520, 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '담당자',
                                    style: TextStyle(
                                      fontSize: 13 * fontScale,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _clockLabel(message.sentAt),
                                    style: TextStyle(
                                      fontSize: 12 * fontScale,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _confirmed ? '확인했어요' : '확인 요청',
                                style: TextStyle(
                                  fontSize: 12 * fontScale,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      _confirmed
                                          ? AppColors.accent
                                          : AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                message.title,
                                style: TextStyle(
                                  fontSize: 22 * fontScale,
                                  height: 1.3,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                message.body,
                                style: TextStyle(
                                  fontSize: 16 * fontScale,
                                  height: 1.6,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (message.changes.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _ConfirmSection(
                          label: '바뀌는 점',
                          fontScale: fontScale,
                          child: Column(
                            children: [
                              for (var i = 0; i < message.changes.length; i++)
                                Padding(
                                  padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 36,
                                        child: Text(
                                          message.changes[i].label,
                                          style: TextStyle(
                                            fontSize: 13 * fontScale,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          message.changes[i].value,
                                          style: TextStyle(
                                            fontSize: 15 * fontScale,
                                            height: 1.4,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                      if (message.prices.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _ConfirmSection(
                          label: '금액',
                          fontScale: fontScale,
                          child: Column(
                            children: [
                              for (final _ConfirmPrice price in message.prices)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          price.name,
                                          style: TextStyle(
                                            fontSize: 15 * fontScale,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        price.amount,
                                        style: TextStyle(
                                          fontSize: 15 * fontScale,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const Divider(height: 1, color: AppColors.border),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text(
                                    '합계',
                                    style: TextStyle(
                                      fontSize: 15 * fontScale,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    message.priceTotal,
                                    style: TextStyle(
                                      fontSize: 18 * fontScale,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '부가세 별도',
                                  style: TextStyle(
                                    fontSize: 12 * fontScale,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (message.board.isNotEmpty ||
                          message.schedule.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _ConfirmSection(
                          label: '일정',
                          fontScale: fontScale,
                          child: _ConfirmSchedule(
                            board: message.board,
                            events: message.schedule,
                            fontScale: fontScale,
                          ),
                        ),
                      ],
                      if (message.files.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _ConfirmSection(
                          label: '첨부',
                          fontScale: fontScale,
                          child: _ConfirmAttachments(
                            files: message.files,
                            fontScale: fontScale,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      16,
                      20,
                      16 + MediaQuery.paddingOf(context).bottom,
                    ),
                    child:
                        _confirmed
                            ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  '이 수정으로 진행해요',
                                  style: TextStyle(
                                    fontSize: 15 * fontScale,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accent,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                AppButton(
                                  label: '닫기',
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            )
                            : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '오른쪽 끝까지 밀면 이 수정으로 진행해요',
                                  style: TextStyle(
                                    fontSize: 14 * fontScale,
                                    height: 1.4,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SlideToConfirm(
                                  label: '밀어 확인',
                                  onCompleted: _accept,
                                ),
                              ],
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmSection extends StatelessWidget {
  const _ConfirmSection({
    required this.label,
    required this.fontScale,
    required this.child,
  });

  final String label;
  final double fontScale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13 * fontScale,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _GridRow {
  _GridRow({required this.title});

  String title;
  Color color = const Color(0xFF9AA3AE);
  final List<DateTime> before = <DateTime>[];
  final List<DateTime> after = <DateTime>[];
}

class _ConfirmSchedule extends StatelessWidget {
  const _ConfirmSchedule({
    required this.board,
    required this.events,
    required this.fontScale,
  });

  final List<_ConfirmSpan> board;
  final List<_ConfirmWhen> events;
  final double fontScale;

  static const double _labelWidth = 88;
  static const double _cellWidth = 46;
  static const double _rowHeight = 36;
  static const double _headerHeight = 40;
  static const double _bandHeight = 24;
  static const List<String> _weekdays = <String>[
    '월',
    '화',
    '수',
    '목',
    '금',
    '토',
    '일',
  ];

  @override
  Widget build(BuildContext context) {
    final List<_ConfirmWhen> holds =
        events
            .where(
              (_ConfirmWhen event) => event.kind == _ScheduleChangeKind.hold,
            )
            .toList();
    final List<_GridRow> rows = _rows();
    final List<DateTime> days = _window(rows);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (rows.isNotEmpty && days.isNotEmpty) ...[
          _charts(rows, days),
          const SizedBox(height: 12),
          Text(
            '수락하면 이 수정이 공정표에 반영돼요.',
            style: TextStyle(
              fontSize: 13 * fontScale,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        if (holds.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (var i = 0; i < holds.length; i++) ...[
            if (i > 0) const SizedBox(height: 4),
            Text(
              '${holds[i].title} ${holds[i].before} 그대로',
              style: TextStyle(
                fontSize: 13 * fontScale,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _charts(List<_GridRow> rows, List<DateTime> days) {
    final double gridWidth = _cellWidth * days.length;
    final double afterBandTop =
        _headerHeight + _bandHeight + _rowHeight * rows.length;
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: _labelWidth,
              child: Column(
                children: [
                  _corner(),
                  _band(),
                  for (final _GridRow row in rows) _taskLabel(row),
                  _band(),
                  for (final _GridRow row in rows) _taskLabel(row),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: gridWidth,
                  child: Column(
                    children: [
                      _dayHeader(days),
                      _bandGap(),
                      _body(rows, days, useBefore: true),
                      _bandGap(),
                      _body(rows, days, useBefore: false),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: _headerHeight,
          left: 0,
          right: 0,
          height: _bandHeight,
          child: _bandTitle('기존', later: false),
        ),
        Positioned(
          top: afterBandTop,
          left: 0,
          right: 0,
          height: _bandHeight,
          child: _bandTitle('변경 후', later: true),
        ),
      ],
    );
  }

  Widget _corner() {
    return Container(
      height: _headerHeight,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 8),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border),
          left: BorderSide(color: AppColors.border),
          right: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Text(
        '공정',
        style: TextStyle(
          fontSize: 12 * fontScale,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _band() {
    return const ColoredBox(
      color: AppColors.background,
      child: SizedBox(width: _labelWidth, height: _bandHeight),
    );
  }

  Widget _bandTitle(String text, {required bool later}) {
    return IgnorePointer(
      child: ColoredBox(
        color: AppColors.background,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13 * fontScale,
              fontWeight: FontWeight.w700,
              color: later ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bandGap() {
    return const ColoredBox(
      color: AppColors.background,
      child: SizedBox(height: _bandHeight),
    );
  }

  Widget _taskLabel(_GridRow row) {
    final bool changed = _changed(row);
    return Container(
      height: _rowHeight,
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: AppColors.border),
          right: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Container(width: 4, color: row.color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              row.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13 * fontScale,
                fontWeight: FontWeight.w700,
                color: changed ? row.color : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayHeader(List<DateTime> days) {
    return SizedBox(
      height: _headerHeight,
      child: Row(
        children: [
          for (final DateTime day in days)
            Container(
              width: _cellWidth,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.border),
                  right: BorderSide(color: AppColors.border),
                  bottom: BorderSide(color: AppColors.border),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${day.month}.${day.day}',
                    style: TextStyle(
                      fontSize: 11 * fontScale,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                      color: _dayColor(day),
                    ),
                  ),
                  Text(
                    '(${_weekdays[day.weekday - 1]})',
                    style: TextStyle(
                      fontSize: 10 * fontScale,
                      height: 1.1,
                      fontWeight: FontWeight.w600,
                      color:
                          day.weekday == DateTime.sunday ||
                                  day.weekday == DateTime.saturday
                              ? _dayColor(day)
                              : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _body(
    List<_GridRow> rows,
    List<DateTime> days, {
    required bool useBefore,
  }) {
    return Column(
      children: [
        for (final _GridRow row in rows)
          SizedBox(
            height: _rowHeight,
            child: Row(
              children: [
                for (final DateTime day in days)
                  Container(
                    width: _cellWidth,
                    height: _rowHeight,
                    decoration: BoxDecoration(
                      color:
                          _contains(useBefore ? row.before : row.after, day)
                              ? row.color
                              : AppColors.surface,
                      border: const Border(
                        right: BorderSide(color: AppColors.border),
                        bottom: BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  List<_GridRow> _rows() {
    final List<_GridRow> rows = <_GridRow>[];
    for (final _ConfirmSpan span in board) {
      final DateTime? start = _tryDate(span.start);
      final DateTime? end = _tryDate(span.end);
      if (start == null || end == null) continue;
      final DateTime from = start.isAfter(end) ? end : start;
      final DateTime to = _later(from, start.isAfter(end) ? start : end);
      final _GridRow row = _GridRow(title: span.title);
      final List<DateTime> days = _dates(from, to);
      if (span.added) {
        row.after.addAll(days);
      } else {
        row.before.addAll(days);
        row.after.addAll(days);
      }
      rows.add(row);
    }
    for (final _ConfirmWhen event in events) {
      switch (event.kind) {
        case _ScheduleChangeKind.hold:
          break;
        case _ScheduleChangeKind.swap:
          _shift(rows, event.title, event.before, event.after);
          _shift(rows, event.pairTitle, event.pairBefore, event.pairAfter);
        case _ScheduleChangeKind.replace:
          _shift(
            rows,
            event.afterTitle.isEmpty ? event.title : event.afterTitle,
            event.before,
            event.after,
            renameFrom: event.title,
          );
        case _ScheduleChangeKind.delay:
        case _ScheduleChangeKind.move:
          _shift(rows, event.title, event.before, event.after);
      }
    }
    _paint(rows);
    return rows;
  }

  void _paint(List<_GridRow> rows) {
    final List<Color> changedColors = <Color>[
      for (var i = 1; i < processSchedulePalette.length; i++)
        processSchedulePalette[i],
      processSchedulePalette.first,
    ];
    var index = 0;
    for (final _GridRow row in rows) {
      if (!_changed(row)) continue;
      row.color = changedColors[index % changedColors.length];
      index++;
    }
  }

  void _shift(
    List<_GridRow> rows,
    String title,
    String beforeRaw,
    String afterRaw, {
    String renameFrom = '',
  }) {
    final DateTime? before = _tryDate(beforeRaw);
    final DateTime? rawAfter = _tryDate(afterRaw);
    if (title.isEmpty || before == null || rawAfter == null) return;
    final DateTime after = _align(before, rawAfter);
    if (_sameDay(before, after)) return;
    final int delta = after.difference(before).inDays;
    _GridRow? row =
        _find(rows, renameFrom.isEmpty ? title : renameFrom) ??
        _find(rows, title);
    if (row == null) {
      row = _GridRow(title: title);
      row.after.add(after);
      rows.add(row);
      return;
    }
    if (renameFrom.isNotEmpty) row.title = title;
    final List<DateTime> previous = List<DateTime>.of(row.before);
    final List<DateTime> next =
        previous.isEmpty
            ? <DateTime>[after]
            : <DateTime>[
              for (final DateTime day in previous)
                day.add(Duration(days: delta)),
            ];
    row.after
      ..clear()
      ..addAll(next);
  }

  _GridRow? _find(List<_GridRow> rows, String title) {
    if (title.isEmpty) return null;
    for (final _GridRow row in rows) {
      if (row.title == title) return row;
    }
    return null;
  }

  bool _changed(_GridRow row) {
    final List<DateTime> days = <DateTime>[...row.before, ...row.after];
    for (final DateTime day in days) {
      if (_contains(row.before, day) != _contains(row.after, day)) return true;
    }
    return false;
  }

  List<DateTime> _window(List<_GridRow> rows) {
    final List<DateTime> all = <DateTime>[];
    final List<DateTime> focus = <DateTime>[];
    for (final _GridRow row in rows) {
      all
        ..addAll(row.before)
        ..addAll(row.after);
      final List<DateTime> days = <DateTime>[...row.before, ...row.after];
      for (final DateTime day in days) {
        if (_contains(row.before, day) == _contains(row.after, day)) continue;
        if (_contains(focus, day)) continue;
        focus.add(day);
      }
    }
    if (all.isEmpty) return const <DateTime>[];
    DateTime earliest(List<DateTime> days) {
      return days.reduce((DateTime a, DateTime b) => a.isBefore(b) ? a : b);
    }

    DateTime latest(List<DateTime> days) {
      return days.reduce((DateTime a, DateTime b) => a.isAfter(b) ? a : b);
    }

    final DateTime allStart = earliest(all);
    final DateTime allEnd = latest(all);
    final DateTime anchorStart = focus.isEmpty ? allStart : earliest(focus);
    final DateTime anchorEnd = focus.isEmpty ? allEnd : latest(focus);
    DateTime start = anchorStart.subtract(const Duration(days: 1));
    DateTime end = anchorEnd.add(const Duration(days: 1));
    if (start.isBefore(allStart)) start = allStart;
    if (end.isAfter(allEnd)) end = allEnd;
    return _dates(start, end);
  }

  List<DateTime> _dates(DateTime start, DateTime end) {
    if (end.isBefore(start)) return const <DateTime>[];
    final List<DateTime> days = <DateTime>[];
    for (
      DateTime day = start;
      !day.isAfter(end);
      day = day.add(const Duration(days: 1))
    ) {
      days.add(day);
    }
    return days;
  }

  DateTime _align(DateTime anchor, DateTime day) {
    if (day.isBefore(anchor) && anchor.difference(day).inDays > 180) {
      return DateTime(day.year + 1, day.month, day.day);
    }
    return day;
  }

  DateTime _later(DateTime anchor, DateTime day) {
    if (!day.isBefore(anchor)) return day;
    if (anchor.month >= 11 && day.month <= 2) {
      return DateTime(day.year + 1, day.month, day.day);
    }
    return day;
  }

  DateTime? _tryDate(String raw) {
    final List<String> parts = raw.split('.');
    if (parts.length < 2) return null;
    final int? month = int.tryParse(parts[0].trim());
    final int? day = int.tryParse(parts[1].trim());
    if (month == null || day == null) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    final DateTime date = DateTime(2000, month, day);
    if (date.month != month || date.day != day) return null;
    return date;
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _contains(List<DateTime> days, DateTime day) {
    return days.any((DateTime item) => _sameDay(item, day));
  }

  Color _dayColor(DateTime day) {
    if (day.weekday == DateTime.sunday) return AppColors.error;
    if (day.weekday == DateTime.saturday) return AppColors.primary;
    return AppColors.textPrimary;
  }
}

class _PendingImage extends StatelessWidget {
  const _PendingImage({required this.path, required this.onRemove});

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AppNetworkImage(url: path, width: 64, height: 64),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: Material(
            color: AppColors.primary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onRemove,
              child: const SizedBox(
                width: 22,
                height: 22,
                child: Icon(Icons.close, size: 14, color: AppColors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfirmAttachments extends StatelessWidget {
  const _ConfirmAttachments({required this.files, required this.fontScale});

  final List<_ConfirmFile> files;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final List<_ConfirmFile> images =
        files
            .where((_ConfirmFile file) => file.kind == _ConfirmFileKind.image)
            .toList();
    final List<_ConfirmFile> docs =
        files
            .where((_ConfirmFile file) => file.kind != _ConfirmFileKind.image)
            .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (images.isNotEmpty)
          SizedBox(
            height: 148,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder:
                  (BuildContext context, int index) => const SizedBox(width: 8),
              itemBuilder: (BuildContext context, int index) {
                final _ConfirmFile file = images[index];
                return GestureDetector(
                  onTap: () => _openConfirmImage(context, file),
                  child: SizedBox(
                    width: 148,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AppNetworkImage(
                            url: file.url,
                            width: 148,
                            height: 112,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          file.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12 * fontScale,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        if (docs.isNotEmpty) ...[
          if (images.isNotEmpty) const SizedBox(height: 8),
          for (var i = 0; i < docs.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _ConfirmDocTile(file: docs[i], fontScale: fontScale),
          ],
        ],
      ],
    );
  }
}

class _ConfirmDocTile extends StatelessWidget {
  const _ConfirmDocTile({required this.file, required this.fontScale});

  final _ConfirmFile file;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final bool excel = file.kind == _ConfirmFileKind.excel;
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: () => showOriginalFileSheet(context, fileName: file.name),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(
                excel
                    ? Icons.table_chart_outlined
                    : Icons.picture_as_pdf_outlined,
                size: 20,
                color: AppColors.accent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  file.name,
                  style: TextStyle(
                    fontSize: 15 * fontScale,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                excel ? '엑셀' : 'PDF',
                style: TextStyle(
                  fontSize: 12 * fontScale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _openConfirmImage(BuildContext context, _ConfirmFile file) {
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: AppNetworkImage(
                url: file.url,
                height: 280,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Text(
                file.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
