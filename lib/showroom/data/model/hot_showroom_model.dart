class HotShowroomModel {
  final String id;
  final String thumbnailUrl;
  final String title;
  final String themeName;
  final String userName;
  final String userProfileUrl;
  final bool favoriteStatus;
  final int likeCount;

  /// 사진 가로 / 세로. 마소니리에서 카드 높이를 이 값으로 잡는다.
  final double imageRatio;

  const HotShowroomModel({
    required this.id,
    required this.thumbnailUrl,
    required this.title,
    required this.themeName,
    required this.userName,
    required this.userProfileUrl,
    required this.favoriteStatus,
    required this.likeCount,
    this.imageRatio = 0.8,
  });

  /// 서버 JSON -> Model
  /// 안전한 파싱: 키 누락/타입 불일치 시 의미있는 예외를 던지거나 기본값을 적용합니다.
  factory HotShowroomModel.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      throw const FormatException('ShowroomSliderModel.fromJson: empty json');
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

    double readDouble(String key, {double defaultValue = 0.8}) {
      final dynamic value = json[key];
      if (value == null) return defaultValue;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    return HotShowroomModel(
      id: readString('id'),
      thumbnailUrl: readString('thumbnailUrl'),
      title: readString('title'),
      themeName: readString('themeName'),
      userName: readString('userName'),
      userProfileUrl: readString('userProfileUrl'),
      favoriteStatus: readBool('favoriteStatus'),
      likeCount: readInt('likeCount'),
      imageRatio: readDouble('imageRatio'),
    );
  }

  /// Model -> JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'thumbnailUrl': thumbnailUrl,
    'title': title,
    'themeName': themeName,
    'userName': userName,
    'userProfileUrl': userProfileUrl,
    'favoriteStatus': favoriteStatus,
    'likeCount': likeCount,
    'imageRatio': imageRatio,
  };

  /// 편의: 복사 후 일부 필드만 변경
  HotShowroomModel copyWith({
    String? id,
    String? thumbnailUrl,
    String? title,
    String? themeName,
    String? userName,
    String? userProfileUrl,
    bool? favoriteStatus,
    int? likeCount,
    double? imageRatio,
  }) {
    return HotShowroomModel(
      id: id ?? this.id,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      title: title ?? this.title,
      themeName: themeName ?? this.themeName,
      userName: userName ?? this.userName,
      userProfileUrl: userProfileUrl ?? this.userProfileUrl,
      favoriteStatus: favoriteStatus ?? this.favoriteStatus,
      likeCount: likeCount ?? this.likeCount,
      imageRatio: imageRatio ?? this.imageRatio,
    );
  }

  /// 리스트 파싱 유틸
  static List<HotShowroomModel> listFromJson(List<dynamic> data) {
    return data
        .where((e) => e is Map<String, dynamic>)
        .map<HotShowroomModel>(
          (e) => HotShowroomModel.fromJson(e as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  @override
  String toString() =>
      'HotShowroomModel(themeName: $themeName, userName: $userName, favoriteStatus: $favoriteStatus, likeCount: $likeCount)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HotShowroomModel &&
        other.id == id &&
        other.thumbnailUrl == thumbnailUrl &&
        other.title == title &&
        other.themeName == themeName &&
        other.userName == userName &&
        other.userProfileUrl == userProfileUrl &&
        other.favoriteStatus == favoriteStatus &&
        other.likeCount == likeCount &&
        other.imageRatio == imageRatio;
  }

  @override
  int get hashCode => Object.hash(
    id,
    thumbnailUrl,
    title,
    themeName,
    userName,
    userProfileUrl,
    favoriteStatus,
    likeCount,
    imageRatio,
  );
}
