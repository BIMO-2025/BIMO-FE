import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthResult> call({
    required String provider,
    required String token,
    String? email,
  }) async {
    return await repository.login(
      provider: provider,
      token: token,
      email: email,
    );
  }
}
