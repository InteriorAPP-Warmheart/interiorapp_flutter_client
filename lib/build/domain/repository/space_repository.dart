import 'package:interiorapp_flutter_client/build/domain/entity/construction_progress.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';

/// 내공간의 상담, 후보지, 진행 현장.
abstract class SpaceRepository {
  static const int maxTrades = 2;

  List<PrepRecord> get consults;
  List<TradeCandidate> get trades;
  List<SpaceProject> get received;
  List<SpaceProject> get ongoing;
  List<SpaceProject> get finished;

  ConstructionProgress? constructionFor(String projectId);
  PrepRecord? recordFor(String projectId);
  SpaceProject? projectForRecord(String recordId);
  SpaceProject? find(String id);

  SpaceProject receiveConsult(PrepRecord record);
  void saveConsult(PrepRecord record);
  void saveTrade(TradeCandidate candidate);
}
