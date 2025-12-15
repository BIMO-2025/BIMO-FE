import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/airport_keyword_mapper.dart';
import '../../../home/domain/models/airport.dart';
import '../../../home/data/models/flight_search_response.dart';

/// 비행 관련 데이터 리포지토리
class FlightRepository {
  final Dio _dio;

  FlightRepository({Dio? dio})
      : _dio = dio ??
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

  /// 공항 검색 (한글 지원)
  ///
  /// [query] 검색어 (예: "서울", "New York")
  /// 내부적으로 [AirportKeywordMapper]를 사용하여 한글을 영어로 변환 후 API 호출
  Future<List<Airport>> searchAirports(String query) async {
    try {
      // 1-1. 초성 검색 확인
      if (AirportKeywordMapper.isChosung(query)) {
        final matches = AirportKeywordMapper.getChosungMatches(query);
        print('🔍 초성 검색: "$query" -> $matches');
        
        // 매칭된 키워드를 '제안' 형태의 Airport 객체로 변환하여 반환
        return matches.map((keyword) {
          // 키워드(한글)로 영어 변환 (표시용)
          final englishName = AirportKeywordMapper.mapToEnglish(keyword); 
          
          return Airport(
            airportCode: '', // 코드는 없음 (제안이므로)
            cityName: keyword, // 한글 키워드 (예: "영국")
            cityCode: '', 
            airportName: englishName, // 영어 이름 (예: "United Kingdom")
            country: '', 
            locationType: 'SUGGESTION', // 제안 타입
          );
        }).toList();
      }

      // 1-2. 매퍼를 통해 한글 -> 영어 변환
      final String mappedQuery = AirportKeywordMapper.mapToEnglish(query);
      print('🔍 공항 검색: "$query" -> "$mappedQuery"');

      // 2. API 호출
      final response = await _dio.get(
        ApiConstants.searchAirportIATA,
        queryParameters: {'location': mappedQuery},
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'] as List<dynamic>;
        
        return results.map((json) {
          final englishCity = json['city'] ?? '';
          final englishName = json['name'] ?? '';
          final iataCode = json['iata_code'] ?? '';
          
          // 한글로 변환 (표시용)
          final koreanCity = AirportKeywordMapper.convertToKorean(englishCity);
          final koreanName = AirportKeywordMapper.convertToKorean(englishName);
          
          // 국가 정보 추론 (API가 null을 주므로 도시/공항명 기반으로 채움)
          String country = '';
          if (['Seoul', 'Incheon', 'Busan', 'Jeju', 'Gimpo'].contains(englishCity) || 
              ['ICN', 'GMP', 'PUS', 'CJU'].contains(iataCode)) {
            country = '대한민국';
          } else if (['New York', 'Los Angeles', 'Chicago', 'Atlanta', 'Dallas', 'Seattle', 'San Francisco', 'Las Vegas', 'Honolulu', 'Guam', 'Boise', 'Knoxville', 'Tampa', 'Amarillo', 'Lanai'].contains(englishCity)) {
            country = '미국';
          } else if (['Tokyo', 'Osaka', 'Fukuoka', 'Sapporo', 'Okinawa', 'Nagoya'].contains(englishCity)) {
            country = '일본';
          } else if (['Beijing', 'Shanghai', 'Hong Kong'].contains(englishCity)) {
            country = '중국';
          } else if (['London'].contains(englishCity)) {
            country = '영국';
          } else if (['Paris'].contains(englishCity)) {
            country = '프랑스';
          } else if (['Bangkok'].contains(englishCity)) {
            country = '태국';
          } else if (['Vietnam', 'Da Nang', 'Hanoi', 'Ho Chi Minh'].contains(englishCity)) {
            country = '베트남';
          } else {
             // 기본값 (해외)
             country = '해외'; 
          }

          return Airport(
            airportCode: iataCode,
            cityName: koreanCity, // 한글 도시명
            cityCode: '', 
            airportName: koreanName, // 한글 공항명
            country: country, // 추론된 국가명
            locationType: 'AIRPORT',
          );
        }).toList();
      } else {
        throw Exception('Failed to search airports: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 공항 검색 실패: $e');
      rethrow;
    }
  }

  /// 항공편 검색
  Future<FlightSearchResponse> searchFlights({
    required String origin,
    required String destination,
    required String departureDate,
    int adults = 1,
  }) async {
    try {
      print('🔍 항공편 검색: $origin -> $destination ($departureDate)');
      
      final response = await _dio.post(
        ApiConstants.flightsSearch,
        data: {
          'origin': origin,
          'destination': destination,
          'departure_date': departureDate,
          'adults': adults,
        },
      );

      if (response.statusCode == 200) {
        return FlightSearchResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to search flights: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 항공편 검색 실패: $e');
      rethrow;
    }
  }
}
