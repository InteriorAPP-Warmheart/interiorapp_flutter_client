import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/app/shell/tab_provider.dart';
import 'package:interiorapp_flutter_client/app/shell/app_app_bar.dart';
import 'package:interiorapp_flutter_client/favorite/ui/favorite_screen.dart';
import 'package:interiorapp_flutter_client/home/ui/screen/home_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/build_screen.dart';
import 'package:interiorapp_flutter_client/showroom/ui/screen/showroom_screen.dart';
import 'package:interiorapp_flutter_client/core/theme/tab_bar_theme.dart';
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
    // Provider의 현재 상태로 초기화
    _tabController = TabController(
      length: 5,
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
      body: TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(), // 탭바 좌우 스크롤 방지 (커스텀 아이콘 넣기위해선 필수)
        children: [
          HomeScreen(),
          ShowroomScreen(),
          StoreScreen(),
          BuildScreen(),
          FavoriteScreen(),
        ],
      ),
      bottomNavigationBar: _buildTab(),
    );
  }

  Widget _buildTab() {
    return Container(
      decoration: AppTabBarTheme.decoration,
      height: AppTabBarTheme.height(context),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTabBarTheme.selectedColor,
        labelStyle: AppTabBarTheme.labelStyle(context),
        indicatorColor: Colors.transparent, // 탭바 인디케이터 색상 제거
        onTap: (index) {
          HapticFeedback.lightImpact(); // 탭 클릭 시 가벼운 진동
          ref.read(tabProvider.notifier).changeTab(index);
        },
        tabs: [
          Tab(
            icon: Icon(Icons.home_rounded, size: AppTabBarTheme.iconSize(context)),
            text: '홈',
          ),
          Tab(
            icon: Icon(Icons.chair_rounded, size: AppTabBarTheme.iconSize(context)),
            text: '쇼룸',
          ),
          Tab(
            icon: Icon(
              Icons.shopping_bag_rounded,
              size: AppTabBarTheme.iconSize(context),
            ),
            text: '스토어',
          ),
          Tab(
            icon: Icon(Icons.build_rounded, size: AppTabBarTheme.iconSize(context)),
            text: '시공',
          ),
          Tab(
            icon: Icon(Icons.favorite_rounded, size: AppTabBarTheme.iconSize(context)),
            text: '즐겨찾기',
          ),
        ],
      ),
    );
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
