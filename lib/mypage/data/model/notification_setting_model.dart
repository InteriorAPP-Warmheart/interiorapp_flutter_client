/// 알림 설정 모델
class NotificationSettingModel {
  final bool pushEnabled;
  final bool marketingEnabled;
  final bool projectUpdateEnabled;

  const NotificationSettingModel({
    required this.pushEnabled,
    required this.marketingEnabled,
    required this.projectUpdateEnabled,
  });

  factory NotificationSettingModel.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic v, {bool fallback = true}) {
      if (v == null) return fallback;
      if (v is bool) return v;
      if (v is String) return v == 'true';
      return fallback;
    }

    return NotificationSettingModel(
      pushEnabled: parseBool(json['pushEnabled']),
      marketingEnabled: parseBool(json['marketingEnabled'], fallback: false),
      projectUpdateEnabled: parseBool(json['projectUpdateEnabled']),
    );
  }

  Map<String, dynamic> toJson() => {
        'pushEnabled': pushEnabled,
        'marketingEnabled': marketingEnabled,
        'projectUpdateEnabled': projectUpdateEnabled,
      };

  NotificationSettingModel copyWith({
    bool? pushEnabled,
    bool? marketingEnabled,
    bool? projectUpdateEnabled,
  }) =>
      NotificationSettingModel(
        pushEnabled: pushEnabled ?? this.pushEnabled,
        marketingEnabled: marketingEnabled ?? this.marketingEnabled,
        projectUpdateEnabled: projectUpdateEnabled ?? this.projectUpdateEnabled,
      );

  @override
  String toString() =>
      'NotificationSettingModel(push: $pushEnabled, marketing: $marketingEnabled, projectUpdate: $projectUpdateEnabled)';
}
