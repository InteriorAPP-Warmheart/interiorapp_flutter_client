import 'package:flutter_test/flutter_test.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/showroom_body.dart';

void main() {
  var seq = 0;
  String nextId() => 'id${seq++}';

  ShowroomBlock text(String id, String value) {
    return ShowroomBlock.text(id: id, paragraphId: '$id-p', text: value);
  }

  setUp(() => seq = 0);

  test('커서 중간에 영역을 넣으면 글이 영역 앞뒤로 나뉜다', () {
    final ShowroomAreaInsert inserted = insertShowroomArea(
      blocks: <ShowroomBlock>[text('post', '안녕하세요')],
      nextId: nextId,
      blockId: 'post',
      paragraphId: 'post-p',
      caret: 2,
    );
    expect(inserted.blocks, hasLength(3));
    expect(inserted.blocks[0].kind, ShowroomBlockKind.text);
    expect(inserted.blocks[0].text, '안녕');
    expect(inserted.blocks[1].kind, ShowroomBlockKind.images);
    expect(inserted.blocks[2].kind, ShowroomBlockKind.text);
    expect(inserted.blocks[2].text, '하세요');
    expect(inserted.focusId, inserted.blocks[2].id);
  });

  test('글 맨 앞에 넣으면 영역이 글 위에 붙고 글은 그대로다', () {
    final ShowroomAreaInsert inserted = insertShowroomArea(
      blocks: <ShowroomBlock>[text('post', '홀 주방')],
      nextId: nextId,
      blockId: 'post',
      paragraphId: 'post-p',
      caret: 0,
    );
    expect(inserted.blocks, hasLength(2));
    expect(inserted.blocks.first.kind, ShowroomBlockKind.images);
    expect(inserted.blocks.last.text, '홀 주방');
    expect(inserted.focusId, 'post');
  });

  test('커서가 없으면 마지막 글 뒤에 영역을 넣고 이어서 쓸 칸을 연다', () {
    final ShowroomAreaInsert inserted = insertShowroomArea(
      blocks: <ShowroomBlock>[
        text('post', '성수'),
        ShowroomBlock.images(id: 'photos'),
      ],
      nextId: nextId,
    );
    expect(inserted.blocks.map((ShowroomBlock block) => block.kind).toList(), [
      ShowroomBlockKind.text,
      ShowroomBlockKind.images,
      ShowroomBlockKind.text,
      ShowroomBlockKind.images,
    ]);
    expect(inserted.blocks.first.text, '성수');
    expect(inserted.blocks[2].text, isEmpty);
    expect(inserted.focusId, inserted.blocks[2].id);
  });

  test('슬라이더는 고른 사진으로 바로 생긴다', () {
    final ShowroomAreaInsert inserted = insertShowroomArea(
      blocks: <ShowroomBlock>[text('post', '안녕하세요')],
      nextId: nextId,
      blockId: 'post',
      paragraphId: 'post-p',
      caret: 2,
      layout: ShowroomImageLayout.slider,
      imageUrl: 'photo.jpg',
    );
    final ShowroomBlock area = inserted.blocks[1];
    expect(area.layout, ShowroomImageLayout.slider);
    expect(area.urls, <String>['photo.jpg']);
    expect(area.pairs, isEmpty);
  });

  test('여러 장은 고른 배치로 한 위젯에 들어간다', () {
    final ShowroomAreaInsert inserted = insertShowroomArea(
      blocks: <ShowroomBlock>[text('post', '안녕하세요')],
      nextId: nextId,
      blockId: 'post',
      paragraphId: 'post-p',
      caret: 2,
      layout: ShowroomImageLayout.gallery,
      imageUrls: <String>['a.jpg', 'b.jpg', 'c.jpg'],
    );
    final ShowroomBlock area = inserted.blocks[1];
    expect(area.layout, ShowroomImageLayout.gallery);
    expect(area.urls, <String>['a.jpg', 'b.jpg', 'c.jpg']);
  });

  test('전후는 빈 영역을 먼저 둔다', () {
    final ShowroomAreaInsert inserted = insertShowroomArea(
      blocks: <ShowroomBlock>[text('post', '안녕하세요')],
      nextId: nextId,
      blockId: 'post',
      paragraphId: 'post-p',
      caret: 2,
      layout: ShowroomImageLayout.beforeAfter,
    );
    final ShowroomBlock area = inserted.blocks[1];
    expect(area.layout, ShowroomImageLayout.beforeAfter);
    expect(area.urls, isEmpty);
    expect(area.pairs, hasLength(1));
    expect(area.pairs.single.beforeUrl, isEmpty);
    expect(area.pairs.single.afterUrl, isEmpty);
  });
}
