import 'dart:async';
import 'package:interiorapp_flutter_client/home_tab/data/model/hot_showroom_model.dart';

abstract class HotShowroomRepository {
  Future<List<HotShowroomModel>> getHotShowroom();
}