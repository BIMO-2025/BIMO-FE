import '../../../home/data/models/flight_search_response.dart';

/// 비행 저장 API 요청 모델
/// POST /users/{userId}/my-flights
/// 
/// IMPORTANT: Flat 구조 사용 (value wrapper 없음)
class CreateFlightRequest {
  final String description;
  final String departureAirport;
  final String departureTime;
  final String arrivalAirport;
  final String arrivalTime;
  final bool hasStopover;
  final String status;
  final List<FlightSegmentRequest> segments;

  CreateFlightRequest({
    required this.description,
    required this.departureAirport,
    required this.departureTime,
    required this.arrivalAirport,
    required this.arrivalTime,
    required this.hasStopover,
    required this.status,
    required this.segments,
  });

  /// FlightSearchData에서 CreateFlightRequest 생성
  factory CreateFlightRequest.fromFlightSearchData(FlightSearchData data) {
    // 출발/도착 시간 (ISO 8601 형식, Z 포함 필수)
    String ensureZ(String time) => time.endsWith('Z') ? time : '${time}Z';
    
    final departureTime = ensureZ(data.departure.time);
    final arrivalTime = ensureZ(data.arrival.time);
    
    // Segments 변환
    final segments = (data.segments ?? []).map((seg) => FlightSegmentRequest(
      operatingCarrier: seg.carrierCode,
      flightNumber: seg.number,
      duration: seg.duration,
      departure: SegmentPoint(
        at: ensureZ(seg.departureTime),
        iataCode: seg.departureAirport,
      ),
      arrival: SegmentPoint(
        at: ensureZ(seg.arrivalTime),
        iataCode: seg.arrivalAirport,
      ),
    )).toList();

    return CreateFlightRequest(
      description: '${data.departure.airport}-${data.arrival.airport} Flight',
      departureAirport: data.departure.airport,
      departureTime: departureTime,
      arrivalAirport: data.arrival.airport,
      arrivalTime: arrivalTime,
      hasStopover: (data.segments?.length ?? 1) > 1,
      status: 'scheduled',
      segments: segments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'departureAirport': departureAirport,
      'departureTime': departureTime,
      'arrivalAirport': arrivalAirport,
      'arrivalTime': arrivalTime,
      'hasStopover': hasStopover,
      'status': status,
      'segments': segments.map((s) => s.toJson()).toList(),
    };
  }
}

/// 비행 세그먼트 정보
class FlightSegmentRequest {
  final String operatingCarrier;
  final String flightNumber;
  final String duration;
  final SegmentPoint departure;
  final SegmentPoint arrival;

  FlightSegmentRequest({
    required this.operatingCarrier,
    required this.flightNumber,
    required this.duration,
    required this.departure,
    required this.arrival,
  });

  Map<String, dynamic> toJson() {
    return {
      'operating_carrier': operatingCarrier,
      'flight_number': flightNumber,
      'duration': duration,
      'departure': departure.toJson(),
      'arrival': arrival.toJson(),
    };
  }
}

/// 세그먼트 포인트 (출발/도착 정보)
class SegmentPoint {
  final String at;
  final String iataCode;

  SegmentPoint({
    required this.at,
    required this.iataCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'at': at,
      'iata_code': iataCode,
    };
  }
}
