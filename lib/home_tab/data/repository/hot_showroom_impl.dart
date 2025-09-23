import 'package:interiorapp_flutter_client/home_tab/data/model/hot_showroom_model.dart';
import 'package:interiorapp_flutter_client/home_tab/data/source/hot_showroom_api.dart';
import 'package:interiorapp_flutter_client/home_tab/domain/repository/hot_showroom_abst.dart';

class HotShowroomImpl implements HotShowroomRepository {

  final HotShowroomApi _showroomSliderApi = HotShowroomApi();
  @override
  Future<List<HotShowroomModel>> getHotShowroom() async {
    return _showroomSliderApi.getHotShowroomApiData();
  }
}