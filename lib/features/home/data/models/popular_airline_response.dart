/// 주차별 인기 항공사 응답 모델
class PopularAirlineResponse {
  final String id;
  final String name;
  final String code;
  final String country;
  final String alliance;
  final String type; // FSC, LCC 등
  final double rating;
  final int reviewCount;
  final String logoUrl;
  final int rank;

  PopularAirlineResponse({
    required this.id,
    required this.name,
    required this.code,
    required this.country,
    required this.alliance,
    required this.type,
    required this.rating,
    required this.reviewCount,
    required this.logoUrl,
    required this.rank,
  });

  /// JSON에서 객체 생성
  factory PopularAirlineResponse.fromJson(Map<String, dynamic> json) {
    return PopularAirlineResponse(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      country: json['country'] as String? ?? '',
      alliance: json['alliance'] as String? ?? '',
      type: json['type'] as String? ?? 'FSC',
      rating: (json['rating'] as num?)?.toDouble() ??
          (json['overall_rating'] as num?)?.toDouble() ??
          (json['overallRating'] as num?)?.toDouble() ??
          0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      logoUrl: json['logo_url'] as String? ?? '',
      rank: json['rank'] as int? ?? 0,
    );
  }

  /// 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'country': country,
      'alliance': alliance,
      'type': type,
      'rating': rating,
      'review_count': reviewCount,
      'logo_url': logoUrl,
      'rank': rank,
    };
  }
}

