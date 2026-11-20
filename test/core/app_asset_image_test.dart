import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interiorapp_flutter_client/core/widget/app_asset_image.dart';

void main() {
  testWidgets('없는 에셋은 이미지 없음 아이콘으로 남긴다', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppAssetImage(
            'assets/images/missing_for_test.png',
            width: 48,
            height: 48,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
