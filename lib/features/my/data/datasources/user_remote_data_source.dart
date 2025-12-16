import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';

/// 사용자 관련 원격 데이터 소스
class UserRemoteDataSource {
  final ApiClient _apiClient = ApiClient();

  UserRemoteDataSource();

  /// 수면 패턴 업데이트
  ///
  /// [sleepPatternStart] 수면 시작 시간 (HH:MM)
  /// [sleepPatternEnd] 수면 종료 시간 (HH:MM)
  Future<Map<String, dynamic>> updateSleepPattern({
    required String userId,
    required String sleepPatternStart,
    required String sleepPatternEnd,
  }) async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.sleepPattern}';
      print('🚀 API 호출: $url');
      print('📦 파라미터: userId=$userId, start=$sleepPatternStart, end=$sleepPatternEnd');

      final response = await _apiClient.put(
        ApiConstants.sleepPattern,
        data: {
          'userId': userId,
          'sleepPatternStart': sleepPatternStart,
          'sleepPatternEnd': sleepPatternEnd,
        },
      );

      print('✅ 응답 성공: ${response.statusCode}');
      print('📄 응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to update sleep pattern: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException 발생 (수면 패턴 업데이트): ${e.type}');
      print('❌ 에러 메시지: ${e.message}');
      print('❌ 응답: ${e.response?.data}');
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      print('❌ 예상치 못한 에러 (수면 패턴 업데이트): $e');
      print('❌ 스택 트레이스: $stackTrace');
      throw Exception('Unexpected error: $e');
    }
  }

  /// 사용자 프로필 조회
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.userProfile}';
      print('🚀 API 호출: $url');

      final response = await _apiClient.get(ApiConstants.userProfile);

      print('✅ 응답 성공: ${response.statusCode}');
      print('📄 응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to get user profile: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException 발생 (프로필 조회): ${e.type}');
      print('❌ 에러 메시지: ${e.message}');
      print('❌ 응답: ${e.response?.data}');
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      print('❌ 예상치 못한 에러 (프로필 조회): $e');
      print('❌ 스택 트레이스: $stackTrace');
      throw Exception('Unexpected error: $e');
    }
  }

  /// 수면 패턴 조회
  Future<Map<String, dynamic>> getSleepPattern() async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.sleepPattern}';
      print('🚀 API 호출: $url');

      final response = await _apiClient.get(ApiConstants.sleepPattern);

      print('✅ 응답 성공: ${response.statusCode}');
      print('📄 응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        // 응답이 문자열인 경우 처리
        if (response.data is String) {
          return {'sleepPatternStart': response.data, 'sleepPatternEnd': response.data};
        }
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to get sleep pattern: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException 발생 (수면 패턴 조회): ${e.type}');
      print('❌ 에러 메시지: ${e.message}');
      print('❌ 응답: ${e.response?.data}');
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      print('❌ 예상치 못한 에러 (수면 패턴 조회): $e');
      print('❌ 스택 트레이스: $stackTrace');
      throw Exception('Unexpected error: $e');
    }
  }

  /// 로그아웃
  Future<String> logout() async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.logout}';
      print('🚀 API 호출: $url');

      final response = await _apiClient.post(ApiConstants.logout);

      print('✅ 응답 성공: ${response.statusCode}');
      print('📄 응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        return response.data is String ? response.data : response.data.toString();
      } else {
        throw Exception(
          'Failed to logout: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException 발생 (로그아웃): ${e.type}');
      print('❌ 에러 메시지: ${e.message}');
      print('❌ 응답: ${e.response?.data}');
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      print('❌ 예상치 못한 에러 (로그아웃): $e');
      print('❌ 스택 트레이스: $stackTrace');
      throw Exception('Unexpected error: $e');
    }
  }

  /// 이미지 파일 업로드 (URL 획득)
  Future<String> uploadImage(String imagePath) async {
    try {
      // TODO: 실제 업로드 엔드포인트 확인 필요. 임시로 '/upload' 사용.
      const uploadEndpoint = '/upload'; 
      final url = '${ApiConstants.baseUrl}$uploadEndpoint';
      print('🚀 이미지 업로드 API 호출: $url');

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
      });

      final response = await _apiClient.post(
        uploadEndpoint,
        data: formData,
      );

      print('✅ 업로드 성공: ${response.statusCode}');
      
      // 응답에서 URL 추출 (서버 응답 구조에 따라 수정 필요)
      // 예: { "url": "https://..." }
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic> && response.data['url'] != null) {
          return response.data['url'];
        }
        // 임시: 응답이 문자열 URL인 경우
        if (response.data is String) {
          return response.data;
        }
      }
      
      throw Exception('Invalid upload response');
    } catch (e) {
      print('❌ 이미지 업로드 실패: $e');
      // 테스트용: 실패 시에도 더미 URL 리턴 (개발 편의성)
      // return 'https://dummyimage.com/600x400/000/fff';
      rethrow;
    }
  }

  /// 프로필 사진 업데이트 (URL 전송)
  Future<Map<String, dynamic>> updateProfilePhoto(String userId, String photoUrl) async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.updateProfilePhoto}';
      print('🚀 프로필 사진 업데이트 API 호출: $url');
      print('📦 파라미터: userId=$userId, photoUrl=$photoUrl');

      final response = await _apiClient.put(
        ApiConstants.updateProfilePhoto,
        data: {
          'userId': userId,
          'photo_url': photoUrl,
        },
      );

      print('✅ 응답 성공: ${response.statusCode}');
      print('📄 응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to update profile photo: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException 발생 (프로필 사진 업데이트): ${e.type}');
      print('❌ 에러 메시지: ${e.message}');
      print('❌ 응답: ${e.response?.data}');
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      print('❌ 예상치 못한 에러 (프로필 사진 업데이트): $e');
      print('❌ 스택 트레이스: $stackTrace');
      throw Exception('Unexpected error: $e');
    }
  }

  /// Dio 에러 핸들링
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Connection timeout');
      case DioExceptionType.sendTimeout:
        return Exception('Send timeout');
      case DioExceptionType.receiveTimeout:
        return Exception('Receive timeout');
      case DioExceptionType.badResponse:
        return Exception('Bad response: ${e.response?.statusCode}');
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      case DioExceptionType.connectionError:
        return Exception('Connection error');
      default:
        return Exception('Network error: ${e.message}');
    }
  }
}
