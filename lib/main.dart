import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interiorapp_flutter_client/app/router.dart';
import 'package:interiorapp_flutter_client/core/editor/quill_simulator_guard.dart';
import 'package:interiorapp_flutter_client/core/theme/app_theme.dart';
import 'package:interiorapp_flutter_client/core/widget/keyboard_dismiss.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  installQuillSimulatorGuard();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
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
    );
  }
}
