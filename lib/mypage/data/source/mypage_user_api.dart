import 'dart:async';
import 'package:interiorapp_flutter_client/mypage/data/model/mypage_user_model.dart';
import 'package:interiorapp_flutter_client/mypage/data/model/notification_setting_model.dart';

/// 사용자 프로필 & 알림 설정 API
/// - 실제 서버 연동 전 더미 데이터로 동작
class MyPageUserApi {
  // 서버 응답 형태를 가정한 목데이터
  final Map<String, dynamic> _userJson = {
    'id': 'user-001',
    'name': '홍길동',
    'email': 'hong@example.com',
    'phone': '010-1234-5678',
    'profileImageUrl': null,
    'isBusinessUser': true,
    'businessName': '홍길동 인테리어',
    'businessNumber': '123-45-67890',
  };

  Map<String, dynamic> _notificationJson = {
    'pushEnabled': true,
    'marketingEnabled': false,
    'projectUpdateEnabled': true,
  };

  Future<MyPageUserModel> getUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MyPageUserModel.fromJson(_userJson);
  }

  Future<MyPageUserModel> updateUser(MyPageUserModel updated) async {
    await Future.delayed(const Duration(milliseconds: 350));
    _userJson.addAll(updated.toJson());
    return MyPageUserModel.fromJson(_userJson);
  }

  Future<NotificationSettingModel> getNotificationSetting() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return NotificationSettingModel.fromJson(_notificationJson);
  }

  Future<NotificationSettingModel> updateNotificationSetting(
    NotificationSettingModel setting,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _notificationJson = setting.toJson();
    return NotificationSettingModel.fromJson(_notificationJson);
  }
}
