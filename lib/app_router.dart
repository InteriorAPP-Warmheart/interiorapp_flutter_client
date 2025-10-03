import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/components/components_widget/app_tabbar.dart';
import 'package:interiorapp_flutter_client/search/ui/screen/combine_search_result_screen.dart';
import 'package:interiorapp_flutter_client/search/ui/screen/combine_search_screen.dart';
import 'package:interiorapp_flutter_client/settings_tab/setting_screen.dart';
import 'package:interiorapp_flutter_client/signin_signup/ui/screen/signin_screen.dart';
import 'package:interiorapp_flutter_client/signin_signup/ui/screen/signup_screen.dart';
// import 'package:interiorapp_flutter_client/splash_screen.dart';

class AppRouter {
  // Use a singleton GoRouter instance to preserve navigation state across hot reloads
  static final GoRouter router = GoRouter(
    routes: [
      // GoRoute(
      //   path: '/',
      //   builder: (context, state) => const SplashScreen(),
      // ),
      // 자동 로그인 개발 전 까지는 splash 화면 없음
      GoRoute(path: '/', builder: (context, state) => const AppTabBar()),
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SigninScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingScreen(),
      ),
      // 검색은 라우트 계층형 구조로 구성
      GoRoute(
        path: '/search',
        builder: (context, state) => const CombineSearchScreen(),
        routes: [
          GoRoute(
            path: 'result',
            builder:
                (context, state) => CombineSearchResultScreen(),
            routes: [
              // GoRoute(path: 'showrooms', builder: ...),
              // GoRoute(path: 'stores', builder: ...),
              // GoRoute(path: 'builds', builder: ...),
              // GoRoute(path: 'companies', builder: ...),
              // context.push('/search/result/showrooms'); <= 이런식으로 페이지 이동
            ],
          ),
        ],
      ),
    ],
  );

  // Backward-compatible helper if other places still call buildRouter()
  static GoRouter buildRouter() => router;
}
