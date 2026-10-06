import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/app/shell/tab_view_model.dart';

final tabProvider = NotifierProvider<TabbarVM, int>(
  TabbarVM.new
);
