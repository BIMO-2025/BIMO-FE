/// 항공사 세부 정보 응답 모델
class AirlineDetailResponse {
  final String airlineName;
  final AverageRatings averageRatings;
  final Map<String, RatingDistribution> ratingBreakdown;
  final TotalRatingSums totalRatingSums;
  final int totalReviews;
  final double? overallRating; // API에서 직접 제공하는 전체 평점

  AirlineDetailResponse({
    required this.airlineName,
    required this.averageRatings,
    required this.ratingBreakdown,
    required this.totalRatingSums,
    required this.totalReviews,
    this.overallRating,
  });

  factory AirlineDetailResponse.fromJson(Map<String, dynamic> json) {
    // ratingBreakdown 파싱
    final Map<String, RatingDistribution> breakdown = {};
    if (json['ratingBreakdown'] != null) {
      final Map<String, dynamic> breakdownJson = json['ratingBreakdown'] as Map<String, dynamic>;
      breakdownJson.forEach((key, value) {
        breakdown[key] = RatingDistribution.fromJson(value as Map<String, dynamic>);
      });
    }

    return AirlineDetailResponse(
      airlineName: json['airlineName'] as String? ?? '',
      averageRatings: AverageRatings.fromJson(json['averageRatings'] as Map<String, dynamic>? ?? {}),
      ratingBreakdown: breakdown,
      totalRatingSums: TotalRatingSums.fromJson(json['totalRatingSums'] as Map<String, dynamic>? ?? {}),
      totalReviews: json['totalReviews'] as int? ?? 0,
      overallRating: (json['overallRating'] as num?)?.toDouble(),
    );
  }
}

/// 평균 평점
class AverageRatings {
  final double checkIn;
  final double cleanliness;
  final double inflightMeal;
  final double seatComfort;
  final double service;

  AverageRatings({
    required this.checkIn,
    required this.cleanliness,
    required this.inflightMeal,
    required this.seatComfort,
    required this.service,
  });

  factory AverageRatings.fromJson(Map<String, dynamic> json) {
    return AverageRatings(
      checkIn: (json['checkIn'] as num?)?.toDouble() ?? 0.0,
      cleanliness: (json['cleanliness'] as num?)?.toDouble() ?? 0.0,
      inflightMeal: (json['inflightMeal'] as num?)?.toDouble() ?? 0.0,
      seatComfort: (json['seatComfort'] as num?)?.toDouble() ?? 0.0,
      service: (json['service'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // 전체 평균 계산
  double get overall => (checkIn + cleanliness + inflightMeal + seatComfort + service) / 5.0;
}

/// 평점 분포 (1~5점 각각의 개수)
class RatingDistribution {
  final int star1;
  final int star2;
  final int star3;
  final int star4;
  final int star5;

  RatingDistribution({
    required this.star1,
    required this.star2,
    required this.star3,
    required this.star4,
    required this.star5,
  });

  factory RatingDistribution.fromJson(Map<String, dynamic> json) {
    return RatingDistribution(
      star1: json['1'] as int? ?? 0,
      star2: json['2'] as int? ?? 0,
      star3: json['3'] as int? ?? 0,
      star4: json['4'] as int? ?? 0,
      star5: json['5'] as int? ?? 0,
    );
  }

  // 총 리뷰 수
  int get total => star1 + star2 + star3 + star4 + star5;
}

/// 총 평점 합계
class TotalRatingSums {
  final int checkIn;
  final int cleanliness;
  final int inflightMeal;
  final int seatComfort;
  final int service;

  TotalRatingSums({
    required this.checkIn,
    required this.cleanliness,
    required this.inflightMeal,
    required this.seatComfort,
    required this.service,
  });

  factory TotalRatingSums.fromJson(Map<String, dynamic> json) {
    return TotalRatingSums(
      checkIn: json['checkIn'] as int? ?? 0,
      cleanliness: json['cleanliness'] as int? ?? 0,
      inflightMeal: json['inflightMeal'] as int? ?? 0,
      seatComfort: json['seatComfort'] as int? ?? 0,
      service: json['service'] as int? ?? 0,
    );
  }
}
