import 'dart:convert';

import 'package:interiorapp_flutter_client/mypage/data/model/recent_content_model.dart';
import 'package:interiorapp_flutter_client/mypage/data/model/saved_content_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 쇼룸 저장·최근 본 기록을 이 기기에만 둔다.
/// 서버 목록이 아니라 사용자가 연 쇼룸과 하트를 누른 쇼룸이다.
class ShowroomContentHistoryStore {
  static const String _savedKey = 'showroom_saved_contents';
  static const String _recentKey = 'showroom_recent_contents';

  /// 최근 본은 계속 쌓이므로, 오래된 기록은 기기에서 버린다.
  static const int recentLimit = 80;

  Future<void> _queue = Future<void>.value();

  Future<T> _run<T>(Future<T> Function() action) {
    final Future<T> result = _queue.then((_) => action());
    _queue = result.then((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<List<SavedContentModel>> readSaved() {
    return _run(() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return SavedContentModel.listFromJson(
        _decode(prefs.getString(_savedKey)),
      );
    });
  }

  Future<List<SavedContentModel>> upsertSaved(SavedContentModel item) {
    return _run(() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<SavedContentModel> current = SavedContentModel.listFromJson(
        _decode(prefs.getString(_savedKey)),
      );
      final List<SavedContentModel> next = <SavedContentModel>[
        item,
        ...current.where((SavedContentModel saved) => saved.id != item.id),
      ];
      await _write(
        prefs,
        _savedKey,
        next.map((SavedContentModel e) => e.toJson()),
      );
      return next;
    });
  }

  Future<List<SavedContentModel>> removeSaved(String id) {
    return _run(() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<SavedContentModel> current = SavedContentModel.listFromJson(
        _decode(prefs.getString(_savedKey)),
      );
      final List<SavedContentModel> next =
          current.where((SavedContentModel saved) => saved.id != id).toList();
      await _write(
        prefs,
        _savedKey,
        next.map((SavedContentModel e) => e.toJson()),
      );
      return next;
    });
  }

  Future<List<RecentContentModel>> readRecent() {
    return _run(() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return RecentContentModel.listFromJson(
        _decode(prefs.getString(_recentKey)),
      );
    });
  }

  Future<List<RecentContentModel>> upsertRecent(RecentContentModel item) {
    return _run(() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<RecentContentModel> current = RecentContentModel.listFromJson(
        _decode(prefs.getString(_recentKey)),
      );
      final List<RecentContentModel> next = <RecentContentModel>[
        item,
        ...current.where((RecentContentModel seen) => seen.id != item.id),
      ];
      if (next.length > recentLimit) {
        next.removeRange(recentLimit, next.length);
      }
      await _write(
        prefs,
        _recentKey,
        next.map((RecentContentModel e) => e.toJson()),
      );
      return next;
    });
  }

  Future<List<RecentContentModel>> removeRecent(String id) {
    return _run(() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<RecentContentModel> current = RecentContentModel.listFromJson(
        _decode(prefs.getString(_recentKey)),
      );
      final List<RecentContentModel> next =
          current.where((RecentContentModel seen) => seen.id != id).toList();
      await _write(
        prefs,
        _recentKey,
        next.map((RecentContentModel e) => e.toJson()),
      );
      return next;
    });
  }

  Future<List<RecentContentModel>> clearRecent() {
    return _run(() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentKey);
      return <RecentContentModel>[];
    });
  }

  Future<void> _write(
    SharedPreferences prefs,
    String key,
    Iterable<Map<String, dynamic>> items,
  ) {
    return prefs.setString(key, jsonEncode(items.toList()));
  }

  List<dynamic> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return const <dynamic>[];
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is List<dynamic>) return decoded;
    } catch (_) {}
    return const <dynamic>[];
  }
}
