import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/airport_keyword_mapper.dart';
import '../../../home/domain/models/airport.dart';
import '../../../home/data/models/flight_search_response.dart';
import '../models/create_flight_request.dart';
import '../models/timeline_request.dart';

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

  String _inferCountry(String englishCity, String iataCode) {
    if (['Seoul', 'Incheon', 'Busan', 'Jeju', 'Gimpo'].contains(englishCity) || 
        ['ICN', 'GMP', 'PUS', 'CJU'].contains(iataCode)) {
      return '대한민국';
    } else if (['New York', 'Los Angeles', 'Chicago', 'Atlanta', 'Dallas', 'Seattle', 'San Francisco', 'Las Vegas', 'Honolulu', 'Guam', 'Boise', 'Knoxville', 'Tampa', 'Amarillo', 'Lanai'].contains(englishCity)) {
      return '미국';
    } else if (['Tokyo', 'Osaka', 'Fukuoka', 'Sapporo', 'Okinawa', 'Nagoya', 
                'Sendai', 'Kochi', 'Kagoshima', 'Hiroshima', 'Hakodate', 'Hachijojima', 'Takamatsu', 'Toyama', 'Komatsu', 'Shizuoka', 'Okayama', 'Kumamoto'].contains(englishCity)) {
      return '일본';
    } else if (['Beijing', 'Shanghai', 'Hong Kong', 'Macau'].contains(englishCity)) {
      return '중국';
    } else if (['London'].contains(englishCity)) {
      return '영국';
    } else if (['Paris'].contains(englishCity)) {
      return '프랑스';
    } else if (['Bangkok', 'Chiang Mai', 'Phuket'].contains(englishCity)) {
      return '태국';
    } else if (['Vietnam', 'Da Nang', 'Hanoi', 'Ho Chi Minh', 'Nha Trang'].contains(englishCity)) {
      return '베트남';
    } else if (['Singapore'].contains(englishCity)) {
      return '싱가포르';
    } else if (['Manila', 'Cebu', 'Boracay'].contains(englishCity)) {
      return '필리핀';
    } else if (['Jakarta', 'Bali'].contains(englishCity)) {
      return '인도네시아';
    } else if (['Sydney', 'Melbourne', 'Brisbane'].contains(englishCity)) {
      return '호주';  
    } else {
       return '해외'; 
    }
  }

  /// 공항 검색 (한글 지원 및 다중 국가 검색 확장)
  Future<List<Airport>> searchAirports(String query) async {
    try {
      List<Airport> localResults = [];
      
      // 1. 로컬 접두사 매칭 (즉시 결과 표시용)
      // 예: "미" -> "미국", "미얀마", "미주리"
      final prefixMatches = AirportKeywordMapper.getPrefixMatches(query);
      
      // API 검색을 위한 영어 쿼리 목록
      final Set<String> englishQueries = {};
      
      // 기본 쿼리 매핑값 추가 (예: "미" -> "United States")
      final String mappedQuery = AirportKeywordMapper.mapToEnglish(query);
      if (mappedQuery.isNotEmpty) {
          englishQueries.add(mappedQuery);
      }
      
      if (prefixMatches.isNotEmpty) {
        localResults = prefixMatches.entries.map((entry) {
          final koreanName = entry.key; // 예: "미국"
          final englishName = entry.value; // 예: "United States"
          
          // API 검색 목록에 추가 (확장 검색)
          // 예: "미국"이 매칭되면 "United States"로 API 검색하여 하위 공항 가져오기
          englishQueries.add(englishName);
          
          final isCountry = AirportKeywordMapper.isCountryKey(koreanName);
          
          return Airport(
            airportCode: '', 
            cityName: koreanName, 
            cityCode: '', 
            airportName: englishName, 
            country: '', 
            locationType: isCountry ? 'COUNTRY' : 'CITY', 
            type: isCountry ? SearchResultType.COUNTRY : SearchResultType.CITY, 
          );
        }).toList();
        
        print('🔍 로컬 프리픽스 매칭: "$query" -> ${prefixMatches.keys}');
      }
      
      // 1-1. 초성 검색 제거 (요청사항 반영)
      // if (AirportKeywordMapper.isChosung(query)) { ... }

      // 2. API 호출 (병렬 처리)
      List<Airport> apiResults = [];
      
      if (englishQueries.isNotEmpty) {
          print('🔍 공항 검색 API 요청 (다중): $englishQueries');
          
          // 최대 3개까지만 제한하여 API 과부하 방지 (예: 너무 많은 매칭이 있을 경우)
          final queriesToSearch = englishQueries.take(3).toList();
          
          final futures = queriesToSearch.map((q) => _searchApi(q));
          final results = await Future.wait(futures);
          
          for (var list in results) {
              apiResults.addAll(list);
          }
      }

      // 3. 결과 그룹화 및 계층화 로직은 그대로 유지 (하단 코드)


      // 3. 결과 그룹화 및 계층화
      // Map<Country, Map<City, List<Airport>>>
      final Map<String, Map<String, List<Airport>>> groupedMap = {};
      
      // API 결과 기반으로 그룹핑
      for (var airport in apiResults) {
        if (airport.country.isEmpty) continue;
        
        groupedMap.putIfAbsent(airport.country, () => {});
        groupedMap[airport.country]!.putIfAbsent(airport.cityName, () => []);
        groupedMap[airport.country]![airport.cityName]!.add(airport);
      }
      
      final List<Airport> finalStructuredList = [];

      final Set<String> processedCountries = {};
      
      // 1순위: 로컬 프리픽스 매칭된 국가들의 그룹
      for (var local in localResults) {
         if (local.type == SearchResultType.COUNTRY) {
             final countryName = local.cityName; 
             if (groupedMap.containsKey(countryName)) {
                 _addCountryGroup(finalStructuredList, countryName, groupedMap[countryName]!);
                 processedCountries.add(countryName);
             } else {
                 finalStructuredList.add(local);
             }
         }
      }
      
      // 2순위: 나머지 그룹들
      groupedMap.forEach((country, cityMap) {
          if (!processedCountries.contains(country)) {
              _addCountryGroup(finalStructuredList, country, cityMap);
          }
      });
      
      // 3순위: 그룹핑되지 못한 나머지 API 결과들 (혹시 모를 예외 처리)
      // (여기선 생략, 대부분 country가 있을 것으로 가정)
      
      return finalStructuredList;
      
    } catch (e) {
      print('❌ 공항 검색 메소드 실패: $e');
      rethrow;
    }
  }

  void _addCountryGroup(List<Airport> list, String country, Map<String, List<Airport>> cityMap) {
      // Country Header
      list.add(Airport(
          cityName: country,
          cityCode: '',
          airportName: '',
          airportCode: '',
          country: country,
          locationType: 'COUNTRY',
          type: SearchResultType.COUNTRY
      ));
      
      cityMap.forEach((city, airports) {
          // City Header
          list.add(Airport(
              cityName: city,
              cityCode: airports.isNotEmpty ? airports.first.cityCode : '', 
              airportName: '',
              airportCode: '',
              country: country,
              locationType: 'CITY',
              type: SearchResultType.CITY
          ));
          
          // Airports
          for (var airport in airports) {
              list.add(Airport(
                  cityName: airport.cityName,
                  cityCode: airport.cityCode,
                  airportName: airport.airportName,
                  airportCode: airport.airportCode,
                  country: airport.country,
                  locationType: 'AIRPORT',
                  type: SearchResultType.AIRPORT
              ));
          }
      });
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
          'departure': origin,
          'arrive': destination,
          'departure_date': departureDate,
          // 'adults': adults, // 사용자 제보 기반으로 adults 제외 시도 (혹은 필요 시 포함)
          // 일단 키 이름 변경이 매뉴얼에 가까워 보임
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




  /// 내부 API 검색 헬퍼
  Future<List<Airport>> _searchApi(String mappedQuery) async {
    try {
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
            
            // 국가 정보 추론
            String country = _inferCountry(englishCity, iataCode);

            // API 결과 타입 설정
            final apiLocationType = json['locationType'] ?? 'AIRPORT'; 
            SearchResultType type = SearchResultType.AIRPORT;
            if (apiLocationType == 'CITY') type = SearchResultType.CITY;

            return Airport(
              airportCode: iataCode,
              cityName: koreanCity, 
              cityCode: '', 
              airportName: koreanName, 
              country: country, 
              locationType: apiLocationType,
              type: type,
            );
          }).toList();
        }
        return [];
    } catch (e) {
      print('API search failed for "$mappedQuery": $e');
      return [];
    }
  }

  /// 비행 저장
  /// POST /users/{userId}/my-flights
  Future<void> saveFlight(String userId, CreateFlightRequest request) async {
    try {
      print('🚀 비행 저장 API 호출: /users/$userId/my-flights');
      print('📦 Request Body: ${request.toJson()}');
      
      final response = await _dio.post(
        '/users/$userId/my-flights',
        data: request.toJson(),
      );
      
      if (response.statusCode == 201) {
        print('✅ 비행 저장 성공');
      } else {
        throw Exception('비행 저장 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 비행 저장 에러: $e');
      rethrow;
    }
  }

  /// 타임라인 생성
  /// POST /wellness/flight-timeline
  Future<void> generateTimeline(TimelineRequest request) async {
    try {
      print('🚀 타임라인 생성 API 호출: /wellness/flight-timeline');
      print('📦 Request Body: ${request.toJson()}');
      
      final response = await _dio.post(
        '/wellness/flight-timeline',
        data: request.toJson(),
      );
      
      if (response.statusCode == 200) {
        print('✅ 타임라인 생성 성공');
      } else {
        throw Exception('타임라인 생성 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 타임라인 생성 에러: $e');
      rethrow;
    }
  }
}
