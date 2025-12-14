/// 항공편 검색 응답의 항공사 정보
class FlightAirlineInfo {
  final String airlineName;
  final String? logoUrl;
  final int totalReviews;
  final double overallRating;
  final String? alliance;
  final String? type;
  final String? country;

  FlightAirlineInfo({
    required this.airlineName,
    this.logoUrl,
    required this.totalReviews,
    required this.overallRating,
    this.alliance,
    this.type,
    this.country,
  });

  factory FlightAirlineInfo.fromJson(Map<String, dynamic> json) {
    return FlightAirlineInfo(
      airlineName: json['airlineName'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
      totalReviews: json['totalReviews'] as int? ?? 0,
      overallRating: (json['overallRating'] as num?)?.toDouble() ?? 0.0,
      alliance: json['alliance'] as String?,
      type: json['type'] as String?,
      country: json['country'] as String?,
    );
  }
}

/// 항공편 검색 응답 모델
class FlightSearchResponse {
  final List<FlightAirlineInfo> airlines;
  final int count;
  final List<dynamic> flightOffers;

  FlightSearchResponse({
    required this.airlines,
    required this.count,
    required this.flightOffers,
  });

  factory FlightSearchResponse.fromJson(Map<String, dynamic> json) {
    return FlightSearchResponse(
      airlines: (json['airlines'] as List<dynamic>?)
              ?.map((e) => FlightAirlineInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      count: json['count'] as int? ?? 0,
      flightOffers: json['flight_offers'] as List<dynamic>? ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'airlines': airlines,
      'count': count,
      'flight_offers': flightOffers,
    };
  }
}
