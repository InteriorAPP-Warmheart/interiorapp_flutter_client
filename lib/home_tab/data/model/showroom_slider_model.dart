class ShowroomSliderModel {
  final String thumbnailUrl;
  final String themeName;
  final String userName;
  final String userProfileUrl;
  final int likeCount;

  const ShowroomSliderModel({
    required this.thumbnailUrl,
    required this.themeName,
    required this.userName,
    required this.userProfileUrl,
    required this.likeCount,
  });

  /// 서버 JSON -> Model
  /// 안전한 파싱: 키 누락/타입 불일치 시 의미있는 예외를 던지거나 기본값을 적용합니다.
  factory ShowroomSliderModel.fromJson(Map<String, dynamic> json) {
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

    return ShowroomSliderModel(
      thumbnailUrl: readString('thumbnailUrl'),
      themeName: readString('themeName'),
      userName: readString('userName'),
      userProfileUrl: readString('userProfileUrl'),
      likeCount: readInt('likeCount'),
    );
  }

  /// Model -> JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
        'thumbnailUrl': thumbnailUrl,
        'themeName': themeName,
        'userName': userName,
        'userProfileUrl': userProfileUrl,
        'likeCount': likeCount,
      };

  /// 편의: 복사 후 일부 필드만 변경
  ShowroomSliderModel copyWith({
    String? thumbnailUrl,
    String? themeName,
    String? userName,
    String? userProfileUrl,
    int? likeCount,
  }) {
    return ShowroomSliderModel(
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      themeName: themeName ?? this.themeName,
      userName: userName ?? this.userName,
      userProfileUrl: userProfileUrl ?? this.userProfileUrl,
      likeCount: likeCount ?? this.likeCount,
    );
  }

  /// 리스트 파싱 유틸
  static List<ShowroomSliderModel> listFromJson(List<dynamic> data) {
    return data
        .where((e) => e is Map<String, dynamic>)
        .map<ShowroomSliderModel>((e) => ShowroomSliderModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  String toString() =>
      'ShowroomSliderModel(themeName: $themeName, userName: $userName, likeCount: $likeCount)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShowroomSliderModel &&
        other.thumbnailUrl == thumbnailUrl &&
        other.themeName == themeName &&
        other.userName == userName &&
        other.userProfileUrl == userProfileUrl &&
        other.likeCount == likeCount;
  }

  @override
  int get hashCode => Object.hash(
        thumbnailUrl,
        themeName,
        userName,
        userProfileUrl,
        likeCount,
      );
}