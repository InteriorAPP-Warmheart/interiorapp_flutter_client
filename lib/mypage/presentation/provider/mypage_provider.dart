import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/mypage/data/model/completed_project_model.dart';
import 'package:interiorapp_flutter_client/mypage/data/model/mypage_user_model.dart';
import 'package:interiorapp_flutter_client/mypage/data/model/notification_setting_model.dart';
import 'package:interiorapp_flutter_client/mypage/data/model/recent_content_model.dart';
import 'package:interiorapp_flutter_client/mypage/data/model/saved_content_model.dart';
import 'package:interiorapp_flutter_client/mypage/data/repository/completed_project_repository_impl.dart';
import 'package:interiorapp_flutter_client/mypage/data/repository/mypage_user_repository_impl.dart';
import 'package:interiorapp_flutter_client/mypage/data/repository/recent_content_repository_impl.dart';
import 'package:interiorapp_flutter_client/mypage/data/repository/saved_content_repository_impl.dart';
import 'package:interiorapp_flutter_client/mypage/data/source/completed_project_api.dart';
import 'package:interiorapp_flutter_client/mypage/data/source/mypage_user_api.dart';
import 'package:interiorapp_flutter_client/mypage/data/source/recent_content_api.dart';
import 'package:interiorapp_flutter_client/mypage/data/source/saved_content_api.dart';
import 'package:interiorapp_flutter_client/mypage/domain/use_case/completed_project_use_case.dart';
import 'package:interiorapp_flutter_client/mypage/domain/use_case/mypage_user_use_case.dart';
import 'package:interiorapp_flutter_client/mypage/domain/use_case/recent_content_use_case.dart';
import 'package:interiorapp_flutter_client/mypage/domain/use_case/saved_content_use_case.dart';
import 'package:interiorapp_flutter_client/mypage/presentation/vm/mypage_vm.dart';

// ─────────────────────────────────────────────────────────────────────────────
// API Providers
// ─────────────────────────────────────────────────────────────────────────────

final myPageUserApiProvider = Provider((_) => MyPageUserApi());
final savedContentApiProvider = Provider((_) => SavedContentApi());
final recentContentApiProvider = Provider((_) => RecentContentApi());
final completedProjectApiProvider = Provider((_) => CompletedProjectApi());

// ─────────────────────────────────────────────────────────────────────────────
// Repository Providers
// ─────────────────────────────────────────────────────────────────────────────

final myPageUserRepositoryProvider = Provider(
  (ref) => MyPageUserRepositoryImpl(ref.read(myPageUserApiProvider)),
);

final savedContentRepositoryProvider = Provider(
  (ref) => SavedContentRepositoryImpl(ref.read(savedContentApiProvider)),
);

final recentContentRepositoryProvider = Provider(
  (ref) => RecentContentRepositoryImpl(ref.read(recentContentApiProvider)),
);

final completedProjectRepositoryProvider = Provider(
  (ref) =>
      CompletedProjectRepositoryImpl(ref.read(completedProjectApiProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// UseCase Providers
// ─────────────────────────────────────────────────────────────────────────────

final myPageUserUseCaseProvider = Provider(
  (ref) => MyPageUserUseCase(ref.read(myPageUserRepositoryProvider)),
);

final savedContentUseCaseProvider = Provider(
  (ref) => SavedContentUseCase(ref.read(savedContentRepositoryProvider)),
);

final recentContentUseCaseProvider = Provider(
  (ref) => RecentContentUseCase(ref.read(recentContentRepositoryProvider)),
);

final completedProjectUseCaseProvider = Provider(
  (ref) =>
      CompletedProjectUseCase(ref.read(completedProjectRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// ViewModel Providers
// ─────────────────────────────────────────────────────────────────────────────

final myPageUserVmProvider =
    NotifierProvider<MyPageUserVm, MyPageUserModel?>(MyPageUserVm.new);

final notificationSettingVmProvider =
    NotifierProvider<NotificationSettingVm, NotificationSettingModel>(
      NotificationSettingVm.new,
    );

final savedContentVmProvider =
    NotifierProvider<SavedContentVm, List<SavedContentModel>>(
      SavedContentVm.new,
    );

final recentContentVmProvider =
    NotifierProvider<RecentContentVm, List<RecentContentModel>>(
      RecentContentVm.new,
    );

final completedProjectVmProvider =
    NotifierProvider<CompletedProjectVm, List<CompletedProjectModel>>(
      CompletedProjectVm.new,
    );
