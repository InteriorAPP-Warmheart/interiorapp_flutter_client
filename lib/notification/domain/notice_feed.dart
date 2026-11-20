import 'package:interiorapp_flutter_client/build/domain/entity/construction_progress.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/work_quote.dart';
import 'package:interiorapp_flutter_client/notification/domain/app_notice.dart';

/// 지금 공간 상태에서 고객이 봐야 하는 알림만 고른다.
///
/// 확인 필요는 견적 확인과 변경 확인처럼 고객이 직접 처리하는 일이다.
/// 중요는 내일 공정, 남아 있는 A/S, 담당자 채팅처럼 먼저 읽을 안내이고,
/// 안내는 사진, 시공 기록, 광고다.
/// 채팅은 메시지마다 알림을 만들지 않고, 방 하나에 안 읽은 수를 쌓는다.
List<AppNotice> buildNoticeFeed({
  required List<SpaceProject> projects,
  required ConstructionProgress? Function(String id) progressOf,
  required List<NoticeConfirm> confirms,
  required DateTime now,
}) {
  final Map<String, SpaceProject> byId = <String, SpaceProject>{
    for (final SpaceProject project in projects) project.id: project,
  };
  final List<AppNotice> items = <AppNotice>[];

  for (final NoticeConfirm confirm in confirms) {
    final SpaceProject? project = byId[confirm.projectId];
    if (project == null) continue;
    items.add(
      AppNotice(
        id: 'change-${confirm.id}',
        projectId: project.id,
        placeName: project.placeName,
        imageUrl: project.imageUrl,
        grade: NoticeGrade.confirm,
        title: confirm.title,
        body: confirm.summary,
        linkLabel: '변경',
        link: NoticeLink.change,
        sentAt: now.subtract(const Duration(hours: 1)),
      ),
    );
  }

  for (final SpaceProject project in projects) {
    if (!_awaitsQuote(project)) continue;
    items.add(
      AppNotice(
        id: 'quote-${project.id}',
        projectId: project.id,
        placeName: project.placeName,
        imageUrl: project.imageUrl,
        grade: NoticeGrade.confirm,
        title: '금액 확인',
        body: '총 ${formatWon(project.workQuote!.sheet.grandTotal)}원',
        linkLabel: '견적',
        link: NoticeLink.estimate,
        sentAt: now.subtract(const Duration(hours: 3)),
      ),
    );
  }

  for (final SpaceProject project in projects) {
    final ConstructionProgress? progress = progressOf(project.id);
    if (project.phase == SpacePhase.construction &&
        progress != null &&
        progress.nextWhen.startsWith('내일') &&
        progress.nextTrade.trim().isNotEmpty) {
      items.add(
        AppNotice(
          id: 'next-${project.id}',
          projectId: project.id,
          placeName: project.placeName,
          imageUrl: project.imageUrl,
          grade: NoticeGrade.important,
          title: '내일 ${_tradeName(progress.nextTrade)}',
          body: progress.nextSummary.trim(),
          linkLabel: '일정',
          link: NoticeLink.project,
          sentAt: now.subtract(const Duration(hours: 7)),
        ),
      );
    }

    if (project.phase == SpacePhase.afterCare &&
        project.nextAction.contains('A/S')) {
      items.add(
        AppNotice(
          id: 'care-${project.id}',
          projectId: project.id,
          placeName: project.placeName,
          imageUrl: project.imageUrl,
          grade: NoticeGrade.important,
          title: '',
          body: _careLine(progress),
          linkLabel: 'A/S',
          link: NoticeLink.project,
          sentAt: now.subtract(const Duration(days: 2, hours: 4)),
        ),
      );
    }
  }

  for (final SpaceProject project in projects) {
    if (project.phase != SpacePhase.construction) continue;
    final List<PublicSitePhoto> photos =
        progressOf(project.id)?.recentPhotos ?? const <PublicSitePhoto>[];
    if (photos.isEmpty) continue;
    final PublicSitePhoto photo = photos.first;
    items.add(
      AppNotice(
        id: 'photos-${project.id}',
        projectId: project.id,
        placeName: project.placeName,
        imageUrl: photo.imageUrl.isEmpty ? project.imageUrl : photo.imageUrl,
        grade: NoticeGrade.guide,
        title: '',
        body: _photoLine(photo, photos.length),
        linkLabel: '사진',
        link: NoticeLink.photos,
        sentAt: now.subtract(const Duration(hours: 20)),
      ),
    );
  }

  var recordAge = 4;
  for (final SpaceProject project in projects) {
    if (!project.completed || !project.nextAction.contains('기록')) continue;
    items.add(
      AppNotice(
        id: 'record-${project.id}',
        projectId: project.id,
        placeName: project.placeName,
        imageUrl: project.imageUrl,
        grade: NoticeGrade.guide,
        title: '',
        body: _recordLine(
          progressOf(project.id)?.recentPhotos ?? const <PublicSitePhoto>[],
        ),
        linkLabel: '기록',
        link: NoticeLink.project,
        sentAt: now.subtract(Duration(days: recordAge)),
      ),
    );
    recordAge += 2;
  }

  final SpaceProject? seongsu = byId['project-seongsu-cafe'];
  if (seongsu != null) {
    items.add(
      AppNotice(
        id: 'chat-seongsu-outlet',
        projectId: seongsu.id,
        placeName: seongsu.placeName,
        imageUrl: '',
        grade: NoticeGrade.important,
        title: '콘센트 위치',
        body:
            '나: 카운터 콘센트, 냉장고 옆으로 옮겨 주세요\n'
            '오세진: 배선 길이 확인하고 그쪽으로 할게요',
        linkLabel: '채팅',
        link: NoticeLink.project,
        form: NoticeForm.chat,
        sender: '오세진',
        messageCount: 3,
        sentAt: now.subtract(const Duration(minutes: 40)),
      ),
    );
  }

  final SpaceProject? mangwon = byId['project-mangwon-bakery'];
  if (mangwon != null) {
    items.add(
      AppNotice(
        id: 'chat-mangwon-visit',
        projectId: mangwon.id,
        placeName: mangwon.placeName,
        imageUrl: '',
        grade: NoticeGrade.important,
        title: '실사',
        body: '윤재원: 진열대랑 배수 위치, 오늘 정리해서 보낼게요',
        linkLabel: '채팅',
        link: NoticeLink.project,
        form: NoticeForm.chat,
        sender: '윤재원',
        messageCount: 1,
        sentAt: now.subtract(const Duration(hours: 5)),
      ),
    );
  }

  items.add(
    AppNotice(
      id: 'promo-warmheart',
      projectId: '',
      placeName: '',
      imageUrl: '',
      grade: NoticeGrade.guide,
      title: '사무실 2주 사례',
      body: '전문직 사무실 22평, 2,000만원',
      linkLabel: '광고',
      link: NoticeLink.showroom,
      sentAt: now.subtract(const Duration(days: 1, hours: 3)),
      form: NoticeForm.promo,
      showroomId: 'showroom-warmheart',
    ),
  );

  items.sort((AppNotice a, AppNotice b) {
    final int byGrade = a.grade.index.compareTo(b.grade.index);
    if (byGrade != 0) return byGrade;
    return b.sentAt.compareTo(a.sentAt);
  });
  return items;
}

bool _awaitsQuote(SpaceProject project) {
  if (project.workQuote == null) return false;
  if (project.phase != SpacePhase.estimate &&
      project.phase != SpacePhase.design) {
    return false;
  }
  return project.nextAction.contains('확인');
}

String _tradeName(String trade) {
  return trade.replaceAll('공사', '').trim();
}

String _careLine(ConstructionProgress? progress) {
  final PublicSitePhoto? photo = _firstPhoto(progress?.recentPhotos);
  if (photo == null) return 'A/S 기간이 남아 있어요';
  return '${_photoWhen(photo)} · A/S 기간이 남아 있어요';
}

String _photoLine(PublicSitePhoto photo, int count) {
  final String note = photo.note.trim();
  final String what =
      note.isEmpty
          ? '${photo.area} ${photo.trade}'.trim()
          : '${photo.area} $note'.trim();
  if (count <= 1) return what;
  return '$what · $count장';
}

String _recordLine(List<PublicSitePhoto> photos) {
  final PublicSitePhoto? photo = _firstPhoto(photos);
  if (photo == null) return '시공 기록을 다시 볼 수 있어요';
  return _photoWhen(photo);
}

PublicSitePhoto? _firstPhoto(List<PublicSitePhoto>? photos) {
  if (photos == null || photos.isEmpty) return null;
  return photos.first;
}

String _photoWhen(PublicSitePhoto photo) {
  return '${photo.takenOn} ${photo.area} ${photo.trade}'.trim();
}
