class Review {
  final String nickname;
  final String profileImage;
  final double rating;
  final String date;
  final int likes;
  final List<String> tags;
  final String content;
  final List<String> images;

  Review({
    required this.nickname,
    required this.profileImage,
    required this.rating,
    required this.date,
    required this.likes,
    required this.tags,
    required this.content,
    required this.images,
  });
}
