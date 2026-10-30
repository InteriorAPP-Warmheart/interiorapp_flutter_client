import 'package:flutter_test/flutter_test.dart';
import 'package:interiorapp_flutter_client/core/editor/rich_text_document.dart';

RichTextParagraph _paragraph(String text) {
  return RichTextParagraph(
    id: 'p',
    runs: <RichTextRun>[RichTextRun(text: text)],
  );
}

void main() {
  test('새 글자만 방금 고른 스타일을 받는다', () {
    final List<RichTextParagraph> next = applyTextEdit(
      paragraph: _paragraph('안녕'),
      before: '안녕',
      after: '안녕요',
      typingSize: RichTextSize.large,
      typingBold: true,
      nextId: () => 'n',
    );
    expect(next, hasLength(1));
    expect(next.single.runs, hasLength(2));
    expect(next.single.runs.first.text, '안녕');
    expect(next.single.runs.first.bold, isFalse);
    expect(next.single.runs.last.text, '요');
    expect(next.single.runs.last.bold, isTrue);
    expect(next.single.runs.last.size, RichTextSize.large);
  });

  test('선택한 구간만 굵기가 바뀐다', () {
    final RichTextParagraph next = applyInlineStyle(
      paragraph: _paragraph('안녕하세요'),
      start: 2,
      end: 4,
      bold: true,
    );
    expect(next.text, '안녕하세요');
    expect(next.runs.first.text, '안녕');
    expect(next.runs.first.bold, isFalse);
    expect(next.runs[1].text, '하세');
    expect(next.runs[1].bold, isTrue);
    expect(next.runs.last.bold, isFalse);
  });

  test('문단 끝이 아니면 뒤쪽만 정렬이 바뀐다', () {
    final RichTextAlignEdit edit = applyParagraphAlign(
      paragraph: _paragraph('안녕하세요'),
      start: 2,
      end: 2,
      align: RichTextAlign.center,
      nextId: () => 'head',
    );
    expect(edit.paragraphs, hasLength(2));
    expect(edit.paragraphs.first.text, '안녕');
    expect(edit.paragraphs.first.align, RichTextAlign.left);
    expect(edit.paragraphs.last.id, 'p');
    expect(edit.paragraphs.last.text, '하세요');
    expect(edit.paragraphs.last.align, RichTextAlign.center);
    expect(edit.focusId, 'p');
    expect(edit.caret, 0);
  });

  test('글 중간에서 나누면 앞뒤 글자가 둘 다 남는다', () {
    final RichTextParagraph paragraph = RichTextParagraph(
      id: 'p',
      runs: <RichTextRun>[
        RichTextRun(text: '안녕'),
        RichTextRun(text: '하세요', bold: true),
      ],
    );
    final ({List<RichTextParagraph> head, List<RichTextParagraph> tail}) cut =
        splitRichParagraphs(
          paragraphs: <RichTextParagraph>[paragraph],
          paragraphId: 'p',
          caret: 2,
          nextId: () => 'tail',
        );
    expect(cut.head.single.text, '안녕');
    expect(cut.head.single.runs.single.bold, isFalse);
    expect(cut.tail.single.text, '하세요');
    expect(cut.tail.single.runs.single.bold, isTrue);
    expect('${cut.head.single.text}${cut.tail.single.text}', paragraph.text);
  });

  test('줄 끝에서 정렬을 바꿔도 글자는 남고 줄은 갈라지지 않는다', () {
    final List<RichTextParagraph> source = <RichTextParagraph>[
      RichTextParagraph(id: 'a', runs: <RichTextRun>[RichTextRun(text: '안녕')]),
      RichTextParagraph(id: 'b', runs: <RichTextRun>[RichTextRun(text: '하세요')]),
    ];
    final String before = plainTextOf(source);
    final List<RichTextParagraph> next = setLineAlign(
      paragraphs: source,
      start: before.length,
      end: before.length,
      align: RichTextAlign.center,
    );
    expect(plainTextOf(next), '안녕\n하세요');
    expect(next, hasLength(2));
    expect(next.first.align, RichTextAlign.left);
    expect(next.first.text, '안녕');
    expect(next.last.id, 'b');
    expect(next.last.align, RichTextAlign.center);
    expect(next.last.text, '하세요');
  });

  test('커서가 있는 줄만 정렬이 바뀐다', () {
    final List<RichTextParagraph> source = <RichTextParagraph>[
      _paragraph('홀'),
      RichTextParagraph(
        id: 'kitchen',
        runs: <RichTextRun>[RichTextRun(text: '주방')],
      ),
    ];
    final List<RichTextParagraph> next = setLineAlign(
      paragraphs: source,
      start: 0,
      end: 0,
      align: RichTextAlign.right,
    );
    expect(plainTextOf(next), plainTextOf(source));
    expect(next.first.align, RichTextAlign.right);
    expect(next.last.align, RichTextAlign.left);
  });

  test('문단 전체를 고르면 정렬만 바뀌고 나뉘지 않는다', () {
    final RichTextParagraph paragraph = _paragraph('홀');
    final RichTextAlignEdit edit = applyParagraphAlign(
      paragraph: paragraph,
      start: 0,
      end: paragraph.text.length,
      align: RichTextAlign.right,
      nextId: () => 'unused',
    );
    expect(edit.paragraphs, hasLength(1));
    expect(edit.paragraphs.single.text, '홀');
    expect(edit.paragraphs.single.align, RichTextAlign.right);
  });

  test('엔터를 쳐도 앞 글이 남고 빈 줄만 생긴다', () {
    final List<RichTextParagraph> next = applyDocumentEdit(
      paragraphs: <RichTextParagraph>[_paragraph('안녕하세요')],
      before: '안녕하세요',
      after: '안녕하세요\n',
      typingSize: RichTextSize.medium,
      typingBold: false,
      nextId: () => 'n',
    );
    expect(plainTextOf(next), '안녕하세요\n');
    expect(next.first.id, 'p');
    expect(next.first.text, '안녕하세요');
    expect(next.last.id, 'n');
    expect(next.last.text, isEmpty);
  });
}
