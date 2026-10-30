import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interiorapp_flutter_client/core/widget/app_network_image.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/showroom_story_model.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/showroom_body.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/showroom_wipe_compare.dart';
import 'package:interiorapp_flutter_client/showroom/ui/widget/write_body_editor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('갤러리에서 작은 사진을 누르면 큰 영역이 그 사진으로 바뀐다', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShowroomBodyView(
            blocks: <ShowroomBlock>[
              ShowroomBlock.images(
                id: 'gallery',
                layout: ShowroomImageLayout.gallery,
                urls: <String>['https://img/a', 'https://img/b'],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey<String>('https://img/a')), findsOneWidget);

    await tester.tap(find.byType(InkWell).at(1));
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('https://img/b')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('https://img/a')), findsNothing);
  });

  testWidgets('완성된 전후는 한 칸에서 스위치로 바뀐다', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShowroomBodyView(
            blocks: <ShowroomBlock>[
              ShowroomBlock.images(
                id: 'pair',
                layout: ShowroomImageLayout.beforeAfter,
                pairs: <ShowroomBeforeAfterPair>[
                  ShowroomBeforeAfterPair(
                    id: 'hall',
                    caption: '홀',
                    beforeUrl: 'https://img/before',
                    afterUrl: 'https://img/after',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('홀'), findsOneWidget);
    expect(find.text('시공 전'), findsWidgets);
    expect(find.byType(ShowroomBeforeAfterToggle), findsOneWidget);

    await tester.tap(find.text('시공 후'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('시공 후'), findsWidgets);
  });

  testWidgets('전후가 여러 구역이면 한 칸에서 고른다', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShowroomBodyView(
            blocks: <ShowroomBlock>[
              ShowroomBlock.images(
                id: 'hall',
                layout: ShowroomImageLayout.beforeAfter,
                pairs: <ShowroomBeforeAfterPair>[
                  ShowroomBeforeAfterPair(
                    id: 'hall',
                    caption: '홀',
                    beforeUrl: 'https://img/hall-before',
                    afterUrl: 'https://img/hall-after',
                  ),
                ],
              ),
              ShowroomBlock.images(
                id: 'kitchen',
                layout: ShowroomImageLayout.beforeAfter,
                pairs: <ShowroomBeforeAfterPair>[
                  ShowroomBeforeAfterPair(
                    id: 'kitchen',
                    caption: '주방',
                    beforeUrl: 'https://img/kitchen-before',
                    afterUrl: 'https://img/kitchen-after',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(ShowroomBeforeAfterToggle), findsOneWidget);
    expect(find.text('홀'), findsOneWidget);
    expect(find.text('주방'), findsOneWidget);

    await tester.tap(find.text('주방'));
    await tester.pump();

    expect(find.byType(ShowroomBeforeAfterToggle), findsOneWidget);
    expect(find.text('주방'), findsOneWidget);
  });

  testWidgets('현장 기록은 글 사이에 순서대로 나온다', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShowroomBodyView(
            blocks: <ShowroomBlock>[
              ShowroomBlock.text(id: 'before', text: '공사를 시작했습니다'),
              ShowroomBlock.process(
                id: 'record',
                frames: const <ShowroomProcessFrame>[
                  ShowroomProcessFrame(
                    id: 'demo',
                    trade: '철거',
                    imageUrl: 'https://img/demo',
                    caption: '벽을 비웠습니다',
                  ),
                  ShowroomProcessFrame(
                    id: 'finish',
                    trade: '마감',
                    imageUrl: 'https://img/finish',
                    caption: '조명을 달았습니다',
                  ),
                ],
              ),
              ShowroomBlock.text(id: 'after', text: '마감 후 공간입니다'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('공사를 시작했습니다'), findsOneWidget);
    expect(find.text('철거'), findsOneWidget);
    expect(find.text('01'), findsOneWidget);
    expect(find.text('마감'), findsOneWidget);
    expect(find.text('02'), findsOneWidget);
    expect(find.text('벽을 비웠습니다'), findsOneWidget);
    expect(find.text('마감 후 공간입니다'), findsOneWidget);
  });

  testWidgets('슬라이더와 갤러리 작은 사진은 글과 같은 여백에서 시작한다', (WidgetTester tester) async {
    const double screen = 390;
    tester.view.physicalSize = const Size(screen, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ShowroomBodyView(
              blocks: <ShowroomBlock>[
                ShowroomBlock.text(id: 't', text: '본문 문장입니다'),
                ShowroomBlock.images(
                  id: 's',
                  layout: ShowroomImageLayout.slider,
                  urls: const <String>['https://img/a', 'https://img/b'],
                ),
                ShowroomBlock.images(
                  id: 'g',
                  layout: ShowroomImageLayout.gallery,
                  urls: const <String>['https://img/c', 'https://img/d'],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final double textLeft = tester.getRect(find.text('본문 문장입니다')).left;
    final List<Element> images =
        find.byType(AppNetworkImage).evaluate().toList();
    Rect at(String url, int occurrence) {
      var seen = 0;
      for (final Element element in images) {
        final AppNetworkImage image = element.widget as AppNetworkImage;
        if (image.url != url) continue;
        if (seen == occurrence) return tester.getRect(find.byWidget(image));
        seen++;
      }
      fail('missing $url');
    }

    final Rect firstSlide = at('https://img/a', 0);
    final Rect nextSlide = at('https://img/b', 0);
    final Rect hero = at('https://img/c', 0);
    final Rect thumb = at('https://img/c', 1);

    expect(firstSlide.left, textLeft);
    expect(nextSlide.left, screen - textLeft);
    expect(hero.left, textLeft);
    expect(hero.right, screen - textLeft);
    expect(thumb.left, greaterThanOrEqualTo(textLeft));
    expect(thumb.left, lessThan(textLeft + 8));
  });

  testWidgets('사진 한 장은 글과 같은 여백에 한 장으로 붙는다', (WidgetTester tester) async {
    const double screen = 390;
    tester.view.physicalSize = const Size(screen, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShowroomBodyView(
            blocks: <ShowroomBlock>[
              ShowroomBlock.text(id: 't', text: '본문 문장입니다'),
              ShowroomBlock.images(
                id: 'one',
                layout: ShowroomImageLayout.photo,
                urls: const <String>['https://img/one'],
              ),
            ],
          ),
        ),
      ),
    );

    final double textLeft = tester.getRect(find.text('본문 문장입니다')).left;
    final Rect photo = tester.getRect(find.byType(AppNetworkImage));
    expect(photo.left, textLeft);
    expect(photo.right, screen - textLeft);
  });
}
