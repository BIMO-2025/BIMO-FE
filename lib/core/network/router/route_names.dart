/// 앱 내 모든 라우트 경로를 관리하는 상수 클래스
class RouteNames {
  RouteNames._(); // Private constructor to prevent instantiation

  // Onboarding Routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // Auth Routes
  static const String login = '/login';
  static const String signUp = '/sign-up';

  // Main Routes
  static const String nicknameSetup = '/nickname-setup';
  static const String sleepPattern = '/sleep-pattern';
  static const String home = '/home';
  static const String myFlight = '/myflight';
  static const String reviewWrite = '/review-write'; // 리뷰 작성 페이지
 
  static const List<String> bottomNavRoutes = [
    home,
    myFlight,
  ];
}
