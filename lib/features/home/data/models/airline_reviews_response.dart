/// 항공사 리뷰 목록 응답 모델
class AirlineReviewsResponse {
  final String airlineCode;
  final String airlineName;
  final double overallRating;
  final int totalReviews;
  final Map<String, double> averageRatings;
  final List<ReviewItem> reviews;
  final bool hasMore;

  AirlineReviewsResponse({
    required this.airlineCode,
    required this.airlineName,
    required this.overallRating,
    required this.totalReviews,
    required this.averageRatings,
    required this.reviews,
    required this.hasMore,
  });

  factory AirlineReviewsResponse.fromJson(Map<String, dynamic> json) {
    // averageRatings 파싱
    final Map<String, double> avgRatings = {};
    if (json['average_ratings'] != null) {
      final ratingsJson = json['average_ratings'] as Map<String, dynamic>;
      ratingsJson.forEach((key, value) {
        avgRatings[key] = (value as num?)?.toDouble() ?? 0.0;
      });
    }

    // reviews 파싱
    final List<ReviewItem> reviewsList = [];
    if (json['reviews'] != null) {
      final reviewsJson = json['reviews'] as List<dynamic>;
      reviewsList.addAll(
        reviewsJson.map((e) => ReviewItem.fromJson(e as Map<String, dynamic>)),
      );
    }

    return AirlineReviewsResponse(
      airlineCode: json['airline_code'] as String? ?? '',
      airlineName: json['airline_name'] as String? ?? '',
      overallRating: (json['overall_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      averageRatings: avgRatings,
      reviews: reviewsList,
      hasMore: json['has_more'] as bool? ?? false,
    );
  }
}

/// 개별 리뷰 아이템
class ReviewItem {
  final String airlineCode;
  final String airlineName;
  final bool isVerified;
  final double overallRating;
  final ReviewRatings ratings;
  final String route;
  final String text;
  final String userId;
  final String userNickname;
  final List<String> imageUrls; // 추가
  final int likes; // 추가
  final String createdAt; // 추가
  final String? flightNumber; // 추가
  final String? seatClass; // 추가
  final String? reviewId; // 추가 (좋아요 API용)

  final String? userProfileImage; // 추가: 사용자 프로필 이미지

  ReviewItem({
    required this.airlineCode,
    required this.airlineName,
    required this.isVerified,
    required this.overallRating,
    required this.ratings,
    required this.route,
    required this.text,
    required this.userId,
    required this.userNickname,
    required this.imageUrls,
    required this.likes,
    required this.createdAt,
    this.flightNumber,
    this.seatClass,
    this.reviewId,
    this.userProfileImage, // 추가
  });

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    return ReviewItem(
      airlineCode: json['airlineCode'] as String? ?? '',
      airlineName: json['airlineName'] as String? ?? '',
      isVerified: json['isVerified'] as bool? ?? false,
      overallRating: (json['overallRating'] as num?)?.toDouble() ?? 0.0,
      ratings: ReviewRatings.fromJson(json['ratings'] as Map<String, dynamic>? ?? {}),
      route: json['route'] as String? ?? '',
      text: json['text'] as String? ?? '',
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      userNickname: json['userNickname'] as String? ?? json['user_nickname'] as String? ?? '',
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      likes: json['likes'] as int? ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
      flightNumber: json['flightNumber'] as String?,
      seatClass: json['seatClass'] as String?,
      reviewId: json['id'] as String?,
      // 프로필 이미지 파싱 (다양한 키 시도)
      userProfileImage: json['userProfileImage'] as String? ?? 
                       json['user_profile_image'] as String? ??
                       json['profileImage'] as String? ??
                       json['profile_image'] as String?,
    );
  }
}

/// 리뷰 세부 평점
class ReviewRatings {
  final int checkIn;
  final int cleanliness;
  final int inflightMeal;
  final int seatComfort;
  final int service;

  ReviewRatings({
    required this.checkIn,
    required this.cleanliness,
    required this.inflightMeal,
    required this.seatComfort,
    required this.service,
  });

  factory ReviewRatings.fromJson(Map<String, dynamic> json) {
    return ReviewRatings(
      checkIn: json['checkIn'] as int? ?? 0,
      cleanliness: json['cleanliness'] as int? ?? 0,
      inflightMeal: json['inflightMeal'] as int? ?? 0,
      seatComfort: json['seatComfort'] as int? ?? 0,
      service: json['service'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'checkIn': checkIn,
      'cleanliness': cleanliness,
      'inflightMeal': inflightMeal,
      'seatComfort': seatComfort,
      'service': service,
    };
  }
}
