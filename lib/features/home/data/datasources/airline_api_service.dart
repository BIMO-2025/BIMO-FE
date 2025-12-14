import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/popular_airline_response.dart';

/// 항공사 API 서비스
class AirlineApiService {
  final Dio _dio;

  AirlineApiService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          );

  /// 주차별 인기 항공사 조회
  ///
  /// [year] 연도 (예: 2024)
  /// [month] 월 (1-12)
  /// [week] 주차 (1주차=1~7일, 2주차=8~14일...)
  /// [limit] 조회할 개수 (기본값: 3)
  Future<List<PopularAirlineResponse>> getPopularAirlinesWeekly({
    required int year,
    required int month,
    required int week,
    int limit = 3,
  }) async {
    try {
      final url =
          '${ApiConstants.baseUrl}${ApiConstants.airlinesPopularWeekly}';
      print('🚀 API 호출: $url');
      print('📦 파라미터: year=$year, month=$month, week=$week, limit=$limit');

      final response = await _dio.get(
        ApiConstants.airlinesPopularWeekly,
        queryParameters: {
          'year': year,
          'month': month,
          'week': week,
          'limit': limit,
        },
      );

      print('✅ 응답 성공: ${response.statusCode}');
      print('📄 응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map(
              (json) =>
                  PopularAirlineResponse.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception(
          'Failed to load popular airlines: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException 발생: ${e.type}');
      print('❌ 에러 메시지: ${e.message}');
      print('❌ 응답: ${e.response?.data}');
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      print('❌ 예상치 못한 에러: $e');
      print('❌ 스택 트레이스: $stackTrace');
      throw Exception('Unexpected error: $e');
    }
  }

  /// 전체 인기 항공사 조회 (리뷰 수 기준)
  ///
  /// [limit] 조회할 개수 (기본값: 5)
  Future<List<PopularAirlineResponse>> getPopularAirlines({
    int limit = 5,
  }) async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.airlinesPopular}';
      print('🚀 API 호출: $url');
      print('📦 파라미터: limit=$limit');

      final response = await _dio.get(
        ApiConstants.airlinesPopular,
        queryParameters: {'limit': limit},
      );

      print('✅ 응답 성공: ${response.statusCode}');
      print('📄 응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map(
              (json) =>
                  PopularAirlineResponse.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception(
          'Failed to load popular airlines: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // 404는 데이터 없음으로 처리하여 빈 리스트 반환 (또는 UI에서 기본값 표시하도록 유도)
      if (e.response?.statusCode == 404) {
        print('⚠️ 인기 항공사 데이터 없음 (404) -> 빈 리스트 반환');
        return [];
      }
      
      print('❌ DioException 발생 (전체 인기 항공사): ${e.type}');
      print('❌ 에러 메시지: ${e.message}');
      print('❌ 응답: ${e.response?.data}');
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      print('❌ 예상치 못한 에러 (전체 인기 항공사): $e');
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
