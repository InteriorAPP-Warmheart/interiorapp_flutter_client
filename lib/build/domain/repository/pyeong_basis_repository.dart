import 'package:interiorapp_flutter_client/build/domain/prep_budget_guide.dart';

/// 업종, 환경, 상황의 평당 기준.
abstract class PyeongBasisRepository {
  Future<PrepPyeongBasis?> find(PrepPyeongQuery query);
}
