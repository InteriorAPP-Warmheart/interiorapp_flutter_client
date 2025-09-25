class RecentSearchKeyword {
  final String keyword;
  final DateTime searchedAt;
  final int searchCount;

  const RecentSearchKeyword({
    required this.keyword,
    required this.searchedAt,
    this.searchCount = 1,
  });

  /// SharedPreferences 저장용 JSON 변환
  Map<String, dynamic> toJson() => {
        'keyword': keyword,
        'searchedAt': searchedAt.millisecondsSinceEpoch,
        'searchCount': searchCount,
      };

  /// SharedPreferences에서 로드용 JSON 파싱
  factory RecentSearchKeyword.fromJson(Map<String, dynamic> json) {
    return RecentSearchKeyword(
      keyword: json['keyword'] as String? ?? '',
      searchedAt: DateTime.fromMillisecondsSinceEpoch(
        json['searchedAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      searchCount: json['searchCount'] as int? ?? 1,
    );
  }

  /// 검색 횟수 증가
  RecentSearchKeyword incrementSearchCount() {
    return RecentSearchKeyword(
      keyword: keyword,
      searchedAt: searchedAt,
      searchCount: searchCount + 1,
    );
  }

  /// 검색 시간 업데이트
  RecentSearchKeyword updateSearchTime() {
    return RecentSearchKeyword(
      keyword: keyword,
      searchedAt: DateTime.now(),
      searchCount: searchCount,
    );
  }

  /// 리스트 JSON 변환
  static List<Map<String, dynamic>> listToJson(List<RecentSearchKeyword> keywords) {
    return keywords.map((keyword) => keyword.toJson()).toList();
  }

  /// 리스트 JSON 파싱
  static List<RecentSearchKeyword> listFromJson(List<dynamic> data) {
    return data
        .where((e) => e is Map<String, dynamic>)
        .map<RecentSearchKeyword>((e) => RecentSearchKeyword.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  String toString() => 'RecentSearchKeyword(keyword: $keyword, searchedAt: $searchedAt, searchCount: $searchCount)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecentSearchKeyword &&
        other.keyword == keyword &&
        other.searchedAt == searchedAt &&
        other.searchCount == searchCount;
  }

  @override
  int get hashCode => Object.hash(keyword, searchedAt, searchCount);
}
