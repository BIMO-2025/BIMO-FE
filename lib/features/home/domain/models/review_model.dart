class Review {
  final String nickname;
  final String profileImage;
  final double rating;
  final String date;
  final int likes;
  final List<String> tags;
  final String content;
  final List<String> images;
  final Map<String, dynamic>? detailRatings; // 카테고리별 평점 (선택사항)
  final String? userId; // 리뷰 작성자 ID (선택사항)
  final String? reviewId; // 리뷰 ID (선택사항, 좋아요 API용)

  Review({
    required this.nickname,
    required this.profileImage,
    required this.rating,
    required this.date,
    required this.likes,
    required this.tags,
    required this.content,
    required this.images,
    this.detailRatings, // 선택적 필드
    this.userId, // 선택적 필드
    this.reviewId, // 선택적 필드
  });
}
