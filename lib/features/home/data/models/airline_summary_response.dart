/// BIMO 요약 응답 모델
class AirlineSummaryResponse {
  final String airlineCode;
  final String airlineName;
  final List<String> goodPoints;
  final List<String> badPoints;
  final int reviewCount;

  AirlineSummaryResponse({
    required this.airlineCode,
    required this.airlineName,
    required this.goodPoints,
    required this.badPoints,
    required this.reviewCount,
  });

  factory AirlineSummaryResponse.fromJson(Map<String, dynamic> json) {
    return AirlineSummaryResponse(
      airlineCode: json['airline_code'] as String? ?? '',
      airlineName: json['airline_name'] as String? ?? '',
      goodPoints: (json['good_points'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      badPoints: (json['bad_points'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      reviewCount: json['review_count'] as int? ?? 0,
    );
  }
}
