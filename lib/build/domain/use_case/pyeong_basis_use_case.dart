import 'package:interiorapp_flutter_client/build/domain/prep_budget_guide.dart';
import 'package:interiorapp_flutter_client/build/domain/repository/pyeong_basis_repository.dart';

class PyeongBasisUseCase {
  PyeongBasisUseCase(this._repository);

  final PyeongBasisRepository _repository;

  Future<PrepPyeongBasis?> find(PrepPyeongQuery query) => _repository.find(query);
}
