import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interiorapp_flutter_client/core/editor/quill_simulator_guard.dart';
import 'package:interiorapp_flutter_client/core/editor/rich_text_editor.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/showroom_body.dart';
import 'package:interiorapp_flutter_client/showroom/domain/showroom_quill_document.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_quill_body.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('시뮬레이터 채널이 없어도 에디터 시작 확인이 예외로 끝나지 않는다', () {
    expect(quillReportsIosSimulator(), completion(isFalse));
  });

  ShowroomBlock text(
    String id,
    String value, {
    RichTextAlign align = RichTextAlign.left,
    RichTextSize size = RichTextSize.medium,
    bool bold = false,
    List<RichTextParagraph>? paragraphs,
  }) {
    return ShowroomBlock.text(
      id: id,
      paragraphId: '$id-p',
      text: value,
      align: align,
      size: size,
      bold: bold,
      paragraphs: paragraphs,
    );
  }

  test('글 스타일과 사진 영역이 문서와 블록을 왕복한다', () {
    final List<ShowroomBlock> blocks = <ShowroomBlock>[
      text(
        'post',
        '',
        paragraphs: <RichTextParagraph>[
          RichTextParagraph(
            id: 'a',
            align: RichTextAlign.center,
            runs: const <RichTextRun>[
              RichTextRun(text: '안녕', bold: true, size: RichTextSize.small),
              RichTextRun(text: '하세요', size: RichTextSize.large),
            ],
          ),
          const RichTextParagraph(
            id: 'b',
            runs: <RichTextRun>[RichTextRun(text: '다음 줄')],
          ),
        ],
      ),
      ShowroomBlock.images(
        id: 'slide',
        layout: ShowroomImageLayout.slider,
        urls: const <String>['https://img/1', 'https://img/2'],
      ),
      ShowroomBlock.images(
        id: 'pair',
        layout: ShowroomImageLayout.beforeAfter,
        pairs: const <ShowroomBeforeAfterPair>[
          ShowroomBeforeAfterPair(
            id: 'hall',
            caption: '홀',
            beforeUrl: 'https://img/before',
            afterUrl: 'https://img/after',
          ),
        ],
      ),
      text('tail', '뒤에 이어지는 글'),
    ];

    final List<ShowroomBlock> restored = blocksFromQuillDocument(
      documentFromShowroomBlocks(blocks),
    );

    expect(sameShowroomBody(blocks, restored), isTrue);
    expect(restored[1].id, 'slide');
    expect(restored[2].id, 'pair');
  });

  test('제목 속성은 크기로 읽지 않고 정렬은 줄바꿈에서 읽는다', () {
    final Document document = Document.fromJson(<Map<String, dynamic>>[
      <String, dynamic>{'insert': '첫 줄'},
      <String, dynamic>{
        'insert': '\n',
        'attributes': <String, dynamic>{'header': 1, 'align': 'center'},
      },
      <String, dynamic>{
        'insert': '다음',
        'attributes': <String, dynamic>{'size': 'small'},
      },
      <String, dynamic>{
        'insert': '\n',
        'attributes': <String, dynamic>{'align': 'right'},
      },
    ]);

    final List<RichTextParagraph> paragraphs =
        blocksFromQuillDocument(document).single.paragraphs;

    expect(paragraphs[0].align, RichTextAlign.center);
    expect(paragraphs[0].runs.single.size, RichTextSize.medium);
    expect(paragraphs[0].runs.single.text, '첫 줄');
    expect(paragraphs[1].align, RichTextAlign.right);
    expect(paragraphs[1].runs.single.size, RichTextSize.small);
  });

  test('크기와 정렬을 고르면 델타에서 둘 다 돌아온다', () {
    final QuillController controller = QuillController.basic();
    addTearDown(controller.dispose);
    controller.replaceText(
      0,
      0,
      '안녕하세요',
      const TextSelection.collapsed(offset: 5),
    );
    controller.updateSelection(
      const TextSelection(baseOffset: 0, extentOffset: 5),
      ChangeSource.local,
    );
    controller.formatSelection(Attribute.centerAlignment);
    controller.formatSelection(const SizeAttribute('large'));
    controller.replaceText(
      5,
      0,
      '\n다음',
      const TextSelection.collapsed(offset: 8),
    );

    final List<RichTextParagraph> paragraphs =
        blocksFromQuillDocument(controller.document).single.paragraphs;
    expect(paragraphs[0].align, RichTextAlign.center);
    expect(paragraphs[0].runs.single.size, RichTextSize.large);
    expect(paragraphs[0].runs.single.text, '안녕하세요');
    expect(paragraphs[1].align, RichTextAlign.center);
    expect(paragraphs[1].runs.single.size, RichTextSize.medium);
    expect(paragraphs[1].runs.single.text, '다음');
    expect(
      controller.document.toDelta().toJson().toString(),
      isNot(contains('header')),
    );
  });

  test('제목 속성은 문서에서 빠진다', () {
    final QuillController controller = QuillController(
      document: Document.fromJson(<Map<String, dynamic>>[
        <String, dynamic>{'insert': '첫 줄\n'},
      ]),
      selection: const TextSelection.collapsed(offset: 3),
    );
    addTearDown(controller.dispose);
    controller.formatSelection(Attribute.h1);

    expect(stripShowroomHeadings(controller), isTrue);
    expect(
      controller.document.toDelta().toJson().toString(),
      isNot(contains('header')),
    );
    expect(
      blocksFromQuillDocument(
        controller.document,
      ).single.paragraphs.single.runs.single.size,
      RichTextSize.medium,
    );
  });

  testWidgets('빈 본문의 첫 글은 중간 크기이고 제목 줄도 커지지 않는다', (WidgetTester tester) async {
    final QuillController controller = QuillController(
      document: Document.fromJson(<Map<String, dynamic>>[
        <String, dynamic>{
          'insert': '첫 줄\n',
          'attributes': <String, dynamic>{'header': 1},
        },
      ]),
      selection: const TextSelection.collapsed(offset: 3),
    );
    final FocusNode focus = FocusNode();
    final ScrollController scroll = ScrollController();
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    addTearDown(scroll.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          FlutterQuillLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const <Locale>[Locale('ko')],
        home: Scaffold(
          body: Column(
            children: [
              ShowroomQuillBody(
                controller: controller,
                focusNode: focus,
                scrollController: scroll,
                pickImages: ({bool multiple = false}) async => const <String>[],
              ),
              ShowroomQuillToolbar(
                controller: controller,
                focusNode: focus,
                emojiOpen: false,
                onEmojiToggle: () {},
                onEmoji: (_) {},
                onImage: () {},
                onArea: () {},
                onRecord: () {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(_paintedSize(tester, '첫 줄'), 16);

    controller.replaceText(
      3,
      0,
      '\n다음',
      const TextSelection.collapsed(offset: 6),
    );
    await tester.pump();
    expect(
      controller.document.toDelta().toJson().toString(),
      isNot(contains('size')),
    );
    expect(_paintedSize(tester, '다음'), 16);

    controller.updateSelection(
      const TextSelection.collapsed(offset: 5),
      ChangeSource.local,
    );
    await tester.tap(find.text('가').first);
    await tester.pump();

    expect(_paintedSize(tester, '다음'), 14);
    expect(
      blocksFromQuillDocument(
        controller.document,
      ).single.paragraphs.last.runs.single.size,
      RichTextSize.small,
    );
  });

  testWidgets('가운데 정렬은 미리보기 문단 너비에서 보인다', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            child: RichTextView(
              paragraphs: <RichTextParagraph>[
                RichTextParagraph(
                  id: 'p',
                  align: RichTextAlign.center,
                  runs: <RichTextRun>[RichTextRun(text: '안녕')],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
      find.text('안녕', findRichText: true),
    );
    expect(paragraph.textAlign, TextAlign.center);
    expect(paragraph.size.width, 300);
  });

  test('엔터를 쳐도 앞에 적은 글이 남는다', () {
    final QuillController controller = QuillController(
      document: documentFromShowroomBlocks(<ShowroomBlock>[
        text('post', '안녕하세요'),
      ]),
      selection: const TextSelection.collapsed(offset: 5),
    );
    addTearDown(controller.dispose);

    controller.replaceText(
      5,
      0,
      '\n',
      const TextSelection.collapsed(offset: 6),
    );

    final List<ShowroomBlock> blocks = blocksFromQuillDocument(
      controller.document,
    );
    expect(blocks, hasLength(1));
    expect(blocks.single.text, '안녕하세요\n');
    expect(blocks.single.paragraphs, hasLength(2));
    expect(blocks.single.paragraphs.first.text, '안녕하세요');
    expect(blocks.single.paragraphs.last.text, '');
  });

  test('커서 중간에 영역을 넣으면 글이 영역 앞뒤로 나뉜다', () {
    final QuillController controller = QuillController(
      document: documentFromShowroomBlocks(<ShowroomBlock>[
        text('post', '안녕하세요'),
      ]),
      selection: const TextSelection.collapsed(offset: 2),
    );
    addTearDown(controller.dispose);

    insertShowroomBlock(
      controller,
      ShowroomBlock.images(
        id: 'area',
        layout: ShowroomImageLayout.beforeAfter,
        pairs: const <ShowroomBeforeAfterPair>[
          ShowroomBeforeAfterPair(id: 'pair'),
        ],
      ),
      index: 2,
    );

    final List<ShowroomBlock> blocks = blocksFromQuillDocument(
      controller.document,
    );
    expect(blocks, hasLength(3));
    expect(blocks[0].text, '안녕');
    expect(blocks[1].id, 'area');
    expect(blocks[1].layout, ShowroomImageLayout.beforeAfter);
    expect(blocks[2].text, '하세요');
  });

  testWidgets('본문 에디터는 리스트 안에서 글을 보여주고 탭하면 포커스를 받는다', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final QuillController controller = QuillController(
      document: documentFromShowroomBlocks(<ShowroomBlock>[
        text('post', '안녕하세요'),
        ShowroomBlock.images(
          id: 'pair',
          layout: ShowroomImageLayout.beforeAfter,
          pairs: const <ShowroomBeforeAfterPair>[
            ShowroomBeforeAfterPair(id: 'hall', caption: '홀'),
          ],
        ),
      ]),
      selection: const TextSelection.collapsed(offset: 0),
    );
    final FocusNode focus = FocusNode();
    final ScrollController scroll = ScrollController();
    var picks = 0;
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    addTearDown(scroll.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          FlutterQuillLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const <Locale>[Locale('ko')],
        home: Scaffold(
          body: ListView(
            children: <Widget>[
              ShowroomQuillBody(
                controller: controller,
                focusNode: focus,
                scrollController: scroll,
                pickImages: ({bool multiple = false}) async {
                  picks += 1;
                  return <String>[];
                },
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('안녕하세요', findRichText: true), findsOneWidget);
    expect(find.text('전후'), findsOneWidget);
    expect(find.text('시공 전'), findsOneWidget);
    expect(find.text('시공 후'), findsOneWidget);
    expect(find.text('시공 전 사진'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    await tester.tap(find.text('시공 전 사진'));
    await tester.pump();
    expect(picks, 1);
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('안녕하세요', findRichText: true));
    await tester.pump();
    expect(focus.hasFocus, isTrue);
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('글 영역 빈칸을 눌러도 커서가 생긴다', (WidgetTester tester) async {
    final QuillController controller = QuillController(
      document: documentFromShowroomBlocks(<ShowroomBlock>[
        ShowroomBlock.text(id: 'post', paragraphId: 'p', text: '안녕'),
      ]),
      selection: const TextSelection.collapsed(offset: 0),
    );
    final FocusNode focus = FocusNode();
    final ScrollController scroll = ScrollController();
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    addTearDown(scroll.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          FlutterQuillLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const <Locale>[Locale('ko')],
        home: Scaffold(
          body: ListView(
            children: <Widget>[
              ShowroomQuillBody(
                controller: controller,
                focusNode: focus,
                scrollController: scroll,
                pickImages: ({bool multiple = false}) async => const <String>[],
              ),
            ],
          ),
        ),
      ),
    );

    final Rect box = tester.getRect(find.byType(QuillEditor));
    await tester.tapAt(Offset(box.center.dx, box.bottom - 8));
    await tester.pump();
    expect(focus.hasFocus, isTrue);
  });
}

double? _paintedSize(WidgetTester tester, String text) {
  final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
    find.text(text, findRichText: true),
  );
  double? size = paragraph.text.style?.fontSize;
  void walk(InlineSpan span) {
    if (span.style?.fontSize != null) size = span.style?.fontSize;
    if (span is TextSpan && span.children != null) {
      for (final InlineSpan child in span.children!) {
        walk(child);
      }
    }
  }

  walk(paragraph.text);
  return size;
}
