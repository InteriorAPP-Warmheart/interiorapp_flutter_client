/// 좋아요와 댓글이 무게를 가지고, 조회수가 순서를 밀어 올린다.
int showroomPopularity({
  required int likes,
  required int comments,
  required int views,
}) {
  return likes * 10 + comments * 8 + views ~/ 20;
}
