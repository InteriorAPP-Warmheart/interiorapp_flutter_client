import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color white = Color(0xFFFFFFFF);
}

abstract final class AppTheme {
  static ThemeData get light {
    const Color white = AppColors.white;
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
      surface: white,
      surfaceBright: white,
      surfaceDim: white,
      surfaceContainerLowest: white,
      surfaceContainerLow: white,
      surfaceContainer: white,
      surfaceContainerHigh: white,
      surfaceContainerHighest: white,
      surfaceTint: Colors.transparent,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: white,
      canvasColor: white,
      fontFamily: 'Pretendard',
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: white,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: white,
        modalBackgroundColor: white,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: const CardThemeData(
        color: white,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
