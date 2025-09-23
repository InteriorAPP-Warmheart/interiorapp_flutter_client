import 'package:interiorapp_flutter_client/home_tab/data/model/showroom_slider_model.dart';
import 'package:interiorapp_flutter_client/home_tab/domain/repository/showroom_slider_abst.dart';

class ShowroomSliderUseCase {
  final ShowroomSliderRepository _showroomSliderRepository;

  ShowroomSliderUseCase(this._showroomSliderRepository);

  Future<List<ShowroomSliderModel>> getShowroomSlider() async {
    return _showroomSliderRepository.getShowroomSlider();
  }
}