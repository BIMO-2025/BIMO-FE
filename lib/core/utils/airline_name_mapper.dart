/// 항공사 영문명 → 한글명 매핑
class AirlineNameMapper {
  static const Map<String, String> _airlineNames = {
    // 한국 항공사
    'Korean Air': '대한항공',
    'Asiana Airlines': '아시아나항공',
    'Jeju Air': '제주항공',
    'Jin Air': '진에어',
    'T\'way Air': '티웨이항공',
    'Air Busan': '에어부산',
    'Eastar Jet': '이스타항공',
    'Air Seoul': '에어서울',
    'Fly Gangwon': '플라이강원',
    'Air Premia': '에어프레미아',
    'Air Incheon': '에어인천',
    'Aero K': '에어로케이',
    
    // 일본 항공사
    'Japan Airlines': '일본항공',
    'All Nippon Airways': '아나항공',
    'ANA': '아나항공',
    'Peach Aviation': '피치항공',
    'Jetstar Japan': '젯스타 재팬',
    'Spring Airlines Japan': '스프링 재팬',
    
    // 중국 항공사
    'Air China': '중국국제항공',
    'China Eastern Airlines': '중국동방항공',
    'China Southern Airlines': '중국남방항공',
    'Hainan Airlines': '하이난항공',
    'Sichuan Airlines': '쓰촨항공',
    'Spring Airlines': '스프링항공',
    
    // 미국 항공사
    'American Airlines': '아메리칸항공',
    'Delta Air Lines': '델타항공',
    'United Airlines': '유나이티드항공',
    'Southwest Airlines': '사우스웨스트항공',
    'JetBlue Airways': '젯블루항공',
    'Alaska Airlines': '알래스카항공',
    'Hawaiian Airlines': '하와이안항공',
    
    // 유럽 항공사
    'Lufthansa': '루프트한자',
    'Air France': '에어프랑스',
    'British Airways': '브리티시항공',
    'KLM': 'KLM 네덜란드항공',
    'Swiss International Air Lines': '스위스항공',
    'Swiss': '스위스항공',
    'Austrian Airlines': '오스트리아항공',
    'Iberia': '이베리아항공',
    'Alitalia': '알이탈리아',
    'Turkish Airlines': '터키항공',
    'Aeroflot': '아에로플로트',
    'Finnair': '핀에어',
    'SAS': '스칸디나비아항공',
    'EasyJet': '이지젯',
    'Ryanair': '라이언에어',
    'Wizz Air': '위즈에어',
    'Vueling': '부엘링',
    'Norwegian Air': '노르웨이항공',
    'TAP Air Portugal': 'TAP 포르투갈항공',
    'LOT Polish Airlines': 'LOT 폴란드항공',
    'Czech Airlines': '체코항공',
    'Brussels Airlines': '브뤼셀항공',
    
    // 동남아시아 항공사
    'Singapore Airlines': '싱가포르항공',
    'Thai Airways': '타이항공',
    'Malaysia Airlines': '말레이시아항공',
    'Cathay Pacific': '캐세이퍼시픽',
    'Philippine Airlines': '필리핀항공',
    'Vietnam Airlines': '베트남항공',
    'Garuda Indonesia': '가루다인도네시아',
    'AirAsia': '에어아시아',
    'Scoot': '스쿠트',
    'VietJet Air': '비엣젯항공',
    'Lion Air': '라이온에어',
    'Cebu Pacific': '세부퍼시픽',
    'Nok Air': '녹에어',
    'Bangkok Airways': '방콕항공',
    'Malindo Air': '말린도에어',
    'Batik Air': '바틱에어',
    
    // 중동 항공사
    'Emirates': '에미레이트항공',
    'Qatar Airways': '카타르항공',
    'Etihad Airways': '에티하드항공',
    'Saudia': '사우디아항공',
    
    // 호주/오세아니아 항공사
    'Qantas': '콴타스항공',
    'Air New Zealand': '뉴질랜드항공',
    'Virgin Australia': '버진오스트레일리아',
    'Jetstar Airways': '젯스타항공',
    
    // 기타 항공사
    'Air Canada': '에어캐나다',
    'Aer Lingus': '에어링구스',
    'Avianca': '아비앙카',
    'LATAM Airlines': 'LATAM 항공',
    'Copa Airlines': '코파항공',
    'Aeromexico': '아에로멕시코',
    'Air India': '에어인디아',
    'IndiGo': '인디고',
    'SpiceJet': '스파이스젯',
    'Vistara': '비스타라',
    'Air Astana': '에어아스타나',
    'Uzbekistan Airways': '우즈베키스탄항공',
    'Ethiopian Airlines': '에티오피아항공',
    'Kenya Airways': '케냐항공',
    'South African Airways': '남아프리카항공',
    'EgyptAir': '이집트항공',
    'Royal Jordanian': '로열요르단항공',
    'Gulf Air': '걸프에어',
    'Oman Air': '오만항공',
    'Kuwait Airways': '쿠웨이트항공',
  };

  /// 영문 항공사 이름을 한글로 변환
  /// 매핑되지 않은 경우 원본 반환
  static String toKorean(String englishName) {
    // 정확히 일치하는 경우 먼저 확인
    if (_airlineNames.containsKey(englishName)) {
      return _airlineNames[englishName]!;
    }
    
    // 괄호 제거 후 검색 (예: "All Nippon Airways (ANA)" -> "All Nippon Airways")
    final nameWithoutParentheses = englishName.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();
    if (_airlineNames.containsKey(nameWithoutParentheses)) {
      return _airlineNames[nameWithoutParentheses]!;
    }
    
    // 대소문자 구분 없이 검색
    final lowerName = englishName.toLowerCase();
    for (final entry in _airlineNames.entries) {
      if (entry.key.toLowerCase() == lowerName) {
        return entry.value;
      }
    }
    
    // 괄호 제거 후 대소문자 구분 없이 검색
    final lowerNameWithoutParentheses = nameWithoutParentheses.toLowerCase();
    for (final entry in _airlineNames.entries) {
      if (entry.key.toLowerCase() == lowerNameWithoutParentheses) {
        return entry.value;
      }
    }
    
    // 매칭되지 않으면 원본 반환
    return englishName;
  }

  /// 여러 항공사 이름을 한번에 변환
  static List<String> toKoreanList(List<String> englishNames) {
    return englishNames.map((name) => toKorean(name)).toList();
  }
}
