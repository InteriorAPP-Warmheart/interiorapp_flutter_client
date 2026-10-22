import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/domain/repository/space_repository.dart';

class SpaceUseCase {
  SpaceUseCase(this._repository);

  final SpaceRepository _repository;

  List<PrepRecord> get consults => _repository.consults;
  List<TradeCandidate> get trades => _repository.trades;
  List<SpaceProject> get received => _repository.received;
  List<SpaceProject> get ongoing => _repository.ongoing;
  List<SpaceProject> get finished => _repository.finished;

  PrepRecord? recordFor(String projectId) => _repository.recordFor(projectId);
  SpaceProject? projectForRecord(String recordId) => _repository.projectForRecord(recordId);
  SpaceProject? find(String id) => _repository.find(id);

  SpaceProject receiveConsult(PrepRecord record) => _repository.receiveConsult(record);
  void saveConsult(PrepRecord record) => _repository.saveConsult(record);
  void saveTrade(TradeCandidate candidate) => _repository.saveTrade(candidate);
}
