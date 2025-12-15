/// 항공사 한글-영문명 매핑 데이터
/// 
/// 사용자가 한글로 검색하면 영문 항공사명으로 변환하여 API에 전달
class AirlineMapper {
  // 한글 항공사명 -> 영문 항공사명 매핑
  static const Map<String, String> koreanToEnglish = {
    // 한국 항공사
    '대한항공': 'Korean Air',
    '대한': 'Korean Air',
    '아시아나': 'Asiana Airlines',
    '아시아나항공': 'Asiana Airlines',
    '제주항공': 'Jeju Air',
    '제주': 'Jeju Air',
    '제주에어': 'Jeju Air',
    '진에어': 'Jin Air',
    '티웨이': 'T\'way Air',
    '티웨이항공': 'T\'way Air',
    '에어부산': 'Air Busan',
    '에어서울': 'Air Seoul',
    '이스타항공': 'Eastar Jet',
    '에어프레미아': 'Air Premia',
    
    // 일본 항공사
    '일본항공': 'Japan Airlines',
    'jal': 'Japan Airlines',
    '전일본공수': 'All Nippon Airways',
    '전일공': 'All Nippon Airways',
    'ana': 'All Nippon Airways',
    '피치': 'Peach',
    '피치항공': 'Peach',
    
    // 중국 항공사
    '중국국제항공': 'Air China',
    '에어차이나': 'Air China',
    '중국남방항공': 'China Southern Airlines',
    '중국동방항공': 'China Eastern Airlines',
    '하이난항공': 'Hainan Airlines',
    
    // 동남아 항공사
    '타이항공': 'Thai Airways',
    '싱가포르항공': 'Singapore Airlines',
    '말레이시아항공': 'Malaysia Airlines',
    '에어아시아': 'AirAsia',
    '베트남항공': 'Vietnam Airlines',
    '비엣젯': 'VietJet Air',
    '비엣젯항공': 'VietJet Air',
    '필리핀항공': 'Philippine Airlines',
    '세부퍼시픽': 'Cebu Pacific',
    '세부패시픽': 'Cebu Pacific',
    
    // 미국 항공사
    '유나이티드': 'United Airlines',
    '유나이티드항공': 'United Airlines',
    '아메리칸': 'American Airlines',
    '아메리칸항공': 'American Airlines',
    '델타': 'Delta',
    '델타항공': 'Delta',
    
    // 유럽 항공사
    '루프트한자': 'Lufthansa',
    '루프트한자항공': 'Lufthansa',
    '에어프랑스': 'Air France',
    '영국항공': 'British Airways',
    'ba': 'British Airways',
    'klm': 'KLM',
    'klm네덜란드항공': 'KLM',
    '터키항공': 'Turkish Airlines',
    '에어링구스': 'Aer Lingus',
    '에어링': 'Aer Lingus',
    '이지젯': 'EasyJet',
    '라이언에어': 'Ryanair',
    '라이언': 'Ryanair',
    
    // 중동 항공사
    '에미레이트': 'Emirates',
    '에미레이트항공': 'Emirates',
    '에티하드': 'Etihad Airways',
    '에티하드항공': 'Etihad Airways',
    '카타르항공': 'Qatar Airways',
    
    // 캐나다 항공사
    '에어캐나다': 'Air Canada',
    '캐나다': 'Air Canada',
    '웨스트젯': 'WestJet',
    
    // 국가명 기반 검색
    '일본': 'Japan Airlines',
    '중국': 'Air China',
    '싱가포르': 'Singapore Airlines',
    '타이': 'Thai Airways',
    '베트남': 'Vietnam Airlines',
    '필리핀': 'Philippine Airlines',
    '터키': 'Turkish Airlines',
    '영국': 'British Airways',
    '프랑스': 'Air France',
    '독일': 'Lufthansa',
  };

  // 항공사 코드 → 한국어 이름 매핑
  static const Map<String, String> codeToKorean = {
    // 한국 항공사
    'KE': '대한항공',
    'OZ': '아시아나항공',
    '7C': '제주항공',
    'LJ': '진에어',
    'TW': '티웨이항공',
    'BX': '에어부산',
    'RS': '에어서울',
    'YP': '에어프레미아',
    
    // 일본 항공사
    'JL': '일본항공',
    'NH': '전일본공수',
    'MM': '피치항공',
    
    // 중국 항공사
    'CA': '중국국제항공',
    'CZ': '중국남방항공',
    'MU': '중국동방항공',
    'HU': '하이난항공',
    
    // 동남아 항공사
    'TG': '타이항공',
    'SQ': '싱가포르항공',
    'MH': '말레이시아항공',
    'AK': '에어아시아',
    'VN': '베트남항공',
    'VJ': '비엣젯항공',
    'PR': '필리핀항공',
    '5J': '세부퍼시픽',
    
    // 미국 항공사
    'UA': '유나이티드항공',
    'AA': '아메리칸항공',
    'DL': '델타항공',
    'ZZ': '항공사 미상(ZZ)', // ZZ는 항공사 코드 미확인
    
    // 유럽 항공사
    'LH': '루프트한자',
    'AF': '에어프랑스',
    'BA': '영국항공',
    'KL': 'KLM네덜란드항공',
    'TK': '터키항공',
    
    // 중동 항공사
    'EK': '에미레이트항공',
    'EY': '에티하드항공',
    'QR': '카타르항공',
    
    // 캐나다 항공사
    'AC': '에어캐나다',
    'WS': '웨스트젯',
  };

  /// 한글 검색어를 영문 항공사명으로 변환
  /// 
  /// 예: "대한항공" -> "Korean Air", "아시아나" -> "Asiana Airlines"
  static String? getEnglishFromKorean(String korean) {
    return koreanToEnglish[korean.trim()];
  }

  /// 부분 매칭으로 영문 항공사명 찾기
  /// 
  /// "대한" -> "Korean Air"
  /// 여러 후보가 있으면 첫 번째 반환
  static String? getEnglishByPartialMatch(String query) {
    final trimmed = query.trim();
    
    // 1. 완전 일치 우선
    if (koreanToEnglish.containsKey(trimmed)) {
      return koreanToEnglish[trimmed];
    }
    
    // 2. 부분 일치 (시작 부분)
    for (final entry in koreanToEnglish.entries) {
      if (entry.key.startsWith(trimmed)) {
        return entry.value;
      }
    }
    
    // 3. 포함 검색
    for (final entry in koreanToEnglish.entries) {
      if (entry.key.contains(trimmed)) {
        return entry.value;
      }
    }
    
    return null;
  }

  /// 검색어가 한글인지 확인
  static bool isKorean(String text) {
    return RegExp(r'[ㄱ-ㅎ가-힣]').hasMatch(text);
  }

  /// 검색 키워드 변환
  /// 
  /// 한글이면 영문명으로 변환, 영문이면 그대로 반환
  /// 부분 매칭 지원
  static String convertSearchKeyword(String keyword) {
    final trimmed = keyword.trim();
    
    // 한글이 포함되어 있으면 영문명으로 변환 시도
    if (isKorean(trimmed)) {
      final englishName = getEnglishByPartialMatch(trimmed);
      if (englishName != null) {
        return englishName;
      }
    }
    
    // 변환 실패하거나 영문이면 원본 반환
    return trimmed;
  }
}
