import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';

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

  @override
  void initState() {
    super.initState();
    _input.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final String text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          mine: true,
          sentAt: DateTime.now(),
          read: false,
        ),
      );
      _input.clear();
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
    final bool canSend = _input.text.trim().isNotEmpty;
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
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
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
        _Bubble(
          text: message.text,
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
  });

  final String text;
  final bool mine;
  final DateTime sentAt;
  final bool read;
}

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
    required this.mine,
    required this.sentAt,
    required this.read,
    required this.fontScale,
  });

  final String text;
  final bool mine;
  final DateTime sentAt;
  final bool read;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final Color metaColor = read ? AppColors.textSecondary : AppColors.accent;
    final Widget meta = Text(
      '${read ? '읽음' : '안읽음'} · ${_clockLabel(sentAt)}',
      style: TextStyle(
        fontSize: 11 * fontScale,
        fontWeight: FontWeight.w600,
        color: metaColor,
      ),
    );
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14 * fontScale,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: mine ? AppColors.white : AppColors.textPrimary,
                  ),
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
