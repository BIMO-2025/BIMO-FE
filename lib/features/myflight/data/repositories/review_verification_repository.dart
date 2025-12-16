
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

class ReviewVerificationRepository {
  final ApiClient _apiClient = ApiClient();

  /// 티켓 이미지 인증 요청
  /// [imagePaths]: 이미지 파일 경로 리스트
  /// Returns: 인증 성공 여부 (true/false)
  Future<bool> verifyTicket(List<String> imagePaths) async {
    try {
      final formData = FormData();

      // 파일 추가
      for (final path in imagePaths) {
        // 파일명 추출
        final fileName = path.split('/').last;
        
        formData.files.add(MapEntry(
          'images',
          await MultipartFile.fromFile(
            path,
            filename: fileName,
          ),
        ));
      }

      print('🚀 티켓 인증 요청 시작: ${imagePaths.length}개 파일');
      
      final response = await _apiClient.post(
        '/reviews/verify',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print('✅ 티켓 인증 응답: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final isVerified = data['isVerified'] as bool? ?? false;
          print('🎫 인증 결과: $isVerified');
          return isVerified;
        }
      }
      
      return false;
    } catch (e) {
      print('❌ 티켓 인증 오류: $e');
      if (e is DioException) {
        print('❌ 응답 데이터: ${e.response?.data}');
      }
      return false;
    }
  }
}
