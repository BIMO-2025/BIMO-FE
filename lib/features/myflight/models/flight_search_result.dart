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
  final double? overallRating; // 평균 평점
  final int? totalReviews; // 리뷰 개수

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
    this.overallRating,
    this.totalReviews,
  });

  /// Amadeus API Response JSON 파싱
  factory FlightSearchResult.fromAmadeusJson(Map<String, dynamic> json) {
    // ... (기존 변수들 생략하지 않고, 모델 필드 파싱 추가를 위해 아래 로직 사용)
    
    // JSON 구조가 조금씩 다를 수 있어 안전하게 처리
    final itineraries = json['itineraries'] != null ? json['itineraries'] as List : [];
    // 로그에 따르면 top-level에 segments가 있을 수도 있음 (Duffel/Custom style)
    // 하지만 기존 로직 유지하면서 추가 필드만 파싱 시도
    
    // (기존 Amadeus 로직 유지 - 로그 구조와 일치하는지 확인 필요하지만, 사용자가 매핑해달라고 했으니 필드 추가가 핵심)
    
    // 만약 Amadeus 구조라면, segments 등은 itineraries 안에 있음.
    // 하지만 사용자의 로그에는 top-level에 'overall_rating'이 있음.
    
    // 기존 로직 그대로 사용하되, 추가 필드만 파싱
    final firstItinerary = itineraries.isNotEmpty ? itineraries[0] : {'segments': [], 'duration': 'PT0H'};
    final segments = firstItinerary['segments'] as List? ?? [];
    
    // ... (기존 파싱 로직 재사용 불가피, 전체 교체 필요할 수 있음)
    // replace_file_content는 부분 교체이므로 전체 함수를 다시 써야 함.
    
    // 일단 기존 로직과 동일하게 가져가되, JSON 최상위에서 rating 파싱
    
    final itinerariesList = json['itineraries'] as List? ?? [];
    var segmentsList = <dynamic>[];
    String durationIso = 'PT00H00M';
    
    // 구조 대응: Duffel/Custom vs Amadeus
    if (json.containsKey('segments') && json['segments'] is List) {
       // Custom style (로그 기반)
       segmentsList = json['segments'];
       durationIso = json['total_duration'] ?? 'PT00H00M'; // 로그엔 '46M' 같은 포맷일 수도..
       // 로그의 duration: "46M" or "13H15M" -> ISO가 아닐 수 있음
    } else if (itinerariesList.isNotEmpty) {
       // Amadeus style
       final firstItinerary = itinerariesList[0];
       segmentsList = firstItinerary['segments'] as List;
       durationIso = firstItinerary['duration'] as String;
    }
    
    // 세그먼트가 비어있으면 더미 데이터 반환 (에러 방지)
    if (segmentsList.isEmpty) {
        return FlightSearchResult(
            airlineLogo: '',
            departureCode: '',
            departureTime: '',
            arrivalCode: '',
            arrivalTime: '',
            duration: '',
            date: '',
            flightNumber: '',
            layoverCount: 0,
            overallRating: 0.0,
            totalReviews: 0,
        );
    }
    
    final firstSegment = segmentsList.first;
    final lastSegment = segmentsList.last;

    // 1. 운항 시간 및 공항
    final departureAt = DateTime.parse(firstSegment['departure']['at']);
    final arrivalAt = DateTime.parse(lastSegment['arrival']['at']);
    
    final departureTimeStr = _formatTime(departureAt); 
    final arrivalTimeStr = _formatTime(arrivalAt); 
    
    final depCode = firstSegment['departure']['iataCode'];
    final arrCode = lastSegment['arrival']['iataCode'];

    // 2. 총 소요 시간
    // 로그의 "9H55M" 형식 처리 필요할 수도 있음. 
    // _parseDuration 함수가 ISO(PT..)만 처리하면 수정 필요.
    // 일단 기존 durationIso 사용
    final durationStr = _parseDuration(durationIso.startsWith('PT') ? durationIso : 'PT$durationIso');

    // 3. 항공편명
    final flightNumbers = segmentsList.map((seg) {
      final carrier = seg['operating_carrier'] ?? seg['carrierCode'] ?? ''; // 로그엔 operating_carrier
      final number = seg['flight_number'] ?? seg['number'] ?? '';      // 로그엔 flight_number
      // 로그의 flight_number가 "AC0064"라면 이미 합쳐져 있음.
      if (number.toString().startsWith(carrier)) return number;
      return '$carrier$number';
    }).join('/');

    // 4. 경유 여부
    final layoverCount = segmentsList.length - 1;
    List<LayoverInfo>? layoverInfos;

    if (layoverCount > 0) {
      layoverInfos = [];
      for (int i = 0; i < segmentsList.length - 1; i++) {
        final prevSegArr = DateTime.parse(segmentsList[i]['arrival']['at']);
        final nextSegDep = DateTime.parse(segmentsList[i + 1]['departure']['at']);
        final diff = nextSegDep.difference(prevSegArr);
        final airport = segmentsList[i]['arrival']['iataCode'];
        
        final h = diff.inHours.toString().padLeft(2, '0');
        final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
        
        layoverInfos.add(LayoverInfo(
          duration: '${h}시간 ${m}분',
          airportCode: airport,
        ));
      }
    }

    // 5. 항공사 로고 & 날짜
    final dateStr = _formatDate(departureAt);
    final airlineCode = (firstSegment['operating_carrier'] ?? firstSegment['carrierCode']) as String? ?? 'KE';
    final logoPath = _getAirlineLogo(airlineCode);
    
    // 6. 평점 및 리뷰 수 (NEW)
    final overallRating = (json['overall_rating'] as num?)?.toDouble();
    final totalReviews = json['total_reviews'] as int?;

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
      overallRating: overallRating,
      totalReviews: totalReviews,
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

