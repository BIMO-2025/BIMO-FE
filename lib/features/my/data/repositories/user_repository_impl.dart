import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';
import '../../../../core/storage/auth_token_storage.dart';

/// 사용자 관련 리포지토리 구현체
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;

  UserRepositoryImpl({UserRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? UserRemoteDataSource();

  @override
  Future<void> updateSleepPattern({
    required String userId,
    required String sleepPatternStart,
    required String sleepPatternEnd,
  }) async {
    await _remoteDataSource.updateSleepPattern(
      userId: userId,
      sleepPatternStart: sleepPatternStart,
      sleepPatternEnd: sleepPatternEnd,
    );
  }

  @override
  Future<Map<String, dynamic>> getUserProfile() async {
    return await _remoteDataSource.getUserProfile();
  }

  @override
  Future<Map<String, dynamic>> getSleepPattern() async {
    return await _remoteDataSource.getSleepPattern();
  }

  @override
  Future<String> logout() async {
    return await _remoteDataSource.logout();
  }

  @override
  Future<Map<String, dynamic>> updateProfilePhoto(String imagePath) async {
    // 1. 이미지 업로드 (URL 획득)
    final photoUrl = await _remoteDataSource.uploadImage(imagePath);
    
    // 2. 사용자 ID 획득
    final storage = AuthTokenStorage();
    final userInfo = await storage.getUserInfo();
    final userId = userInfo['userId'];
    
    if (userId == null) {
      throw Exception('User ID not found in local storage');
    }

    // 3. 프로필 업데이트 (URL 전송)
    return await _remoteDataSource.updateProfilePhoto(userId, photoUrl);
  }
}
