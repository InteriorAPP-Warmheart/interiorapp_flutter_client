import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/mypage/data/model/completed_project_model.dart';
import 'package:interiorapp_flutter_client/mypage/data/model/mypage_user_model.dart';
import 'package:interiorapp_flutter_client/mypage/data/model/notification_setting_model.dart';
import 'package:interiorapp_flutter_client/mypage/data/model/recent_content_model.dart';
import 'package:interiorapp_flutter_client/mypage/data/model/saved_content_model.dart';
import 'package:interiorapp_flutter_client/mypage/presentation/provider/mypage_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 사용자 프로필 VM
// ─────────────────────────────────────────────────────────────────────────────

class MyPageUserVm extends Notifier<MyPageUserModel?> {
  @override
  MyPageUserModel? build() {
    // 초기 한 번만 자동 로드
    Future.microtask(() async {
      if (state == null) {
        state = await ref.read(myPageUserUseCaseProvider).getUser();
      }
    });
    return null;
  }

  Future<void> loadUser() async {
    state = await ref.read(myPageUserUseCaseProvider).getUser();
  }

  Future<void> updateUser(MyPageUserModel updated) async {
    state = await ref.read(myPageUserUseCaseProvider).updateUser(updated);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 알림 설정 VM
// ─────────────────────────────────────────────────────────────────────────────

class NotificationSettingVm extends Notifier<NotificationSettingModel> {
  @override
  NotificationSettingModel build() {
    Future.microtask(() async {
      state = await ref
          .read(myPageUserUseCaseProvider)
          .getNotificationSetting();
    });
    return const NotificationSettingModel(
      pushEnabled: true,
      marketingEnabled: false,
      projectUpdateEnabled: true,
    );
  }

  Future<void> togglePush() async {
    final updated = state.copyWith(pushEnabled: !state.pushEnabled);
    state = await ref
        .read(myPageUserUseCaseProvider)
        .updateNotificationSetting(updated);
  }

  Future<void> toggleMarketing() async {
    final updated =
        state.copyWith(marketingEnabled: !state.marketingEnabled);
    state = await ref
        .read(myPageUserUseCaseProvider)
        .updateNotificationSetting(updated);
  }

  Future<void> toggleProjectUpdate() async {
    final updated =
        state.copyWith(projectUpdateEnabled: !state.projectUpdateEnabled);
    state = await ref
        .read(myPageUserUseCaseProvider)
        .updateNotificationSetting(updated);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 저장한 콘텐츠 VM
// ─────────────────────────────────────────────────────────────────────────────

class SavedContentVm extends Notifier<List<SavedContentModel>> {
  @override
  List<SavedContentModel> build() {
    Future.microtask(() async {
      if (state.isEmpty) {
        state =
            await ref.read(savedContentUseCaseProvider).getSavedContents();
      }
    });
    return const <SavedContentModel>[];
  }

  Future<void> load() async {
    state = await ref.read(savedContentUseCaseProvider).getSavedContents();
  }

  Future<void> remove(String id) async {
    await ref.read(savedContentUseCaseProvider).removeSavedContent(id);
    state = state.where((e) => e.id != id).toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 최근 본 콘텐츠 VM
// ─────────────────────────────────────────────────────────────────────────────

class RecentContentVm extends Notifier<List<RecentContentModel>> {
  @override
  List<RecentContentModel> build() {
    Future.microtask(() async {
      if (state.isEmpty) {
        state = await ref
            .read(recentContentUseCaseProvider)
            .getRecentContents();
      }
    });
    return const <RecentContentModel>[];
  }

  Future<void> load() async {
    state =
        await ref.read(recentContentUseCaseProvider).getRecentContents();
  }

  Future<void> clearAll() async {
    await ref.read(recentContentUseCaseProvider).clearAllRecentContents();
    state = const <RecentContentModel>[];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 완료된 프로젝트 VM
// ─────────────────────────────────────────────────────────────────────────────

class CompletedProjectVm extends Notifier<List<CompletedProjectModel>> {
  @override
  List<CompletedProjectModel> build() {
    Future.microtask(() async {
      if (state.isEmpty) {
        state = await ref
            .read(completedProjectUseCaseProvider)
            .getCompletedProjects();
      }
    });
    return const <CompletedProjectModel>[];
  }

  Future<void> load() async {
    state = await ref
        .read(completedProjectUseCaseProvider)
        .getCompletedProjects();
  }
}
