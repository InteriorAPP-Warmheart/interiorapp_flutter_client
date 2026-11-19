/// 알림 등급. 미확인이 0건이면 그 등급 영역은 그리지 않는다.
enum NoticeGrade {
  confirm('확인 필요'),
  important('중요'),
  guide('안내');

  const NoticeGrade(this.label);

  final String label;
}

/// 채팅에서 확인을 기다리는 변경. 알림 목록을 만들 때 필요한 값만 둔다.
class NoticeConfirm {
  const NoticeConfirm({
    required this.id,
    required this.projectId,
    required this.title,
    required this.summary,
  });

  final String id;
  final String projectId;
  final String title;
  final String summary;
}

/// 알림을 눌렀을 때 여는 자리.
enum NoticeLink {
  /// 시공과 금액을 보는 견적 화면.
  estimate,

  /// 고객 확인을 기다리는 변경.
  change,

  /// 프로젝트의 중요 안내, 채팅, 또는 일반 기록.
  project,

  /// 현장에 올라온 사진 기록.
  photos,

  /// 광고가 가리키는 쇼룸.
  showroom,
}

/// 알림이 화면에 놓이는 모양. 현장 카드, 채팅, 광고는 서로 다르다.
enum NoticeForm {
  /// 현장 사진과 장소 이름.
  place,

  /// 사람이 보낸 말. 사진 대신 대화 아이콘을 둔다.
  chat,

  /// 광고. 장소 사진 없이 문구만 둔다.
  promo,
}

/// 알림 한 건. 읽음과 삭제는 따로 둔다.
class AppNotice {
  const AppNotice({
    required this.id,
    required this.projectId,
    required this.placeName,
    required this.imageUrl,
    required this.grade,
    required this.title,
    required this.body,
    required this.linkLabel,
    required this.link,
    required this.sentAt,
    this.form = NoticeForm.place,
    this.sender = '',
    this.showroomId = '',
    this.messageCount = 0,
  });

  final String id;
  final String projectId;
  final String placeName;
  final String imageUrl;
  final NoticeGrade grade;
  final String title;
  final String body;

  /// 어디로 가는지 카드에 붙는 짧은 이름. 견적, 변경, 현장, 기록.
  final String linkLabel;
  final NoticeLink link;
  final DateTime sentAt;
  final NoticeForm form;

  /// 채팅을 보낸 사람. 현장 카드와 광고는 비운다.
  final String sender;

  /// [NoticeLink.showroom]일 때 여는 쇼룸.
  final String showroomId;

  /// 채팅방에 쌓인 안 읽은 메시지 수. 메시지마다 알림을 만들지 않는다.
  final int messageCount;

  bool get isChatRoom => form == NoticeForm.chat;
}
