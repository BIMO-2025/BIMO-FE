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
import '../../../features/myflight/pages/flight_plan_page.dart';
import '../../../features/myflight/pages/review_write_page.dart';
import '../../../features/home/domain/models/airline.dart';
import '../../../features/my/presentation/pages/sleep_pattern_page.dart'; // SleepPatternPage import

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
        builder: (context, state) {
          // 쿼리 파라미터에서 tab 값 가져오기
          final tabParam = state.uri.queryParameters['tab'];
          final tabIndex = tabParam != null ? int.tryParse(tabParam) ?? 0 : 0;
          
          // extra에서도 initialIndex 가져오기 (기존 호환성 유지)
          final extra = state.extra as Map<String, dynamic>?;
          final extraIndex = extra?['initialIndex'] as int?;
          
          // 쿼리 파라미터 우선, 없으면 extra 사용
          final initialIndex = tabIndex != 0 ? tabIndex : (extraIndex ?? 0);
          
          return HomePage(initialIndex: initialIndex);
        },
      ),
      GoRoute(
        path: RouteNames.myFlight,
        name: 'myFlight',
        builder: (context, state) => const MyFlightPage(),
      ),
      GoRoute(
        path: '/flight-plan',
        name: 'flight-plan',
        builder: (context, state) => const FlightPlanPage(),
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
      GoRoute(
        path: RouteNames.sleepPattern,
        name: 'sleepPattern',
        builder: (context, state) => const SleepPatternPage(),
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
          // 전달받은 airline 객체 사용
          if (state.extra is Airline) {
            return AirlineDetailPage(airline: state.extra as Airline);
          }

          // Fallback: 대한항공 mock 데이터 사용
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
