import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/construction_plan.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/construction_progress.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/prep_detail_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/industry_cover.dart';
import 'package:interiorapp_flutter_client/core/theme/app_colors.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/core/widget/app_bottom_sheet.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';

part 'progress/progress_shared.dart';
part 'progress/consult_stage.dart';
part 'progress/visit_stage.dart';
part 'progress/plan_stage.dart';
part 'progress/estimate_stage.dart';
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
  });

  final String placeName;
  final ProjectStage stage;
  final PrepRecord? record;
  final ConstructionProgress? progress;

  /// 전화 상담에서 정한 현장 방문.
  final VisitAppointment? visitAppointment;

  /// 현장방문 이후 확정된 시공안.
  final ConstructionPlan? constructionPlan;

  @override
  State<ProjectProgressView> createState() => _ProjectProgressViewState();
}

class _ProjectProgressViewState extends State<ProjectProgressView> {
  late ProjectStage _stage;
  final ScrollController _stages = ScrollController();
  final List<GlobalKey> _stageKeys = List<GlobalKey>.generate(
    ProjectStage.timeline.length,
    (_) => GlobalKey(),
  );

  @override
  void initState() {
    super.initState();
    _stage = widget.stage;
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(_stage));
  }

  @override
  void dispose() {
    _stages.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final double fontScale = ResponsiveSize.fontScale(context);
    final EdgeInsets padding = ResponsiveSize.responsivePadding(context);
    final double subGap = ResponsiveSize.subGap(context);
    final double sectionGap = ResponsiveSize.sectionGap(context);
    final bool preview = _stage != widget.stage;
    final ConstructionProgress? progress =
        _stage == ProjectStage.build ? widget.progress ?? _sampleBuild : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.placeName)),
      body: Column(
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
                            final ProjectStage stage = ProjectStage.timeline[i];
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
                    ? _ConsultStage(record: widget.record, fontScale: fontScale)
                    : ListView(
                      physics: const _ScrollOnlyWhenNeeded(),
                      padding: EdgeInsets.fromLTRB(
                        padding.left,
                        subGap,
                        padding.right,
                        24 + MediaQuery.paddingOf(context).bottom,
                      ),
                      children: [
                        if (_stage == ProjectStage.build && progress != null)
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
                            fontScale: fontScale,
                          ),
                      ],
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

class _JourneyStage extends StatelessWidget {
  const _JourneyStage({
    required this.stage,
    required this.record,
    required this.visitAppointment,
    required this.constructionPlan,
    required this.fontScale,
  });

  final ProjectStage stage;
  final PrepRecord? record;
  final VisitAppointment? visitAppointment;
  final ConstructionPlan? constructionPlan;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    switch (stage) {
      case ProjectStage.consult:
        return _ConsultStage(record: record, fontScale: fontScale);
      case ProjectStage.visit:
        return _VisitStage(visit: visitAppointment, fontScale: fontScale);
      case ProjectStage.plan:
        return _PlanStage(
          record: record,
          plan: constructionPlan,
          fontScale: fontScale,
        );
      case ProjectStage.estimate:
        return _EstimateStage(fontScale: fontScale);
      case ProjectStage.contract:
        return _ContractStage(fontScale: fontScale);
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
