import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/construction_progress.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/presentation/provider/build_provider.dart';
import 'package:interiorapp_flutter_client/build/presentation/vm/space_board_vm.dart';
import 'package:interiorapp_flutter_client/build/ui/widget/project_progress_view.dart';

class SpaceDetailScreen extends ConsumerWidget {
  const SpaceDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SpaceBoard board = ref.watch(spaceBoardProvider);
    final SpaceProject? project = board.find(projectId);
    if (project == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('현장을 찾지 못했어요')),
      );
    }

    return ProjectProgressView(
      placeName: project.placeName,
      stage: _projectStage(project.phase),
      projectId: project.id,
      record: board.recordFor(project.id),
      progress: board.constructionFor(project.id),
      visitAppointment: project.visitAppointment,
      constructionPlan: project.constructionPlan,
      workQuote: project.workQuote,
      handoverDone: project.completed,
    );
  }
}

ProjectStage _projectStage(SpacePhase phase) {
  switch (phase) {
    case SpacePhase.consult:
      return ProjectStage.consult;
    case SpacePhase.estimate:
    case SpacePhase.design:
      return ProjectStage.quote;
    case SpacePhase.construction:
      return ProjectStage.build;
    case SpacePhase.handover:
      return ProjectStage.handover;
    case SpacePhase.afterCare:
      return ProjectStage.afterCare;
  }
}
