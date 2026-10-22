import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/domain/prep_budget_guide.dart';

/// 평당 기준 서버. 연결 전에는 업종, 철거, 공사 형태에 따른 더미를 준다.
class PyeongBasisApi {
  const PyeongBasisApi();

  Future<PrepPyeongBasis?> find(PrepPyeongQuery query) async {
    if (!query.isComplete) return null;
    final int byIndustry = switch (query.industry) {
      '카페' || '베이커리' => 1800000,
      '식당' => 2100000,
      '병원' => 2300000,
      '미용' => 1700000,
      '사무실' || '학원' => 1400000,
      '소매' => 1500000,
      _ => 1600000,
    };
    final int byEnvironment = switch (query.environment) {
      '전체 철거' => 200000,
      '부분 철거' => 100000,
      '철거 없음' => 0,
      _ => 50000,
    };
    final int bySituation = query.situation == PrepLabels.partialWork ? -300000 : 0;
    final int base = byIndustry + byEnvironment + bySituation;
    return PrepPyeongBasis(
      basePerPyeong: base < 800000 ? 800000 : base,
      lowDelta: -50000,
      highDelta: 120000,
      industry: query.industry,
      environment: query.environment,
      situation: query.situation,
    );
  }
}
