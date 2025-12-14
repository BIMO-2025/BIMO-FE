/// 평점 순 정렬된 항공사 목록 응답 모델
class AirlineSortingResponse {
  final String id;
  final String name;
  final String code;
  final String country;
  final String alliance;
  final String type; // "FSC" or "LCC"
  final double rating;
  final int reviewCount;
  final String logoUrl;
  final int rank;

  AirlineSortingResponse({
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

  factory AirlineSortingResponse.fromJson(Map<String, dynamic> json) {
    return AirlineSortingResponse(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      country: json['country'] as String? ?? '',
      alliance: json['alliance'] as String? ?? '',
      type: json['type'] as String? ?? 'FSC',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      logoUrl: json['logo_url'] as String? ?? '',
      rank: json['rank'] as int? ?? 0,
    );
  }
}
