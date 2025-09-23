import 'package:interiorapp_flutter_client/home_tab/data/model/showroom_slider_model.dart';
import 'package:interiorapp_flutter_client/home_tab/data/source/showroom_slider_api.dart';
import 'package:interiorapp_flutter_client/home_tab/domain/repository/showroom_slider_abst.dart';

class ShowroomSliderImpl implements ShowroomSliderRepository {

  final ShowroomSliderApi _showroomSliderApi = ShowroomSliderApi();
  @override
  Future<List<ShowroomSliderModel>> getShowroomSlider() async {
    return _showroomSliderApi.getShowroomSliderApiData();
  }
}