import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/app/shell/shell_tab.dart';
import 'package:interiorapp_flutter_client/app/shell/tab_provider.dart';
import 'package:interiorapp_flutter_client/app/shell/app_app_bar.dart';
import 'package:interiorapp_flutter_client/home/ui/screen/home_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/build_screen.dart';
import 'package:interiorapp_flutter_client/mypage/ui/screen/mypage_screen.dart';
import 'package:interiorapp_flutter_client/showroom/ui/screen/showroom_screen.dart';
import 'package:interiorapp_flutter_client/core/theme/tab_bar_theme.dart';
import 'package:interiorapp_flutter_client/core/utils/responsive_size.dart';
import 'package:interiorapp_flutter_client/store/ui/store_screen.dart';

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
    final int lastIndex = ShellTabs.active.length - 1;
    final int initialIndex = ref.read(tabProvider).clamp(0, lastIndex).toInt();
    _tabController = TabController(
      length: ShellTabs.active.length,
      vsync: this,
      initialIndex: initialIndex,
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(ResponsiveSize.appBarHeight(context)),
        child: const AppAppBar(),
      ),
      body: TabBarView(
        controller: _tabController,
        physics:
            NeverScrollableScrollPhysics(), // 탭바 좌우 스크롤 방지 (커스텀 아이콘 넣기위해선 필수)
        children: [for (final tab in ShellTabs.active) _pageFor(tab)],
      ),
      bottomNavigationBar: _buildTab(),
    );
  }

  Widget _buildTab() {
    final EdgeInsets inset = ResponsiveSize.responsivePadding(context);
    final double tabGap = ResponsiveSize.subGap(context) * 0.5;

    return Container(
      decoration: AppTabBarTheme.decoration,
      height: AppTabBarTheme.height(context),
      padding: EdgeInsets.symmetric(horizontal: inset.left),
      child: TabBar(
        controller: _tabController,
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.symmetric(horizontal: tabGap),
        labelColor: AppTabBarTheme.selectedColor,
        unselectedLabelColor: AppTabBarTheme.unselectedColor,
        labelStyle: AppTabBarTheme.labelStyle(context),
        unselectedLabelStyle: AppTabBarTheme.unselectedLabelStyle(context),
        indicator: AppTabBarTheme.indicator,
        indicatorSize: TabBarIndicatorSize.tab,
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        onTap: (index) {
          HapticFeedback.lightImpact(); // 탭 클릭 시 가벼운 진동
          ref.read(tabProvider.notifier).changeTab(index);
        },
        tabs: [
          for (final tab in ShellTabs.active)
            Tab(
              icon: Icon(tab.icon, size: AppTabBarTheme.iconSize(context)),
              iconMargin: const EdgeInsets.only(bottom: 2),
              text: tab.label,
            ),
        ],
      ),
    );
  }

  Widget _pageFor(ShellTab tab) {
    return switch (tab) {
      ShellTab.home => const HomeScreen(),
      ShellTab.showroom => const ShowroomScreen(),
      ShellTab.store => const StoreScreen(),
      ShellTab.mySpace => const BuildScreen(),
      ShellTab.mypage => const MyPageScreen(),
    };
  }
}

// === 커스텀으로 이미지 아이콘으로 탭 생성하는 로직 ===
// Tab(
//   icon: imageToIcon(
//     context,
//     'assets/images/bone.png',
//     AppTabBarTheme.iconSize,
//     currentIndex == 1 ? Colors.blue : Colors.black,
//   ),
//   text: '식사관리',
// ),

// === style 폴더 만들어서 빼두기 ===
// Widget imageToIcon(
//   BuildContext context,
//   String imagePath,
//   double size,
//   Color color,
// ) {
//   return Image.asset(
//     imagePath,
//     width: size,
//     height: size,
//     fit: BoxFit.cover,
//     color: color,
//   );
// }
