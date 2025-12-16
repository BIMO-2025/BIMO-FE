import '../../../home/data/models/flight_search_response.dart';

/// 타임라인 생성 API 요청 모델
/// POST /wellness/flight-timeline
/// 
/// Flat 구조 (wrapper 없음)
class TimelineRequest {
  final String origin;
  final String destination;
  final String departureTime;
  final String arrivalTime;
  final String totalDuration;
  final String seatClass;
  final String flightGoal;

  TimelineRequest({
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.totalDuration,
    required this.seatClass,
    required this.flightGoal,
  });

  /// FlightSearchData와 사용자 선택사항으로 TimelineRequest 생성
  factory TimelineRequest.fromFlightSearchData({
    required FlightSearchData data,
    required String seatClass,
    required String flightGoal,
  }) {
    // duration은 분 단위이므로 "14h 30m" 형식으로 변환
    final hours = data.duration ~/ 60;
    final minutes = data.duration % 60;
    final durationStr = '${hours}h ${minutes}m';
    
    return TimelineRequest(
      origin: data.departure.airport,
      destination: data.arrival.airport,
      departureTime: data.departure.time,
      arrivalTime: data.arrival.time,
      totalDuration: durationStr,
      seatClass: seatClass,
      flightGoal: flightGoal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seat_class': seatClass,
      'flight_goal': flightGoal,
    };
  }
}
