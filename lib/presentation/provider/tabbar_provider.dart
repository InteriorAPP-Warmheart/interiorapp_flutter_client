import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/presentation/vm/tabbar_vm.dart';

final tabProvider = NotifierProvider<TabbarVM, int>(
  TabbarVM.new
);
