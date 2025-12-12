abstract class ShowroomRepository {
  Future<List<Map<String, dynamic>>> getRecentBuildings(bool hasData);
  Future<Map<String, dynamic>?> getBuildingDetail(String buildId);
}