/// GET /users/{userId}/my-flights 응답 모델
/// 저장된 비행 목록을 가져옵니다
class MyFlightsResponse {
  final List<SavedFlight> flights;

  MyFlightsResponse({required this.flights});

  factory MyFlightsResponse.fromJson(List<dynamic> json) {
    return MyFlightsResponse(
      flights: json.map((item) => SavedFlight.fromJson(item)).toList(),
    );
  }
}

/// 개별 저장된 비행 정보
class SavedFlight {
  final String description;
  final SavedFlightValue value;

  SavedFlight({
    required this.description,
    required this.value,
  });

  factory SavedFlight.fromJson(Map<String, dynamic> json) {
    return SavedFlight(
      description: json['description'] as String? ?? '',
      value: SavedFlightValue.fromJson(json['value'] as Map<String, dynamic>),
    );
  }
}

/// 저장된 비행 상세 정보
class SavedFlightValue {
  final String departureAirport;
  final String departureTime;
  final String arrivalAirport;
  final String arrivalTime;
  final bool hasStopover;
  final String status;
  final List<SavedFlightSegment> segments;

  SavedFlightValue({
    required this.departureAirport,
    required this.departureTime,
    required this.arrivalAirport,
    required this.arrivalTime,
    required this.hasStopover,
    required this.status,
    required this.segments,
  });

  factory SavedFlightValue.fromJson(Map<String, dynamic> json) {
    return SavedFlightValue(
      departureAirport: json['departureAirport'] as String? ?? '',
      departureTime: json['departureTime'] as String? ?? '',
      arrivalAirport: json['arrivalAirport'] as String? ?? '',
      arrivalTime: json['arrivalTime'] as String? ?? '',
      hasStopover: json['hasStopover'] as bool? ?? false,
      status: json['status'] as String? ?? 'scheduled',
      segments: (json['segments'] as List<dynamic>?)
              ?.map((s) => SavedFlightSegment.fromJson(s))
              .toList() ??
          [],
    );
  }
}

/// 저장된 비행 세그먼트
class SavedFlightSegment {
  final String operatingCarrier;
  final String flightNumber;
  final String duration;
  final SavedSegmentPoint departure;
  final SavedSegmentPoint arrival;

  SavedFlightSegment({
    required this.operatingCarrier,
    required this.flightNumber,
    required this.duration,
    required this.departure,
    required this.arrival,
  });

  factory SavedFlightSegment.fromJson(Map<String, dynamic> json) {
    return SavedFlightSegment(
      operatingCarrier: json['operating_carrier'] as String? ?? '',
      flightNumber: json['flight_number'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      departure: SavedSegmentPoint.fromJson(json['departure'] as Map<String, dynamic>),
      arrival: SavedSegmentPoint.fromJson(json['arrival'] as Map<String, dynamic>),
    );
  }
}

/// 세그먼트 포인트
class SavedSegmentPoint {
  final String at;
  final String iataCode;

  SavedSegmentPoint({
    required this.at,
    required this.iataCode,
  });

  factory SavedSegmentPoint.fromJson(Map<String, dynamic> json) {
    return SavedSegmentPoint(
      at: json['at'] as String? ?? '',
      iataCode: json['iata_code'] as String? ?? '',
    );
  }
}
