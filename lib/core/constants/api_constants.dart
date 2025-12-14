/// API 관련 상수
class ApiConstants {
  // 베이스 URL
  static const String baseUrl =
      'https://myron-effaceable-patiently.ngrok-free.dev';

<<<<<<< HEAD
  /// 백엔드 Base URL
  static const String baseUrl = 'https://myron-effaceable-patiently.ngrok-free.dev/';

  /// API 타임아웃 (밀리초)
  static const int connectTimeout = 30000; // 30초
  static const int receiveTimeout = 30000; // 30초

  /// API 엔드포인트
  static const String _apiPrefix = '';

  // 인증 관련
  // 인증 관련
  static const String login = '${_apiPrefix}auth/login';
  static const String logout = '${_apiPrefix}auth/logout';
  static const String register = '${_apiPrefix}auth/register';

  // 사용자 관련
  static const String userProfile = '${_apiPrefix}user/profile';
  static const String updateNickname = '${_apiPrefix}user/nickname';
  static const String checkNickname = '${_apiPrefix}user/nickname/check';

  // 항공사 관련
  static const String airlines = '$_apiPrefix/airlines';
  static String airlineDetail(String id) => '$_apiPrefix/airlines/$id';
  static String airlineReviews(String id) => '$_apiPrefix/airlines/$id/reviews';

  // 리뷰 관련
  static const String reviews = '$_apiPrefix/reviews';
  static const String myReviews = '$_apiPrefix/reviews/my';

  // TODO: 실제 백엔드 API 스펙에 맞춰 엔드포인트 수정 필요
=======
  // Endpoints
  static const String airlinesPopularWeekly = '/airlines/popular/weekly';
  static const String airlinesPopular = '/airlines/popular';
  static const String airlinesSearch = '/airlines/search';
>>>>>>> cbe30da4baa3ab86f74a1ea6822f5b192d6b1f7a
}
