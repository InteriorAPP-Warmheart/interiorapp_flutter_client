class FilteredShowroomModel {
  final String id;
  final String thumbnailUrl;
  final String themeName;
  final String userName;
  final String userProfileUrl;
  final bool favoriteStatus;
  final int likeCount;
  final List<String> tags; 

  const FilteredShowroomModel({
    required this.id,
    required this.thumbnailUrl,
    required this.themeName,
    required this.userName,
    required this.userProfileUrl,
    required this.favoriteStatus,
    required this.likeCount,
    required this.tags,
  });

  factory FilteredShowroomModel.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      throw const FormatException('JSON 없음');
    }

    String readString(String key, {String defaultValue = ''}) {
      final dynamic value = json[key];
      if (value == null) return defaultValue;
      if (value is String) return value;
      return value.toString();
    }

    int readInt(String key, {int defaultValue = 0}) {
      final dynamic value = json[key];
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
      return defaultValue;
    }

    bool readBool(String key, {bool defaultValue = false}) {
      final dynamic value = json[key];
      if (value == null) return defaultValue;
      if (value is bool) return value;
      return value.toString() == 'true';
    }

    List<String> readStringList(String key) {
      final dynamic value = json[key];
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    return FilteredShowroomModel(
      id: readString('id'),
      thumbnailUrl: readString('thumbnailUrl'),
      themeName: readString('themeName'),
      userName: readString('userName'),
      userProfileUrl: readString('userProfileUrl'),
      favoriteStatus: readBool('favoriteStatus'),
      likeCount: readInt('likeCount'),
      tags: readStringList('tags'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'thumbnailUrl': thumbnailUrl,
        'themeName': themeName,
        'userName': userName,
        'userProfileUrl': userProfileUrl,
        'favoriteStatus': favoriteStatus,
        'likeCount': likeCount,
        'tags': tags,
      };

  FilteredShowroomModel copyWith({
    String? id,
    String? thumbnailUrl,
    String? themeName,
    String? userName,
    String? userProfileUrl,
    bool? favoriteStatus,
    int? likeCount,
    List<String>? tags,
  }) {
    return FilteredShowroomModel(
      id: id ?? this.id,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      themeName: themeName ?? this.themeName,
      userName: userName ?? this.userName,
      userProfileUrl: userProfileUrl ?? this.userProfileUrl,
      favoriteStatus: favoriteStatus ?? this.favoriteStatus,
      likeCount: likeCount ?? this.likeCount,
      tags: tags ?? this.tags,
    );
  }

  static List<FilteredShowroomModel> listFromJson(List<dynamic> data) {
    return data
        .where((e) => e is Map<String, dynamic>)
        .map<FilteredShowroomModel>(
            (e) => FilteredShowroomModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  String toString() =>
      'FilteredShowroomModel(themeName: $themeName, userName: $userName, tags: $tags)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilteredShowroomModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}