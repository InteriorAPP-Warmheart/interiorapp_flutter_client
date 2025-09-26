class ShowroomEntity {
  final String id;
  final String title;
  final String authorId;
  final String authorName;
  final String mainImageUrl;
  final List<String> imageUrls;
  final String description;
  final String showroomStyle;
  final int likeCount;
  final bool isBookmarked;
  final DateTime createdAt;

  const ShowroomEntity({
    required this.id,
    required this.title,
    required this.authorId,
    required this.authorName,
    required this.mainImageUrl,
    required this.imageUrls,
    required this.description,
    required this.showroomStyle,
    required this.likeCount,
    required this.isBookmarked,
    required this.createdAt,
  });
}