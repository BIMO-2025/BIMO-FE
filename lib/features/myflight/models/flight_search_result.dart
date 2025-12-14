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

  /// Amadeus API Response JSON 파싱
  factory FlightSearchResult.fromAmadeusJson(Map<String, dynamic> json) {
    final itineraries = json['itineraries'] as List;
    final firstItinerary = itineraries[0];
    final segments = firstItinerary['segments'] as List;
    final firstSegment = segments.first;
    final lastSegment = segments.last;

    // 1. 운항 시간 및 공항
    // departure.at 형태: "2024-11-26T10:30:00"
    final departureAt = DateTime.parse(firstSegment['departure']['at']);
    final arrivalAt = DateTime.parse(lastSegment['arrival']['at']);
    
    final departureTimeStr = _formatTime(departureAt); // HH:mm
    final arrivalTimeStr = _formatTime(arrivalAt); // HH:mm
    
    final depCode = firstSegment['departure']['iataCode'];
    final arrCode = lastSegment['arrival']['iataCode'];

    // 2. 총 소요 시간 (PT14H30M -> 14h 30m)
    final durationIso = firstItinerary['duration'] as String;
    final durationStr = _parseDuration(durationIso);

    // 3. 항공편명 (KE081/DL192)
    final flightNumbers = segments.map((seg) {
      final carrier = seg['carrierCode'];
      final number = seg['number'];
      return '$carrier$number';
    }).join('/');

    // 4. 경유 여부 및 환승 정보
    final layoverCount = segments.length - 1;
    List<LayoverInfo>? layoverInfos;

    if (layoverCount > 0) {
      layoverInfos = [];
      for (int i = 0; i < segments.length - 1; i++) {
        final prevSegArr = DateTime.parse(segments[i]['arrival']['at']);
        final nextSegDep = DateTime.parse(segments[i + 1]['departure']['at']);
        final diff = nextSegDep.difference(prevSegArr);
        
        final airport = segments[i]['arrival']['iataCode'];
        
        // 예: "02시간 00분"
        final h = diff.inHours.toString().padLeft(2, '0');
        final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
        
        layoverInfos.add(LayoverInfo(
          duration: '${h}시간 ${m}분',
          airportCode: airport,
        ));
      }
    }

    // 5. 항공사 정보 & 날짜
    // 날짜 포맷: YYYY.MM.DD. (요일)
    final dateStr = _formatDate(departureAt);
    
    // 항공사 로고 (validatingAirlineCodes 첫 번째 기준)
    // NOTE: 실제 매핑은 프론트엔드 Map 데이터를 사용해야 하지만, 여기선 코드 기반으로 임시 로고 할당
    final airlineCodes = json['validatingAirlineCodes'] as List;
    final primaryAirline = airlineCodes.isNotEmpty ? airlineCodes[0] : '';
    final logoPath = _getAirlineLogo(primaryAirline);

    return FlightSearchResult(
      airlineLogo: logoPath,
      departureCode: depCode,
      departureTime: departureTimeStr,
      arrivalCode: arrCode,
      arrivalTime: arrivalTimeStr,
      duration: durationStr,
      date: dateStr,
      flightNumber: flightNumbers,
      layoverCount: layoverCount,
      layovers: layoverInfos,
    );
  }

  /// Helper: HH:mm 포맷
  static String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Helper: YYYY.MM.DD. (요일) 포맷
  static String _formatDate(DateTime dt) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[dt.weekday - 1];
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}. ($weekday)';
  }

  /// Helper: ISO Duration (PT14H30M) -> 14h 30m
  static String _parseDuration(String isoDuration) {
    // PT##H##M 형태 파싱
    // 정규식으로 H와 M 앞의 숫자 추출
    final hMatch = RegExp(r'(\d+)H').firstMatch(isoDuration);
    final mMatch = RegExp(r'(\d+)M').firstMatch(isoDuration);
    
    final h = hMatch != null ? hMatch.group(1) : '0';
    final m = mMatch != null ? mMatch.group(1) : '0';
    
    return '${h}h ${m}m';
  }

  /// Helper: 항공사 로고 매핑 (임시)
  static String _getAirlineLogo(String code) {
    // 주요 항공사만 예시로 매핑, 나머지는 empty or default
    switch (code) {
      case 'KE': return 'assets/images/home/korean_air_logo.png';
      case 'OZ': return 'assets/images/home/asiana_logo.png';
      case 'DL': return 'assets/images/home/delta_logo.png';
      case 'AF': return 'assets/images/home/airfrance_logo.png';
      case 'TW': return 'assets/images/home/tway_logo.png';
      default: return 'assets/images/home/korean_air_logo.png'; // Fallback
    }
  }

  /// 경유가 있는지 확인
  bool get hasLayover => layoverCount > 0;
}

