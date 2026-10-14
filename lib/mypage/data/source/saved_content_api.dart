import 'dart:async';
import 'package:interiorapp_flutter_client/mypage/data/model/saved_content_model.dart';

/// 저장한 콘텐츠(북마크) API
/// - 실제 서버 연동 전 더미 데이터로 동작
class SavedContentApi {
  final List<Map<String, dynamic>> _jsonList = [
    {
      'id': 'sc-001',
      'thumbnailUrl': 'https://picsum.photos/seed/sc1/400/300',
      'title': '모던 미니멀 욕실 리모델링',
      'category': '욕실',
      'contentType': 'showroom',
      'savedAt': '2026-10-01T10:00:00.000Z',
    },
    {
      'id': 'sc-002',
      'thumbnailUrl': 'https://picsum.photos/seed/sc2/400/300',
      'title': '북유럽 스타일 거실 인테리어',
      'category': '거실',
      'contentType': 'showroom',
      'savedAt': '2026-09-28T14:30:00.000Z',
    },
    {
      'id': 'sc-003',
      'thumbnailUrl': 'https://picsum.photos/seed/sc3/400/300',
      'title': '프리미엄 원목 마루 시공',
      'category': '바닥',
      'contentType': 'store',
      'savedAt': '2026-09-20T09:15:00.000Z',
    },
    {
      'id': 'sc-004',
      'thumbnailUrl': 'https://picsum.photos/seed/sc4/400/300',
      'title': '아파트 전체 도배 시공 후기',
      'category': '도배',
      'contentType': 'article',
      'savedAt': '2026-09-15T18:00:00.000Z',
    },
    {
      'id': 'sc-005',
      'thumbnailUrl': 'https://picsum.photos/seed/sc5/400/300',
      'title': '주방 타일 교체 비용 정리',
      'category': '주방',
      'contentType': 'article',
      'savedAt': '2026-09-10T11:20:00.000Z',
    },
    {
      'id': 'sc-006',
      'thumbnailUrl': 'https://picsum.photos/seed/sc6/400/300',
      'title': '침실 붙박이장 설치 사례',
      'category': '침실',
      'contentType': 'showroom',
      'savedAt': '2026-09-05T16:40:00.000Z',
    },
    {
      'id': 'sc-007',
      'thumbnailUrl': 'https://picsum.photos/seed/sc7/400/300',
      'title': '발코니 확장 셀프 시공기',
      'category': '발코니',
      'contentType': 'article',
      'savedAt': '2026-08-30T13:00:00.000Z',
    },
    {
      'id': 'sc-008',
      'thumbnailUrl': 'https://picsum.photos/seed/sc8/400/300',
      'title': '인테리어 조명 고르는 방법',
      'category': '조명',
      'contentType': 'article',
      'savedAt': '2026-08-25T20:00:00.000Z',
    },
    {
      'id': 'sc-009',
      'thumbnailUrl': 'https://picsum.photos/seed/sc9/400/300',
      'title': '소형 아파트 수납 인테리어',
      'category': '수납',
      'contentType': 'showroom',
      'savedAt': '2026-08-18T08:30:00.000Z',
    },
    {
      'id': 'sc-010',
      'thumbnailUrl': 'https://picsum.photos/seed/sc10/400/300',
      'title': '카페 분위기 홈 오피스 꾸미기',
      'category': '홈오피스',
      'contentType': 'showroom',
      'savedAt': '2026-08-10T15:50:00.000Z',
    },
    {
      'id': 'sc-011',
      'thumbnailUrl': 'https://picsum.photos/seed/sc11/400/300',
      'title': '반셀프 인테리어 견적 가이드',
      'category': '견적',
      'contentType': 'article',
      'savedAt': '2026-08-02T10:10:00.000Z',
    },
    {
      'id': 'sc-012',
      'thumbnailUrl': 'https://picsum.photos/seed/sc12/400/300',
      'title': '창호 교체 전문 업체 추천',
      'category': '창호',
      'contentType': 'store',
      'savedAt': '2026-07-28T12:00:00.000Z',
    },
  ];

  Future<List<SavedContentModel>> getSavedContents() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return SavedContentModel.listFromJson(_jsonList);
  }

  Future<void> removeSavedContent(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _jsonList.removeWhere((e) => e['id'] == id);
  }
}
