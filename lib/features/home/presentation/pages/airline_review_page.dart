import 'dart:io'; // File 클래스 사용을 위해 추가
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../../../core/utils/airline_name_mapper.dart'; // AirlineNameMapper import
import '../../../../core/storage/auth_token_storage.dart'; // AuthTokenStorage import
import '../../domain/models/airline.dart';
import '../../domain/models/review_model.dart'; // Review 모델 import
import '../../data/datasources/airline_api_service.dart';
import '../../data/models/airline_reviews_response.dart';
import 'review_detail_page.dart';
import 'photo_grid_page.dart'; // PhotoGridPage import
import '../widgets/review_filter_bottom_sheet.dart';
import '../widgets/review_card.dart'; // ReviewCard import

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
  final AirlineApiService _apiService = AirlineApiService();
  
  bool _isFilterActive = false;
  String _selectedSort = '최신순';
  final List<String> _sortOptions = ['최신순', '추천순', '평점 높은 순', '평점 낮은 순'];
  
  // API 데이터
  bool _isLoading = true;
  List<ReviewItem> _apiReviews = [];
  AirlineReviewsResponse? _reviewsResponse;
  String? _currentUserId; // 현재 로그인한 사용자 ID

  // Mock Data for Reviews (fallback)
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
  void initState() {
    super.initState();
    _loadCurrentUserId();
    _loadReviews();
  }

  Future<void> _loadCurrentUserId() async {
    final storage = AuthTokenStorage();
    final userInfo = await storage.getUserInfo();
    setState(() {
      _currentUserId = userInfo['userId'];
    });
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getAirlineReviews(
        airlineCode: widget.airline.code,
        sort: _getSortParam(_selectedSort),
        limit: 100, // 리뷰 개수 제한 증가
        offset: 0,
      );

      if (!mounted) return;

      setState(() {
        _reviewsResponse = response;
        _apiReviews = response.reviews;
        _isLoading = false;
      });
      
      // 디버깅 로그
      print('📸 API 리뷰 로드 완료: ${response.reviews.length}개');
      for (var r in response.reviews) {
        if (r.imageUrls.isNotEmpty) {
          print('📸 리뷰(${r.userNickname}): 사진 ${r.imageUrls.length}장');
        }
      }
    } catch (e) {
      print('⚠️ 리뷰 API 실패, mock 데이터 사용: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getSortParam(String sortOption) {
    switch (sortOption) {
      case '최신순':
        return 'latest';
      case '추천순':
        return 'recommended';
      case '평점 높은 순':
        return 'rating_high';
      case '평점 낮은 순':
        return 'rating_low';
      default:
        return 'latest';
    }
  }

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
            AirlineNameMapper.toKorean(widget.airline.name), // 한국어 변환
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
    // API 데이터 우선 사용
    final rating = _reviewsResponse?.overallRating ?? widget.airline.rating;
    final reviewCount = _reviewsResponse?.totalReviews ?? widget.airline.reviewCount;
    
    // 세부 평점 매핑 (API 데이터가 있으면 사용, 없으면 Mock 데이터 사용)
    final avgRatings = _reviewsResponse?.averageRatings;
    final seatComfort = avgRatings?['seatComfort'] ?? widget.airline.detailRating.seatComfort;
    final foodAndBeverage = avgRatings?['inflightMeal'] ?? widget.airline.detailRating.foodAndBeverage;
    final service = avgRatings?['service'] ?? widget.airline.detailRating.service;
    final cleanliness = avgRatings?['cleanliness'] ?? widget.airline.detailRating.cleanliness;
    final punctuality = avgRatings?['checkIn'] ?? widget.airline.detailRating.punctuality; // checkIn을 시간 준수/수속으로 매핑

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
                '${rating.toStringAsFixed(1)}',
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
                '(${_formatNumber(reviewCount)})',
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
                  double roundedRating = (rating * 2).round() / 2;
                  
                  // 전체 별
                  if (roundedRating >= index + 1) {
                    return Icon(
                      Icons.star,
                      color: AppColors.yellow1,
                      size: context.w(20),
                    );
                  } 
                  // 반 별 (테두리 없이)
                  else if (roundedRating >= index + 0.5) {
                    return SizedBox(
                      width: context.w(20),
                      height: context.w(20),
                      child: Stack(
                        children: [
                          // 배경 (회색 별)
                          Icon(
                            Icons.star,
                            color: Colors.white.withOpacity(0.5),
                            size: context.w(20),
                          ),
                          // 반만 채워진 노란색 별
                          ClipRect(
                            clipper: _HalfClipper(),
                            child: Icon(
                              Icons.star,
                              color: AppColors.yellow1,
                              size: context.w(20),
                            ),
                          ),
                        ],
                      ),
                    );
                  } 
                  // 빈 별
                  else {
                    return Icon(
                      Icons.star,
                      color: Colors.white.withOpacity(0.5),
                      size: context.w(20),
                    );
                  }
                }),
              ),
            ],
          ),
          SizedBox(height: context.h(20)),
          _buildDetailRatingRow(context, '좌석 편안함', seatComfort),
          _buildDetailRatingRow(context, '기내식 및 음료', foodAndBeverage),
          _buildDetailRatingRow(context, '서비스', service),
          _buildDetailRatingRow(context, '청결도', cleanliness),
          _buildDetailRatingRow(context, '시간 준수도 및 수속', punctuality),
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
    // 1. 현재 표시할 리뷰 데이터 가져오기 (API 또는 Mock)
    List<Review> currentReviews = [];
    if (_apiReviews.isNotEmpty) {
      currentReviews = _apiReviews.map((apiReview) {
        String formattedDate = apiReview.createdAt;
        if (formattedDate.length >= 10) {
          formattedDate = formattedDate.substring(0, 10).replaceAll('-', '.');
        }
        final tags = <String>[];
        if (apiReview.route.isNotEmpty) tags.add(apiReview.route);
        if (apiReview.flightNumber != null && apiReview.flightNumber!.isNotEmpty) tags.add(apiReview.flightNumber!);
        // 좌석 등급 삭제
        // if (apiReview.seatClass != null && apiReview.seatClass!.isNotEmpty) tags.add(apiReview.seatClass!);

        return Review(
          nickname: apiReview.userNickname,
          profileImage: 'assets/images/my/default_profile.png',
          rating: apiReview.overallRating,
          date: formattedDate,
          likes: apiReview.likes,
          tags: tags,
          content: apiReview.text,
          images: apiReview.imageUrls,
          userId: apiReview.userId, // userId 추가
          detailRatings: apiReview.ratings.toJson(), // 세부 평점 (Map으로 변환)
          reviewId: apiReview.reviewId, // reviewId 추가 (좋아요 API용)
        );
      }).toList();
    } else {
      currentReviews = _reviews;
    }

    // 2. 사진이 있는 리뷰만 필터링
    final photoReviews = currentReviews.where((r) => r.images.isNotEmpty).toList();
    
    // 3. 전체 사진 개수 계산
    int totalPhotoCount = 0;
    for (var review in photoReviews) {
      totalPhotoCount += review.images.length;
    }

    if (photoReviews.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(20)),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhotoGridPage(reviews: currentReviews),
                ),
              );
            },
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
                      '${photoReviews.length}', // 사진이 있는 리뷰 개수 표시
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: context.fs(16),
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
                Image.asset(
                  'assets/images/home/chevron_right.png',
                  width: context.w(24),
                  height: context.h(24),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: context.h(12)),
        SizedBox(
          height: context.w(100),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: context.w(20)),
            scrollDirection: Axis.horizontal,
            itemCount: photoReviews.length,
            separatorBuilder: (context, index) => SizedBox(width: context.w(8)),
            itemBuilder: (context, index) {
              final review = photoReviews[index];
              return GestureDetector(
                onTap: () {
                  // 사진 클릭 시 해당 리뷰 상세 팝업
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: EdgeInsets.all(context.w(20)),
                      child: Stack(
                        children: [
                          ReviewCard(review: review),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: EdgeInsets.all(context.w(8)),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  width: context.w(100),
                  height: context.w(100),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(context.w(12)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildReviewImage(review.images[0]), // 이미지 렌더링 헬퍼 사용
                        // 사진이 여러 장인 경우 표시
                        if (review.images.length > 1)
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              margin: EdgeInsets.all(context.w(6)),
                              padding: EdgeInsets.all(context.w(4)),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(context.w(4)),
                              ),
                              child: Icon(
                                Icons.filter_none, // 여러 장 아이콘
                                color: Colors.white,
                                size: context.w(12),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: context.h(32)),
      ],
    );
  }

  Widget _buildReviewImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.network(
            'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800&q=80', // 비행기 대체 이미지
            fit: BoxFit.cover,
          );
        },
      );
    } else if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
           return Container(color: const Color(0xFF333333));
        },
      );
    } else {
      return Image.file(
        File(imagePath), 
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
           return Container(color: const Color(0xFF333333));
        },
      );
    }
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
                  _loadReviews(); // API 재호출
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
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(context.w(40)),
          child: CircularProgressIndicator(color: AppColors.yellow1),
        ),
      );
    }
    
    // API 데이터를 Review 객체로 변환
    List<Review> displayReviews = [];
    
    if (_apiReviews.isNotEmpty) {
      // API 데이터를 Mock Review 형식으로 변환
      displayReviews = _apiReviews.map((apiReview) {
        // 날짜 포맷팅 (YYYY-MM-DD)
        String formattedDate = apiReview.createdAt;
        if (formattedDate.length >= 10) {
          formattedDate = formattedDate.substring(0, 10).replaceAll('-', '.');
        }

        // 태그 생성
        final tags = <String>[];
        if (apiReview.route.isNotEmpty) tags.add(apiReview.route);
        if (apiReview.flightNumber != null && apiReview.flightNumber!.isNotEmpty) {
          tags.add(apiReview.flightNumber!);
        }
        // 좌석 등급 제거 (요구사항에 따라)
        // if (apiReview.seatClass != null && apiReview.seatClass!.isNotEmpty) {
        //   tags.add(apiReview.seatClass!);
        // }

        return Review(
          nickname: apiReview.userNickname,
          profileImage: 'assets/images/my/default_profile.png', // 기본 프로필 이미지로 변경
          rating: apiReview.overallRating,
          date: formattedDate,
          likes: apiReview.likes,
          tags: tags,
          content: apiReview.text,
          images: apiReview.imageUrls, // 이미지 URL 리스트 연결
          userId: apiReview.userId, // userId 추가
          detailRatings: apiReview.ratings.toJson(), // 세부 평점 (Map으로 변환)
          reviewId: apiReview.reviewId, // reviewId 추가 (좋아요 API용)
        );
      }).toList();
    } else {
      // API 데이터 없으면 Mock 데이터 사용
      displayReviews = _reviews;
    }
    
    return ListView.separated(
      padding: EdgeInsets.all(context.w(20)),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayReviews.length,
      separatorBuilder: (context, index) => SizedBox(height: context.h(12)),
      itemBuilder: (context, index) {
        final review = displayReviews[index];
        // 현재 사용자의 리뷰인지 확인
        final isMyReview = _currentUserId != null && review.userId == _currentUserId;
        return ReviewCard(
          review: review,
          isMyReview: isMyReview, // 본인 리뷰면 신고하기 버튼 숨김
        );
      },
    );
  }

  ImageProvider _getImageProvider(String imagePath) {
    if (imagePath.startsWith('http')) {
      return NetworkImage(imagePath);
    } else if (imagePath.startsWith('assets/')) {
      return AssetImage(imagePath);
    } else {
      return FileImage(File(imagePath));
    }
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }
}

/// Custom clipper to show half of a star
class _HalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width / 2, size.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => false;
}
