import 'package:interiorapp_flutter_client/showroom_tab/data/model/filter_showroom_model.dart';
import 'package:interiorapp_flutter_client/showroom_tab/data/source/filter_api.dart';
import 'package:interiorapp_flutter_client/showroom_tab/domain/repository/filter_repository.dart';

class FilteredShowroomImpl implements FilteredShowroomRepository {
  final FilteredShowroomApi _api;

  FilteredShowroomImpl(this._api);

  @override
  Future<List<FilteredShowroomModel>> getFilteredShowrooms({
    List<String>? styles,
    List<String>? spaceTypes,
    double? minBudget,
    double? maxBudget,
    List<String>? tones,
    List<String>? materials,
  }) async {
    return _api.getFilteredShowrooms(
      styles: styles,
      spaceTypes: spaceTypes,
      minBudget: minBudget,
      maxBudget: maxBudget,
      tones: tones,
      materials: materials,
    );
  }
}
