class SearchSuggestionModel {
  const SearchSuggestionModel({
    required this.keyword,
    required this.type,
    this.isTrending = false,
  });

  final String keyword;
  final SearchSuggestionType type;
  final bool isTrending;

  // JSON 변환 메서드
  Map<String, dynamic> toJson() {
    return {
      'keyword': keyword,
      'type': type.name,
      'isTrending': isTrending,
    };
  }

  factory SearchSuggestionModel.fromJson(Map<String, dynamic> json) {
    return SearchSuggestionModel(
      keyword: json['keyword'] as String,
      type: SearchSuggestionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SearchSuggestionType.related,
      ),
      isTrending: json['isTrending'] as bool? ?? false,
    );
  }

  @override
  String toString() => 'SearchSuggestionModel(keyword: $keyword, type: $type, isTrending: $isTrending)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchSuggestionModel &&
        other.keyword == keyword &&
        other.type == type &&
        other.isTrending == isTrending;
  }

  @override
  int get hashCode => Object.hash(keyword, type, isTrending);
}

enum SearchSuggestionType {
  related, // 연관 검색어
  trending, // 추천 검색어
}
