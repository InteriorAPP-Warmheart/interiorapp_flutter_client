import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_button.dart';
import 'package:interiorapp_flutter_client/home/domain/home_board.dart';

/// 공지, 질문, 상담 문의, 신고. 마이페이지의 고객 지원에서 연다.
class HomeBoardScreen extends StatefulWidget {
  const HomeBoardScreen({super.key});

  @override
  State<HomeBoardScreen> createState() => _HomeBoardScreenState();
}

class _HomeBoardScreenState extends State<HomeBoardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final EdgeInsets inset = ResponsiveSize.textInset(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: ResponsiveSize.appBarHeight(context),
        title: const Text('고객 지원'),
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
            tabs: const <Widget>[
              Tab(text: '공지'),
              Tab(text: 'FAQ'),
              Tab(text: '문의'),
              Tab(text: '신고'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: <Widget>[
          ListView.separated(
            padding: inset.copyWith(top: 16, bottom: 24),
            itemCount: homeBulletins.length,
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: 8);
            },
            itemBuilder: (BuildContext context, int index) {
              final HomeBulletin bulletin = homeBulletins[index];
              return DecoratedBox(
                decoration: _card(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 42,
                        child: Column(
                          children: [
                            Text(
                              bulletin.month,
                              style: TextStyle(
                                fontSize: 11 * fontScale,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              bulletin.day,
                              style: TextStyle(
                                fontSize: 22 * fontScale,
                                height: 1.05,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.6,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bulletin.title,
                              style: TextStyle(
                                fontSize: 15 * fontScale,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bulletin.body,
                              style: TextStyle(
                                fontSize: 13 * fontScale,
                                height: 1.45,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          ListView.separated(
            padding: inset.copyWith(top: 16, bottom: 24),
            itemCount: homeFaqs.length,
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: 8);
            },
            itemBuilder: (BuildContext context, int index) {
              return _FaqCard(faq: homeFaqs[index], fontScale: fontScale);
            },
          ),
          _SupportForm(
            prompt: '무엇에 대한 문의인가요?',
            choices: const <String>['상담', '견적', '공사', '기타'],
            hint: '문의 내용을 적어 주세요',
            action: '문의 남기기',
            done: '문의를 남겼어요. 평일 10:00–18:00에 연락드려요.',
          ),
          _SupportForm(
            prompt: '어떤 내용인가요?',
            choices: const <String>['스팸', '욕설 · 비방', '광고', '기타'],
            hint: '신고 이유를 적어 주세요',
            action: '신고하기',
            done: '신고를 접수했어요.',
          ),
        ],
      ),
    );
  }
}

class _FaqCard extends StatefulWidget {
  const _FaqCard({required this.faq, required this.fontScale});

  final HomeFaq faq;
  final double fontScale;

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final HomeFaq faq = widget.faq;
    final double fontScale = widget.fontScale;
    return DecoratedBox(
      decoration: _card(),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => setState(() => _open = !_open),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        faq.question,
                        style: TextStyle(
                          fontSize: 15 * fontScale,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      _open
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                if (_open) ...[
                  const SizedBox(height: 8),
                  Text(
                    faq.answer,
                    style: TextStyle(
                      fontSize: 13 * fontScale,
                      height: 1.45,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

BoxDecoration _card() {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: const Color(0xFFD7DCE3)),
  );
}

class _SupportForm extends StatefulWidget {
  const _SupportForm({
    required this.prompt,
    required this.choices,
    required this.hint,
    required this.action,
    required this.done,
  });

  final String prompt;
  final List<String> choices;
  final String hint;
  final String action;
  final String done;

  @override
  State<_SupportForm> createState() => _SupportFormState();
}

class _SupportFormState extends State<_SupportForm> {
  final TextEditingController _body = TextEditingController();
  String? _choice;
  bool _sent = false;

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  bool get _canSend => _choice != null && _body.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final EdgeInsets inset = ResponsiveSize.textInset(context);
    if (_sent) {
      return Padding(
        padding: inset.copyWith(top: 16),
        child: DecoratedBox(
          decoration: _card(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: Text(
              widget.done,
              style: TextStyle(
                fontSize: 15 * fontScale,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      );
    }
    return ListView(
      padding: inset.copyWith(top: 16, bottom: 24),
      children: [
        Text(
          widget.prompt,
          style: TextStyle(
            fontSize: 15 * fontScale,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final String choice in widget.choices)
              GestureDetector(
                onTap: () => setState(() => _choice = choice),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color:
                        _choice == choice
                            ? AppColors.primary
                            : AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color:
                          _choice == choice
                              ? AppColors.primary
                              : const Color(0xFFD7DCE3),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text(
                      choice,
                      style: TextStyle(
                        fontSize: 13 * fontScale,
                        fontWeight: FontWeight.w600,
                        color:
                            _choice == choice
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
          controller: _body,
          minLines: 4,
          maxLines: 6,
          onChanged: (_) => setState(() {}),
          style: TextStyle(
            fontSize: 14 * fontScale,
            height: 1.45,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD7DCE3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD7DCE3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 16),
        AppButton(
          label: widget.action,
          onPressed: _canSend ? () => setState(() => _sent = true) : null,
        ),
      ],
    );
  }
}
