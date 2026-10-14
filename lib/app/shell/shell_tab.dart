import 'package:flutter/material.dart';

/// 하단 탭 목적지.
///
/// [ShellTabs.active]에 있는 항목만 탭바에 그린다.
/// 스토어는 기능이 열리기 전까지 목록에 넣지 않는다.
/// 다시 열 때는 쇼룸과 내 공간 사이에 [ShellTab.store]를 둔다.
enum ShellTab { home, showroom, store, mySpace, mypage }

abstract final class ShellTabs {
  static const List<ShellTab> active = [
    ShellTab.home,
    ShellTab.showroom,
    ShellTab.mySpace,
    ShellTab.mypage,
  ];

  static int indexOf(ShellTab tab) => active.indexOf(tab);
}

extension ShellTabView on ShellTab {
  String get label => switch (this) {
    ShellTab.home => '홈',
    ShellTab.showroom => '쇼룸',
    ShellTab.store => '스토어',
    ShellTab.mySpace => '내공간',
    ShellTab.mypage => '마이페이지',
  };

  IconData get icon => switch (this) {
    ShellTab.home => Icons.home_rounded,
    ShellTab.showroom => Icons.chair_rounded,
    ShellTab.store => Icons.shopping_bag_rounded,
    ShellTab.mySpace => Icons.build_rounded,
    ShellTab.mypage => Icons.person_rounded,
  };
}
