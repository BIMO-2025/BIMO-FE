class Flight {
  final String departureCode;
  final String departureCity;
  final String arrivalCode;
  final String arrivalCity;
  final String duration;
  final String departureTime;
  final String arrivalTime;
  final double? rating;
  final String? date;
  final String? id;
  final bool? hasReview; // 리뷰 작성 여부

  const Flight({
    this.id,
    required this.departureCode,
    required this.departureCity,
    required this.arrivalCode,
    required this.arrivalCity,
    required this.duration,
    required this.departureTime,
    required this.arrivalTime,
    this.rating,
    this.date,
    this.hasReview,
  });
}
