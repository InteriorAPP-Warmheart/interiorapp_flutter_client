import 'package:go_router/go_router.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/build_screen.dart';
import 'package:interiorapp_flutter_client/build/domain/entity/space_project.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/prep_consult_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/prep_create_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/prep_detail_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/prep_hub_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/space_detail_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/trade_create_screen.dart';
import 'package:interiorapp_flutter_client/build/ui/screen/trade_detail_screen.dart';
import 'package:interiorapp_flutter_client/core/widget/adaptive_frame.dart';
import 'package:interiorapp_flutter_client/app/shell/app_tab_bar.dart';
import 'package:interiorapp_flutter_client/search/ui/screen/combine_search_result_screen.dart';
import 'package:interiorapp_flutter_client/search/ui/screen/combine_search_screen.dart';
import 'package:interiorapp_flutter_client/settings/ui/setting_screen.dart';
import 'package:interiorapp_flutter_client/showroom/ui/screen/showroom_write_detail_screen.dart';
import 'package:interiorapp_flutter_client/showroom/ui/screen/showroom_write_screen.dart';
import 'package:interiorapp_flutter_client/auth/ui/screen/signin_screen.dart';
import 'package:interiorapp_flutter_client/auth/ui/screen/signup_screen.dart';

// import 'package:interiorapp_flutter_client/app/splash_screen.dart';

class AppRouter {
  // Use a singleton GoRouter instance to preserve navigation state across hot reloads
  static final GoRouter router = GoRouter(
    routes: [
      // GoRoute(
      //   path: '/',
      //   builder: (context, state) => const SplashScreen(),
      // ),
      // 자동 로그인 개발 전 까지는 splash 화면 없음
      GoRoute(
        path: '/',
        builder: (context, state) => const AdaptiveFrame(child: AppTabBar()),
      ),
      GoRoute(
        path: '/signin',
        builder: (context, state) => const AdaptiveFrame(child: SigninScreen()),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const AdaptiveFrame(child: SignupScreen()),
      ),
      GoRoute(
        path: '/build',
        builder: (context, state) => const AdaptiveFrame(child: BuildScreen()),
        routes: [
          GoRoute(
            path: 'prep',
            builder: (context, state) => const AdaptiveFrame(child: PrepHubScreen()),
            routes: [
              GoRoute(
                path: 'record',
                builder: (context, state) {
                  final Object? extra = state.extra;
                  return AdaptiveFrame(
                    child: PrepDetailScreen(record: extra is PrepRecord ? extra : null),
                  );
                },
              ),
              GoRoute(
                path: 'trade',
                builder: (context, state) {
                  final Object? extra = state.extra;
                  return AdaptiveFrame(
                    child: TradeDetailScreen(candidate: extra is TradeCandidate ? extra : null),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (context, state) {
                      final Object? extra = state.extra;
                      return AdaptiveFrame(
                        child: TradeCreateScreen(initial: extra is TradeCandidate ? extra : null),
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'consult',
                builder: (context, state) {
                  final Object? extra = state.extra;
                  final PrepRecord record = extra is PrepRecord
                      ? extra
                      : const PrepRecord(
                          placeName: '상담준비',
                          buildingType: '',
                          address: '',
                          detailAddress: '',
                          area: '',
                          buildingCondition: '',
                          style: '',
                          budget: '',
                          period: '',
                          needs: '',
                          floorPlanLabels: [],
                          referenceImageLabels: [],
                        );
                  return AdaptiveFrame(child: PrepConsultScreen(record: record));
                },
              ),
              GoRoute(
                path: 'create',
                builder: (context, state) {
                  final Object? extra = state.extra;
                  final int step = int.tryParse(state.uri.queryParameters['step'] ?? '') ?? 0;
                  return AdaptiveFrame(
                    child: PrepCreateScreen(
                      initial: extra is PrepRecord ? extra : null,
                      initialStep: step,
                    ),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: ':projectId',
            builder: (context, state) => AdaptiveFrame(
              child: SpaceDetailScreen(
                projectId: state.pathParameters['projectId']!,
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder:
            (context, state) => const AdaptiveFrame(child: SettingScreen()),
      ),
      GoRoute(
        path: '/showroom-write',
        builder:
            (context, state) =>
                const AdaptiveFrame(child: ShowroomWriteScreen()),
        routes: [
          GoRoute(
            path: 'first-write',
            builder:
                (context, state) => AdaptiveFrame(
                  child: ShowroomWriteDetailScreen(
                    buildId: state.uri.queryParameters['buildId'],
                  ),
                ),
          ),
        ],
      ),
      // 검색은 라우트 계층형 구조로 구성
      GoRoute(
        path: '/search',
        builder:
            (context, state) =>
                const AdaptiveFrame(child: CombineSearchScreen()),
        routes: [
          GoRoute(
            path: 'result',
            builder:
                (context, state) =>
                    const AdaptiveFrame(child: CombineSearchResultScreen()),
            routes: [
              // GoRoute(path: 'showrooms', builder: (context, state) => ShowroomWriteScreen()),
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
