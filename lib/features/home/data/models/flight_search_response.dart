/// 항공편 검색 응답의 항공사 정보
class FlightAirlineInfo {
  final String airlineName;
  final String? logoUrl;
  final int totalReviews;
  final double overallRating;
  final String? alliance;
  final String? type;
  final String? country;

  FlightAirlineInfo({
    required this.airlineName,
    this.logoUrl,
    required this.totalReviews,
    required this.overallRating,
    this.alliance,
    this.type,
    this.country,
  });

  factory FlightAirlineInfo.fromJson(Map<String, dynamic> json) {
    return FlightAirlineInfo(
      airlineName: json['airlineName'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
      totalReviews: json['totalReviews'] as int? ?? 0,
      overallRating: (json['overallRating'] as num?)?.toDouble() ?? 0.0,
      alliance: json['alliance'] as String?,
      type: json['type'] as String?,
      country: json['country'] as String?,
    );
  }
}

/// 단일 항공편 정보 (카드에 표시될 데이터)
class FlightSearchData {
  final FlightAirline airline;
  final FlightEndpoint departure;
  final FlightEndpoint arrival;
  final int layoverDuration; // 경유 대기 시간 (분 단위)
  final int duration; // 분 단위
  final String flightNumber;
  final List<FlightSegment>? segments; // 복구
  final String date; // 복구 (표시용 날짜)
  final double ratingScore; // 변경된 필드 유지
  final int reviewCountNum; // 변경된 필드 유지

  FlightSearchData({
    required this.airline,
    required this.departure,
    required this.arrival,
    required this.duration,
    required this.layoverDuration, // 추가
    required this.flightNumber,
    this.segments,
    required this.date,
    this.ratingScore = 0.0,
    this.reviewCountNum = 0,
  }) {
    // [DEBUG] 생성자 값 확인
    if (ratingScore > 0) print('✨ FlightSearchData Created: val=$ratingScore');
  }

  // existing fromJson kept for compatibility/tests if needed, but delegating
  factory FlightSearchData.fromJson(Map<String, dynamic> json) {
    return FlightSearchData.fromMap(json);
  }

  factory FlightSearchData.fromMap(Map<String, dynamic> json, {Map<String, String>? airlineLogos}) {
    // 디버그 로그 제거됨 -> 복구하여 확인
    // print('🔍 Parsing Flight: ${json['operating_carrier']}');
    // print('🔍 Keys: ${json.keys.toList()}');
    if (json.containsKey('overall_rating')) {
       print('🔍 overall_rating found: ${json['overall_rating']} (Type: ${json['overall_rating'].runtimeType})');
    } else {
       print('⚠️ overall_rating MISSING in this item');
    }
    
    // segments가 있으면 첫 번째 세그먼트의 출발, 마지막 세그먼트의 도착 정보를 사용
    final segmentsList = (json['segments'] as List<dynamic>?)
        ?.map((e) => FlightSegment.fromJson(e as Map<String, dynamic>))
        .toList();
    
    FlightEndpoint depEndpoint;
    FlightEndpoint arrEndpoint;
    
    if (segmentsList != null && segmentsList.isNotEmpty) {
        final first = segmentsList.first;
        final last = segmentsList.last;
        depEndpoint = FlightEndpoint(airport: first.departureAirport, time: first.departureTime);
        arrEndpoint = FlightEndpoint(airport: last.arrivalAirport, time: last.arrivalTime);
    } else {
        depEndpoint = FlightEndpoint(airport: '', time: '');
        arrEndpoint = FlightEndpoint(airport: '', time: '');
    }

    var rawDuration = json['total_duration'] ?? json['duration'];
    int parsedDuration = _parseDuration(rawDuration);
    
    // 세그먼트 비행 시간 합계 및 경유 대기 시간 계산
    int totalSegmentDuration = 0;
    int calculatedLayover = 0;
    
    if (segmentsList != null && segmentsList.isNotEmpty) {
      for (int i = 0; i < segmentsList.length; i++) {
        // 1. 비행 시간 합산
        totalSegmentDuration += _parseDuration(segmentsList[i].duration);
        
        // 2. 경유 대기 시간 합산 (같은 공항이므로 로컬 시간 차이 계산 가능)
        if (i < segmentsList.length - 1) {
          try {
            final currentArr = DateTime.parse(segmentsList[i].arrivalTime);
            final nextDep = DateTime.parse(segmentsList[i+1].departureTime);
            final diff = nextDep.difference(currentArr).inMinutes;
            
            // 대기 시간이 음수이거나 너무 길면 오류일 수 있으나, 일반적으로는 양수
            if (diff > 0) {
              calculatedLayover += diff;
            }
          } catch (e) {
            print('⚠️ Layover calculation failed: $e');
          }
        }
      }
    }
    
    // 🚀 [수정] Total Duration = 비행 시간 합계 + 대기 시간 합계
    // 시차가 있는 공항 간의 단순 차이(Arrival - Departure)는 부정확하므로 이 방식이 가장 정확함
    if (totalSegmentDuration > 0) {
      parsedDuration = totalSegmentDuration + calculatedLayover;
      print('✅ Final Duration: Flight($totalSegmentDuration) + Layover($calculatedLayover) = $parsedDuration');
    }

    // 디버깅용 (빌드 후 로그 확인)
    if (parsedDuration == 0) {
        print('⚠️ Duration parsing still failed. Fallback to start/end diff if available.');
        // 이미 위에서 계산했으므로 여기는 최후의 수단
        if (depEndpoint.time.isNotEmpty && arrEndpoint.time.isNotEmpty) {
          try {
            final start = DateTime.parse(depEndpoint.time);
            final end = DateTime.parse(arrEndpoint.time);
            parsedDuration = end.difference(start).inMinutes;
          } catch (_) {}
        }
    }
    
    String? logoUrl = json['logo_symbol_url'] as String?;
    String carrierCode = json['operating_carrier'] as String? ?? '';
    if (logoUrl == null || logoUrl.isEmpty) {
        if (carrierCode.isEmpty && segmentsList != null && segmentsList.isNotEmpty) {
          carrierCode = segmentsList.first.carrierCode;
        }
        logoUrl = airlineLogos?[carrierCode] ?? 'https://pic.sopoo.kr/upload/1.png';
    }

    return FlightSearchData(
      airline: FlightAirline(
          name: carrierCode, 
          logo: logoUrl
      ), 
      departure: depEndpoint,
      arrival: arrEndpoint,
      duration: parsedDuration,
      layoverDuration: calculatedLayover, // 대기 시간 추가
      flightNumber: json['flight_number'] ?? _parseFlightNumber(json),
      segments: segmentsList,
      date: '', 
      // 필드명 변경 적용, 정상 파싱 로직 사용
      ratingScore: double.tryParse(json['overall_rating']?.toString() ?? '') ?? 0.0,
      reviewCountNum: int.tryParse(json['total_reviews']?.toString() ?? '') ?? 0,
    );
  }

  static int _parseDuration(dynamic duration) {
    if (duration is int) return duration;
    if (duration is String) {
      // PT14H30M or 14H30M format
      String d = duration.toUpperCase();
      if (d.startsWith('PT')) d = d.substring(2);
      
      int days = 0;
      int hours = 0;
      int minutes = 0;
      
      final dMatch = RegExp(r'(\d+)\s*D').firstMatch(d);
      if (dMatch != null) {
        days = int.parse(dMatch.group(1)!);
      }

      final hMatch = RegExp(r'(\d+)\s*H').firstMatch(d);
      if (hMatch != null) {
        hours = int.parse(hMatch.group(1)!);
      }
      
      final mMatch = RegExp(r'(\d+)\s*M').firstMatch(d);
      if (mMatch != null) {
        minutes = int.parse(mMatch.group(1)!);
      }
      
      return (days * 24 * 60) + (hours * 60) + minutes;
    }
    return 0;
  }
  
  static String _parseFlightNumber(Map<String, dynamic> json) {
    // API 구조에 따라 다름. 여기서는 itineraras -> segments -> [0] -> carrierCode + number 조합 가정
    try {
      if (json['itineraries'] != null) {
        final segments = json['itineraries'][0]['segments'] as List;
        if (segments.isNotEmpty) {
           final first = segments[0];
           return '${first['carrierCode']}${first['number']}';
        }
      }
    } catch (_) {}
    return '';
  }
}

class FlightAirline {
  final String name;
  final String logo;

  FlightAirline({required this.name, required this.logo});

  factory FlightAirline.fromJson(Map<String, dynamic> json) {
    return FlightAirline(
      name: json['name'] ?? '',
      logo: json['logo'] ?? '', // 실제 API 응답에 맞춰 수정 필요
    );
  }
}

class FlightEndpoint {
  final String airport;
  final String time;

  FlightEndpoint({required this.airport, required this.time});

  factory FlightEndpoint.fromJson(Map<String, dynamic> json) {
    return FlightEndpoint(
      airport: json['iataCode'] ?? '',
      time: json['at'] ?? '',
    );
  }
}

class FlightSegment {
  final String departureAirport;
  final String arrivalAirport;
  final String departureTime;
  final String arrivalTime;
  final String carrierCode;
  final String number;
  final String duration;

  FlightSegment({
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureTime,
    required this.arrivalTime,
    required this.carrierCode,
    required this.number,
    required this.duration,
  });

  factory FlightSegment.fromJson(Map<String, dynamic> json) {
    return FlightSegment(
      departureAirport: json['departure']?['iata_code'] ?? '',
      arrivalAirport: json['arrival']?['iata_code'] ?? '',
      departureTime: json['departure']?['at'] ?? '',
      arrivalTime: json['arrival']?['at'] ?? '',
      carrierCode: json['operating_carrier'] ?? '',
      number: json['flight_number'] ?? '',
      duration: json['duration'] ?? '',
    );
  }
}

/// 항공편 검색 응답 모델
class FlightSearchResponse {
  final List<FlightAirlineInfo> airlines;
  final int count;
  final List<FlightSearchData> data; // flightOffers -> data (type safe)

  FlightSearchResponse({
    required this.airlines,
    required this.count,
    required this.data,
  });

  factory FlightSearchResponse.fromJson(Map<String, dynamic> json) {
    // 1. 항공사 로고 맵 생성
    final airlineLogos = <String, String>{};
    final rawAirlines = json['airlines'] as List<dynamic>?;
    if (rawAirlines != null) {
      for (final item in rawAirlines) {
        final logo = item['logo_url'] as String?;
        if (logo != null) {
            final code = item['code'] as String?;
            final id = item['id'] as String?;
            
            if (code != null) airlineLogos[code] = logo;
            if (id != null) airlineLogos[id] = logo;
        }
      }
    }

    // 2. 결과 파싱 (로고 맵 전달)
    final rawResults = json['results'] as List<dynamic>? ?? [];
    
    final flightDataList = rawResults.map((e) {
        return FlightSearchData.fromMap(e as Map<String, dynamic>, airlineLogos: airlineLogos);
    }).toList();

    return FlightSearchResponse(
      airlines: (rawAirlines?.map((e) => FlightAirlineInfo.fromJson(e)).toList()) ?? [],
      count: json['count'] as int? ?? 0,
      data: flightDataList,
    );
  }
}
