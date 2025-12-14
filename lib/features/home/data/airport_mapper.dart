/// 공항 한글-공항코드 매핑 데이터
/// 
/// 사용자가 한글로 검색하면 공항 코드로 변환하여 API에 전달
class AirportMapper {
  // 한글 도시명/공항명 -> 공항 코드 매핑
  static const Map<String, String> koreanToCode = {
    // 한국
    '한국': 'KR',
    '대한민국': 'KR',
    '인천': 'ICN',
    '인천국제공항': 'ICN',
    '서울': 'SEL',
    '김포': 'GMP',
    '김포공항': 'GMP',
    '부산': 'PUS',
    '김해': 'PUS',
    '김해공항': 'PUS',
    '제주': 'CJU',
    '제주공항': 'CJU',
    '대구': 'TAE',
    '광주': 'KWJ',
    '청주': 'CJJ',
    
    // 일본
    '일본': 'JP',
    '도쿄': 'TYO',
    '동경': 'TYO',
    '나리타': 'NRT',
    '하네다': 'HND',
    '오사카': 'OSA',
    '간사이': 'KIX',
    '후쿠오카': 'FUK',
    '삿포로': 'CTS',
    '오키나와': 'OKA',
    '나고야': 'NGO',
    
    // 중국
    '중국': 'CN',
    '베이징': 'BJS',
    '북경': 'BJS',
    '상하이': 'SHA',
    '상해': 'SHA',
    '푸동': 'PVG',
    '홍콩': 'HKG',
    '광저우': 'CAN',
    '선전': 'SZX',
    
    // 동남아시아
    '태국': 'TH',
    '방콕': 'BKK',
    '싱가포르': 'SG',
    '말레이시아': 'MY',
    '쿠알라룸푸르': 'KUL',
    '인도네시아': 'ID',
    '자카르타': 'JKT',
    '필리핀': 'PH',
    '마닐라': 'MNL',
    '베트남': 'VN',
    '하노이': 'HAN',
    '호치민': 'SGN',
    '다낭': 'DAD',
    '푸켓': 'HKT',
    
    // 미국
    '미국': 'US',
    '뉴욕': 'NYC',
    '로스앤젤레스': 'LAX',
    '엘에이': 'LAX',
    '샌프란시스코': 'SFO',
    '시카고': 'ORD',
    '시애틀': 'SEA',
    '라스베가스': 'LAS',
    '하와이': 'HNL',
    '호놀룰루': 'HNL',
    
    // 유럽
    '영국': 'GB',
    '런던': 'LON',
    '프랑스': 'FR',
    '파리': 'PAR',
    '독일': 'DE',
    '프랑크푸르트': 'FRA',
    '네덜란드': 'NL',
    '암스테르담': 'AMS',
    '이탈리아': 'IT',
    '로마': 'ROM',
    '스페인': 'ES',
    '바르셀로나': 'BCN',
    '마드리드': 'MAD',
    '스위스': 'CH',
    '취리히': 'ZRH',
    
    // 오세아니아
    '호주': 'AU',
    '시드니': 'SYD',
    '멜버른': 'MEL',
    '뉴질랜드': 'NZ',
    '오클랜드': 'AKL',
    
    // 중동
    '아랍에미리트': 'AE',
    '두바이': 'DXB',
    '카타르': 'QA',
    '도하': 'DOH',
    '터키': 'TR',
    '이스탄불': 'IST',
  };

  /// 부분 매칭으로 공항 코드 찾기
  static String? getCodeByPartialMatch(String query) {
    final trimmed = query.trim();
    
    // 1. 완전 일치 우선
    if (koreanToCode.containsKey(trimmed)) {
      return koreanToCode[trimmed];
    }
    
    // 2. 부분 일치 (시작 부분)
    for (final entry in koreanToCode.entries) {
      if (entry.key.startsWith(trimmed)) {
        return entry.value;
      }
    }
    
    // 3. 포함 검색
    for (final entry in koreanToCode.entries) {
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
  static String convertSearchKeyword(String keyword) {
    final trimmed = keyword.trim();
    
    // 한글이 포함되어 있으면 공항 코드로 변환 시도
    if (isKorean(trimmed)) {
      final code = getCodeByPartialMatch(trimmed);
      if (code != null) {
        return code;
      }
    }
    
    // 변환 실패하거나 영문이면 원본 반환
    return trimmed;
  }
}
