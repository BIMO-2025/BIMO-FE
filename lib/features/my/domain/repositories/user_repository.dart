/// 사용자 관련 리포지토리 인터페이스
abstract class UserRepository {
  /// 수면 패턴 업데이트
  Future<void> updateSleepPattern({
    required String userId,
    required String sleepPatternStart,
    required String sleepPatternEnd,
  });

  /// 사용자 프로필 조회
  Future<Map<String, dynamic>> getUserProfile();

  /// 수면 패턴 조회
  Future<Map<String, dynamic>> getSleepPattern();

  /// 로그아웃
  Future<String> logout();

  /// 프로필 사진 업데이트
  Future<Map<String, dynamic>> updateProfilePhoto(String imagePath);
}
