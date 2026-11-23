import 'package:flutter_test/flutter_test.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/showroom_story_model.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/showroom_body.dart';
import 'package:interiorapp_flutter_client/showroom/presentation/vm/showroom_composer.dart';

void main() {
  ShowroomDraft draft({
    String title = '동탄 사무실',
    String budget = '20,000,000원',
    List<ShowroomBlock> blocks = const <ShowroomBlock>[],
  }) {
    return ShowroomDraft(
      seeded: true,
      title: title,
      thumbnailUrl: 'cover.webp',
      style: '깔끔하고 실용적인',
      industry: '사무실',
      areaPyeong: 22,
      area: '22평',
      budget: budget,
      period: '2주',
      showCostDetail: true,
      costTotal: '20,000,000원',
      costLines: const <ShowroomCostLine>[
        ShowroomCostLine(name: '자재비', amount: '19,000,000원'),
        ShowroomCostLine(name: '인력비', amount: ''),
        ShowroomCostLine(name: '경비', amount: '1,000,000원'),
      ],
      blocks:
          blocks.isEmpty
              ? <ShowroomBlock>[
                ShowroomBlock.text(id: 'open', text: '처음 본문'),
              ]
              : blocks,
    );
  }

  test('금액 표기만 달라도 같은 글이다', () {
    final ShowroomDraft opened = draft();
    final ShowroomDraft typed = draft(budget: '20000000원');
    expect(opened.sameEditableContent(typed), isTrue);
  });

  test('본문을 넣었다 지우면 차이가 아니다', () {
    final ShowroomDraft opened = draft();
    final ShowroomDraft restored = draft(
      blocks: <ShowroomBlock>[
        ShowroomBlock.text(id: 'open', text: '처음 본문'),
        ShowroomBlock.text(id: 'added', text: '   '),
      ],
    );
    expect(opened.sameEditableContent(restored), isTrue);
  });

  test('제목이나 금액이 달라지면 수정이다', () {
    final ShowroomDraft opened = draft();
    expect(opened.sameEditableContent(draft(title: '다른 제목')), isFalse);
    expect(
      opened.sameEditableContent(
        draft().copyWith(
          costLines: const <ShowroomCostLine>[
            ShowroomCostLine(name: '자재비', amount: '18,000,000원'),
            ShowroomCostLine(name: '경비', amount: '1,000,000원'),
          ],
        ),
      ),
      isFalse,
    );
  });
}
