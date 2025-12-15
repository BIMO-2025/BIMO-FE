import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';

/// 사용자 관련 리포지토리 구현체
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;

  UserRepositoryImpl({UserRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? UserRemoteDataSource();

  @override
  Future<void> updateSleepPattern({
    required String sleepPatternStart,
    required String sleepPatternEnd,
  }) async {
    await _remoteDataSource.updateSleepPattern(
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
}
