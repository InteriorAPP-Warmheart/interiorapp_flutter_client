import 'package:interiorapp_flutter_client/showroom_tab/data/model/filter_showroom_model.dart';
import 'package:interiorapp_flutter_client/showroom_tab/domain/repository/filter_repository.dart';

class FilteredShowroomUseCase {
  final FilteredShowroomRepository _repository;

  FilteredShowroomUseCase(this._repository);

  Future<List<FilteredShowroomModel>> getFilteredShowrooms({
    List<String>? styles,
    List<String>? spaceTypes,
    double? minBudget,
    double? maxBudget,
    List<String>? tones,
    List<String>? materials,
  }) async {
    return _repository.getFilteredShowrooms(
      styles: styles,
      spaceTypes: spaceTypes,
      minBudget: minBudget,
      maxBudget: maxBudget,
      tones: tones,
      materials: materials,
    );
  }

  // Future<FilteredShowroomModel> updateFavoriteStatus(String id) async {
  //   return _repository.updateFavoriteStatus(id);
  // }
}