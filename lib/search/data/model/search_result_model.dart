class SearchResultModel {
  const SearchResultModel({
    this.imageUrls,
    required this.title,
    required this.contentSnippet,
    required this.publisherNickname,
    this.publisherAvatarUrl,
  });

  final List<String>? imageUrls;
  final String? title;
  final String? contentSnippet;
  final String? publisherNickname;
  final String? publisherAvatarUrl;

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      imageUrls: json['imageUrls'] as List<String>?,
      title: json['title'] as String?,
      contentSnippet: json['contentSnippet'] as String?,
      publisherNickname: json['publisherNickname'] as String?,
      publisherAvatarUrl: json['publisherAvatarUrl'] as String?,
    );
  }



  static List<SearchResultModel> listFromJson(List<dynamic> data) {
    return data
        .whereType<Map<String, dynamic>>()
        .map((e) => SearchResultModel.fromJson(e))
        .toList(growable: false);
  }

  @override
  String toString() => 'SearchResultModel(imageUrls: $imageUrls, title: $title, contentSnippet: $contentSnippet, publisherNickname: $publisherNickname, publisherAvatarUrl: $publisherAvatarUrl)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchResultModel &&
        other.imageUrls == imageUrls &&
        other.title == title &&
        other.contentSnippet == contentSnippet &&
        other.publisherNickname == publisherNickname &&
        other.publisherAvatarUrl == publisherAvatarUrl;
  }

  @override
  int get hashCode => imageUrls.hashCode ^ title.hashCode ^ contentSnippet.hashCode ^ publisherNickname.hashCode ^ publisherAvatarUrl.hashCode; 
}
