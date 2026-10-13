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
    this.beforeAfter,
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
  final ShowroomBeforeAfter? beforeAfter;
  final ShowroomCost? cost;
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
    required this.beforeUrl,
    required this.afterUrl,
    required this.caption,
  });

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
  const ShowroomProcessFrame({required this.imageUrl, required this.caption});

  final String imageUrl;
  final String caption;
}
