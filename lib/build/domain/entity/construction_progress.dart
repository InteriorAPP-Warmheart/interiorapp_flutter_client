/// 상담 접수 이후 프로젝트가 가는 단계.
enum ProjectStage {
  consult('상담'),
  visit('현장방문·실사'),
  quote('시공·견적'),
  contract('계약'),
  prep('착공준비'),
  build('공사진행'),
  handover('준공'),
  afterCare('A/S');

  const ProjectStage(this.label);

  final String label;

  static const List<ProjectStage> timeline = ProjectStage.values;
}

/// 오늘 현장의 고객용 상태. 내부 누락 경고는 넣지 않는다.
enum TodayWorkState {
  /// 오늘 공정이 진행 중이고, 확인된 요약이 있다.
  underway,

  /// 오늘 작업은 예정돼 있으나 검토가 끝나지 않았다. 공사 중단이 아니다.
  checking,

  /// 예정된 현장 작업이 없다.
  idle,

  /// 시공 실행은 끝났고 최종 확인 중이다.
  closing,
}

/// 오늘 중심 공정 옆에 같이 가는 공정.
class SideTrade {
  const SideTrade({
    required this.name,
    required this.summary,
    required this.when,
  });

  final String name;
  final String summary;

  /// 예정 시점. 예: 오늘, 내일.
  final String when;
}

/// 현장관리가 고객에게 공개한 사진.
class PublicSitePhoto {
  const PublicSitePhoto({
    required this.imageUrl,
    required this.trade,
    required this.takenOn,
  });

  final String imageUrl;
  final String trade;

  /// 고객에게 보이는 날짜. 예: 10월 22일.
  final String takenOn;
}

/// 공사진행 단계에서 보여 주는 오늘·다음 공정. 작업자 원문은 담지 않는다.
class ConstructionProgress {
  const ConstructionProgress({
    required this.currentLabel,
    required this.today,
    required this.trades,
    required this.tradeIndex,
    this.expectedCompletion = '',
    this.todayTrade = '',
    this.todaySummary = '',
    this.workers = '',
    this.sideTrades = const <SideTrade>[],
    this.idleReason = '',
    this.nextWhen = '',
    this.nextTrade = '',
    this.nextSummary = '',
    this.recentPhotos = const <PublicSitePhoto>[],
  });

  /// 지금 중심 공정. 예: 목공 공사 진행중.
  final String currentLabel;

  /// 예상 완료일. 비어 있으면 보여 주지 않는다.
  final String expectedCompletion;

  final TodayWorkState today;

  /// 오늘 중심 공정 이름. 예: 목공 공사.
  final String todayTrade;

  /// 확인된 작업 요약. 검토 중이면 가장 최근 확인 내용이다.
  final String todaySummary;

  /// 오늘 투입 인원 요약. 개인 평가는 넣지 않는다.
  final String workers;

  final List<SideTrade> sideTrades;

  /// 작업 없는 날의 확인된 이유. 없으면 비우고 추정하지 않는다.
  final String idleReason;

  /// 다음 작업 시점. 예: 내일. 비어 있으면 다음 일정이 미정이다.
  final String nextWhen;

  /// 다음 공정 이름. 비어 있으면 일정 확인중이다.
  final String nextTrade;

  final String nextSummary;
  final List<PublicSitePhoto> recentPhotos;

  /// 이 현장에 만든 공정. 없는 공정은 넣지 않는다.
  final List<String> trades;

  /// [trades] 안에서 지금 중심 공정의 위치.
  final int tradeIndex;

  List<PublicSitePhoto> get previewPhotos =>
      recentPhotos.length <= 3 ? recentPhotos : recentPhotos.sublist(0, 3);

  bool get showsWorkers => workers.isNotEmpty && today != TodayWorkState.idle;

  bool get showsSideTrades =>
      sideTrades.isNotEmpty && today != TodayWorkState.idle;

  String get todayMark {
    switch (today) {
      case TodayWorkState.underway:
        return '진행중';
      case TodayWorkState.checking:
        return '확인중';
      case TodayWorkState.idle:
        return '작업 없음';
      case TodayWorkState.closing:
        return '최종 확인중';
    }
  }

  String get todayTitle {
    switch (today) {
      case TodayWorkState.underway:
        return todayTrade.isEmpty ? '오늘 공사' : todayTrade;
      case TodayWorkState.checking:
        return todayTrade.isEmpty ? '오늘 작업기록 확인중' : todayTrade;
      case TodayWorkState.idle:
        return '오늘은 예정된 현장 작업이 없습니다';
      case TodayWorkState.closing:
        return '시공 마무리 · 최종 확인중';
    }
  }

  String get todayNote {
    switch (today) {
      case TodayWorkState.underway:
        return todaySummary;
      case TodayWorkState.checking:
        if (todaySummary.isEmpty) return '오늘 작업기록을 확인하고 있어요';
        return '오늘 작업기록을 확인하고 있어요\n최근 확인 · $todaySummary';
      case TodayWorkState.idle:
        return idleReason;
      case TodayWorkState.closing:
        return todaySummary;
    }
  }

  String get nextLabel => nextWhen.isEmpty ? '다음' : nextWhen;

  String get nextTitle => nextTrade.isEmpty ? '일정 확인중' : nextTrade;
}
