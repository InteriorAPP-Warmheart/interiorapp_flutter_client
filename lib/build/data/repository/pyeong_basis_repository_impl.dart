import 'package:interiorapp_flutter_client/build/data/source/pyeong_basis_api.dart';
import 'package:interiorapp_flutter_client/build/domain/prep_budget_guide.dart';
import 'package:interiorapp_flutter_client/build/domain/repository/pyeong_basis_repository.dart';

class PyeongBasisRepositoryImpl implements PyeongBasisRepository {
  PyeongBasisRepositoryImpl(this._api);

  final PyeongBasisApi _api;

  @override
  Future<PrepPyeongBasis?> find(PrepPyeongQuery query) => _api.find(query);
}
