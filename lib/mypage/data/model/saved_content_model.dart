/// 이 기기에 저장한 쇼룸.
class SavedContentModel {
  final String id;
  final String thumbnailUrl;
  final String title;
  final String category;
  final String contentType;
  final String authorName;
  final String place;
  final DateTime savedAt;

  const SavedContentModel({
    required this.id,
    required this.thumbnailUrl,
    required this.title,
    required this.category,
    this.contentType = 'showroom',
    this.authorName = '',
    this.place = '',
    required this.savedAt,
  });

  factory SavedContentModel.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      throw const FormatException('SavedContentModel.fromJson: empty json');
    }
    return SavedContentModel(
      id: json['id']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      contentType: json['contentType']?.toString() ?? 'showroom',
      authorName: json['authorName']?.toString() ?? '',
      place: json['place']?.toString() ?? '',
      savedAt:
          json['savedAt'] is String
              ? DateTime.tryParse(json['savedAt'] as String) ?? DateTime.now()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'thumbnailUrl': thumbnailUrl,
    'title': title,
    'category': category,
    'contentType': contentType,
    'authorName': authorName,
    'place': place,
    'savedAt': savedAt.toIso8601String(),
  };

  SavedContentModel copyWith({
    String? id,
    String? thumbnailUrl,
    String? title,
    String? category,
    String? contentType,
    String? authorName,
    String? place,
    DateTime? savedAt,
  }) => SavedContentModel(
    id: id ?? this.id,
    thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    title: title ?? this.title,
    category: category ?? this.category,
    contentType: contentType ?? this.contentType,
    authorName: authorName ?? this.authorName,
    place: place ?? this.place,
    savedAt: savedAt ?? this.savedAt,
  );

  static List<SavedContentModel> listFromJson(List<dynamic> data) => data
      .whereType<Map<String, dynamic>>()
      .map(SavedContentModel.fromJson)
      .toList(growable: false);

  @override
  String toString() =>
      'SavedContentModel(id: $id, title: $title, category: $category)';
}
