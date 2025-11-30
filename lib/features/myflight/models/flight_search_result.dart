/// 경유 정보 모델
class LayoverInfo {
  final String duration; // 경유 대기 시간 (예: "02시간 00분")
  final String airportCode; // 경유 공항 코드 (예: "SFO")

  const LayoverInfo({
    required this.duration,
    required this.airportCode,
  });
}

/// 비행편 검색 결과 모델
class FlightSearchResult {
  final String airlineLogo; // 항공사 로고 이미지 경로
  final String departureCode; // 출발지 코드 (예: "DXB")
  final String departureTime; // 출발 시간 (예: "09:00")
  final String arrivalCode; // 도착지 코드 (예: "INC")
  final String arrivalTime; // 도착 시간 (예: "19:40")
  final String duration; // 비행 시간 (예: "14h 30m")
  final String date; // 날짜 (예: "2025.11.12. (토)")
  final String flightNumber; // 편명 (예: "DF445" 또는 "DF445/ER555")
  final int layoverCount; // 경유 횟수 (0이면 직항)
  final List<LayoverInfo>? layovers; // 경유 정보 리스트 (null이면 경유 없음)

  const FlightSearchResult({
    required this.airlineLogo,
    required this.departureCode,
    required this.departureTime,
    required this.arrivalCode,
    required this.arrivalTime,
    required this.duration,
    required this.date,
    required this.flightNumber,
    required this.layoverCount,
    this.layovers,
  });

  /// 경유가 있는지 확인
  bool get hasLayover => layoverCount > 0 && layovers != null && layovers!.isNotEmpty;
}

