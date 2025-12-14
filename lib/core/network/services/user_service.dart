import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';
import '../api_client.dart';

/// 사용자 관련 API 서비스
class UserService {
  final ApiClient _apiClient = ApiClient();

  /// 닉네임 중복 체크
  /// 
  /// Returns: true if nickname is available, false if already taken
  Future<bool> checkNicknameAvailability(String nickname) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.checkNickname,
        queryParameters: {'nickname': nickname},
      );

      // TODO: 실제 백엔드 응답 형식에 맞춰 수정
      return response.data['available'] ?? false;
    } on DioException catch (e) {
      print('닉네임 중복 체크 실패: ${e.message}');
      rethrow;
    }
  }

  /// 닉네임 변경
  /// 
  /// Returns: 성공 시 true, 실패 시 false
  Future<bool> updateNickname(String userId, String newNickname) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.updateNickname,
        data: {
          'userId': userId,
          'nickname': newNickname,
        },
      );

      // TODO: 실제 백엔드 응답 형식에 맞춰 수정
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('닉네임 변경 실패: ${e.message}');
      rethrow;
    }
  }

  /// 사용자 프로필 조회
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.userProfile}/$userId',
      );

      // TODO: 실제 백엔드 응답 형식에 맞춰 수정
      return response.data;
    } on DioException catch (e) {
      print('사용자 프로필 조회 실패: ${e.message}');
      rethrow;
    }
  }

  /// API 연결 테스트
  Future<bool> testConnection() async {
    try {
      final response = await _apiClient.get('/');
      print('✅ 백엔드 연결 성공: ${response.data}');
      return true;
    } on DioException catch (e) {
      print('❌ 백엔드 연결 실패: ${e.message}');
      return false;
    }
  }
}

