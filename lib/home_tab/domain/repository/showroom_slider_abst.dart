import 'dart:async';
import 'package:interiorapp_flutter_client/home_tab/data/model/showroom_slider_model.dart';

abstract class ShowroomSliderRepository {
  Future<List<ShowroomSliderModel>> getShowroomSlider();
}