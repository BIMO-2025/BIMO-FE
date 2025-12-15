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
      airlineName: json['airlineName'] as String? ?? '',
      logoUrl: json['logoUrl'] as String? ?? '',
      totalReviews: json['totalReviews'] as int? ?? 0,
      overallRating: (json['overallRating'] as num?)?.toDouble() ?? 0.0,
      alliance: json['alliance'] as String? ?? '',
      type: json['type'] as String? ?? '',
      country: json['country'] as String? ?? '',
      hubAirport: json['hubAirport'] as String?,
      hubAirportName: json['hubAirportName'] as String?,
      operatingClasses: (json['operatingClasses'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      description: json['description'] as String? ?? '',
      bimoSummary: json['bimoSummary'] != null
          ? AirlineSummaryResponse.fromJson(json['bimoSummary'] as Map<String, dynamic>)
          : null,
      averageRatings: json['averageRatings'] != null
          ? AverageRatings.fromJson(json['averageRatings'] as Map<String, dynamic>)
          : null,
    );
  }
}
