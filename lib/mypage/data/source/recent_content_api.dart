import 'dart:async';
import 'package:interiorapp_flutter_client/mypage/data/model/recent_content_model.dart';

/// 최근 본 콘텐츠 API
/// - 실제 서버 연동 전 더미 데이터로 동작
class RecentContentApi {
  final List<Map<String, dynamic>> _jsonList = [
    {
      'id': 'rc-001',
      'thumbnailUrl': 'https://picsum.photos/seed/rc1/400/300',
      'title': '강남 신축 아파트 거실 풀패키지',
      'category': '거실',
      'contentType': 'showroom',
      'viewedAt': '2026-10-14T09:00:00.000Z',
    },
    {
      'id': 'rc-002',
      'thumbnailUrl': 'https://picsum.photos/seed/rc2/400/300',
      'title': '욕실 방수 시공 전문업체',
      'category': '욕실',
      'contentType': 'store',
      'viewedAt': '2026-10-13T18:30:00.000Z',
    },
    {
      'id': 'rc-003',
      'thumbnailUrl': 'https://picsum.photos/seed/rc3/400/300',
      'title': '셀프 도배 완전 정복 가이드',
      'category': '도배',
      'contentType': 'article',
      'viewedAt': '2026-10-12T14:00:00.000Z',
    },
    {
      'id': 'rc-004',
      'thumbnailUrl': 'https://picsum.photos/seed/rc4/400/300',
      'title': '25평 아파트 인테리어 비용 총정리',
      'category': '견적',
      'contentType': 'article',
      'viewedAt': '2026-10-11T10:20:00.000Z',
    },
    {
      'id': 'rc-005',
      'thumbnailUrl': 'https://picsum.photos/seed/rc5/400/300',
      'title': '주방 싱크대 교체 추천 브랜드',
      'category': '주방',
      'contentType': 'store',
      'viewedAt': '2026-10-10T16:45:00.000Z',
    },
    {
      'id': 'rc-006',
      'thumbnailUrl': 'https://picsum.photos/seed/rc6/400/300',
      'title': '빈티지 무드 침실 인테리어',
      'category': '침실',
      'contentType': 'showroom',
      'viewedAt': '2026-10-09T11:00:00.000Z',
    },
    {
      'id': 'rc-007',
      'thumbnailUrl': 'https://picsum.photos/seed/rc7/400/300',
      'title': '현관 타일 교체 공사 사례',
      'category': '현관',
      'contentType': 'showroom',
      'viewedAt': '2026-10-08T08:30:00.000Z',
    },
    {
      'id': 'rc-008',
      'thumbnailUrl': 'https://picsum.photos/seed/rc8/400/300',
      'title': '작은 방 넓어 보이는 인테리어 팁',
      'category': '수납',
      'contentType': 'article',
      'viewedAt': '2026-10-07T20:00:00.000Z',
    },
  ];

  Future<List<RecentContentModel>> getRecentContents() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return RecentContentModel.listFromJson(_jsonList);
  }

  Future<void> clearAllRecentContents() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _jsonList.clear();
  }
}
