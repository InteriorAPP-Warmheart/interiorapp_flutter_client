import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interiorapp_flutter_client/core/editor/rich_text_editor.dart';

void main() {
  testWidgets('정렬 버튼을 눌러도 쓰던 글이 남는다', (WidgetTester tester) async {
    RichTextController? editor;
    List<RichTextParagraph> paragraphs = <RichTextParagraph>[
      const RichTextParagraph(id: 'p'),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return RichTextFields(
                paragraphs: paragraphs,
                autofocus: true,
                onChanged:
                    (List<RichTextParagraph> next) =>
                        setState(() => paragraphs = next),
                onActive: (RichTextController? controller, FocusNode? node) {
                  editor = controller;
                },
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.enterText(find.byType(TextField), '안녕하세요');
    await tester.pump();
    expect(editor, isNotNull);
    editor!.selection = TextSelection.collapsed(offset: editor!.text.length);
    editor!.applyAlign(RichTextAlign.center);
    await tester.pump();
    expect(editor!.text, '안녕하세요');
    expect(editor!.paragraph.align, RichTextAlign.center);
    expect(find.byType(TextField), findsOneWidget);
    final TextField field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration?.isCollapsed, isTrue);
    expect(field.textAlign, TextAlign.center);
    editor!.applySize(RichTextSize.large);
    editor!.toggleBold();
    await tester.pump();
    expect(editor!.text, '안녕하세요');
  });

  testWidgets('엔터를 쳐도 앞 글이 남고 칸은 하나다', (WidgetTester tester) async {
    List<RichTextParagraph> paragraphs = <RichTextParagraph>[
      const RichTextParagraph(id: 'p'),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return RichTextFields(
                paragraphs: paragraphs,
                onChanged:
                    (List<RichTextParagraph> next) =>
                        setState(() => paragraphs = next),
                onActive: (RichTextController? controller, FocusNode? node) {},
              );
            },
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), '안녕하세요');
    await tester.pump();
    await tester.enterText(find.byType(TextField), '안녕하세요\n다음 줄');
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);
    expect(paragraphs.map((RichTextParagraph item) => item.text), <String>[
      '안녕하세요',
      '다음 줄',
    ]);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      '안녕하세요\n다음 줄',
    );
  });
}
