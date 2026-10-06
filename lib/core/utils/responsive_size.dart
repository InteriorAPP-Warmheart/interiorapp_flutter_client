import 'dart:ui' show DisplayFeature, DisplayFeatureType;

import 'package:flutter/material.dart';

/// 화면 폭 기준. Material 창 크기 등급과 같다.
enum AppWindowClass {
  /// 접힌 폴더블, 일반 폰. 너비 600 미만.
  compact,

  /// 펼친 폴더블, 작은 태블릿. 너비 600 이상 840 미만.
  medium,

  /// 태블릿, 펼친 폴더블 가로. 너비 840 이상.
  expanded,
}

/// 현재 창의 크기와 접힘선.
class AppWindow {
  const AppWindow({
    required this.sizeClass,
    required this.size,
    required this.hasHinge,
  });

  final AppWindowClass sizeClass;
  final Size size;
  final bool hasHinge;

  bool get isCompact => sizeClass == AppWindowClass.compact;
  bool get isMedium => sizeClass == AppWindowClass.medium;
  bool get isExpanded => sizeClass == AppWindowClass.expanded;

  static AppWindow of(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    final double width = media.size.width;
    final bool hasHinge = media.displayFeatures.any(
      (DisplayFeature feature) =>
          feature.type == DisplayFeatureType.hinge ||
          feature.type == DisplayFeatureType.fold,
    );

    final AppWindowClass sizeClass;
    if (width >= 840) {
      sizeClass = AppWindowClass.expanded;
    } else if (width >= 600) {
      sizeClass = AppWindowClass.medium;
    } else {
      sizeClass = AppWindowClass.compact;
    }

    return AppWindow(
      sizeClass: sizeClass,
      size: media.size,
      hasHinge: hasHinge,
    );
  }
}

/// 통합 사이즈 로직 유틸
/// - 화면 너비/방향/브레이크포인트를 고려하여 일관된 배너 높이 계산
/// - 폴더블/태블릿/폰에서 안정적인 결과 제공
class ResponsiveSize {
  const ResponsiveSize._();

  /// 배너/카루셀 위젯 높이 계산
  /// - aspectRatio가 null이면 내부 브레이크포인트(21:9 / 16:9)로 결정
  /// - useResponsiveHeight=false면 fixedHeight를 그대로 사용
  static double bannerHeight(
    BuildContext context, {
    required double maxWidth,
    double? aspectRatio,
    double minHeight = 140.0,
    double maxHeight = 360.0,
    bool useResponsiveHeight = true,
    double fixedHeight = 200.0,
  }) {
    if (!useResponsiveHeight) return fixedHeight;

    final AppWindow window = AppWindow.of(context);

    // 브레이크포인트 기반 화면비 결정
    double decidedAspectRatio;
    if (aspectRatio != null) {
      decidedAspectRatio = aspectRatio;
    } else if (window.isExpanded) {
      decidedAspectRatio = 21 / 9;
    } else {
      decidedAspectRatio = 16 / 9;
    }

    final double responsiveHeight = (maxWidth / decidedAspectRatio)
        .clamp(minHeight, maxHeight);
    return responsiveHeight;
  }

  /// 카드(예: 상품 카드) 높이 계산
  /// - columns: 한 줄에 보여줄 카드 개수 (Grid 레이아웃 기준)
  /// - aspectRatio: 카드의 가로:세로 비 (기본 3:4)
  static double cardHeight(
    BuildContext context, {
    required int columns,
    double horizontalGap = 16.0,
    double horizontalPadding = 16.0,
    double aspectRatio = 3 / 4,
    double minHeight = 140.0,
    double maxHeight = 380.0,
  }) {
    final Size size = MediaQuery.of(context).size;
    final double contentWidth = size.width - (horizontalPadding * 2) - (horizontalGap * (columns - 1));
    final double tileWidth = (contentWidth / columns).clamp(80.0, size.width);
    final double height = tileWidth / aspectRatio;
    return height.clamp(minHeight, maxHeight);
  }

  /// 그리드 타일 높이 - 타일의 가로폭과 비율로 계산
  static double gridTileHeightByWidth({
    required double tileWidth,
    double aspectRatio = 1.0,
    double minHeight = 80.0,
    double maxHeight = 420.0,
  }) {
    final double height = tileWidth / aspectRatio;
    return height.clamp(minHeight, maxHeight);
  }

  /// 정사각 썸네일 사이즈 계산 (그리드/리스트 공용)
  static double squareThumbSize(
    BuildContext context, {
    required int columns,
    double horizontalGap = 12.0,
    double horizontalPadding = 16.0,
    double min = 56.0,
    double max = 160.0,
  }) {
    final Size size = MediaQuery.of(context).size;
    final double contentWidth = size.width - (horizontalPadding * 2) - (horizontalGap * (columns - 1));
    final double tileWidth = (contentWidth / columns).clamp(min, max);
    return tileWidth;
  }

  /// 모달/바텀시트 최대 높이 (화면 비율 기반)
  static double modalMaxHeight(
    BuildContext context, {
    double screenFraction = 0.9,
    double minHeight = 240.0,
    double maxHeight = 720.0,
  }) {
    final double h = MediaQuery.of(context).size.height * screenFraction;
    return h.clamp(minHeight, maxHeight);
  }

  /// AppBar 높이 (디바이스에 따라 약간 가변)
  static double appBarHeight(BuildContext context) {
    final AppWindow window = AppWindow.of(context);
    if (window.isExpanded) return 64.0;
    if (window.isMedium) return 60.0;
    return kToolbarHeight;
  }

  /// BottomNavigationBar 높이 (가변)
  static double bottomNavHeight(BuildContext context) {
    final AppWindow window = AppWindow.of(context);
    if (window.isExpanded) return 72.0;
    if (window.isMedium) return 68.0;
    return 64.0;
  }

  /// 반응형 패딩 (화면 너비 브레이크포인트 기반)
  static EdgeInsets responsivePadding(BuildContext context) {
    final AppWindow window = AppWindow.of(context);
    if (window.isExpanded) return const EdgeInsets.symmetric(horizontal: 24.0);
    if (window.isMedium) return const EdgeInsets.symmetric(horizontal: 20.0);
    return const EdgeInsets.symmetric(horizontal: 16.0);
  }

  /// 섹션 간 기본 간격 (디바이스 폭 기준 고정 비율)
  static double sectionGap(BuildContext context) {
    final AppWindow window = AppWindow.of(context);
    if (window.isExpanded) return 32.0;
    if (window.isMedium) return 28.0;
    return 24.0;
  }

  /// 제목-컨텐츠, 요소 내부의 보조 간격 (sectionGap의 약 0.5배)
  static double subGap(BuildContext context) {
    final AppWindow window = AppWindow.of(context);
    if (window.isExpanded) return 16.0;
    if (window.isMedium) return 14.0;
    return 12.0;
  }

  /// 폰트 스케일 팩터. 화면이 커져도 글자가 두 배로 커지지 않게 제한한다.
  static double fontScale(BuildContext context) {
    final AppWindow window = AppWindow.of(context);
    if (window.isExpanded) return 1.08;
    if (window.isMedium) return 1.0;
    return 0.96;
  }

  /// 홈 카테고리 카드처럼 화면 한가운데 뜨는 카드 크기.
  static Size centeredCardSize(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double cardWidth = (width * 0.62).clamp(180.0, 320.0);
    return Size(cardWidth, cardWidth * 1.25);
  }
}


