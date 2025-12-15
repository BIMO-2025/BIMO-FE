import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../../../core/storage/auth_token_storage.dart';
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
        
        // Mock 데이터 생성 (실제 사용자 정보 반영)
        _myReviews = [
          Review(
            nickname: _nickname,
            profileImage: _profileImage,
            rating: 4.0,
            date: '2025.10.09.',
            likes: 22,
            tags: ['인천 - 파리 노선', 'KE901', '이코노미'],
            content:
                '좌석은 이코노미지만 넓고 나쁘지 않았어요 동양인들이 타기에는 나쁘지 않은 것 같아요 기내식은 비빔밥이랑 치즈랑 빵이 나왔어요 맛있어요 그리고 승무원 님들 서비스가 너무 좋았어요 14시간 내내 고생하시더라고요 그래서 어저구 저쩌구 했어요 ...더보기',
            images: [
              'assets/images/search/review_photo_1.png',
              'assets/images/search/review_photo_2.png',
              'assets/images/search/review_photo_3.png',
              'assets/images/search/review_photo_1.png',
            ],
          ),
        ];
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
      body: _myReviews.isEmpty
          ? Center(child: CircularProgressIndicator()) // 로딩 중
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
