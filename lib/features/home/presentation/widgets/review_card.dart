import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../../../core/utils/image_utils.dart'; // ImageUtils import
import '../../domain/models/review_model.dart';
import '../../../../core/widgets/user_profile_image.dart'; // UserProfileImage import
import '../../data/datasources/airline_api_service.dart'; // API Service import
import '../pages/review_detail_page.dart';

class ReviewCard extends StatefulWidget {
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
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  final AirlineApiService _apiService = AirlineApiService();
  late int _currentLikes;
  bool _isLiking = false;

  @override
  void initState() {
    super.initState();
    _currentLikes = widget.review.likes;
  }

  // 좋아요 처리
  Future<void> _handleLike() async {
    print('🔥 좋아요 클릭됨!');
    print('  - isMyReview: ${widget.isMyReview}');
    print('  - reviewId: ${widget.review.reviewId}');
    print('  - _isLiking: $_isLiking');
    
    if (widget.isMyReview || _isLiking || widget.review.reviewId == null) {
      print('❌ 좋아요 처리 중단');
      return;
    }

    print('✅ 좋아요 API 호출 시작');
    setState(() {
      _isLiking = true;
    });

    try {
      final updatedLikes = await _apiService.addReviewLike(
        reviewId: widget.review.reviewId!,
      );

      print('✅ 좋아요 성공! 업데이트된 개수: $updatedLikes');
      if (mounted) {
        setState(() {
          _currentLikes = updatedLikes;
          _isLiking = false;
        });
      }
    } catch (e) {
      print('❌ 좋아요 실패: $e');
      if (mounted) {
        setState(() {
          _isLiking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap ?? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewDetailPage(
              review: widget.review,
              isMyReview: widget.isMyReview, // isMyReview 파라미터 전달
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
                    UserProfileImage(
                      imageUrl: widget.review.profileImage,
                      size: context.w(32),
                    ),
                    SizedBox(width: context.w(8)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.review.nickname,
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
                              '${widget.review.rating}',
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
                // 좋아요 (본인 리뷰가 아닐 때만 클릭 가능)
                GestureDetector(
                  onTap: widget.isMyReview ? null : _handleLike,
                  child: Text(
                    '좋아요 $_currentLikes',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: context.fs(13),
                      fontWeight: FontWeight.w500,
                      color: _isLiking 
                          ? AppColors.yellow1.withOpacity(0.5)
                          : AppColors.yellow1,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.h(12)),
            
            // Tags
            if (widget.review.tags.isNotEmpty) ...[
              Row(
                children: widget.review.tags.map((tag) {
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
            if (widget.review.images.isNotEmpty) ...[
              SizedBox(
                height: context.w(80),
                width: context.w(315),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: widget.review.images.length,
                  separatorBuilder: (context, index) => SizedBox(width: context.w(8)),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(context.w(8)),
                      child: SizedBox(
                        width: context.w(80),
                        height: context.w(80),
                        child: _buildReviewImage(widget.review.images[index]),
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
                    text: widget.review.content.length > 100 
                        ? '${widget.review.content.substring(0, 100)}...' 
                        : widget.review.content,
                  ),
                  if (widget.review.content.length > 100)
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewDetailPage(
                                review: widget.review,
                                isMyReview: widget.isMyReview, // isMyReview 파라미터 전달
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
            if (widget.isMyReview)
              // 나의 리뷰인 경우 날짜만 표시
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  widget.review.date,
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
                    widget.review.date,
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
    return ImageUtils.buildImage(imagePath);
  }
}
