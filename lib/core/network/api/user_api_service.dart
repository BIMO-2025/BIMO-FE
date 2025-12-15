import 'dart:io';
import 'package:dio/dio.dart';
import '../api_client.dart';
import '../../storage/auth_token_storage.dart';

class UserApiService {
  final ApiClient _apiClient = ApiClient();
  final AuthTokenStorage _tokenStorage = AuthTokenStorage();

  UserApiService();

  /// 닉네임 변경 API
  Future<Map<String, dynamic>> updateNickname(String newNickname) async {
    try {
      final response = await _apiClient.put(
        '/user/nickname',
        data: {
          'nickname': newNickname,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update nickname: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // 서버 에러 응답 처리
        final errorData = e.response?.data;
        final message = errorData is Map ? errorData['detail'] ?? errorData['message'] : e.message;
        throw Exception(message);
      }
      throw Exception('네트워크 오류가 발생했습니다.');
    } catch (e) {
      throw Exception('예기치 않은 오류가 발생했습니다: $e');
    }
  }

  /// 프로필 사진 업로드 API
  Future<Map<String, dynamic>> updateProfileImage(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "profile_image": await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      // TODO: 백엔드 API 엔드포인트 확인 필요 (임시: /user/profile-image)
      final response = await _apiClient.put(
        '/user/profile-image', 
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to upload profile image: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        final message = errorData is Map ? errorData['detail'] ?? errorData['message'] : e.message;
        throw Exception(message);
      }
      throw Exception('네트워크 오류가 발생했습니다.');
    } catch (e) {
      throw Exception('예기치 않은 오류가 발생했습니다: $e');
    }
  }
}
