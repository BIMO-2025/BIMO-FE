import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/popular_airline_response.dart';
import '../models/flight_search_response.dart';
import '../models/location_search_response.dart';
import '../models/airline_sorting_response.dart';

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

  /// 항공사 이름으로 검색
  ///
  /// [query] 검색어 (항공사 이름)
  Future<List<PopularAirlineResponse>> searchAirlines({
    required String query,
  }) async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.airlinesSearch}';
      print('🚀 API 호출: $url');
      print('📦 파라미터: query=$query');

      final response = await _dio.get(
        ApiConstants.airlinesSearch,
        queryParameters: {'query': query},
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
          'Failed to search airlines: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException 발생 (항공사 검색): ${e.type}');
      print('❌ 에러 메시지: ${e.message}');
      print('❌ 응답: ${e.response?.data}');
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      print('❌ 예상치 못한 에러 (항공사 검색): $e');
      print('❌ 스택 트레이스: $stackTrace');
      throw Exception('Unexpected error: $e');
    }
  }

  /// 항공편 검색 (목적지 기반)
  ///
  /// [origin] 출발 공항 코드 (예: ICN)
  /// [destination] 도착 공항 코드 (예: LHR)
  /// [departureDate] 출발 날짜 (YYYY-MM-DD)
  /// [adults] 성인 승객 수 (기본값: 1)
  Future<FlightSearchResponse> searchFlights({
    required String origin,
    required String destination,
    required String departureDate,
    int adults = 1,
  }) async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.flightsSearch}';
      print('🚀 API 호출: $url');
      print('📦 파라미터: origin=$origin, destination=$destination, departureDate=$departureDate, adults=$adults');

      final response = await _dio.post(
        ApiConstants.flightsSearch,
        data: {
          'origin': origin,
          'destination': destination,
          'departure_date': departureDate,
          'adults': adults,
        },
      );

      print('✅ 응답 성공: ${response.statusCode}');
      print('📄 응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        return FlightSearchResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw Exception(
          'Failed to search flights: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException 발생 (항공편 검색): ${e.type}');
      print('❌ 에러 메시지: ${e.message}');
      print('❌ 응답: ${e.response?.data}');
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      print('❌ 예상치 못한 에러 (항공편 검색): $e');
      print('❌ 스택 트레이스: $stackTrace');
      throw Exception('Unexpected error: $e');
    }
  }

  /// 공항/도시 검색
  ///
  /// [keyword] 검색어 (예: "Seoul", "JFK", "London")
  Future<LocationSearchResponse> searchLocations({
    required String keyword,
  }) async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.locationsSearch}';
      print('🚀 API 호출: $url');
      print('📦 파라미터: keyword=$keyword');

      final response = await _dio.get(
        ApiConstants.locationsSearch,
        queryParameters: {'keyword': keyword},
      );

      print('✅ 응답 성공: ${response.statusCode}');
      print('📄 응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        return LocationSearchResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw Exception(
          'Failed to search locations: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException 발생 (공항 검색): ${e.type}');
      print('❌ 에러 메시지: ${e.message}');
      print('❌ 응답: ${e.response?.data}');
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      print('❌ 예상치 못한 에러 (공항 검색): $e');
      print('❌ 스택 트레이스: $stackTrace');
      throw Exception('Unexpected error: $e');
    }
  }

  /// 평점 순으로 정렬된 항공사 목록 조회
  Future<List<AirlineSortingResponse>> getSortedAirlines() async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.airlinesSorting}';
      print('🚀 API 호출: $url');

      final response = await _dio.get(ApiConstants.airlinesSorting);

      print('✅ 응답 성공: ${response.statusCode}');
      print('📄 응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => AirlineSortingResponse.fromJson(
                  json as Map<String, dynamic>,
                ))
            .toList();
      } else {
        throw Exception(
          'Failed to get sorted airlines: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException 발생 (정렬 항공사): ${e.type}');
      print('❌ 에러 메시지: ${e.message}');
      print('❌ 응답: ${e.response?.data}');
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      print('❌ 예상치 못한 에러 (정렬 항공사): $e');
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
