import '../domain/models/airline.dart';

final List<Airline> mockAirlines = [
  Airline(
    name: '대한항공',
    code: 'KE',
    englishName: 'KOREAN AIR',
    logoPath: 'assets/images/home/korean_air_logo.png',
    imagePath: 'assets/images/search/korean_air_plane.png',
    tags: ['SkyTeam', 'FSC'],
    rating: 4.8,
    reviewCount: 2334,
    detailRating: const AirlineDetailRating(
      seatComfort: 4.6,
      foodAndBeverage: 4.7,
      service: 4.9,
      cleanliness: 4.8,
      punctuality: 4.5,
    ),
    reviewSummary: const AirlineReviewSummary(
      goodPoints: ['서비스가 친절해요', '기내식이 맛있어요'],
      badPoints: ['가격이 조금 비싸요'],
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
    code: 'OZ',
    englishName: 'ASIANA AIRLINES',
    logoPath: 'assets/images/search/asiana_plane_mini.png',
    imagePath: 'assets/images/search/asiana_plane.png',
    tags: ['Star Alliance', 'FSC'],
    rating: 4.5,
    reviewCount: 3110,
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
    code: 'AF',
    englishName: 'AIRFRANCE',
    logoPath: 'assets/images/search/airfrance_plane_mini.png',
    imagePath: 'assets/images/search/airfrance_plane.png', // Placeholder path
    tags: ['SkyTeam', 'FSC'],
    rating: 4.0,
    reviewCount: 1405,
    detailRating: const AirlineDetailRating(
      seatComfort: 4.2,
      foodAndBeverage: 4.5,
      service: 4.3,
      cleanliness: 4.0,
      punctuality: 4.1,
    ),
    reviewSummary: const AirlineReviewSummary(
      goodPoints: ['와인이 맛있어요', '빵이 맛있어요'],
      badPoints: ['수하물 분실이 잦아요'],
    ),
    basicInfo: const AirlineBasicInfo(
      headquarters: '프랑스',
      hubAirport: 'CDG(샤를 드 골 공항)',
      alliance: 'SkyTeam',
      classes: '이코노미, 프리미엄 이코노미, 비즈니스, 라 프리미에르',
    ),
  ),
];
