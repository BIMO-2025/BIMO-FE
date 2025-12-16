import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_token_storage.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final AuthTokenStorage _tokenStorage = AuthTokenStorage();

  @override
  Future<AuthResult> login({
    required String provider,
    required String token,
    String? email,
  }) async {
    try {
      final response = await _apiClient.post(
        'auth/$provider/login',
        data: {
          'token': token,
          if (email != null) 'email': email,
          'fcm_token': 'dummy_fcm_token', // TODO: 실제 FCM 토큰 연동 필요
        },
      );

      final data = response.data;
      print('✅ AuthRepository: Login Response Data: $data');

      final accessToken = data['access_token'];
      final refreshToken = data['refresh_token']; // 리프레시 토큰 추가
      final tokenType = data['token_type'];
      final user = data['user'];

      // 토큰 저장
      if (accessToken != null) {
        await _tokenStorage.saveAccessToken(accessToken);
        print('✅ Access Token 저장 완료');
      }
      if (refreshToken != null) {
        await _tokenStorage.saveRefreshToken(refreshToken);
        print('✅ Refresh Token 저장 완료: ${refreshToken.substring(0, 20)}...');
      } else {
        print('⚠️ Refresh Token이 응답에 없습니다!');
      }

      return AuthResult(
        accessToken: accessToken ?? '', // null safety 처리
        tokenType: tokenType ?? 'Bearer',
        user: user,
      );
    } catch (e) {
      // 에러 처리
      print('로그인 실패 (Repository): $e');
      if (e is DioException && e.response != null) {
        print('응답 데이터: ${e.response?.data}');
      }
      rethrow;
    }
  }
}
