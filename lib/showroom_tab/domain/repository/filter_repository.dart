import 'package:interiorapp_flutter_client/showroom_tab/data/model/filter_showroom_model.dart';

abstract class FilteredShowroomRepository {
  Future<List<FilteredShowroomModel>> getFilteredShowrooms({
    List<String>? styles,
    List<String>? spaceTypes,
    List<String>? budgets,
    List<String>? tones,
    List<String>? materials,
  });

}