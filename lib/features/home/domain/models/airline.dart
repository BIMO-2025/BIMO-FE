class Airline {
  final String name;
  final String code; // 항공사 코드 (예: KE, AF, SQ)
  final String englishName;
  final String logoPath;
  final String imagePath;
  final List<String> tags;
  final double rating;
  final int reviewCount;
  final AirlineDetailRating detailRating;
  final AirlineReviewSummary reviewSummary;
  final AirlineBasicInfo basicInfo;

  const Airline({
    required this.name,
    required this.code,
    required this.englishName,
    required this.logoPath,
    required this.imagePath,
    required this.tags,
    required this.rating,
    required this.reviewCount,
    required this.detailRating,
    required this.reviewSummary,
    required this.basicInfo,
  });
}

class AirlineDetailRating {
  final double seatComfort;
  final double foodAndBeverage;
  final double service;
  final double cleanliness;
  final double punctuality;

  const AirlineDetailRating({
    required this.seatComfort,
    required this.foodAndBeverage,
    required this.service,
    required this.cleanliness,
    required this.punctuality,
  });
}

class AirlineReviewSummary {
  final List<String> goodPoints;
  final List<String> badPoints;

  const AirlineReviewSummary({
    required this.goodPoints,
    required this.badPoints,
  });
}

class AirlineBasicInfo {
  final String headquarters;
  final String hubAirport;
  final String alliance;
  final String classes;

  const AirlineBasicInfo({
    required this.headquarters,
    required this.hubAirport,
    required this.alliance,
    required this.classes,
  });
}
