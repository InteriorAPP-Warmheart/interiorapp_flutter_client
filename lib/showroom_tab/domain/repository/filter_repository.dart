import 'package:interiorapp_flutter_client/showroom_tab/data/model/filter_showroom_model.dart';

abstract class FilteredShowroomRepository {
  Future<List<FilteredShowroomModel>> getFilteredShowrooms({
    List<String>? styles,
    List<String>? spaceTypes,
    double? minBudget,  
    double? maxBudget, 
    List<String>? tones,
    List<String>? materials,
  });

  //추후 좋아요 상태 갱신할 때 사용
  // Future<FilteredShowroomModel> updateFavoriteStatus(String id);

}