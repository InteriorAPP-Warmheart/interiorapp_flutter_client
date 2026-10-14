import 'package:interiorapp_flutter_client/mypage/data/model/mypage_user_model.dart';
import 'package:interiorapp_flutter_client/mypage/data/model/notification_setting_model.dart';

abstract class MyPageUserRepository {
  Future<MyPageUserModel> getUser();
  Future<MyPageUserModel> updateUser(MyPageUserModel updated);
  Future<NotificationSettingModel> getNotificationSetting();
  Future<NotificationSettingModel> updateNotificationSetting(
    NotificationSettingModel setting,
  );
}
