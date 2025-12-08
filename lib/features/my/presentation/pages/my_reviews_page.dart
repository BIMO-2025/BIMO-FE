import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../../home/presentation/pages/airline_review_page.dart'; // Review 클래스
import '../../../home/presentation/pages/review_detail_page.dart';

/// 나의 리뷰 페이지
class MyReviewsPage extends StatelessWidget {
  const MyReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 백엔드에서 사용자 리뷰 데이터 가져오기
    final myReviews = [
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
        actions: [
          // 리뷰 메뉴 아이콘 (40x40, 오른쪽 20 패딩)
          Padding(
            padding: EdgeInsets.only(right: context.w(20)),
            child: GestureDetector(
              onTap: () {
                // TODO: 리뷰 메뉴 (편집/삭제 등) 바텀시트 표시
              },
              child: Image.asset(
                'assets/images/my/Review_menu.png',
                width: context.w(40),
                height: context.h(40),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: EdgeInsets.only(
          top: context.h(15),
          left: context.w(20),
          right: context.w(20),
          bottom: context.h(20),
        ),
        itemCount: myReviews.length,
        separatorBuilder: (context, index) => SizedBox(height: context.h(12)),
        itemBuilder: (context, index) {
          final review = myReviews[index];
          return _buildReviewCard(context, review);
        },
      ),
    );
  }

  /// 리뷰 카드 위젯 (airline_review_page.dart와 동일 구조)
  Widget _buildReviewCard(BuildContext context, Review review) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewDetailPage(review: review),
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
                  margin: EdgeInsets.only(right: context.w(4)),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.w(8),
                    vertical: context.h(4),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(context.w(12)),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: context.fs(12),
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
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

            // Photos (if any)
            if (review.images.isNotEmpty) ...[
              SizedBox(height: context.h(12)),
              Transform.translate(
                offset: Offset(-20, 0),
                child: SizedBox(
                  height: context.h(80),
                  width: context.w(335),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    itemCount: review.images.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(width: context.w(8)),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(context.w(8)),
                        child: Image.asset(
                          review.images[index],
                          width: context.w(80),
                          height: context.h(80),
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],

            SizedBox(height: context.h(12)),

            // Date
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
}

