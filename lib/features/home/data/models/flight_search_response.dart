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
  final int duration; // 분 단위
  final String flightNumber;
  final List<FlightSegment>? segments;
  final String date; // 표시용 날짜

  FlightSearchData({
    required this.airline,
    required this.departure,
    required this.arrival,
    required this.duration,
    required this.flightNumber,
    this.segments,
    required this.date,
  });

  factory FlightSearchData.fromJson(Map<String, dynamic> json) {
    return FlightSearchData(
      airline: FlightAirline.fromJson(json['airline'] ?? {}),
      departure: FlightEndpoint.fromJson(json['departure'] ?? {}),
      arrival: FlightEndpoint.fromJson(json['arrival'] ?? {}),
      duration: _parseDuration(json['duration']),
      flightNumber: _parseFlightNumber(json),
      segments: (json['itineraries'] != null && (json['itineraries'] as List).isNotEmpty)
          ? ((json['itineraries'][0]['segments'] as List?)
              ?.map((e) => FlightSegment.fromJson(e))
              .toList())
          : null,
      date: json['lastTicketingDate'] ?? '', // TODO: 적절한 날짜 필드 매핑 필요
    );
  }

  static int _parseDuration(dynamic duration) {
    if (duration is int) return duration;
    if (duration is String) {
      // PT13H50M 형식 파싱 필요시 구현, 여기서는 임시로 0 처리
      return 0;
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
      departureAirport: json['departure']?['iataCode'] ?? '',
      arrivalAirport: json['arrival']?['iataCode'] ?? '',
      departureTime: json['departure']?['at'] ?? '',
      arrivalTime: json['arrival']?['at'] ?? '',
      carrierCode: json['carrierCode'] ?? '',
      number: json['number'] ?? '',
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
    // API 응답 구조가 Amadeus Flight Offers Search와 유사하다고 가정
    // 하지만 사용자의 코드는 'flight_offers' 키를 사용함
    
    final rawOffers = json['flight_offers'] as List<dynamic>? ?? [];
    
    // API 응답을 내부 모델 형식으로 변환하는 로직이 필요할 수 있음
    // 여기서는 rawOffers를 직접 파싱하기보다, 
    // 기존 코드의 데이터 구조에 맞추기 위해 더미 매핑을 하거나 
    // 실제 API 응답을 확인해야 함.
    // 임시로 rawOffers를 FlightSearchData로 변환 시도
    
    final flightDataList = rawOffers.map((e) {
        // Amadeus 응답 구조라고 가정하고 매핑
        return FlightSearchData(
            airline: FlightAirline(name: 'Airline', logo: 'https://pic.sopoo.kr/upload/1.png'), // 더미
            departure: FlightEndpoint(
                airport: e['itineraries'][0]['segments'][0]['departure']['iataCode'],
                time: e['itineraries'][0]['segments'][0]['departure']['at']
            ),
            arrival: FlightEndpoint(
                airport: e['itineraries'][0]['segments'].last['arrival']['iataCode'],
                time: e['itineraries'][0]['segments'].last['arrival']['at']
            ),
            duration: 0, // DURATION PARSING NEEDED
            flightNumber: '${e['itineraries'][0]['segments'][0]['carrierCode']}${e['itineraries'][0]['segments'][0]['number']}',
            segments: (e['itineraries'][0]['segments'] as List).map((s) => FlightSegment.fromJson(s)).toList(),
            date: e['lastTicketingDate'] ?? '',
        );
    }).toList();

    return FlightSearchResponse(
      airlines: (json['airlines'] as List<dynamic>?)
              ?.map((e) => FlightAirlineInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      count: json['count'] as int? ?? 0,
      data: flightDataList,
    );
  }
}
