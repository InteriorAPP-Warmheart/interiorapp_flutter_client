import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:interiorapp_flutter_client/build/data/repository/pyeong_basis_repository_impl.dart';
import 'package:interiorapp_flutter_client/build/data/repository/space_repository_impl.dart';
import 'package:interiorapp_flutter_client/build/data/source/pyeong_basis_api.dart';
import 'package:interiorapp_flutter_client/build/data/source/space_api.dart';
import 'package:interiorapp_flutter_client/build/domain/use_case/pyeong_basis_use_case.dart';
import 'package:interiorapp_flutter_client/build/domain/use_case/space_use_case.dart';
import 'package:interiorapp_flutter_client/build/presentation/vm/space_board_vm.dart';

final spaceApiProvider = Provider((ref) => SpaceApi());

final spaceRepositoryProvider = Provider((ref) {
  return SpaceRepositoryImpl(ref.read(spaceApiProvider));
});

final spaceUseCaseProvider = Provider((ref) {
  return SpaceUseCase(ref.read(spaceRepositoryProvider));
});

final spaceBoardProvider = ChangeNotifierProvider((ref) {
  return SpaceBoard(ref.read(spaceUseCaseProvider));
});

final pyeongBasisApiProvider = Provider((ref) => const PyeongBasisApi());

final pyeongBasisRepositoryProvider = Provider((ref) {
  return PyeongBasisRepositoryImpl(ref.read(pyeongBasisApiProvider));
});

final pyeongBasisUseCaseProvider = Provider((ref) {
  return PyeongBasisUseCase(ref.read(pyeongBasisRepositoryProvider));
});
