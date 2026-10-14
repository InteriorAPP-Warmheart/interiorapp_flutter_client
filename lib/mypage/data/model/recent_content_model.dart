/// 최근 본 콘텐츠 모델
class RecentContentModel {
  final String id;
  final String thumbnailUrl;
  final String title;
  final String category;
  final String contentType; // 'showroom' | 'store' | 'article'
  final DateTime viewedAt;

  const RecentContentModel({
    required this.id,
    required this.thumbnailUrl,
    required this.title,
    required this.category,
    required this.contentType,
    required this.viewedAt,
  });

  factory RecentContentModel.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      throw const FormatException('RecentContentModel.fromJson: empty json');
    }
    return RecentContentModel(
      id: json['id']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      contentType: json['contentType']?.toString() ?? 'showroom',
      viewedAt: json['viewedAt'] is String
          ? DateTime.tryParse(json['viewedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'thumbnailUrl': thumbnailUrl,
        'title': title,
        'category': category,
        'contentType': contentType,
        'viewedAt': viewedAt.toIso8601String(),
      };

  RecentContentModel copyWith({
    String? id,
    String? thumbnailUrl,
    String? title,
    String? category,
    String? contentType,
    DateTime? viewedAt,
  }) =>
      RecentContentModel(
        id: id ?? this.id,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        title: title ?? this.title,
        category: category ?? this.category,
        contentType: contentType ?? this.contentType,
        viewedAt: viewedAt ?? this.viewedAt,
      );

  static List<RecentContentModel> listFromJson(List<dynamic> data) => data
      .whereType<Map<String, dynamic>>()
      .map(RecentContentModel.fromJson)
      .toList(growable: false);

  @override
  String toString() =>
      'RecentContentModel(id: $id, title: $title, viewedAt: $viewedAt)';
}
