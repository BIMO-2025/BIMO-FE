import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../../../features/onboarding/pages/splash_page.dart';
import '../../../features/onboarding/pages/onboarding_page.dart';
import '../../../features/auth/presentation/pages/nickname_setup_page.dart';
import '../../../features/home/presentation/pages/home_page.dart';
import '../../../features/auth/presentation/pages/login_page.dart';

/// 앱의 라우팅 설정을 관리하는 클래스
class AppRouter {
  AppRouter._(); // Private constructor to prevent instantiation

  /// GoRouter 인스턴스를 생성하고 반환
  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      // Auth Routes
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      // GoRoute(
      //   path: RouteNames.signUp,
      //   name: 'signUp',
      //   builder: (context, state) => const SignUpPage(),
      // ),
      // Main routes
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: RouteNames.nicknameSetup,
        builder: (context, state) {
           final extra = state.extra as Map<String, dynamic>?;
           return NicknameSetupPage(
             userId: extra?['userId'] ?? '',
             prefillNickname: extra?['nickname'],
           );
        },
      ),
    ],
  );
}
