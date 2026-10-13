import 'dart:async';
import 'package:interiorapp_flutter_client/showroom/data/model/hot_showroom_model.dart';

abstract class HotShowroomRepository {
  Future<List<HotShowroomModel>> getHotShowroom();
  Future<HotShowroomModel> updateFavoriteStatus(String id);
}
