class ShowroomStoryModel {
  const ShowroomStoryModel({
    required this.id,
    required this.title,
    required this.themeName,
    required this.thumbnailUrl,
    required this.userName,
    required this.userProfileUrl,
    required this.likeCount,
    required this.favoriteStatus,
    this.situation,
    this.comparisons = const <ShowroomBeforeAfter>[],
    this.cost,
    this.process = const <ShowroomProcessFrame>[],
    this.guide = const <String>[],
  });

  final String id;
  final String title;
  final String themeName;
  final String thumbnailUrl;
  final String userName;
  final String userProfileUrl;
  final int likeCount;
  final bool favoriteStatus;
  final ShowroomSituation? situation;

  /// 홀, 주방, 실외처럼 나눠 보여주는 시공 전후.
  final List<ShowroomBeforeAfter> comparisons;
  final ShowroomCost? cost;

  ShowroomBeforeAfter? get beforeAfter =>
      comparisons.isEmpty ? null : comparisons.first;
  final List<ShowroomProcessFrame> process;
  final List<String> guide;
}

class ShowroomSituation {
  const ShowroomSituation({
    required this.industry,
    required this.area,
    required this.budget,
    required this.period,
  });

  final String industry;
  final String area;
  final String budget;
  final String period;
}

class ShowroomBeforeAfter {
  const ShowroomBeforeAfter({
    this.zone = '',
    required this.beforeUrl,
    required this.afterUrl,
    required this.caption,
  });

  /// 보여주고 싶은 곳. 예: 홀, 주방, 실외.
  final String zone;
  final String beforeUrl;
  final String afterUrl;
  final String caption;
}

class ShowroomCost {
  const ShowroomCost({required this.total, required this.lines});

  final String total;
  final List<ShowroomCostLine> lines;
}

class ShowroomCostLine {
  const ShowroomCostLine({required this.name, required this.amount});

  final String name;
  final String amount;
}

class ShowroomProcessFrame {
  const ShowroomProcessFrame({
    this.id = '',
    this.trade = '',
    required this.imageUrl,
    required this.caption,
  });

  final String id;

  /// 공정 이름. 예: 철거, 목공, 마감.
  final String trade;
  final String imageUrl;

  /// 그 공정에서 남길 내용.
  final String caption;
}
