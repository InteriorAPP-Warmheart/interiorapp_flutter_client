import 'dart:async';
import 'package:interiorapp_flutter_client/mypage/data/model/completed_project_model.dart';

/// 완료된 인테리어 프로젝트 이력 API
/// - 실제 서버 연동 전 더미 데이터로 동작
class CompletedProjectApi {
  final List<Map<String, dynamic>> _jsonList = [
    {
      'id': 'cp-001',
      'thumbnailUrl': 'https://picsum.photos/seed/cp1/900/600',
      'title': '마포구 25평 아파트 욕실 리모델링',
      'category': '욕실',
      'companyName': '바론 인테리어',
      'buildCost': 12000000,
      'rating': 4.8,
      'completedAt': '2026-08-15T00:00:00.000Z',
    },
    {
      'id': 'cp-002',
      'thumbnailUrl': 'https://picsum.photos/seed/cp2/900/600',
      'title': '분당 32평 거실·주방 리모델링',
      'category': '거실·주방',
      'companyName': '소담 하우징',
      'buildCost': 24500000,
      'rating': 4.5,
      'completedAt': '2025-12-20T00:00:00.000Z',
    },
    {
      'id': 'cp-003',
      'thumbnailUrl': 'https://picsum.photos/seed/cp3/900/600',
      'title': '역삼동 오피스텔 전체 도배·바닥',
      'category': '도배·바닥',
      'companyName': '무드디자인',
      'buildCost': 8900000,
      'rating': 4.9,
      'completedAt': '2025-06-10T00:00:00.000Z',
    },
  ];

  Future<List<CompletedProjectModel>> getCompletedProjects() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return CompletedProjectModel.listFromJson(_jsonList);
  }
}
