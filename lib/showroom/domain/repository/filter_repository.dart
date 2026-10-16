import 'package:interiorapp_flutter_client/showroom/data/model/filter_showroom_model.dart';

abstract class FilteredShowroomRepository {
  Future<List<FilteredShowroomModel>> getFilteredShowrooms({
    List<String>? styles,
    List<String>? spaceTypes,
    double? minBudget,
    double? maxBudget,
    List<String>? tones,
    List<String>? materials,
    List<String>? industryIds,
    List<String>? areaRangeIds,
    List<String>? budgetRangeIds,
    List<String>? styleMoodIds,
  });

  //추후 좋아요 상태 갱신할 때 사용
  // Future<FilteredShowroomModel> updateFavoriteStatus(String id);
}
