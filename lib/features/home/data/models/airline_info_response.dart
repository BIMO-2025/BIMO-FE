import 'airline_summary_response.dart';
import 'airline_detail_response.dart'; // AverageRatings 사용을 위해 import

/// 항공사 기본 정보 응답 모델
class AirlineInfoResponse {
  final String airlineName;
  final String logoUrl;
  final int totalReviews;
  final double overallRating;
  final String alliance;
  final String type; // FSC, LCC
  final String country;
  final String? hubAirport;
  final String? hubAirportName;
  final List<String> operatingClasses;
  final List<String> images;
  final String description;
  final AirlineSummaryResponse? bimoSummary;
  final AverageRatings? averageRatings; // 추가

  AirlineInfoResponse({
    required this.airlineName,
    required this.logoUrl,
    required this.totalReviews,
    required this.overallRating,
    required this.alliance,
    required this.type,
    required this.country,
    this.hubAirport,
    this.hubAirportName,
    required this.operatingClasses,
    required this.images,
    required this.description,
    this.bimoSummary,
    this.averageRatings,
  });

  factory AirlineInfoResponse.fromJson(Map<String, dynamic> json) {
    return AirlineInfoResponse(
      airlineName: json['name'] as String? ?? '', // API는 'name' 키 사용
      logoUrl: json['logo_url'] as String? ?? '', // API는 'logo_url' 키 사용
      totalReviews: json['total_reviews'] as int? ?? 0, // API는 'total_reviews' 키 사용
      overallRating: (json['overall_rating'] as num?)?.toDouble() ?? 0.0, // API는 'overall_rating' 키 사용
      alliance: json['alliance'] as String? ?? '',
      type: json['type'] as String? ?? '',
      country: json['country'] as String? ?? '',
      hubAirport: json['hub_airport'] as String?, // API는 'hub_airport' 키 사용
      hubAirportName: json['hub_airport_name'] as String?, // API는 'hub_airport_name' 키 사용
      operatingClasses: (json['operating_classes'] as List<dynamic>?) // API는 'operating_classes' 키 사용
              ?.map((e) => e.toString())
              .toList() ??
          [],
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      description: json['description'] as String? ?? '',
      bimoSummary: json['bimo_summary'] != null 
          ? AirlineSummaryResponse.fromJson(json['bimo_summary'] as Map<String, dynamic>)
          : (json['good_points'] != null || json['bad_points'] != null)
              ? AirlineSummaryResponse.fromJson(json)
              : null,
      averageRatings: json['average_ratings'] != null // API는 'average_ratings' 키 사용 (스네이크 케이스!)
          ? AverageRatings.fromJson(json['average_ratings'] as Map<String, dynamic>)
          : null,
    );
  }
}
