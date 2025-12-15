import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/auth_token_storage.dart';

/// API 클라이언트 (Dio 인스턴스)
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 인터셉터 추가
    dio.interceptors.add(_ApiInterceptor());
  }

  /// GET 요청
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST 요청
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT 요청
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PATCH 요청
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE 요청
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

/// API 인터셉터 (로깅, 인증 토큰 추가 등)
class _ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 인증 토큰 추가
    final storage = AuthTokenStorage();
    final token = await storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    print('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print('❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    print('❌ ERROR MESSAGE: ${err.message}');

    // 401 에러이고, 토큰 갱신 요청이 아닌 경우
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains('refresh')) {
      print('🔄 토큰 만료 감지. 갱신 시도...');
      
      final storage = AuthTokenStorage();
      final refreshToken = await storage.getRefreshToken();
      
      if (refreshToken != null) {
        try {
          // 토큰 갱신 요청 (새로운 Dio 인스턴스 사용 - 인터셉터 루프 방지)
          final dio = Dio(BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            headers: {'Content-Type': 'application/json'},
          ));
          
          final response = await dio.post(ApiConstants.refresh, data: {
            'refresh_token': refreshToken,
          });
          
          if (response.statusCode == 200) {
            final newAccessToken = response.data['access_token'];
            final newRefreshToken = response.data['refresh_token']; // 새로운 refresh token (선택적)
            
            if (newAccessToken != null) {
              print('✅ 토큰 갱신 성공!');
              await storage.saveAccessToken(newAccessToken);
              
              // 새로운 refresh token이 있으면 저장
              if (newRefreshToken != null) {
                await storage.saveRefreshToken(newRefreshToken);
                print('✅ 새로운 리프레시 토큰 저장 완료');
              }
              
              // 원래 요청의 헤더 업데이트
              final options = err.requestOptions;
              options.headers['Authorization'] = 'Bearer $newAccessToken';
              
              // 원래 요청 재시도
              final cloneReq = await ApiClient().dio.fetch(options);
              return handler.resolve(cloneReq);
            }
          }
        } catch (e) {
          print('❌ 토큰 갱신 실패: $e');
          // 갱신 실패 시 로그아웃 처리 (토큰 삭제)
          await storage.deleteAllTokens();
          // TODO: 로그인 화면으로 이동하는 로직이 필요할 수 있음 (GlobalKey 사용 등)
        }
      } else {
        print('❌ 리프레시 토큰 없음.');
      }
    }

    super.onError(err, handler);
  }
}


