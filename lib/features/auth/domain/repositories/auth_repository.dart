import '../entities/auth_result.dart';

abstract class AuthRepository {
  /// 소셜 로그인 (백엔드 연동)
  Future<AuthResult> login({
    required String provider,
    required String token,
    String? email,
  });
}
