import 'package:interiorapp_flutter_client/build/data/source/space_api.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/domain/repository/space_repository.dart';

class SpaceRepositoryImpl implements SpaceRepository {
  SpaceRepositoryImpl(this._api);

  final SpaceApi _api;

  @override
  List<PrepRecord> get consults => _api.consults;

  @override
  List<TradeCandidate> get trades => _api.trades;

  @override
  List<SpaceProject> get received => _api.received;

  @override
  List<SpaceProject> get ongoing => _api.ongoing;

  @override
  List<SpaceProject> get finished => _api.finished;

  @override
  PrepRecord? recordFor(String projectId) => _api.recordFor(projectId);

  @override
  SpaceProject? projectForRecord(String recordId) => _api.projectForRecord(recordId);

  @override
  SpaceProject? find(String id) => _api.find(id);

  @override
  SpaceProject receiveConsult(PrepRecord record) => _api.receiveConsult(record);

  @override
  void saveConsult(PrepRecord record) => _api.saveConsult(record);

  @override
  void saveTrade(TradeCandidate candidate) => _api.saveTrade(candidate);
}
