/// 상담 접수 이후의 정식 프로젝트. 고객 화면에서는 현장명으로 보여 준다.
enum SpacePhase {
  consult('상담'),
  estimate('견적'),
  design('설계'),
  construction('공사'),
  handover('준공'),
  afterCare('A/S');

  const SpacePhase(this.label);

  final String label;

  static const List<SpacePhase> timeline = SpacePhase.values;
}

class SpaceProject {
  const SpaceProject({
    required this.id,
    required this.placeName,
    required this.statusLabel,
    required this.nextAction,
    required this.phase,
    required this.imageUrl,
    required this.completed,
  });

  final String id;
  final String placeName;
  final String statusLabel;
  final String nextAction;
  final SpacePhase phase;
  final String imageUrl;
  final bool completed;

  int get filledSteps => phase.index + 1;
}

/// 상담 전 사전준비. 정식 프로젝트와 따로 둔다.
class InteriorPrep {
  const InteriorPrep({
    required this.activePlaceName,
    required this.activeSummary,
    required this.candidates,
  });

  final String activePlaceName;
  final String activeSummary;

  /// 후보 현장. 최대 2곳.
  final List<String> candidates;
}
