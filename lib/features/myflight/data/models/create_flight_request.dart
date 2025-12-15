import '../../../home/data/models/flight_search_response.dart';

/// 비행 저장 API 요청 모델
/// POST /users/{userId}/my-flights
/// 
/// IMPORTANT: 이 API는 "value" 래퍼 구조를 사용합니다:
/// {
///   "description": "...",
///   "value": { /* 실제 데이터 */ }
/// }
class CreateFlightRequest {
  final String description;
  final FlightValue value;

  CreateFlightRequest({
    required this.description,
    required this.value,
  });

  /// FlightSearchData에서 CreateFlightRequest 생성
  factory CreateFlightRequest.fromFlightSearchData(FlightSearchData data) {
    // FlightSearchData는 departure/arrival이 FlightEndpoint 타입
    // segments가 List<FlightSegment>?
    
    // 출발/도착 시간 (ISO 8601 형식, Z 포함 필수)
    // API가 Z 없이 주면 수동으로 추가
    String ensureZ(String time) => time.endsWith('Z') ? time : '${time}Z';
    
    final departureTime = ensureZ(data.departure.time);
    final arrivalTime = ensureZ(data.arrival.time);
    
    // Segments 변환 (segments가 있으면)
    final segments = (data.segments ?? []).map((seg) => FlightSegmentRequest(
      operatingCarrier: seg.carrierCode,
      flightNumber: seg.number, // 'number' 필드 사용
      duration: seg.duration, // 이미 "XhYm" 형식 문자열
      departure: SegmentPoint(
        at: ensureZ(seg.departureTime), // Z 보장
        iataCode: seg.departureAirport,
      ),
      arrival: SegmentPoint(
        at: ensureZ(seg.arrivalTime), // Z 보장
        iataCode: seg.arrivalAirport,
      ),
    )).toList();

    return CreateFlightRequest(
      description: '${data.departure.airport}-${data.arrival.airport} Flight',
      value: FlightValue(
        departureAirport: data.departure.airport,
        departureTime: departureTime,
        arrivalAirport: data.arrival.airport,
        arrivalTime: arrivalTime,
        hasStopover: (data.segments?.length ?? 1) > 1,
        status: 'scheduled',
        segments: segments,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'value': value.toJson(),
    };
  }
}

/// 실제 비행 데이터 (value 필드 안에 들어가는 내용)
class FlightValue {
  final String departureAirport;
  final String departureTime;
  final String arrivalAirport;
  final String arrivalTime;
  final bool hasStopover;
  final String status;
  final List<FlightSegmentRequest> segments;

  FlightValue({
    required this.departureAirport,
    required this.departureTime,
    required this.arrivalAirport,
    required this.arrivalTime,
    required this.hasStopover,
    required this.status,
    required this.segments,
  });

  Map<String, dynamic> toJson() {
    return {
      'arrivalAirport': arrivalAirport, // API 스펙 순서: arrival 먼저
      'arrivalTime': arrivalTime,
      'departureAirport': departureAirport,
      'departureTime': departureTime,
      'hasStopover': hasStopover,
      'segments': segments.map((s) => s.toJson()).toList(),
      'status': status,
    };
  }
}

/// 비행 세그먼트 정보 (요청용)
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
