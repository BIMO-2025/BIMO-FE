import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_extensions.dart';
import 'airline_review_page.dart'; // For Review class

class ReviewDetailPage extends StatelessWidget {
  final Review review;

  const ReviewDetailPage({
    super.key,
    required this.review,
  });

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
          '${review.nickname} 님의 리뷰',
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
        padding: EdgeInsets.all(context.w(20)),
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
                        radius: context.w(20),
                        backgroundColor: const Color(0xFF333333),
                        backgroundImage: AssetImage(review.profileImage),
                      ),
                      SizedBox(width: context.w(12)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.nickname,
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: context.fs(16),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: context.h(4)),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.white, size: context.w(14)),
                              SizedBox(width: context.w(2)),
                              Text(
                                '${review.rating}',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: context.fs(14),
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '/5.0',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: context.fs(14),
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
                      fontSize: context.fs(14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.yellow1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.h(16)),

              // Tags
              Row(
                children: review.tags.map((tag) {
                  return Container(
                    margin: EdgeInsets.only(right: context.w(6)),
                    padding: EdgeInsets.symmetric(
                      horizontal: context.w(10),
                      vertical: context.h(6),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF333333),
                      borderRadius: BorderRadius.circular(context.w(6)),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: context.fs(13),
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFCCCCCC),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: context.h(24)),

              // Detail Ratings (Mock data for now as it's not in Review model yet)
              _buildDetailRatingRow(context, '좌석 편안함', 2.4),
              _buildDetailRatingRow(context, '기내식 및 음료', 3.8),
              _buildDetailRatingRow(context, '서비스', 4.8),
              _buildDetailRatingRow(context, '청결도', 2.7),
              _buildDetailRatingRow(context, '시간 준수도 및 수속', 5.0),
              
              SizedBox(height: context.h(24)),

              // Content
              Text(
                review.content.replaceAll('...더보기', '') + '\n그래서 말이죠 저희는 앞으로 이 항공사만 탈 것입니다 너무너무 좋고요 파리 갈 대 이것만 타겠습니다', // Extending content as per image
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: context.fs(15),
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFCCCCCC),
                  height: 1.6,
                ),
              ),
              SizedBox(height: context.h(24)),

              // Photos
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // First 3 images - fixed width
                    ...List.generate(
                      review.images.length > 3 ? 3 : review.images.length,
                      (index) {
                        return Container(
                          width: context.w(100),
                          height: context.w(100),
                          margin: EdgeInsets.only(right: context.w(8)),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(context.w(12)),
                            color: const Color(0xFF333333),
                            // image: DecorationImage(...)
                          ),
                        );
                      },
                    ),
                    // Fourth image - constrained to avoid overflow
                    if (review.images.length > 3)
                      Container(
                        width: context.w(100),
                        height: context.w(100),
                        margin: EdgeInsets.only(right: context.w(8)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(context.w(12)),
                          color: const Color(0xFF333333),
                          // image: DecorationImage(...)
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: context.h(24)),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '신고하기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: context.fs(13),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF555555),
                    ),
                  ),
                  Text(
                    review.date,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: context.fs(13),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
}