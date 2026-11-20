/// 앱 안에 쌓아 두는 공지. 고객 지원에서 본다.
class HomeBulletin {
  const HomeBulletin({
    required this.postedOn,
    required this.title,
    required this.body,
  });

  final DateTime postedOn;
  final String title;
  final String body;

  String get month => '${postedOn.month}월';
  String get day => '${postedOn.day}';
}

/// 자주 묻는 질문. 공지와 같이 고객 지원에 둔다.
class HomeFaq {
  const HomeFaq({required this.question, required this.answer});

  final String question;
  final String answer;
}

final List<HomeBulletin> homeBulletins = <HomeBulletin>[
  HomeBulletin(
    postedOn: DateTime(2026, 11, 19),
    title: '겨울 현장 안내',
    body: '난방을 켠 뒤에는 도장 일정이 하루 늦어질 수 있어요. 일정은 각 공간에서 다시 확인해요.',
  ),
  HomeBulletin(
    postedOn: DateTime(2026, 11, 12),
    title: '고객센터',
    body: '평일 10:00–18:00에 연결돼요. 주말과 공휴일은 쉽니다.',
  ),
  HomeBulletin(
    postedOn: DateTime(2026, 10, 28),
    title: '견적 확인',
    body: '금액이 도착하면 알림에서 바로 열 수 있어요. 확인 전에도 견적서는 그 공간에 남아요.',
  ),
  HomeBulletin(
    postedOn: DateTime(2026, 10, 6),
    title: '상담 시간',
    body: '방문 상담은 평일 오전으로 잡고 있어요. 시간은 전화로 다시 정해요.',
  ),
];

const List<HomeFaq> homeFaqs = <HomeFaq>[
  HomeFaq(
    question: '견적은 어디서 보나요?',
    answer: '알림의 견적을 누르면 견적서로 열려요. 그 공간에서도 다시 볼 수 있어요.',
  ),
  HomeFaq(
    question: '바꿔 달라는 내용은 어디서 확인하나요?',
    answer: '확인이 필요한 일은 알림에 모여요. 누르면 그 공간으로 가요.',
  ),
  HomeFaq(
    question: '상담은 어떻게 시작하나요?',
    answer: '홈 오른쪽 아래 상담받기에서 공간 정보를 남기면 전화로 이어져요.',
  ),
  HomeFaq(
    question: 'A/S는 어디서 보나요?',
    answer: '공사가 끝난 공간에 남아 있어요. 기간이 끝나면 기록만 다시 볼 수 있어요.',
  ),
];
