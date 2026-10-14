import 'package:interiorapp_flutter_client/mypage/data/model/mypage_user_model.dart';
import 'package:interiorapp_flutter_client/mypage/data/model/notification_setting_model.dart';
import 'package:interiorapp_flutter_client/mypage/domain/repository/mypage_user_repository.dart';

class MyPageUserUseCase {
  final MyPageUserRepository _repository;
  MyPageUserUseCase(this._repository);

  Future<MyPageUserModel> getUser() => _repository.getUser();

  Future<MyPageUserModel> updateUser(MyPageUserModel updated) =>
      _repository.updateUser(updated);

  Future<NotificationSettingModel> getNotificationSetting() =>
      _repository.getNotificationSetting();

  Future<NotificationSettingModel> updateNotificationSetting(
    NotificationSettingModel setting,
  ) =>
      _repository.updateNotificationSetting(setting);
}
