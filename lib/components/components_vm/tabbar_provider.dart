import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/signin_signup/presentation/vm/tabbar_vm.dart';

final tabProvider = NotifierProvider<TabbarVM, int>(
  TabbarVM.new
);
