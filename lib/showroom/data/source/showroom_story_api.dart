import 'package:interiorapp_flutter_client/core/editor/rich_text_document.dart';
import 'package:interiorapp_flutter_client/showroom/data/model/showroom_story_model.dart';
import 'package:interiorapp_flutter_client/showroom/domain/entity/showroom_body.dart';

/// 서버 연동 전까지 쇼룸 한 편의 이야기를 돌려주는 목 API.
class ShowroomStoryApi {
  static final Map<String, ShowroomStoryModel>
  _stories = <String, ShowroomStoryModel>{
    'showroom-warmheart': ShowroomStoryModel(
      id: 'showroom-warmheart',
      title: '동탄 웜하트사무실',
      themeName: '깔끔하고 실용적인',
      thumbnailUrl: '$_warmheart/wh_01.webp',
      userName: '웜하트',
      authorUserId: 'user-001',
      userProfileUrl: 'https://i.pravatar.cc/100?img=12',
      likeCount: 32,
      favoriteStatus: false,
      situation: ShowroomSituation(
        industry: '전문직 사무실',
        area: '22평',
        budget: '2,000만원',
        period: '2주',
      ),
      cost: ShowroomCost(
        total: '2,000만원',
        lines: <ShowroomCostLine>[
          ShowroomCostLine(name: '자재비', amount: '1,900만원'),
          ShowroomCostLine(name: '인건비', amount: '0원'),
          ShowroomCostLine(name: '경비', amount: '100만원'),
        ],
      ),
      blocks: _warmheartBody(),
    ),
    'showroom-ddonga': ShowroomStoryModel(
      id: 'showroom-ddonga',
      title: '남한강 뚱아농장',
      themeName: '따뜻하고 자연스러운',
      thumbnailUrl: '$_ddonga/ddonga_main05.webp',
      userName: '뚱아농장',
      userProfileUrl: 'https://i.pravatar.cc/100?img=32',
      likeCount: 48,
      favoriteStatus: false,
      situation: ShowroomSituation(
        industry: '카페',
        area: '70평',
        budget: '1억 4,000만원',
        period: '7개월',
      ),
      comparisons: <ShowroomBeforeAfter>[
        ShowroomBeforeAfter(
          zone: '외관',
          beforeUrl: '$_ddonga/ddonga_front_b.webp',
          afterUrl: '$_ddonga/ddonga_front_a.webp',
          caption: '외관',
        ),
        ShowroomBeforeAfter(
          zone: '2층 계단',
          beforeUrl: '$_ddonga/ddonga_2f_b.webp',
          afterUrl: '$_ddonga/ddonga_2f_a.webp',
          caption: '2층 계단',
        ),
      ],
      cost: ShowroomCost(
        total: '1억 4,000만원',
        lines: <ShowroomCostLine>[
          ShowroomCostLine(name: '자재비', amount: '7,000만원'),
          ShowroomCostLine(name: '인건비', amount: '5,000만원'),
          ShowroomCostLine(name: '경비', amount: '2,000만원'),
        ],
      ),
      blocks: _ddongaBody(),
    ),
    'showroom1': ShowroomStoryModel(
      id: 'showroom1',
      title: '동탄 횟집',
      themeName: '모던 라이트',
      thumbnailUrl: 'assets/images/showroom/01.jpg',
      userName: '신짱구',
      userProfileUrl: 'https://i.pravatar.cc/100?img=1',
      likeCount: 128,
      favoriteStatus: false,
      situation: ShowroomSituation(
        industry: '횟집',
        area: '32평',
        budget: '8,400만원',
        period: '6주',
      ),
      cost: ShowroomCost(
        total: '8,400만원',
        lines: <ShowroomCostLine>[
          ShowroomCostLine(name: '자재비', amount: '4,800만원'),
          ShowroomCostLine(name: '인력비', amount: '2,800만원'),
          ShowroomCostLine(name: '경비', amount: '800만원'),
        ],
      ),
      blocks: _legacyBody(
        id: 'sashimi',
        open:
            '안녕하세요! 동탄에서 횟집을 하고 있어요.\n\n'
            '홀이랑 주방, 입구를 한 번에 손봤는데, 사진으로 전후가 제일 잘 보여서 그 순서로 올려 볼게요.',
        pairs: <_LegacyPair>[
          _LegacyPair(
            'hall',
            '홀',
            'assets/images/showroom/16.jpg',
            'assets/images/showroom/01.jpg',
            '홀은 수조를 가운데 두고 객석을 둘렀어요. 자리가 좁아 보여도 수조랑 손님 사이는 두 사람이 스칠 폭을 남겼습니다.',
          ),
          _LegacyPair(
            'kitchen',
            '주방',
            'assets/images/showroom/17.jpg',
            'assets/images/showroom/06.jpg',
            '주방은 작업대랑 선어 진열을 같이 봤어요. 조명은 색이 탁해지지 않게 4000K 아래로 맞췄습니다.',
          ),
          _LegacyPair(
            'front',
            '입구',
            'assets/images/showroom/15.jpg',
            'assets/images/showroom/05.jpg',
            '입구는 간판이 먼저 보이게 정리했어요. 배수랑 환기는 마감보다 먼저 잡아 둔 곳입니다.',
          ),
        ],
        close: '긴 글 읽어 주셔서 감사합니다!',
      ),
    ),
    'showroom2': ShowroomStoryModel(
      id: 'showroom2',
      title: '봉담 성심당',
      themeName: '내추럴 우드',
      thumbnailUrl: 'assets/images/showroom/02.jpg',
      userName: '봉미선',
      userProfileUrl: 'https://i.pravatar.cc/100?img=2',
      likeCount: 1239,
      favoriteStatus: true,
      situation: ShowroomSituation(
        industry: '베이커리',
        area: '18평',
        budget: '5,200만원',
        period: '4주',
      ),
      cost: ShowroomCost(
        total: '5,200만원',
        lines: <ShowroomCostLine>[
          ShowroomCostLine(name: '자재비', amount: '2,900만원'),
          ShowroomCostLine(name: '인력비', amount: '1,800만원'),
          ShowroomCostLine(name: '경비', amount: '500만원'),
        ],
      ),
      blocks: _legacyBody(
        id: 'bakery',
        open:
            '안녕하세요! 봉담에서 빵집을 운영하고 있어요.\n\n'
            '계산대에서 보이는 진열대가 제일 많이 바뀌어서, 그 전후부터 보여 드릴게요.',
        pairs: <_LegacyPair>[
          _LegacyPair(
            'counter',
            '진열대',
            'assets/images/showroom/05.jpg',
            'assets/images/showroom/02.jpg',
            '진열대 높이는 손님 시선에 맞췄고, 조명은 빵이 노랗게 뜨지 않는 쪽으로 골랐어요. 오븐 열은 홀로 새지 않게 벽을 막았습니다.',
          ),
        ],
        photos: <(String, String)>[('pack', 'assets/images/showroom/08.jpg')],
        photoLead: '계산이랑 포장대는 따로 뒀어요. 줄이 겹치지 않아서 훨씬 편합니다.',
        close: '다음에 또 손볼 일이 있으면 이 동선 그대로 가고 싶어요!',
      ),
    ),
    'showroom3': ShowroomStoryModel(
      id: 'showroom3',
      title: '인천 야간공격센터',
      themeName: '미니멀 화이트',
      thumbnailUrl: 'assets/images/showroom/03.jpg',
      userName: '신형만',
      userProfileUrl: 'https://i.pravatar.cc/100?img=3',
      likeCount: 342,
      favoriteStatus: true,
      situation: ShowroomSituation(
        industry: '엔터테인먼트',
        area: '45평',
        budget: '1억 2,000만원',
        period: '8주',
      ),
      cost: ShowroomCost(
        total: '1억 2,000만원',
        lines: <ShowroomCostLine>[
          ShowroomCostLine(name: '자재비', amount: '6,600만원'),
          ShowroomCostLine(name: '인력비', amount: '4,200만원'),
          ShowroomCostLine(name: '경비', amount: '1,200만원'),
        ],
      ),
      blocks: _legacyBody(
        id: 'arcade',
        open:
            '안녕하세요! 인천에서 야간에 운영하는 공간입니다.\n\n'
            '좌석 열이 어떻게 바뀌었는지가 핵심이라, 전후 사진으로 먼저 보여 드릴게요.',
        pairs: <_LegacyPair>[
          _LegacyPair(
            'seats',
            '좌석',
            'assets/images/showroom/15.jpg',
            'assets/images/showroom/03.jpg',
            '좌석 간격은 먼저 긋고, 의자를 빼도 한 사람이 지나갈 폭을 남겼어요. 통로 쪽은 소리가 새지 않게 벽을 보강했습니다.',
          ),
        ],
        photos: <(String, String)>[('light', 'assets/images/showroom/04.jpg')],
        photoLead: '야간 조명은 화면 밖으로만 뒀어요. 화면이랑 실내 불을 같이 보니 눈이 덜 피곤합니다.',
        close: '밤 장사라 조명만 잘 맞아도 공간 인상이 확 달라지더라고요.',
      ),
    ),
    'showroom4': ShowroomStoryModel(
      id: 'showroom4',
      title: '차돈이 동탄역점',
      themeName: '미니멀 화이트',
      thumbnailUrl: 'assets/images/showroom/04.jpg',
      userName: '흰둥이',
      userProfileUrl: 'https://i.pravatar.cc/100?img=4',
      likeCount: 477,
      favoriteStatus: false,
      situation: ShowroomSituation(
        industry: '고깃집',
        area: '28평',
        budget: '7,600만원',
        period: '5주',
      ),
      cost: ShowroomCost(
        total: '7,600만원',
        lines: <ShowroomCostLine>[
          ShowroomCostLine(name: '자재비', amount: '4,200만원'),
          ShowroomCostLine(name: '인력비', amount: '2,600만원'),
          ShowroomCostLine(name: '경비', amount: '800만원'),
        ],
      ),
      blocks: _legacyBody(
        id: 'grill',
        open:
            '안녕하세요! 동탄역 쪽에서 고깃집을 하고 있어요.\n\n'
            '테이블이랑 후드가 어떻게 정리됐는지, 전후부터 보시면 감이 오실 거예요.',
        pairs: <_LegacyPair>[
          _LegacyPair(
            'hall',
            '홀',
            'assets/images/showroom/09.jpg',
            'assets/images/showroom/04.jpg',
            '후드는 불판 중심에 맞추고, 자리보다 흡입을 먼저 봤어요. 테이블 사이는 의자를 뺀 뒤의 통로로 계산했습니다.',
          ),
        ],
        photos: <(String, String)>[('floor', 'assets/images/showroom/07.jpg')],
        photoLead: '바닥은 기름이 남아도 괜찮은 마감으로 골랐어요.',
        close: '연기만 잘 빠져도 홀이 훨씬 편하게 유지됩니다.',
      ),
    ),
  };

  Future<ShowroomStoryModel?> getStory(String id) async {
    return _stories[id];
  }

  Future<void> saveStory(ShowroomStoryModel story) async {
    if (story.id.isEmpty) return;
    _stories[story.id] = story;
  }
}

const String _ddonga = 'assets/images/showroom_real/ddonga';
const String _warmheart = 'assets/images/showroom_real/wh';
const String _gamsa = showroomEmoticonGamsa;

List<ShowroomBlock> _ddongaBody() {
  ShowroomBlock text(String id, String body) {
    return ShowroomBlock.text(id: id, paragraphId: '$id-p', text: body);
  }

  ShowroomBlock photo(String id, String fileName) {
    return ShowroomBlock.images(
      id: id,
      layout: ShowroomImageLayout.photo,
      urls: <String>['$_ddonga/$fileName'],
    );
  }

  ShowroomBlock beforeAfter(
    String id,
    String before,
    String after,
    String caption,
  ) {
    return ShowroomBlock.images(
      id: id,
      layout: ShowroomImageLayout.beforeAfter,
      pairs: <ShowroomBeforeAfterPair>[
        ShowroomBeforeAfterPair(
          id: '$id-pair',
          beforeUrl: '$_ddonga/$before',
          afterUrl: '$_ddonga/$after',
          caption: caption,
        ),
      ],
    );
  }

  return <ShowroomBlock>[
    text(
      'ddonga-open',
      '안녕하세요! 처음 쓰는 글이라 두서가 없어도 이해 부탁드립니다.\n\n'
          '경기도 광주시 남종면 산수로 2521에 있는 공간입니다. '
          '원래 가정집으로 쓰던 곳인데, 운영하던 딸기농장과 함께 카페로 바꾸는 공사를 했어요!\n\n'
          '여러 업체를 알아본 뒤, 가격과 품질이 가장 맞다고 생각해 웜하트인테리어와 진행했습니다. '
          '인테리어가 처음이라 걱정이 많았는데, 비용이나 필요한 부분도 대표님께서 이해하기 쉽게 설명해주시고 '
          '진행을 꼼꼼히 챙겨 주셨어요.\n\n'
          '일단 사진부터 보시죠!',
    ),
    beforeAfter(
      'ddonga-front',
      'ddonga_front_b.webp',
      'ddonga_front_a.webp',
      '외관',
    ),
    text(
      'ddonga-hall',
      '여기가 저희 카페 공간이에요.\n'
          '처음에는 많이 낡아 있었지만, 외부에 타일을 다시 붙여서 분위기가 화사해졌습니다~\n\n'
          '메인 홀은 이 사진이에요!',
    ),
    photo('ddonga-main', 'ddonga_main06.webp'),
    text(
      'ddonga-kitchen-lead',
      '조명색과 벽색이 따뜻하지 않나요?\n'
          '공간이 정돈되니 분위기가 살아나서 너무 마음에 들어요~\n\n'
          '다음은 주방입니다! 카페이다 보니 주방을 특히 중요하게 봤어요.',
    ),
    ShowroomBlock.images(
      id: 'ddonga-kitchen',
      layout: ShowroomImageLayout.gallery,
      urls: <String>[
        '$_ddonga/ddonga_main01.webp',
        '$_ddonga/ddonga_main02.webp',
        '$_ddonga/ddonga_main03.webp',
        '$_ddonga/ddonga_main04.webp',
      ],
    ),
    text(
      'ddonga-stair-lead',
      '주방이 깔끔하지 않나요?\n'
          '감성도 살고, 정면 창으로는 테이크아웃도 할 예정이에요!\n\n'
          '1층은 카페로 쓰고, 2층은 주거 공간으로 남겨 두었습니다. '
          '외부인이 올라가면 안 되는 곳이라 계단과 도어까지 신경 써서 시공했어요~',
    ),
    beforeAfter(
      'ddonga-stair',
      'ddonga_2f_b.webp',
      'ddonga_2f_a.webp',
      '2층 계단',
    ),
    text(
      'ddonga-stair-top',
      '깔끔하게 마무리되지 않았나요?\n'
          '집으로 올라가는 느낌도 따뜻해서 정말 만족스럽습니다!\n\n'
          '이 사진은 계단 위에서 바라본 모습이에요~',
    ),
    photo('ddonga-upstairs', 'ddonga_2f.webp'),
    text(
      'ddonga-thanks',
      '웜하트 작업자분들께서 꼼꼼하게 신경 써 주신 덕분에 만족스러운 공사가 되었어요.\n'
          '다음에 인테리어할 일이 생겨도 다시 맡기고 싶습니다!',
    ),
    photo('ddonga-crew', 'ddonga_01.webp'),
    text('ddonga-close-lead', '마지막으로, 가장 마음에 드는 시골 카페 사진으로 마무리합니다~'),
    photo('ddonga-close', 'ddonga_main05.webp'),
    text('ddonga-end', '긴 글 읽어 주셔서 감사합니다!'),
  ];
}

List<ShowroomBlock> _warmheartBody() {
  RichTextParagraph line(
    String id,
    String text, {
    RichTextAlign align = RichTextAlign.left,
    RichTextSize size = RichTextSize.medium,
    bool bold = false,
  }) {
    return RichTextParagraph(
      id: id,
      align: align,
      runs: <RichTextRun>[RichTextRun(text: text, size: size, bold: bold)],
    );
  }

  ShowroomBlock prose(String id, List<RichTextParagraph> paragraphs) {
    return ShowroomBlock.text(id: id, paragraphs: paragraphs);
  }

  ShowroomBlock photo(String id, String fileName) {
    return ShowroomBlock.images(
      id: id,
      layout: ShowroomImageLayout.photo,
      urls: <String>['$_warmheart/$fileName'],
    );
  }

  return <ShowroomBlock>[
    prose('wh-open', <RichTextParagraph>[
      line('wh-open-1', '안녕하세요! 저는 동탄에서 인테리어 웜하트를 운영하고있습니다~'),
      line(
        'wh-open-office',
        '이번에 회사 확장겸 새롭게 인테리어해서 사무실개업하게됐어요!',
      ),
    ]),
    ShowroomBlock.images(
      id: 'wh-congratulations',
      layout: ShowroomImageLayout.photo,
      urls: const <String>[showroomEmoticonCongratulations],
    ),
    prose('wh-open-rest', <RichTextParagraph>[
      line('wh-open-2', '금액정보를 보셔도 아시다싶이 제가 인테리어를 할줄 알았기 때문에 인건비가 0원이 들었어요!! 제가 다 했거든요 ㅎㅎ'),
      line(
        'wh-open-3',
        '혹시라도 우리랑 비슷하게 하실려는 분들 중에서 금액적으로 얼마나 들지 궁금하실수 있어서 참고하실겸 글 작성해봅니다!',
      ),
    ]),
    prose('wh-look', <RichTextParagraph>[
      line('wh-look-line', '그럼 거두절미하고 한번 보시죠~'),
    ]),
    ShowroomBlock.images(
      id: 'wh-overview',
      layout: ShowroomImageLayout.gallery,
      urls: <String>[
        '$_warmheart/wh_03.webp',
        '$_warmheart/wh_02.webp',
        '$_warmheart/wh_07.webp',
        '$_warmheart/wh_08.webp',
      ],
    ),
    prose('wh-overview-note', <RichTextParagraph>[
      line('wh-overview-1', '보시다싶이 탁트인 사무실 전경과 깔끔한 인테리어가 특징이에요~'),
      line('wh-overview-2', '자재도 깔끔하고 고급진 자재들로 선택했어용'),
    ]),
    photo('wh-wallpaper', 'wh_13.webp'),
    prose('wh-wallpaper-note', <RichTextParagraph>[
      line('wh-wallpaper-line', '이런 디아망 벽지와'),
    ]),
    photo('wh-light', 'wh_14.webp'),
    prose('wh-light-note', <RichTextParagraph>[
      line('wh-light-line', '깔끔한 조명으로 무드가 살죠~'),
    ]),
    prose('wh-sign-note', <RichTextParagraph>[
      line('wh-sign-line', '그리고 우리 상호명 간판이 굉장히 깔끔하고 이쁘거덩요~'),
    ]),
    ShowroomBlock.images(
      id: 'wh-sign',
      layout: ShowroomImageLayout.slider,
      urls: <String>['$_warmheart/wh_11.webp', '$_warmheart/wh_10.webp'],
    ),
    prose('wh-rest-note', <RichTextParagraph>[
      line('wh-rest-line', '휴식 공간도 빈백과 커피머신으로 예쁘게 꾸며봤어요!'),
    ]),
    photo('wh-rest-a', 'wh_09.webp'),
    photo('wh-rest-b', 'wh_06.webp'),
    prose('wh-rest-after', <RichTextParagraph>[
      line(
        'wh-rest-after-line',
        '너무 깔끔하고 예쁘지않나요? 가끔 쉴 때 저 공간에서 에너지 충전하면 너무 좋더라구요 ㅎㅎ',
      ),
    ]),
    photo('wh-rest-c', 'wh_05.webp'),
    photo('wh-rest-d', 'wh_04.webp'),
    photo('wh-rest-e', 'wh_12.webp'),
    prose('wh-close', <RichTextParagraph>[
      line(
        'wh-close-1',
        '인테리어 사무실이기 때문에 화이트톤의 깔끔하고 실용적인 스타일로 꾸며봤고, 조명도 무드와 어울리는 색상으로 배치해봤어요 ㅎㅎ',
      ),
      line(
        'wh-close-2',
        '저는 인건비가 들지 않아서 2천만원에 했지만 보통 이정도로 인테리어 진행하게되면 여기에 인건비정도만 추가하게 되는 거라고 생각하시면 될 것 같아요!',
      ),
      line('wh-close-3', '그리고 언제든지 이거랑 비슷하게 하시고싶으시면 편하게 연락 주셔도 됩니다~!'),
    ]),
    ShowroomBlock.images(
      id: 'wh-gamsa',
      layout: ShowroomImageLayout.photo,
      urls: const <String>[_gamsa],
    ),
  ];
}

class _LegacyPair {
  const _LegacyPair(
    this.id,
    this.caption,
    this.beforeUrl,
    this.afterUrl,
    this.afterText,
  );

  final String id;
  final String caption;
  final String beforeUrl;
  final String afterUrl;
  final String afterText;
}

List<ShowroomBlock> _legacyBody({
  required String id,
  required String open,
  required List<_LegacyPair> pairs,
  List<(String, String)> photos = const <(String, String)>[],
  String photoLead = '',
  required String close,
}) {
  final List<ShowroomBlock> blocks = <ShowroomBlock>[
    ShowroomBlock.text(id: '$id-open', paragraphId: '$id-open-p', text: open),
  ];
  for (final _LegacyPair pair in pairs) {
    blocks.add(
      ShowroomBlock.images(
        id: '$id-${pair.id}',
        layout: ShowroomImageLayout.beforeAfter,
        pairs: <ShowroomBeforeAfterPair>[
          ShowroomBeforeAfterPair(
            id: '$id-${pair.id}-pair',
            beforeUrl: pair.beforeUrl,
            afterUrl: pair.afterUrl,
            caption: pair.caption,
          ),
        ],
      ),
    );
    blocks.add(
      ShowroomBlock.text(
        id: '$id-${pair.id}-note',
        paragraphId: '$id-${pair.id}-note-p',
        text: pair.afterText,
      ),
    );
  }
  if (photoLead.trim().isNotEmpty) {
    blocks.add(
      ShowroomBlock.text(
        id: '$id-photo-lead',
        paragraphId: '$id-photo-lead-p',
        text: photoLead,
      ),
    );
  }
  for (final (String name, String url) in photos) {
    blocks.add(
      ShowroomBlock.images(
        id: '$id-$name',
        layout: ShowroomImageLayout.photo,
        urls: <String>[url],
      ),
    );
  }
  blocks.add(
    ShowroomBlock.text(
      id: '$id-close',
      paragraphId: '$id-close-p',
      text: close,
    ),
  );
  return blocks;
}
