class RecommendBuildModel {
  final String id;
  final String thumbnailUrl;
  final String companyName;
  final String buildAddress;
  final int buildPeriod;
  final int buildCost;
  final bool favoriteStatus;
  final double rating;

  const RecommendBuildModel({
    required this.id,
    required this.thumbnailUrl,
    required this.companyName,
    required this.buildAddress,
    required this.buildPeriod,
    required this.buildCost,
    required this.favoriteStatus,
    required this.rating,
  });

  factory RecommendBuildModel.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      throw const FormatException('RecommendBuildCaseModel.fromJson: empty json');
    }


    double parseDouble(dynamic v, {double fallback = 0}) {
      if (v == null) return fallback;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? fallback;
      return fallback;
    }

    return RecommendBuildModel(
      id: json['id']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      buildAddress: json['buildAddress']?.toString() ?? '',
      buildPeriod: json['buildPeriod'] ?? 0,
      buildCost: json['buildCost'] ?? 0,
      favoriteStatus: json['favoriteStatus'] == true || json['favoriteStatus'] == 'true',
      rating: parseDouble(json['rating']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'thumbnailUrl': thumbnailUrl,
      'companyName': companyName,
      'buildAddress': buildAddress,
      'buildPeriod': buildPeriod,
      'buildCost': buildCost,
      'favoriteStatus': favoriteStatus,
      'rating': rating,
    };
  }

  static List<RecommendBuildModel> listFromJson(List<dynamic> data) {
    return data
        .where((e) => e is Map<String, dynamic>)
        .map((e) => RecommendBuildModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  RecommendBuildModel copyWith({
    String? id,
    String? thumbnailUrl,
    String? companyName,
    String? buildAddress,
    int? buildPeriod,
    int? buildCost,
    bool? favoriteStatus,
    double? rating,
  }) {
    return RecommendBuildModel(
      id: id ?? this.id,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      companyName: companyName ?? this.companyName,
      buildAddress: buildAddress ?? this.buildAddress,
      buildPeriod: buildPeriod ?? this.buildPeriod,
      buildCost: buildCost ?? this.buildCost,
      favoriteStatus: favoriteStatus ?? this.favoriteStatus,
      rating: rating ?? this.rating,
    );
  }

  @override
  String toString() =>
      'RecommendBuildModel(id: $id, company: $companyName, rating: $rating, buildCost: $buildCost, buildPeriod: $buildPeriod)';
}
