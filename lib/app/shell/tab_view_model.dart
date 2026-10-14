import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/app/shell/shell_tab.dart';

class TabbarVM extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void changeTab(int index) {
    if (index < 0 || index >= ShellTabs.active.length) return;
    state = index;
  }

  void open(ShellTab tab) {
    changeTab(ShellTabs.indexOf(tab));
  }
}
