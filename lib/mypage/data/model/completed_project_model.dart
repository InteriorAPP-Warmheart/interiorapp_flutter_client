/// 완료된 인테리어 프로젝트 이력 모델
class CompletedProjectModel {
  final String id;
  final String thumbnailUrl;
  final String title;
  final String category;
  final String companyName;
  final int buildCost;
  final double rating;
  final DateTime completedAt;

  const CompletedProjectModel({
    required this.id,
    required this.thumbnailUrl,
    required this.title,
    required this.category,
    required this.companyName,
    required this.buildCost,
    required this.rating,
    required this.completedAt,
  });

  factory CompletedProjectModel.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      throw const FormatException('CompletedProjectModel.fromJson: empty json');
    }

    double parseDouble(dynamic v, {double fallback = 0}) {
      if (v == null) return fallback;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? fallback;
      return fallback;
    }

    return CompletedProjectModel(
      id: json['id']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      buildCost: (json['buildCost'] as num?)?.toInt() ?? 0,
      rating: parseDouble(json['rating']),
      completedAt: json['completedAt'] is String
          ? DateTime.tryParse(json['completedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'thumbnailUrl': thumbnailUrl,
        'title': title,
        'category': category,
        'companyName': companyName,
        'buildCost': buildCost,
        'rating': rating,
        'completedAt': completedAt.toIso8601String(),
      };

  CompletedProjectModel copyWith({
    String? id,
    String? thumbnailUrl,
    String? title,
    String? category,
    String? companyName,
    int? buildCost,
    double? rating,
    DateTime? completedAt,
  }) =>
      CompletedProjectModel(
        id: id ?? this.id,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        title: title ?? this.title,
        category: category ?? this.category,
        companyName: companyName ?? this.companyName,
        buildCost: buildCost ?? this.buildCost,
        rating: rating ?? this.rating,
        completedAt: completedAt ?? this.completedAt,
      );

  static List<CompletedProjectModel> listFromJson(List<dynamic> data) => data
      .whereType<Map<String, dynamic>>()
      .map(CompletedProjectModel.fromJson)
      .toList(growable: false);

  @override
  String toString() =>
      'CompletedProjectModel(id: $id, title: $title, companyName: $companyName, rating: $rating)';
}
