/// API 관련 상수
class ApiConstants {
  /// Base URL
  static const String baseUrl = 'https://nonsubtile-shea-wretched.ngrok-free.dev/';

  /// API 타임아웃 (밀리초)
  static const int connectTimeout = 30000; // 30초
  static const int receiveTimeout = 30000; // 30초

  /// API 엔드포인트
  static const String _apiPrefix = '';

  // 인증 관련
  static const String login = '${_apiPrefix}auth/login';
  static const String logout = '${_apiPrefix}auth/logout';
  static const String register = '${_apiPrefix}auth/register';
  static const String refresh = '${_apiPrefix}auth/refresh'; // 토큰 갱신

  // 사용자 관련
  static const String userProfile = '${_apiPrefix}user/profile';
  static const String updateNickname = '${_apiPrefix}user/nickname';
  static const String checkNickname = '${_apiPrefix}user/nickname/check';
  static const String updateProfilePhoto = '${_apiPrefix}user/profile/photo'; // 프로필 사진 업데이트

  // 항공사 관련
  static const String airlines = '$_apiPrefix/airlines';
  static String airlineDetail(String id) => '$_apiPrefix/airlines/$id';
  static String airlineReviews(String id) => '$_apiPrefix/airlines/$id/reviews';

  // 리뷰 관련
  static const String reviews = '$_apiPrefix/reviews';
  static const String myReviews = '$_apiPrefix/reviews/my';
  static String userReviews(String userId) => '${_apiPrefix}reviews/users/$userId/reviews';

  // 항공사 검색 관련 (feature/home에서 추가)
  static const String airlinesPopularWeekly = 'airlines/popular/weekly';
  static const String airlinesPopular = 'airlines/popular';
  static const String airlinesSorting = 'airlines/sorting';
  static const String airlinesSearch = 'airlines/search';
  static const String airlinesDetail = 'airlines'; // GET /airlines/{airline_code}
  static const String airlinesStatistics = 'airlines'; // GET /airlines/{airline_code}/statistics
  static const String airlinesSummary = 'airlines'; // GET /airlines/{airline_code}/summary
  static const String airlinesReviews = 'airlines'; // GET /airlines/{airline_code}/reviews
  static const String flightsSearch = 'search/airlines';
  static const String locationsSearch = 'flights/locations';
  static const String searchAirportIATA = 'search/airportIATACode';

  // 수면 패턴 관련
  static const String sleepPattern = '${_apiPrefix}user/sleep-pattern';

  // 비행 관련
  static String myFlightsHasReview(String userId) => '${_apiPrefix}users/$userId/my-flights/segments/has-review';
}
