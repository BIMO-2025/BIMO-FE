import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../../home/domain/models/review_model.dart'; // Review 모델 import
import '../../../../core/storage/auth_token_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../home/presentation/pages/airline_review_page.dart'; // Review 클래스
import '../../../home/presentation/pages/review_detail_page.dart';

/// 나의 리뷰 페이지
class MyReviewsPage extends StatefulWidget {
  const MyReviewsPage({super.key});

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> {
  String _nickname = '사용자';
  String _profileImage = 'assets/images/my/default_profile.png'; // 기본 이미지
  List<Review> _myReviews = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final storage = AuthTokenStorage();
    final userInfo = await storage.getUserInfo();
    
    if (mounted) {
      setState(() {
        _nickname = userInfo['name'] ?? '사용자';
        final savedPhotoUrl = userInfo['photoUrl'];
        if (savedPhotoUrl != null && savedPhotoUrl.isNotEmpty) {
           _profileImage = savedPhotoUrl;
        }
      });
      
      // userId로 리뷰 가져오기
      final userId = userInfo['userId'];
      if (userId != null && userId.isNotEmpty) {
        await _fetchUserReviews(userId);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = '사용자 ID를 찾을 수 없습니다.';
        });
      }
    }
  }

  Future<void> _fetchUserReviews(String userId) async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.get(
        ApiConstants.userReviews(userId),
        queryParameters: {
          'limit': 20,
          'offset': 0,
          'sort': 'latest',
        },
      );

      print('🔍 나의 리뷰 API 응답 (Status ${response.statusCode}):');
      print('📦 응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final reviews = data['reviews'] as List;
        
        print('📝 리뷰 개수: ${reviews.length}');
        if (reviews.isNotEmpty) {
          print('📄 첫 번째 리뷰 샘플: ${reviews[0]}');
        }
        
        setState(() {
          _myReviews = reviews.map((reviewData) {
            return Review(
              nickname: reviewData['userNickname'] ?? _nickname,
              profileImage: reviewData['userProfileImage'] ?? _profileImage,
              rating: (reviewData['overallRating'] ?? 0).toDouble(),
              date: reviewData['createdAt'] ?? '',
              likes: reviewData['likes'] ?? 0,
              tags: [
                reviewData['airlineCode'] ?? '',
                reviewData['airlineName'] ?? '',
              ],
              content: reviewData['text'] ?? '',
              images: (reviewData['imageUrls'] as List?)?.cast<String>() ?? [],
            );
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = '리뷰를 불러올 수 없습니다.';
        });
      }
    } catch (e) {
      print('❌ 리뷰 로딩 실패: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = '리뷰를 불러오는 중 오류가 발생했습니다.';
      });
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
          '나의 리뷰',
          style: AppTextStyles.large.copyWith(color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.yellow1))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: AppTextStyles.medium.copyWith(color: AppColors.white),
                      ),
                      SizedBox(height: context.h(16)),
                      ElevatedButton(
                        onPressed: _loadUserInfo,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : _myReviews.isEmpty
                  ? Center(
                      child: Text(
                        '작성한 리뷰가 없습니다.',
                        style: AppTextStyles.medium.copyWith(color: AppColors.white),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.only(
                        top: context.h(15),
                        left: context.w(20),
                        right: context.w(20),
                        bottom: context.h(20),
                      ),
                      itemCount: _myReviews.length,
                      separatorBuilder: (context, index) => SizedBox(height: context.h(12)),
                      itemBuilder: (context, index) {
                        final review = _myReviews[index];
                        return _buildReviewCard(context, review);
                      },
                    ),
    );
  }

  /// 리뷰 카드 위젯
  Widget _buildReviewCard(BuildContext context, Review review) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ReviewDetailPage(
                  review: review,
                  isMyReview: true, // 나의 리뷰임을 표시
                ),
          ),
        );
      },
      child: Container(
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
                      backgroundImage: _getImageProvider(review.profileImage),
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
                            Icon(
                              Icons.star,
                              color: Colors.white,
                              size: context.w(12),
                            ),
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
              children:
                  review.tags.map((tag) {
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
              width: context.w(315), // 콘텐츠 영역(295) + 오른쪽 확장(20)
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: review.images.length,
                separatorBuilder:
                    (context, index) => SizedBox(width: context.w(8)),
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
            Text(
              review.content,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: context.fs(14),
                fontWeight: FontWeight.w400,
                color: Colors.white,
                height: 1.5,
              ),
            ),

            SizedBox(height: context.h(12)),

            // Footer (Date only, no report button for own reviews)
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
      ),
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
}
