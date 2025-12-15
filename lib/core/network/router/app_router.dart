import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../../../features/onboarding/pages/splash_page.dart';
import '../../../features/onboarding/pages/onboarding_page.dart';
import '../../../features/auth/presentation/pages/nickname_setup_page.dart';
import '../../../features/home/presentation/pages/home_page.dart';
import '../../../features/home/presentation/pages/airline_review_page.dart';
import '../../../features/home/presentation/pages/notification_page.dart';
import '../../../features/home/presentation/pages/airline_detail_page.dart';
import '../../../features/home/data/mock_airlines.dart';
import '../../../features/auth/presentation/pages/login_page.dart';
import '../../../features/myflight/pages/myflight_page.dart';
import '../../../features/myflight/pages/review_write_page.dart';

/// 앱의 라우팅 설정을 관리하는 클래스
class AppRouter {
  AppRouter._(); // Private constructor to prevent instantiation

  /// GoRouter 인스턴스를 생성하고 반환
  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    // initialLocation: '/airline-detail',
    initialLocation: '/home', // Start with ReviewWritePage
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
        path: RouteNames.myFlight,
        name: 'myFlight',
        builder: (context, state) => const MyFlightPage(),
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
      // 테스트: 대한항공 상세 페이지
      GoRoute(
        path: '/notification',
        name: 'notification',
        builder: (context, state) => const NotificationPage(),
      ),
      GoRoute(
        path: '/airline-detail',
        name: 'airline-detail',
        builder: (context, state) {
          // 대한항공 mock 데이터 사용
          final koreanAir = mockAirlines.firstWhere(
            (airline) => airline.code == 'KE',
            orElse: () => mockAirlines.first,
          );
          return AirlineDetailPage(airline: koreanAir);
        },
      ),
      GoRoute(
        path: '/review-write',
        name: 'review-write',
        builder: (context, state) => const ReviewWritePage(
          departureCode: 'ICN',
          departureCity: 'Seoul',
          arrivalCode: 'JFK',
          arrivalCity: 'New York',
          flightNumber: 'KE081',
          date: '2025.10.15',
          stopover: '직항',
        ),
      ),
    ],
  );
}
