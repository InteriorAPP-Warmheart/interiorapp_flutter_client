import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/showroom_city_catalog.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ShowroomFeedSort { latest, popular }

class ShowroomFeedBrowse {
  const ShowroomFeedBrowse({
    this.sort = ShowroomFeedSort.latest,
    this.place,
    this.pinFavorites = false,
  });

  final ShowroomFeedSort sort;

  /// 고른 시 또는 도. 예: 수원시, 경기.
  final String? place;

  /// 켜면 찜한 글이 같은 정렬 안에서 맨 위로 붙는다.
  final bool pinFavorites;

  ShowroomFeedBrowse copyWith({
    ShowroomFeedSort? sort,
    String? place,
    bool clearPlace = false,
    bool? pinFavorites,
  }) {
    return ShowroomFeedBrowse(
      sort: sort ?? this.sort,
      place: clearPlace ? null : place ?? this.place,
      pinFavorites: pinFavorites ?? this.pinFavorites,
    );
  }
}

class ShowroomFeedBrowseNotifier extends Notifier<ShowroomFeedBrowse> {
  static const String _placeKey = 'showroom_feed_city';
  bool _placeChosen = false;

  @override
  ShowroomFeedBrowse build() {
    Future<void>(_restorePlace);
    return const ShowroomFeedBrowse();
  }

  Future<void> _restorePlace() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString(_placeKey);
    if (_placeChosen || saved == null || !isShowroomPlace(saved)) return;
    state = state.copyWith(place: saved);
  }

  void setSort(ShowroomFeedSort sort) {
    if (state.sort == sort) return;
    state = state.copyWith(sort: sort);
  }

  void setPinFavorites(bool pin) {
    if (state.pinFavorites == pin) return;
    state = state.copyWith(pinFavorites: pin);
  }

  Future<void> setPlace(String place) async {
    if (!isShowroomPlace(place)) return;
    _placeChosen = true;
    state = state.copyWith(place: place);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_placeKey, place);
  }
}

final showroomFeedBrowseProvider =
    NotifierProvider<ShowroomFeedBrowseNotifier, ShowroomFeedBrowse>(
      ShowroomFeedBrowseNotifier.new,
    );

List<T> sortedShowroomFeed<T>(
  List<T> items,
  ShowroomFeedSort sort, {
  required int Function(T item) likes,
  required DateTime Function(T item) publishedAt,
  bool pinFavorites = false,
  bool Function(T item)? favorite,
}) {
  final List<T> next = <T>[...items];
  next.sort((T a, T b) {
    if (pinFavorites && favorite != null) {
      final bool aPinned = favorite(a);
      final bool bPinned = favorite(b);
      if (aPinned != bPinned) return aPinned ? -1 : 1;
    }
    if (sort == ShowroomFeedSort.popular) {
      return likes(b).compareTo(likes(a));
    }
    return publishedAt(b).compareTo(publishedAt(a));
  });
  return next;
}
