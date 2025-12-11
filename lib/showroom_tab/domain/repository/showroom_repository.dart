abstract class ShowroomRepository {
  Future<List<Map<String, dynamic>>> getRecentBuildings(bool hasData);
}