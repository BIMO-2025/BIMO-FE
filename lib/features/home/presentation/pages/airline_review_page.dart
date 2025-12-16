import 'dart:io'; // File 클래스 사용을 위해 추가
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../../../core/utils/airline_name_mapper.dart'; // AirlineNameMapper import
import '../../../../core/utils/image_utils.dart'; // ImageUtils import
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
  Map<String, dynamic> _filterOptions = {}; // 필터 옵션 저장
  
  // API 데이터
  bool _isLoading = true;
  List<ReviewItem> _apiReviews = [];
  AirlineReviewsResponse? _reviewsResponse;
  String? _currentUserId; // 현재 로그인한 사용자 ID
  String _currentUserNickname = '사용자';
  String _currentUserProfileImage = 'assets/images/my/default_profile.png';

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
    if (mounted) {
      setState(() {
        _currentUserId = userInfo['userId'];
        _currentUserNickname = userInfo['name'] ?? '사용자';
        final savedPhotoUrl = userInfo['photoUrl'];
        if (savedPhotoUrl != null && savedPhotoUrl.isNotEmpty) {
           _currentUserProfileImage = savedPhotoUrl;
        }
      });
    }
  }

  Review _mapToReview(ReviewItem apiReview) {
    String formattedDate = apiReview.createdAt;
    if (formattedDate.length >= 10) {
      formattedDate = formattedDate.substring(0, 10).replaceAll('-', '.');
    }
    
    final tags = <String>[];
    if (apiReview.route.isNotEmpty) tags.add(apiReview.route);
    if (apiReview.flightNumber != null && apiReview.flightNumber!.isNotEmpty) tags.add(apiReview.flightNumber!);
    
    // 내 리뷰인지 확인
    final isMyReview = _currentUserId != null && _currentUserId == apiReview.userId;

    return Review(
      nickname: isMyReview ? _currentUserNickname : apiReview.userNickname, // 내 리뷰면 최신 닉네임 사용
      profileImage: isMyReview ? _currentUserProfileImage : (apiReview.userProfileImage ?? 'assets/images/my/default_profile.png'), // 내 리뷰면 최신 사진, 남의 리뷰면 API 사진 또는 기본값
      rating: apiReview.overallRating,
      date: formattedDate,
      likes: apiReview.likes,
      tags: tags,
      content: apiReview.text,
      images: apiReview.imageUrls,
      userId: apiReview.userId,
      detailRatings: apiReview.ratings.toJson(),
      reviewId: apiReview.reviewId,
    );
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getAirlineReviews(
        airlineCode: widget.airline.code,
        sort: _getSortParam(_selectedSort),
        limit: 100,
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

  int? _parseRating(String? ratingStr) {
    if (ratingStr == null || ratingStr == '전체') return null;
    // "5점" -> 5
    final match = RegExp(r'(\d+)').firstMatch(ratingStr);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
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
            if (_isFilterActive) _buildActiveFilters(context), // 필터 칩 추가
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
      currentReviews = _apiReviews.map((apiReview) => _mapToReview(apiReview)).toList();
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
              return SizedBox(
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
                );
            },
          ),
        ),
        SizedBox(height: context.h(32)),
      ],
    );
  }

  Widget _buildReviewImage(String imagePath) {
    return ImageUtils.buildImage(imagePath);
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
                // If filter is active, clear it
                setState(() {
                  _isFilterActive = false;
                  _filterOptions = {}; // 필터 초기화
                });
                _loadReviews(); // 초기화된 목록 로드
              } else {
                // Open filter bottom sheet
                final result = await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const ReviewFilterBottomSheet(),
                );
                
                if (result != null && result is Map<String, dynamic>) {
                  setState(() {
                    _isFilterActive = result['applied'] ?? false;
                    _filterOptions = result;
                  });
                  _loadReviews(); // 필터 적용된 목록 로드
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

  Widget _buildActiveFilters(BuildContext context) {
    if (!_isFilterActive) return const SizedBox.shrink();

    final chips = <Widget>[];

    // 1. 노선 필터 칩
    final dep = _filterOptions['departureAirport'];
    final arr = _filterOptions['arrivalAirport'];
    if (dep != null && dep != '전체' && arr != null && arr != '전체') {
       // 공항 코드만 추출 (예: "인천 (ICN)" -> "ICN")
       final depCode = RegExp(r'\((.*?)\)').firstMatch(dep)?.group(1) ?? dep;
       final arrCode = RegExp(r'\((.*?)\)').firstMatch(arr)?.group(1) ?? arr;
       
       chips.add(_buildFilterChip(
         label: '$depCode → $arrCode',
         onDeleted: () {
           setState(() {
             _filterOptions['departureAirport'] = '전체';
             _filterOptions['arrivalAirport'] = '전체';
             _checkFilterStatus();
           });
         },
       ));
    }

    // 2. 기간 필터 칩
    final period = _filterOptions['period'];
    if (period != null && period != '전체') {
      chips.add(_buildFilterChip(
        label: period,
        onDeleted: () {
          setState(() {
            _filterOptions['period'] = '전체';
             _checkFilterStatus();
          });
        },
      ));
    }

    // 3. 평점 필터 칩
    final ratingStr = _filterOptions['minRatingRaw']; // 원본 문자열 사용 권장하거나, _filterOptions에 저장된 값 확인
    // _parseRating을 통해 int로 저장했으므로, 다시 확인. 
    // 기존 코드에서는 _parseRating 결과를 저장하지 않고 _filterOptions['minRating']에는 문자열이 들어있을 수 있음.
    // 확인: _loadReviews에서 _parseRating을 호출해서 보냄. _filterOptions 자체에는 바텀시트에서 받은 원본(Map)이 들어있음(문자열).
    final ratingVal = _filterOptions['minRating']; 
    if (ratingVal != null && ratingVal != '전체') {
      chips.add(_buildFilterChip(
        label: ratingVal, // "4점" 등
        onDeleted: () {
          setState(() {
            _filterOptions['minRating'] = '전체';
             _checkFilterStatus();
          });
        },
      ));
    }

    // 4. 사진 필터 칩
    if (_filterOptions['photoOnly'] == true) {
      chips.add(_buildFilterChip(
        label: '사진 리뷰만',
        onDeleted: () {
          setState(() {
            _filterOptions['photoOnly'] = false;
             _checkFilterStatus();
          });
        },
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(context.w(20), 0, context.w(20), context.h(16)),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: context.w(8),
          runSpacing: context.h(8),
          children: chips,
        ),
      ),
    );
  }

  void _checkFilterStatus() {
     // 모든 필터가 해제되었는지 확인
     final dep = _filterOptions['departureAirport'];
     final arr = _filterOptions['arrivalAirport'];
     final period = _filterOptions['period'];
     final rating = _filterOptions['minRating'];
     final photoOnly = _filterOptions['photoOnly'];

     if ((dep == null || dep == '전체') &&
         (arr == null || arr == '전체') &&
         (period == null || period == '전체') &&
         (rating == null || rating == '전체') &&
         (photoOnly != true)) {
       _isFilterActive = false;
     } else {
       _isFilterActive = true;
     }
  }

  Widget _buildFilterChip({required String label, required VoidCallback onDeleted}) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 12, // context.fs 사용 불가시 하드코딩 혹은 수정
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFF333333),
      deleteIcon: const Icon(Icons.close, size: 16, color: Color(0xFF8E8E93)),
      onDeleted: onDeleted,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
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
    List<Review> displayReviews = _apiReviews.map((apiReview) => _mapToReview(apiReview)).toList();
    
    if (_apiReviews.isNotEmpty) {
      // 1. 클라이언트 사이드 필터링
      List<ReviewItem> filteredItems = List.from(_apiReviews);
      
      if (_isFilterActive) {
        filteredItems = filteredItems.where((item) {
          // 노선 필터 (유연한 로직)
          final filterDep = _filterOptions['departureAirport'];
          final filterArr = _filterOptions['arrivalAirport'];
          
          if (filterDep != null && filterDep != '전체') {
            // "ICN"이 route("ICN-CDG")에 포함되는지 확인
            if (!item.route.contains(filterDep)) {
               print('🔍 노선 필터 제외: route(${item.route}) does not contain $filterDep');
               return false;
            }
          }
          if (filterArr != null && filterArr != '전체') {
            if (!item.route.contains(filterArr)) {
               print('🔍 노선 필터 제외: route(${item.route}) does not contain $filterArr');
               return false;
            }
          }
          
          // 평점 필터 (범위)
          // "5점" -> 5.0
          // "4점" -> 4.0 <= rating < 5.0
          final ratingStr = _filterOptions['minRating'];
          final rating = _parseRating(ratingStr);
          
          if (rating != null) {
            if (rating == 5) {
              if (item.overallRating < 5.0) return false;
            } else {
              // 해당 점수 대 (예: 4점대 -> 4.0 ~ 4.9)
              if (item.overallRating < rating || item.overallRating >= rating + 1) return false;
            }
          }
          
          // 사진 리뷰 필터
          if (_filterOptions['photoOnly'] == true && item.imageUrls.isEmpty) return false;
          
          // 기간 필터
          final period = _filterOptions['period'];
          if (period != null && period != '전체') {
            final date = DateTime.tryParse(item.createdAt);
            if (date != null) {
              final now = DateTime.now();
              final diff = now.difference(date).inDays;
              if (period == '최근 3개월' && diff > 90) return false;
              if (period == '최근 6개월' && diff > 180) return false;
              if (period == '최근 1년' && diff > 365) return false;
            }
          }
          
          return true;
        }).toList();
      }
      
      // 2. 클라이언트 사이드 정렬 (필터링된 결과에 적용)
      switch (_selectedSort) {
        case '최신순':
          filteredItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case '추천순':
          filteredItems.sort((a, b) => b.likes.compareTo(a.likes));
          break;
        case '평점 높은 순':
          filteredItems.sort((a, b) => b.overallRating.compareTo(a.overallRating));
          break;
        case '평점 낮은 순':
          filteredItems.sort((a, b) => a.overallRating.compareTo(b.overallRating));
          break;
      }

      // 3. 변환
      // 3. 변환
      displayReviews = filteredItems.map((apiReview) => _mapToReview(apiReview)).toList();
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
