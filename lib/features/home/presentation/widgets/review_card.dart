import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../domain/models/review_model.dart';
import '../pages/review_detail_page.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback? onTap;
  final bool isMyReview; // 나의 리뷰인지 여부

  const ReviewCard({
    super.key,
    required this.review,
    this.onTap,
    this.isMyReview = false, // 기본값은 false
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewDetailPage(
              review: review,
              isMyReview: isMyReview, // isMyReview 파라미터 전달
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
                      onBackgroundImageError: (_, __) {}, 
                      child: review.profileImage.isEmpty 
                          ? Text(
                              review.nickname.isNotEmpty ? review.nickname[0] : 'U',
                              style: const TextStyle(color: Colors.white),
                            )
                          : null,
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
            if (review.tags.isNotEmpty) ...[
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
            ],

            // Photos
            if (review.images.isNotEmpty) ...[
              SizedBox(
                height: context.w(80),
                width: context.w(315),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: review.images.length,
                  separatorBuilder: (context, index) => SizedBox(width: context.w(8)),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(context.w(8)),
                      child: SizedBox(
                        width: context.w(80),
                        height: context.w(80),
                        child: _buildReviewImage(review.images[index]),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: context.h(12)),
            ],

            // Content
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: context.fs(14),
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: review.content.length > 100 
                        ? '${review.content.substring(0, 100)}...' 
                        : review.content,
                  ),
                  if (review.content.length > 100)
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewDetailPage(
                                review: review,
                                isMyReview: isMyReview, // isMyReview 파라미터 전달
                              ),
                            ),
                          );
                        },
                        child: Text(
                          ' ...더보기',
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
            if (isMyReview)
              // 나의 리뷰인 경우 날짜만 표시
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  review.date,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: context.fs(12),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
              )
            else
              // 다른 사람의 리뷰인 경우 신고하기와 날짜 표시
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
}
