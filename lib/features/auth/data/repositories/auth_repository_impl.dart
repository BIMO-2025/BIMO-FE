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
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/$provider/login',
        data: {
          'token': token,
          'fcm_token': 'dummy_fcm_token', // TODO: 실제 FCM 토큰 연동 필요
        },
      );

      final data = response.data;
      final accessToken = data['access_token'];
      final tokenType = data['token_type'];
      final user = data['user'];

      // 토큰 저장 (MVP: access_token만 저장)
      // 실제로는 refresh_token도 있을 수 있음
      if (accessToken != null) {
        await _tokenStorage.saveAccessToken(accessToken);
      }

      return AuthResult(
        accessToken: accessToken,
        tokenType: tokenType,
        user: user,
      );
    } on DioException catch (e) {
      // 에러 처리
      print('로그인 실패: ${e.message}');
      if (e.response != null) {
        print('응답 데이터: ${e.response?.data}');
      }
      rethrow;
    }
  }
}
