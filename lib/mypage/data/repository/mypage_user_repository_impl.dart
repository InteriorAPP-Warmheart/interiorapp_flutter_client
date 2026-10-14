import 'package:interiorapp_flutter_client/mypage/data/model/mypage_user_model.dart';
import 'package:interiorapp_flutter_client/mypage/data/model/notification_setting_model.dart';
import 'package:interiorapp_flutter_client/mypage/data/source/mypage_user_api.dart';
import 'package:interiorapp_flutter_client/mypage/domain/repository/mypage_user_repository.dart';

class MyPageUserRepositoryImpl implements MyPageUserRepository {
  final MyPageUserApi _api;
  MyPageUserRepositoryImpl(this._api);

  @override
  Future<MyPageUserModel> getUser() => _api.getUser();

  @override
  Future<MyPageUserModel> updateUser(MyPageUserModel updated) =>
      _api.updateUser(updated);

  @override
  Future<NotificationSettingModel> getNotificationSetting() =>
      _api.getNotificationSetting();

  @override
  Future<NotificationSettingModel> updateNotificationSetting(
    NotificationSettingModel setting,
  ) =>
      _api.updateNotificationSetting(setting);
}
