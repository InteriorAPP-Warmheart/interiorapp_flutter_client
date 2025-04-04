import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/presentation/provider/tabbar_provider.dart';
import 'package:interiorapp_flutter_client/ui/components/app_appbar.dart';
import 'package:interiorapp_flutter_client/ui/screen/chatting_screen.dart';
import 'package:interiorapp_flutter_client/ui/screen/construct_screen.dart';
import 'package:interiorapp_flutter_client/ui/screen/home_screen.dart';
import 'package:interiorapp_flutter_client/ui/screen/setting_screen.dart';
import 'package:interiorapp_flutter_client/ui/screen/showroom_screen.dart';
import 'package:interiorapp_flutter_client/ui/screen/store_screen.dart';
import 'package:interiorapp_flutter_client/util/theme/tabbar_theme.dart';

class AppTabBar extends ConsumerStatefulWidget {
  const AppTabBar({super.key});

  @override
  ConsumerState<AppTabBar> createState() => _AppTabBarState();
}

class _AppTabBarState extends ConsumerState<AppTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 탭 변경 완료를 추적하기 위한 Completer
  Completer? _tabChangeCompleter;

  @override
  void initState() {
    super.initState();
    // Provider의 현재 상태로 초기화
    _tabController = TabController(
      length: 6,
      vsync: this,
      initialIndex: ref.read(tabProvider),
    );

    // TabController의 변경을 Provider에 반영
    _tabController.addListener(() {
      if (ref.read(tabProvider) != _tabController.index) {
        ref.read(tabProvider.notifier).changeTab(_tabController.index);
      }
      // 탭 변경이 완료되면 Completer 완료
      if (!_tabController.indexIsChanging &&
          _tabChangeCompleter?.isCompleted == false) {
        _tabChangeCompleter?.complete();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(
      tabProvider,
    ); // 현재 탭 인덱스로 나중에 탭 변경 로직시 사용하면 됨

    // Provider 상태가 변경되면 TabController 업데이트
    if (_tabController.index != currentIndex) {
      _tabChangeCompleter = Completer();
      _tabController.animateTo(currentIndex);
    }

    return Scaffold(
      appBar: AppAppBar(),
      body: TabBarView(controller: _tabController, children: [
        HomeScreen(),
        ShowroomScreen(),
        ConstructScreen(),
        StoreScreen(),
        ChattingScreen(),
        SettingScreen(),
        ],
      ),
      bottomNavigationBar: _buildTab(),
    );
  }

  Widget _buildTab() {
    return Container(
      decoration: AppTabBarTheme.decoration,
      height: AppTabBarTheme.height,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTabBarTheme.selectedColor,
        // unselectedLabelColor: AppTabBarTheme.unselectedColor,
        // indicatorWeight: AppTabBarTheme.indicatorWeight,
        labelStyle: AppTabBarTheme.labelStyle,
        onTap: (index) {
          ref.read(tabProvider.notifier).changeTab(index);
        },
        tabs: [
          Tab(
            icon: Icon(Icons.home_rounded, size: AppTabBarTheme.iconSize),
            text: '홈',
          ),
          Tab(
            icon: Icon(Icons.chair_rounded, size: AppTabBarTheme.iconSize),
            text: '쇼룸',
          ),
          Tab(
            icon: Icon(Icons.build_rounded, size: AppTabBarTheme.iconSize),
            text: '시공',
          ),
          Tab(
            icon: Icon(Icons.shopping_bag_rounded, size: AppTabBarTheme.iconSize),
            text: '스토어',
          ),
          Tab(
            icon: Icon(Icons.chat_bubble_rounded, size: AppTabBarTheme.iconSize),
            text: '채팅',
          ),
          Tab(
            icon: Icon(Icons.settings_rounded, size: AppTabBarTheme.iconSize),
            text: '설정',
          ),
        ],
      ),
    );
  }
}
