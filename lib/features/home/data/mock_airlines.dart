import '../domain/models/airline.dart';

final List<Airline> mockAirlines = [
  Airline(
    name: '대한항공',
    englishName: 'KOREAN AIR',
    logoPath: 'assets/images/home/korean_air_logo.png',
    imagePath: 'assets/images/search/korean_air_plane.png', // Placeholder path
    tags: ['SkyTeam', 'FSC'],
    rating: 4.8,
    reviewCount: 2334,
    detailRating: const AirlineDetailRating(
      seatComfort: 4.5,
      foodAndBeverage: 4.7,
      service: 4.9,
      cleanliness: 4.8,
      punctuality: 4.6,
    ),
    reviewSummary: const AirlineReviewSummary(
      goodPoints: ['좌석이 편안해요', '기내식이 맛있어요', '승무원이 친절해요'],
      badPoints: ['가격이 비싸요', '마일리지 좌석이 부족해요'],
    ),
    basicInfo: const AirlineBasicInfo(
      headquarters: '대한민국',
      hubAirport: 'ICN(인천국제공항), GMP(김포국제공항)',
      alliance: 'SkyTeam',
      classes: '이코노미, 프레스티지, 퍼스트',
    ),
  ),
  Airline(
    name: '아시아나 항공',
    englishName: 'ASIANA AIRLINES',
    logoPath: 'assets/images/home/asiana_logo.png',
    imagePath: 'assets/images/search/asiana_plane.png', // Placeholder path
    tags: ['Star Alliance', 'FSC'],
    rating: 4.8,
    reviewCount: 2334,
    detailRating: const AirlineDetailRating(
      seatComfort: 4.4,
      foodAndBeverage: 4.6,
      service: 4.8,
      cleanliness: 4.7,
      punctuality: 4.5,
    ),
    reviewSummary: const AirlineReviewSummary(
      goodPoints: ['서비스가 좋아요', '기내식이 괜찮아요'],
      badPoints: ['기재가 오래된 경우가 있어요'],
    ),
    basicInfo: const AirlineBasicInfo(
      headquarters: '대한민국',
      hubAirport: 'ICN(인천국제공항), GMP(김포국제공항)',
      alliance: 'Star Alliance',
      classes: '이코노미, 비즈니스, 비즈니스 스위트',
    ),
  ),
  Airline(
    name: '에어프랑스',
    englishName: 'AIRFRANCE',
    logoPath: 'assets/images/search/airfrance_logo.png', // Placeholder path
    imagePath: 'assets/images/search/airfrance_plane.png', // Placeholder path
    tags: ['SkyTeam', 'FSC'],
    rating: 4.0,
    reviewCount: 1405,
    detailRating: const AirlineDetailRating(
      seatComfort: 2.4,
      foodAndBeverage: 3.8,
      service: 4.8,
      cleanliness: 2.7,
      punctuality: 5.0,
    ),
    reviewSummary: const AirlineReviewSummary(
      goodPoints: ['만족스러운 기내식', '승무원 서비스 좋음', '지연 안 됨'],
      badPoints: ['청결도가 아쉬움', '옆 자리 사람 시끄러움', '수속 시 문제 있었음', '캐리어 분실함'],
    ),
    basicInfo: const AirlineBasicInfo(
      headquarters: '프랑스',
      hubAirport: 'CDG(파리 샤를 드 골)',
      alliance: 'SkyTeam',
      classes: '이코노미, 프리미엄 이코노미, 비즈니스, 퍼스트',
    ),
  ),
];
