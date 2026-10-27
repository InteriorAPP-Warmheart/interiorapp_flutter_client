/// 시공안에서 확정된 항목 하나. 결론이 있는 것만 담는다.
class PlanDecision {
  const PlanDecision({
    required this.conclusion,
    required this.customerNote,
    required this.staffNote,
  });

  final String conclusion;

  /// 고객이 말한 점.
  final String customerNote;

  /// 담당자가 범위를 정리한 말.
  final String staffNote;
}

/// 현장방문 이후 확정된 시공안. 상담 때 받은 업종·공사 범위는 따로 둔다.
class ConstructionPlan {
  const ConstructionPlan({
    this.scope = const <PlanDecision>[],
    this.excluded = const <PlanDecision>[],
    this.constraints = const <PlanDecision>[],
  });

  /// 살릴 곳과 바꿀 곳.
  final List<PlanDecision> scope;

  /// 이번에 하지 않는 공사.
  final List<PlanDecision> excluded;

  /// 현장에서 확인한 조건.
  final List<PlanDecision> constraints;
}
