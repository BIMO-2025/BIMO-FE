/// BIMO 요약 응답 모델
class AirlineSummaryResponse {
  final String? airlineCode;
  final String? airlineName;
  final List<String> goodPoints;
  final List<String> badPoints;
  final int reviewCount;
  final String? lastUpdated;
  final String? oneLineReview;

  AirlineSummaryResponse({
    this.airlineCode,
    this.airlineName,
    required this.goodPoints,
    required this.badPoints,
    required this.reviewCount,
    this.lastUpdated,
    this.oneLineReview,
  });

  factory AirlineSummaryResponse.fromJson(Map<String, dynamic> json) {
    return AirlineSummaryResponse(
      airlineCode: json['airlineCode'] as String? ?? json['airline_code'],
      airlineName: json['airlineName'] as String? ?? json['airline_name'],
      goodPoints: (json['goodPoints'] as List<dynamic>? ?? json['good_points'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      badPoints: (json['badPoints'] as List<dynamic>? ?? json['bad_points'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      reviewCount: json['reviewCount'] as int? ?? json['review_count'] as int? ?? 0,
      lastUpdated: json['lastUpdated'] as String? ?? json['last_updated'],
      oneLineReview: json['oneLineReview'] as String? ?? json['one_line_review'],
    );
  }
}
