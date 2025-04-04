import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/ui/components/app_tabbar.dart';

class AppRouter {
  static final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AppTabBar(),
      ),
    ]
  );
}