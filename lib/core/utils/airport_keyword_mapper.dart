/// 한글 검색어를 영어 쿼리로 변환하는 매퍼 클래스
class AirportKeywordMapper {
  /// 로컬 한글-영어 매핑 데이터
  static const Map<String, String> _koreanToEnglishMap = {
    // 대한민국
    '서울': 'Seoul',
    '인천': 'Incheon',
    '김포': 'Gimpo',
    '부산': 'Busan',
    '제주': 'Jeju',
    '대구': 'Daegu',
    '광주': 'Gwangju',
    '청주': 'Cheongju',
    '무안': 'Muan',
    '양양': 'Yangyang',

    // 미국
    '미국': 'United States',
    '뉴욕': 'New York',
    '로스앤젤레스': 'Los Angeles',
    '엘에이': 'Los Angeles',
    'LA': 'Los Angeles',
    '샌프란시스코': 'San Francisco',
    '시카고': 'Chicago',
    '워싱턴': 'Washington',
    '라스베가스': 'Las Vegas',
    '시애틀': 'Seattle',
    '보스턴': 'Boston',
    '애틀랜타': 'Atlanta',
    '댈러스': 'Dallas',
    '하와이': 'Hawaii',
    '호놀룰루': 'Honolulu',
    '괌': 'Guam',

    // 일본
    '일본': 'Japan',
    '도쿄': 'Tokyo',
    '오사카': 'Osaka',
    '후쿠오카': 'Fukuoka',
    '삿포로': 'Sapporo',
    '오키나와': 'Okinawa',
    '나고야': 'Nagoya',

    // 중국
    '중국': 'China',
    '베이징': 'Beijing',
    '북경': 'Beijing',
    '상하이': 'Shanghai',
    '상해': 'Shanghai',
    '광저우': 'Guangzhou',
    '칭다오': 'Qingdao',
    '홍콩': 'Hong Kong',

    // 유럽
    '영국': 'United Kingdom',
    '런던': 'London',
    '프랑스': 'France',
    '파리': 'Paris',
    '독일': 'Germany',
    '프랑크푸르트': 'Frankfurt',
    '뮌헨': 'Munich',
    '베를린': 'Berlin',
    '이탈리아': 'Italy',
    '로마': 'Rome',
    '밀라노': 'Milan',
    '스페인': 'Spain',
    '바르셀로나': 'Barcelona',
    '마드리드': 'Madrid',
    '네덜란드': 'Netherlands',
    '암스테르담': 'Amsterdam',
    '스위스': 'Switzerland',
    '취리히': 'Zurich',

    // 동남아/기타 아시아
    '태국': 'Thailand',
    '방콕': 'Bangkok',
    '베트남': 'Vietnam',
    '다낭': 'Da Nang',
    '하노이': 'Hanoi',
    '호치민': 'Ho Chi Minh',
    '싱가포르': 'Singapore',
    '필리핀': 'Philippines',
    '세부': 'Cebu',
    '마닐라': 'Manila',
    '대만': 'Taiwan',
    '타이베이': 'Taipei',
    '말레이시아': 'Malaysia',
    '쿠알라룸푸르': 'Kuala Lumpur',
    '코타키나발루': 'Kota Kinabalu',
    '인도네시아': 'Indonesia',
    '발리': 'Bali',

    // 대양주
    '호주': 'Australia',
    '시드니': 'Sydney',
    '멜버른': 'Melbourne',
    '뉴질랜드': 'New Zealand',
    '오클랜드': 'Auckland',

    // 캐나다
    '캐나다': 'Canada',
    '토론토': 'Toronto',
    '밴쿠버': 'Vancouver',
  };

  /// 한글 검색어를 영어 쿼리로 변환
  /// 매핑되는 키워드가 없으면 입력값을 그대로 반환
  static String mapToEnglish(String input) {
    if (input.isEmpty) return input;
    
    // 로컬 매핑 데이터 (쿼리용)
    final queryMap = {
           // 대한민국
    '서울': 'Seoul',
    '인천': 'Incheon',
    '김포': 'Gimpo',
    '부산': 'Busan',
    '제주': 'Jeju',
    '대구': 'Daegu',
    '광주': 'Gwangju',
    '청주': 'Cheongju',
    '무안': 'Muan',
    '양양': 'Yangyang',

    // 미국
    '미국': 'United States',
    // '미': 'United States', // Ambiguous: removed to avoid conflict with Myanmar
    '뉴욕': 'New York',
    '로스앤젤레스': 'Los Angeles',
    '엘에이': 'Los Angeles',
    'LA': 'Los Angeles',
    '샌프란시스코': 'San Francisco',
    '시카고': 'Chicago',
    '워싱턴': 'Washington',
    '라스베가스': 'Las Vegas',
    '시애틀': 'Seattle',
    '보스턴': 'Boston',
    '애틀랜타': 'Atlanta',
    '댈러스': 'Dallas',
    '하와이': 'Hawaii',
    '호놀룰루': 'Honolulu',
    '괌': 'Guam',

    // 동남아/기타 아시아 (추가)
    '미얀마': 'Myanmar',

    // 일본
    '일본': 'Japan',
    '도쿄': 'Tokyo',
    '오사카': 'Osaka',
    '후쿠오카': 'Fukuoka',
    '삿포로': 'Sapporo',
    '오키나와': 'Okinawa',
    '나고야': 'Nagoya',

    // 중국/동북아
    '중국': 'China',
    '베이징': 'Beijing',
    '북경': 'Beijing',
    '상하이': 'Shanghai',
    '상해': 'Shanghai',
    '홍콩': 'Hong Kong',
    '대만': 'Taiwan',
    '타이베이': 'Taipei',

    // 유럽
    '영국': 'United Kingdom',
    '런던': 'London',
    '프랑스': 'France',
    '파리': 'Paris',
    '독일': 'Germany',
    '프랑크푸르트': 'Frankfurt',
    '이탈리아': 'Italy',
    '로마': 'Rome',
    '스페인': 'Spain',
    '바르셀로나': 'Barcelona',
    '스위스': 'Switzerland',
    '취리히': 'Zurich',

    // 동남아/대양주
    '태국': 'Thailand',
    '방콕': 'Bangkok',
    '베트남': 'Vietnam',
    '다낭': 'Da Nang',
    '호치민': 'Ho Chi Minh',
    '싱가포르': 'Singapore',
    '호주': 'Australia',
    '시드니': 'Sydney',
    };

    // 1. 완전 일치 검색
    final exactMatch = queryMap[input];
    if (exactMatch != null) return exactMatch;

    // 2. 포함 검색 (입력값이 키워드를 포함하는 경우)
    for (final entry in queryMap.entries) {
      if (input.contains(entry.key)) {
        return entry.value;
      }
    }

    return input;
  }
  
  /// 영어 도시/공항명을 한글로 변환 (표시용)
  static String convertToKorean(String englishName) {
    if (englishName.isEmpty) return englishName;
    
    // 로컬 매핑 데이터 (표시용 - 영어 -> 한글)
    // 주요 도시 및 공항 이름
    final displayMap = {
      // 한국
      'Seoul': '서울',
      'ICN': '인천',
      'Incheon': '인천',
      'Incheon International Airport': '인천 국제공항',
      'GMP': '김포',
      'Gimpo': '김포',
      'Gimpo International Airport': '김포 국제공항',

      // Common Layover Hubs & Major Cities
      'ADD': '아디스아바바',
      'DXB': '두바이',
      'DOH': '도하',
      'IST': '이스탄불',
      'HND': '도쿄(하네다)',
      'NRT': '도쿄(나리타)',
      'KIX': '오사카(간사이)',
      'FUK': '후쿠오카',
      'HKG': '홍콩',
      'SIN': '싱가포르',
      'BKK': '방콕',
      'TPE': '타이베이',
      'PEK': '베이징',
      'PVG': '상하이(푸동)',
      'CDG': '파리',
      'LHR': '런던',
      'FRA': '프랑크푸르트',
      'AMS': '암스테르담',
      'FCO': '로마',
      'MAD': '마드리드',
      'BCN': '바르셀로나',
      'ZRH': '취리히',
      'JFK': '뉴욕(JFK)',
      'LAX': '로스앤젤레스',
      'SFO': '샌프란시스코',
      'SEA': '시애틀',
      'YVR': '밴쿠버',
      'YYZ': '토론토',
      'SYD': '시드니',
      'Busan': '부산',
      'Gimhae International Airport': '김해 국제공항',
      'Jeju': '제주',
      'Jeju International Airport': '제주 국제공항',

      // 미국
      'New York': '뉴욕',
      'John F. Kennedy International Airport': '존 F. 케네디 국제공항',
      'John F Kennedy Intl': '존 F. 케네디 국제공항',
      'Newark Liberty International Airport': '뉴어크 리버티 국제공항',
      'Los Angeles': '로스앤젤레스',
      'Los Angeles International Airport': '로스앤젤레스 국제공항',
      'San Francisco': '샌프란시스코',
      'San Francisco International Airport': '샌프란시스코 국제공항',
      'Chicago': '시카고',
      'O\'Hare International Airport': '오헤어 국제공항',
      'Seattle': '시애틀',
      'Seattle-Tacoma International Airport': '시애틀 타코마 국제공항',
      'Atlanta': '애틀랜타',
      'Hartsfield-Jackson Atlanta International Airport': '하츠필드 잭슨 애틀랜타 국제공항',
      'Dallas': '댈러스',
      'Dallas/Fort Worth International Airport': '댈러스 포트워스 국제공항',
      'Las Vegas': '라스베가스',
      'Harry Reid International Airport': '해리 리드 국제공항',
      'McCarran International Airport': '매캐런 국제공항',
      'Honolulu': '호놀룰루',
      'Daniel K. Inouye International Airport': '다니엘 K. 이노우에 국제공항',
      'Guam': '괌',
      'Antonio B. Won Pat International Airport': '안토니오 B. 원 팻 국제공항',
      'Boise': '보이시',
      'Boise Air Terminal/Gowen Field': '보이즈 공항 (가웬 필드)',
      'Knoxville': '녹스빌',
      'McGhee Tyson Airport': '맥기 타이슨 공항',
      'Tampa': '탬파',
      'Tampa International Airport': '탬파 국제공항',
      'Amarillo': '애머릴로',
      'Rick Husband Amarillo International Airport': '릭 허스번드 애머릴로 국제공항',
      'Lanai': '리나이',
      'Lanai Airport': '리나이 공항',
      
      // 캐나다
      'Canada': '캐나다',
      'Toronto': '토론토',
      'Pearson International Airport': '피어슨 국제공항',
      'Vancouver': '밴쿠버',
      'Vancouver International Airport': '밴쿠버 국제공항',
      'Montreal': '몬트리올',
      'Pierre Elliott Trudeau International Airport': '피에르 엘리오트 트뤼도 국제공항',
      'Calgary': '캘거리',
      'Calgary International Airport': '캘거리 국제공항',
      
      // 일본
      'Tokyo': '도쿄',
      'Narita International Airport': '나리타 국제공항',
      'Haneda Airport': '하네다 공항',
      'Osaka': '오사카',
      'Kansai International Airport': '간사이 국제공항',
      'Fukuoka': '후쿠오카',
      'Fukuoka Airport': '후쿠오카 공항',
      'Sapporo': '삿포로',
      'New Chitose Airport': '신치토세 공항',
      
      // 중국/동북아
      'Beijing': '베이징',
      'Beijing Capital International Airport': '베이징 서우두 국제공항',
      'Shanghai': '상하이',
      'Shanghai Pudong International Airport': '상하이 푸동 국제공항',
      'Hong Kong': '홍콩',
      'Hong Kong International Airport': '홍콩 국제공항',
      'Taipei': '타이베이',
      'Taiwan Taoyuan International Airport': '타이완 타오위안 국제공항',
      
      // 유럽
      'London': '런던',
      'Heathrow Airport': '히드로 공항',
      'Paris': '파리',
      'Charles de Gaulle Airport': '샤를 드 골 공항',
      'Frankfurt': '프랑크푸르트',
      'Frankfurt Airport': '프랑크푸르트 공항',
      
      // 동남아
      'Bangkok': '방콕',
      'Suvarnabhumi Airport': '수완나품 공항',
      'Da Nang': '다낭',
      'Da Nang International Airport': '다낭 국제공항',
      'Singapore': '싱가포르',
      'Changi Airport': '창이 공항',
    };
    
    // 1. 완전 일치
    if (displayMap.containsKey(englishName)) {
      return displayMap[englishName]!;
    }
    
    // 2. 부분 일치 (주요 도시명 포함 시)
    for (final entry in displayMap.entries) {
      if (englishName.contains(entry.key) && entry.value.length > 1) { // 너무 짧은 키워드 제외
         // "International Airport" 등을 "국제공항"으로 치환하는 등의 로직도 가능하지만
         // 단순화를 위해 키워드가 포함되면 그대로 반환하지 않고, 
         // 복합적인 처리가 필요함. 일단은 딕셔너리에 없는 경우 원본 반환
      }
    }

    return englishName;
  }

  /// 초성 검색 지원
  /// 입력값이 초성(예: 'ㅇ', 'ㄱ')인지 확인하고, 해당 초성으로 시작하는 매핑 키워드 목록 반환
  static List<String> getChosungMatches(String input) {
    if (input.length != 1) return [];

    final int code = input.codeUnitAt(0);
    // 한글 자음 범위 (ㄱ ~ ㅎ)
    if (code < 0x3131 || code > 0x314E) return [];

    final List<String> matches = [];
    
    // 로컬 매핑 데이터 (쿼리용) Re-use logic would be better but simple copy for now or accessing the map directly if it was public/internal.
    // Accessing private map by duplicating or making it internal. 
    // Since _koreanToEnglishMap is private, we'll iterate a combined list or just the keys we know.
    // For efficiency, we will assume we can access keys. To do this cleanly, we need to access _koreanToEnglishMap.
    // Since we are inside the class, we can access _koreanToEnglishMap.
    
    // 초성 리스트 (순서대로)
    final chosungs = [
      'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'
    ];

    // 각 키의 첫 글자 초성 추출하여 비교
    for (final entry in _koreanToEnglishMap.entries) {
      final key = entry.key; // 한글 키워드 (예: '영국')
      if (key.isEmpty) continue;
      
      final firstChar = key.runes.first;
      // 한글 유니코드 공식: (초성 * 21 + 중성) * 28 + 종성 + 0xAC00
      if (firstChar >= 0xAC00 && firstChar <= 0xD7A3) {
        final chosungIndex = (firstChar - 0xAC00) ~/ (21 * 28);
        if (chosungIndex >= 0 && chosungIndex < chosungs.length) {
          if (chosungs[chosungIndex] == input) {
            matches.add(key);
          }
        }
      }
    }
    
    return matches;
  }
  
  /// 입력값이 한국어 자음(초성) 하나인지 확인
  static bool isChosung(String input) {
    if (input.length != 1) return false;
    final int code = input.codeUnitAt(0);
    return code >= 0x3131 && code <= 0x314E;
  }

  /// 접두사(Prefix) 일치 검색 (로컬 필터링용)
  /// 입력값으로 시작하는 한글 키워드를 찾아 영문 매핑값을 반환
  /// 예: "미" -> ["United States", "Myanmar"]
  static Map<String, String> getPrefixMatches(String input) {
    if (input.isEmpty) return {};

    final Map<String, String> matches = {};
    
    // 로컬 매핑 데이터 (쿼리용) - 데이터 확장
    // NOTE: 실제 프로덕션에서는 별도 파일이나 상수로 관리하는 것이 좋음
    final queryMap = {
      // 대한민국
      '서울': 'Seoul',
      '인천': 'Incheon',
      '김포': 'Gimpo',
      '부산': 'Busan',
      '제주': 'Jeju',
      '대구': 'Daegu',
      '광주': 'Gwangju',
      '청주': 'Cheongju',
      '무안': 'Muan',
      '양양': 'Yangyang',

      // 미국
      '미국': 'United States',
      '뉴욕': 'New York',
      '로스앤젤레스': 'Los Angeles',
      '엘에이': 'Los Angeles',
      'LA': 'Los Angeles',
      '샌프란시스코': 'San Francisco',
      '시카고': 'Chicago',
      '워싱턴': 'Washington',
      '라스베가스': 'Las Vegas',
      '시애틀': 'Seattle',
      '보스턴': 'Boston',
      '애틀랜타': 'Atlanta',
      '댈러스': 'Dallas',
      '하와이': 'Hawaii',
      '호놀룰루': 'Honolulu',
      '괌': 'Guam',
      
      // 일본
      '일본': 'Japan',
      '도쿄': 'Tokyo',
      '오사카': 'Osaka',
      '후쿠오카': 'Fukuoka',
      '삿포로': 'Sapporo',
      '오키나와': 'Okinawa',
      '나고야': 'Nagoya',

      // 중국/동북아
      '중국': 'China',
      '베이징': 'Beijing',
      '북경': 'Beijing',
      '상하이': 'Shanghai',
      '상해': 'Shanghai',
      '홍콩': 'Hong Kong',
      '대만': 'Taiwan',
      '타이베이': 'Taipei',
      '마카오': 'Macau',
      
      // 동남아
      '미얀마': 'Myanmar',
      '태국': 'Thailand',
      '방콕': 'Bangkok',
      '치앙마이': 'Chiang Mai',
      '푸켓': 'Phuket',
      '베트남': 'Vietnam',
      '다낭': 'Da Nang',
      '하노이': 'Hanoi',
      '호치민': 'Ho Chi Minh',
      '나트랑': 'Nha Trang',
      '필리핀': 'Philippines',
      '마닐라': 'Manila',
      '세부': 'Cebu',
      '보라카이': 'Boracay',
      '싱가포르': 'Singapore',
      '말레이시아': 'Malaysia',
      '쿠알라룸푸르': 'Kuala Lumpur',
      '코타키나발루': 'Kota Kinabalu',
      '인도네시아': 'Indonesia',
      '발리': 'Bali',
      '자카르타': 'Jakarta',
      
      // 유럽
      '영국': 'United Kingdom',
      '런던': 'London',
      '프랑스': 'France',
      '파리': 'Paris',
      '독일': 'Germany',
      '프랑크푸르트': 'Frankfurt',
      '뮌헨': 'Munich',
      '이탈리아': 'Italy',
      '로마': 'Rome',
      '밀라노': 'Milan',
      '베니스': 'Venice',
      '스페인': 'Spain',
      '바르셀로나': 'Barcelona',
      '마드리드': 'Madrid',
      '스위스': 'Switzerland',
      '취리히': 'Zurich',
      '제네바': 'Geneva',
      '네덜란드': 'Netherlands',
      '암스테르담': 'Amsterdam',
      '체코': 'Czech Republic',
      '프라하': 'Prague',
      '오스트리아': 'Austria',
      '비엔나': 'Vienna',
      
      // 대양주
      '호주': 'Australia',
      '시드니': 'Sydney',
      '멜버른': 'Melbourne',
      '브리즈번': 'Brisbane',
      '뉴질랜드': 'New Zealand',
      '오클랜드': 'Auckland',
      
      // 캐나다
      '캐나다': 'Canada',
      '토론토': 'Toronto',
      '밴쿠버': 'Vancouver',
    };

    for (final entry in queryMap.entries) {
      if (entry.key.startsWith(input)) {
        matches[entry.key] = entry.value;
      }
    }
    
    return matches;
  }
  
  /// 주어진 키워드가 국가명인지 확인 (헤더 표시용)
  static bool isCountryKey(String key) {
    const countries = {
      '대한민국', '미국', '일본', '중국', '영국', '프랑스', '독일', '이탈리아', '스페인', '네덜란드', '스위스', '체코', '오스트리아',
      '태국', '베트남', '필리핀', '싱가포르', '말레이시아', '인도네시아', '대만',
      '호주', '뉴질랜드', '캐나다', '미얀마'
    };
    return countries.contains(key);
  }
}
