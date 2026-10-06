import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:interiorapp_flutter_client/app/router.dart';
import 'package:interiorapp_flutter_client/core/theme/app_theme.dart';
import 'package:interiorapp_flutter_client/core/widget/keyboard_dismiss.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(402, 874), // IPhone 16 Pro Size
      minTextAdapt: true,
      splitScreenMode: true,
      rebuildFactor: RebuildFactors.size,
      fontSizeResolver: (num fontSize, ScreenUtil util) {
        final double scale = util.scaleText.clamp(0.9, 1.15);
        return fontSize * scale;
      },
      builder:
          (context, child) => MaterialApp.router(
            // Localization
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('ko', '')],
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.router,
            themeMode: ThemeMode.light,
            theme: AppTheme.light,
            builder: (context, child) {
              return KeyboardDismiss(child: child ?? const SizedBox.shrink());
            },
          ),
    );
  }
}
