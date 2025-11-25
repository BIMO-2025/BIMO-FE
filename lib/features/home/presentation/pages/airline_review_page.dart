import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../domain/models/airline.dart';
import 'review_detail_page.dart';
import '../widgets/review_filter_bottom_sheet.dart';

class AirlineReviewPage extends StatefulWidget {
  final Airline airline;

  const AirlineReviewPage({
    super.key,
    required this.airline,
  });

  @override
  State<AirlineReviewPage> createState() => _AirlineReviewPageState();
}

class _AirlineReviewPageState extends State<AirlineReviewPage> {
  bool _isFilterActive = false;
  String _selectedSort = '최신순';
  final List<String> _sortOptions = ['최신순', '추천순', '평점 높은 순', '평점 낮은 순'];

  // Mock Data for Reviews
  final List<Review> _reviews = [
    Review(
      nickname: '여행조아',
      profileImage: 'assets/images/search/user_img.png',
      rating: 4.0,
      date: '2025.10.09.',
      likes: 22,
      tags: ['인천 - 파리 노선', 'KE901', '이코노미'],
      content: '좌석은 이코노미지만 넓고 나쁘지 않았어요 동양인들이 타기에는 나쁘지 않은 것 같아요 기내식은 비빔밥이랑 치즈랑 빵이 나왔어요 맛있어요 그리고 승무원 님들 서비스가 너무 좋았어요 14시간 내내 고생하시더라고요 그래서 어저구 저쩌구 했어요 ...더보기',
      images: [
        'assets/images/search/review_photo_1.png',
        'assets/images/search/review_photo_2.png',
        'assets/images/search/review_photo_3.png',
        'assets/images/search/review_photo_1.png',
      ],
    ),
    Review(
      nickname: '여행조아',
      profileImage: 'assets/images/search/user_img.png',
      rating: 4.0,
      date: '2025.10.09.',
      likes: 22,
      tags: ['인천 - 파리 노선', 'KE901', '이코노미'],
      content: '좌석은 이코노미지만 넓고 나쁘지 않았어요 동양인들이 타기에는 나쁘지 않은 것 같아요 기내식은 비빔밥이랑 치즈랑 빵이 나왔어요 맛있어요 그리고 승무원 님들 서비스가 너무 좋았어요 14시간 내내 고생하시더라고요 그래서 어저구 저쩌구 했어요 ...더보기',
      images: [
        'assets/images/search/review_photo_1.png',
        'assets/images/search/review_photo_2.png',
        'assets/images/search/review_photo_3.png',
        'assets/images/search/review_photo_1.png',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131313),
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: context.w(60),
        leading: Padding(
          padding: EdgeInsets.only(left: context.w(20)),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: SizedBox(
              width: context.w(40),
              height: context.h(40),
              child: Image.asset(
                'assets/images/search/back_arrow_icon.png',
                width: context.w(40),
                height: context.h(40),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        title: Text(
          '상세 리뷰',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: context.fs(17),
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildRatingHeader(context),
            _buildPhotoReviews(context),
            _buildFilterBar(context),
            _buildReviewList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingHeader(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(context.w(20)),
      padding: EdgeInsets.all(context.w(20)),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(context.w(16)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.airline.rating}',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: context.fs(24),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                ' / 5',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: context.fs(16),
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8E8E93),
                ),
              ),
              SizedBox(width: context.w(8)),
              Text(
                '(${_formatNumber(widget.airline.reviewCount)})',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: context.fs(14),
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8E8E93),
                ),
              ),
              SizedBox(width: context.w(12)),
              Row(
                children: List.generate(5, (index) {
                  double rating = widget.airline.rating;
                  double roundedRating = (rating * 2).round() / 2;
                  
                  IconData icon;
                  Color color;

                  if (roundedRating >= index + 1) {
                    icon = Icons.star;
                    color = AppColors.yellow1;
                  } else if (roundedRating >= index + 0.5) {
                    icon = Icons.star_half;
                    color = AppColors.yellow1;
                  } else {
                    icon = Icons.star;
                    color = Colors.white.withOpacity(0.5);
                  }

                  return Icon(
                    icon,
                    color: color,
                    size: context.w(20),
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: context.h(20)),
          _buildDetailRatingRow(context, '좌석 편안함', widget.airline.detailRating.seatComfort),
          _buildDetailRatingRow(context, '기내식 및 음료', widget.airline.detailRating.foodAndBeverage),
          _buildDetailRatingRow(context, '서비스', widget.airline.detailRating.service),
          _buildDetailRatingRow(context, '청결도', widget.airline.detailRating.cleanliness),
          _buildDetailRatingRow(context, '시간 준수도 및 수속', widget.airline.detailRating.punctuality),
        ],
      ),
    );
  }

  Widget _buildDetailRatingRow(BuildContext context, String label, double rating) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.h(12)),
      child: Row(
        children: [
          SizedBox(
            width: context.w(120),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: context.fs(14),
                fontWeight: FontWeight.w400,
                color: const Color(0xFFCCCCCC),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: context.h(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(context.w(3)),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: rating / 5.0,
                  child: Container(
                    height: context.h(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCCCCC),
                      borderRadius: BorderRadius.circular(context.w(3)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.w(12)),
          SizedBox(
            width: context.w(30),
            child: Text(
              rating.toStringAsFixed(1),
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: context.fs(14),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoReviews(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '사진 리뷰',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: context.fs(16),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: context.w(6)),
                  Text(
                    '850', // Mock count
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: context.fs(16),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
              Icon(Icons.chevron_right, color: Colors.white, size: context.w(24)),
            ],
          ),
        ),
        SizedBox(height: context.h(12)),
        SizedBox(
          height: context.w(100),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: context.w(20)),
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            separatorBuilder: (context, index) => SizedBox(width: context.w(8)),
            itemBuilder: (context, index) {
              return Container(
                width: context.w(100),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.w(12)),
                  color: const Color(0xFF333333), // Placeholder color
                  // image: DecorationImage(...) // TODO: Add real images
                ),
              );
            },
          ),
        ),
        SizedBox(height: context.h(32)),
      ],
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: _sortOptions.map((option) {
              final isSelected = _selectedSort == option;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSort = option;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.only(right: context.w(12)),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: context.fs(13),
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF8E8E93),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          GestureDetector(
            onTap: () async {
              if (_isFilterActive) {
                // If filter is active, just clear it without opening bottom sheet
                setState(() {
                  _isFilterActive = false;
                });
              } else {
                // Open filter bottom sheet
                final result = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const ReviewFilterBottomSheet(),
                );
                
                if (result != null) {
                  setState(() {
                    _isFilterActive = result;
                  });
                }
              }
            },
            child: Row(
              children: [
                Icon(
                  Icons.tune,
                  color: _isFilterActive ? Colors.white : const Color(0xFF8E8E93),
                  size: context.w(16),
                ),
                SizedBox(width: context.w(4)),
                Text(
                  _isFilterActive ? '필터 해제' : '리뷰 필터',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: context.fs(13),
                    fontWeight: FontWeight.w500,
                    color: _isFilterActive ? Colors.white : const Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewList(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(context.w(20)),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _reviews.length,
      separatorBuilder: (context, index) => SizedBox(height: context.h(12)),
      itemBuilder: (context, index) {
        final review = _reviews[index];
        return Container(
          padding: EdgeInsets.all(context.w(20)),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(context.w(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: context.w(16),
                        backgroundColor: const Color(0xFF333333),
                        backgroundImage: AssetImage(review.profileImage),
                      ),
                      SizedBox(width: context.w(8)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.nickname,
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: context.fs(14),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: context.h(2)),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.white, size: context.w(12)),
                              SizedBox(width: context.w(2)),
                              Text(
                                '${review.rating}',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: context.fs(12),
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '/5.0',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: context.fs(12),
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF8E8E93),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    '좋아요 ${review.likes}',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: context.fs(13),
                      fontWeight: FontWeight.w500,
                      color: AppColors.yellow1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.h(12)),
              
              // Tags
              Row(
                children: review.tags.map((tag) {
                  return Container(
                    margin: EdgeInsets.only(right: context.w(6)),
                    padding: EdgeInsets.symmetric(
                      horizontal: context.w(8),
                      vertical: context.h(4),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF333333),
                      borderRadius: BorderRadius.circular(context.w(4)),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: context.fs(12),
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFCCCCCC),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: context.h(12)),

              // Photos
              SizedBox(
                height: context.w(80),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero, // Remove default padding
                  itemCount: review.images.length,
                  separatorBuilder: (context, index) => SizedBox(width: context.w(8)),
                  itemBuilder: (context, index) {
                    return Container(
                      width: context.w(80),
                      height: context.w(80),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(context.w(8)),
                        color: const Color(0xFF333333),
                        // image: DecorationImage(...)
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: context.h(12)),

              // Content
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: context.fs(14),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFCCCCCC),
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: review.content.replaceAll('...더보기', ''),
                    ),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewDetailPage(review: review),
                            ),
                          );
                        },
                        child: Text(
                          '...더보기',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: context.fs(14),
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF8E8E93),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.h(12)),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '신고하기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: context.fs(12),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF555555),
                    ),
                  ),
                  Text(
                    review.date,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: context.fs(12),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }
}

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
