import 'package:flutter/material.dart';

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

    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = orientation == Orientation.landscape;

    // 브레이크포인트 기반 화면비 결정
    double decidedAspectRatio;
    if (aspectRatio != null) {
      decidedAspectRatio = aspectRatio;
    } else {
      if (isLandscape || maxWidth >= 900) {
        decidedAspectRatio = 21 / 9; // 폴더블/태블릿 가로
      } else if (maxWidth >= 600) {
        decidedAspectRatio = 16 / 9; // 큰 폰/작은 태블릿
      } else {
        decidedAspectRatio = 16 / 9; // 일반 폰 기본값
      }
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
    final double width = MediaQuery.of(context).size.width;
    if (width >= 900) return 64.0; // 태블릿/폴더블 와이드
    if (width >= 600) return 60.0; // 큰 폰/작은 태블릿
    return kToolbarHeight; // 기본 56.0
  }

  /// BottomNavigationBar 높이 (가변)
  static double bottomNavHeight(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    if (width >= 900) return 68.0;
    if (width >= 600) return 64.0;
    return 60.0;
  }

  /// 반응형 패딩 (화면 너비 브레이크포인트 기반)
  static EdgeInsets responsivePadding(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    if (width >= 900) return const EdgeInsets.symmetric(horizontal: 24.0);
    if (width >= 600) return const EdgeInsets.symmetric(horizontal: 20.0);
    return const EdgeInsets.symmetric(horizontal: 16.0);
  }

  /// 폰트 스케일 팩터 (살짝만 조정)
  static double fontScale(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    if (width >= 900) return 1.08;
    if (width >= 600) return 1.0;
    return 0.96;
  }
}


