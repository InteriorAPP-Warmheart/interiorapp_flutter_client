import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/construction_plan.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/construction_progress.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/work_quote.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/contract_review_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/estimate_reader_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/consult_chat_panel.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/quote_money_summary.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/prep_detail_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/proposal_reader_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/industry_cover.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/slide_to_confirm.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_bottom_sheet.dart';
import 'package:interiorapp_flutter_client/core/widget/app_button.dart';
import 'package:interiorapp_flutter_client/core/widget/app_dialog.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';

part 'progress/progress_shared.dart';
part 'progress/consult_stage.dart';
part 'progress/visit_stage.dart';
part 'progress/plan_stage.dart';
part 'progress/quote_stage.dart';
part 'progress/contract_stage.dart';
part 'progress/prep_stage.dart';
part 'progress/handover_stage.dart';
part 'progress/care_stage.dart';
part 'progress/build_stage.dart';

/// 상담 접수 이후의 진행. 위 단계는 화면을 넘겨 보는 자리고, 실제 위치는 따로 둔다.
class ProjectProgressView extends StatefulWidget {
  const ProjectProgressView({
    super.key,
    required this.placeName,
    required this.stage,
    this.record,
    this.progress,
    this.visitAppointment,
    this.constructionPlan,
    this.workQuote,
  });

  final String placeName;
  final ProjectStage stage;
  final PrepRecord? record;
  final ConstructionProgress? progress;

  /// 전화 상담에서 정한 현장 방문.
  final VisitAppointment? visitAppointment;

  /// 현장방문 이후 확정된 시공안.
  final ConstructionPlan? constructionPlan;

  /// 시공 판단과 견적, 받은 자료.
  final WorkQuote? workQuote;

  @override
  State<ProjectProgressView> createState() => _ProjectProgressViewState();
}

class _ProjectProgressViewState extends State<ProjectProgressView>
    with SingleTickerProviderStateMixin {
  late ProjectStage _stage;
  bool _quoteReviewed = false;
  bool _contractSigned = false;
  late final AnimationController _chat = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 340),
    reverseDuration: const Duration(milliseconds: 280),
  );
  late final CurvedAnimation _chatScale = CurvedAnimation(
    parent: _chat,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  final ScrollController _stages = ScrollController();
  final List<GlobalKey> _stageKeys = List<GlobalKey>.generate(
    ProjectStage.timeline.length,
    (_) => GlobalKey(),
  );

  @override
  void initState() {
    super.initState();
    _stage = widget.stage;
    _chat.addStatusListener((_) {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(_stage));
  }

  @override
  void dispose() {
    _chatScale.dispose();
    _chat.dispose();
    _stages.dispose();
    super.dispose();
  }

  void _toggleChat() {
    if (_chat.status == AnimationStatus.dismissed ||
        _chat.status == AnimationStatus.reverse) {
      _chat.forward();
    } else {
      _chat.reverse();
    }
  }

  void _reveal(ProjectStage stage) {
    final BuildContext? target = _stageKeys[stage.index].currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      alignment: 0.5,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<bool> _confirmQuoteRead() async {
    final bool? read = await showAppDialog<bool>(
      context: context,
      title: '모든 내용을 열람하셨나요?',
      message: '열람하신 내역이 확인되면 계약 단계로 넘어가요.',
      actions: (BuildContext dialogContext) {
        return [
          AppButton(
            label: '네, 모두 열람했어요',
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
          AppButton(
            label: '아니요, 더 살펴볼게요',
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
        ];
      },
    );
    if (read != true || !mounted) return false;
    setState(() => _quoteReviewed = true);
    return true;
  }

  Future<void> _openContract() async {
    final WorkQuote? quote = widget.workQuote;
    if (quote == null) return;
    final bool? signed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder:
            (BuildContext context) => ContractReviewScreen(
              quote: quote,
              alreadySigned: _contractSigned,
            ),
      ),
    );
    if (signed == true && mounted) setState(() => _contractSigned = true);
  }

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final EdgeInsets padding = ResponsiveSize.responsivePadding(context);
    final double subGap = ResponsiveSize.subGap(context);
    final double sectionGap = ResponsiveSize.sectionGap(context);
    final bool preview = _stage != widget.stage;
    final ConstructionProgress? progress =
        _stage == ProjectStage.build ? widget.progress ?? _sampleBuild : null;

    final bool quoteBar =
        _stage == ProjectStage.quote && widget.workQuote != null;
    final double barGap = (quoteBar ? 88 : 16) + 72;
    final double safeBottom = MediaQuery.paddingOf(context).bottom;
    final double fabLift = quoteBar ? 76 : 0;
    final double chatBottom = safeBottom + 16 + 56 + 12 + fabLift;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.placeName)),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: fabLift),
        child: FloatingActionButton.extended(
          heroTag: 'space-consult-chat',
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 2,
          onPressed: _toggleChat,
          label: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              _chat.status == AnimationStatus.forward ||
                      _chat.status == AnimationStatus.completed
                  ? '닫기'
                  : '문의',
              key: ValueKey<bool>(
                _chat.status == AnimationStatus.forward ||
                    _chat.status == AnimationStatus.completed,
              ),
              style: TextStyle(
                fontSize: 15 * fontScale,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  padding.left,
                  subGap,
                  padding.right,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      controller: _stages,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (
                            var i = 0;
                            i < ProjectStage.timeline.length;
                            i++
                          ) ...[
                            if (i > 0) const SizedBox(width: 6),
                            _StageChip(
                              key: _stageKeys[i],
                              label: ProjectStage.timeline[i].label,
                              selected: ProjectStage.timeline[i] == _stage,
                              fontScale: fontScale,
                              onTap: () {
                                final ProjectStage stage =
                                    ProjectStage.timeline[i];
                                setState(() => _stage = stage);
                                _reveal(stage);
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _StageTrack(index: widget.stage.index),
                    if (preview) ...[
                      const SizedBox(height: 8),
                      Text(
                        '미리보기 · 이 현장은 지금 ${widget.stage.label}',
                        style: TextStyle(
                          fontSize: 12 * fontScale,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child:
                    _stage == ProjectStage.visit
                        ? Padding(
                          padding: EdgeInsets.fromLTRB(
                            padding.left,
                            subGap,
                            padding.right,
                            8 + MediaQuery.paddingOf(context).bottom,
                          ),
                          child: _VisitStage(
                            visit: widget.visitAppointment,
                            fontScale: fontScale,
                          ),
                        )
                        : _stage == ProjectStage.consult
                        ? _ConsultStage(
                          record: widget.record,
                          fontScale: fontScale,
                        )
                        : ListView(
                          physics: const _ScrollOnlyWhenNeeded(),
                          padding: EdgeInsets.fromLTRB(
                            padding.left,
                            subGap,
                            padding.right,
                            barGap + MediaQuery.paddingOf(context).bottom,
                          ),
                          children: [
                            if (_stage == ProjectStage.build &&
                                progress != null)
                              _BuildBody(
                                progress: progress,
                                fontScale: fontScale,
                                sectionGap: sectionGap,
                                subGap: subGap,
                              )
                            else
                              _JourneyStage(
                                stage: _stage,
                                record: widget.record,
                                visitAppointment: widget.visitAppointment,
                                constructionPlan: widget.constructionPlan,
                                workQuote: widget.workQuote,
                                fontScale: fontScale,
                                quoteReviewed: _quoteReviewed,
                                contractSigned: _contractSigned,
                                onOpenContract: _openContract,
                              ),
                          ],
                        ),
              ),
              if (quoteBar)
                _QuoteActionBar(
                  reviewed: _quoteReviewed,
                  signed: _contractSigned,
                  padding: padding,
                  onSlideDone: _confirmQuoteRead,
                  onContract: _openContract,
                ),
            ],
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: _chat.isDismissed,
              child: AnimatedBuilder(
                animation: _chat,
                builder: (BuildContext context, Widget? child) {
                  final double t = _chatScale.value;
                  return Stack(
                    children: [
                      Opacity(
                        opacity: t,
                        child: const ColoredBox(color: Color(0x660B1F38)),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          padding.left,
                          8,
                          padding.right,
                          chatBottom,
                        ),
                        child: Transform.scale(
                          scale: t,
                          alignment: Alignment.bottomRight,
                          child: child,
                        ),
                      ),
                    ],
                  );
                },
                child: ConsultChatPanel(placeName: widget.placeName),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StageChip extends StatelessWidget {
  const _StageChip({
    super.key,
    required this.label,
    required this.selected,
    required this.fontScale,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double fontScale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: 0.7,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13 * fontScale,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _StageTrack extends StatelessWidget {
  const _StageTrack({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < ProjectStage.timeline.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: i <= index ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _QuoteActionBar extends StatelessWidget {
  const _QuoteActionBar({
    required this.reviewed,
    required this.signed,
    required this.padding,
    required this.onSlideDone,
    required this.onContract,
  });

  final bool reviewed;
  final bool signed;
  final EdgeInsets padding;
  final Future<bool> Function() onSlideDone;
  final VoidCallback onContract;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          padding.left,
          8,
          padding.right,
          8 + MediaQuery.paddingOf(context).bottom,
        ),
        child:
            reviewed
                ? AppButton(
                  label: signed ? '계약요청했어요' : '계약 단계로 넘어가기',
                  onPressed: onContract,
                )
                : SlideToConfirm(
                  label: '모든 내용 열람완료시 밀어주세요',
                  onCompleted: onSlideDone,
                ),
      ),
    );
  }
}

class _JourneyStage extends StatelessWidget {
  const _JourneyStage({
    required this.stage,
    required this.record,
    required this.visitAppointment,
    required this.constructionPlan,
    required this.workQuote,
    required this.fontScale,
    required this.quoteReviewed,
    required this.contractSigned,
    required this.onOpenContract,
  });

  final ProjectStage stage;
  final PrepRecord? record;
  final VisitAppointment? visitAppointment;
  final ConstructionPlan? constructionPlan;
  final WorkQuote? workQuote;
  final double fontScale;
  final bool quoteReviewed;
  final bool contractSigned;
  final VoidCallback onOpenContract;

  @override
  Widget build(BuildContext context) {
    switch (stage) {
      case ProjectStage.consult:
        return _ConsultStage(record: record, fontScale: fontScale);
      case ProjectStage.visit:
        return _VisitStage(visit: visitAppointment, fontScale: fontScale);
      case ProjectStage.quote:
        return _QuoteStage(
          plan: constructionPlan,
          quote: workQuote,
          fontScale: fontScale,
        );
      case ProjectStage.contract:
        return _ContractStage(
          fontScale: fontScale,
          reviewed: quoteReviewed,
          signed: contractSigned,
          onOpen: onOpenContract,
        );
      case ProjectStage.prep:
        return _PrepStage(fontScale: fontScale);
      case ProjectStage.build:
        return const SizedBox.shrink();
      case ProjectStage.handover:
        return _HandoverStage(fontScale: fontScale);
      case ProjectStage.afterCare:
        return _CareStage(fontScale: fontScale);
    }
  }
}
