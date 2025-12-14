import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'ACCESS_TOKEN';
  static const _refreshTokenKey = 'REFRESH_TOKEN';

  static const _userNameKey = 'USER_NAME';
  static const _userEmailKey = 'USER_EMAIL';
  static const _userPhotoUrlKey = 'USER_PHOTO_URL';
  static const _userIdKey = 'USER_ID';

  /// 액세스 토큰 저장
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// 리프레시 토큰 저장
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// 사용자 정보 저장
  Future<void> saveUserInfo({String? name, String? email, String? photoUrl, String? userId}) async {
    if (name != null) await _storage.write(key: _userNameKey, value: name);
    if (email != null) await _storage.write(key: _userEmailKey, value: email);
    if (photoUrl != null) await _storage.write(key: _userPhotoUrlKey, value: photoUrl);
    if (userId != null) await _storage.write(key: _userIdKey, value: userId);
  }

  /// 액세스 토큰 조회
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// 리프레시 토큰 조회
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// 사용자 정보 조회
  Future<Map<String, String?>> getUserInfo() async {
    final name = await _storage.read(key: _userNameKey);
    final email = await _storage.read(key: _userEmailKey);
    final photoUrl = await _storage.read(key: _userPhotoUrlKey);
    final userId = await _storage.read(key: _userIdKey);
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'userId': userId,
    };
  }

  /// 모든 토큰 및 정보 삭제 (로그아웃 시)
  Future<void> deleteAllTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userNameKey);
    await _storage.delete(key: _userEmailKey);
    await _storage.delete(key: _userPhotoUrlKey);
    await _storage.delete(key: _userIdKey);
  }
}
