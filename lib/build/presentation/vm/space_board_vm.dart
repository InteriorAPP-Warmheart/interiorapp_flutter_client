import 'package:flutter/foundation.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/domain/repository/space_repository.dart';
import 'package:interiorapp_flutter_client/build/domain/use_case/space_use_case.dart';

/// 내공간 화면이 듣는 상태. 데이터는 유스케이스를 통해서만 바꾼다.
class SpaceBoard extends ChangeNotifier {
  SpaceBoard(this._useCase);

  final SpaceUseCase _useCase;

  static const int maxTrades = SpaceRepository.maxTrades;

  List<PrepRecord> get consults => _useCase.consults;
  List<TradeCandidate> get trades => _useCase.trades;
  List<SpaceProject> get received => _useCase.received;
  List<SpaceProject> get ongoing => _useCase.ongoing;
  List<SpaceProject> get finished => _useCase.finished;

  PrepRecord? recordFor(String projectId) => _useCase.recordFor(projectId);
  SpaceProject? projectForRecord(String recordId) => _useCase.projectForRecord(recordId);
  SpaceProject? find(String id) => _useCase.find(id);

  SpaceProject receiveConsult(PrepRecord record) {
    final SpaceProject project = _useCase.receiveConsult(record);
    notifyListeners();
    return project;
  }

  void saveConsult(PrepRecord record) {
    _useCase.saveConsult(record);
    notifyListeners();
  }

  void saveTrade(TradeCandidate candidate) {
    _useCase.saveTrade(candidate);
    notifyListeners();
  }
}
