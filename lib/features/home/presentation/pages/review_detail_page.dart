import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../domain/models/review_model.dart'; // Review 모델 import
import 'airline_review_page.dart'; // For Review class

class ReviewDetailPage extends StatefulWidget {
  final Review review;
  final bool isMyReview; // 나의 리뷰인지 여부

  const ReviewDetailPage({
    super.key,
    required this.review,
    this.isMyReview = false, // 기본값은 false
  });

  @override
  State<ReviewDetailPage> createState() => _ReviewDetailPageState();
}

class _ReviewDetailPageState extends State<ReviewDetailPage> {
  // 메뉴 버튼을 표시하는 메서드
  void _showReviewMenu(BuildContext context, Offset buttonPosition) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx - context.w(90), // 버튼보다 90만큼 왼쪽 (오른쪽에 40 공간)
        buttonPosition.dy + context.h(1), // 버튼보다 1만큼 아래
        buttonPosition.dx,
        buttonPosition.dy,
      ),
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.w(12)),
      ),
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: Container(
            width: context.w(90),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.w(12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 수정하기
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: 리뷰 수정 페이지로 이동
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.w(14.5),
                      vertical: context.h(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit,
                          size: context.w(8),
                          color: AppColors.white,
                        ),
                        SizedBox(width: context.w(8)),
                        Text(
                          '수정하기',
                          style: AppTextStyles.smallBody.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 구분선
                Container(
                  width: context.w(90),
                  height: 1,
                  color: AppColors.white.withOpacity(0.1),
                ),

                // 삭제하기
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: 리뷰 삭제 확인 다이얼로그 표시
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.w(14.5),
                      vertical: context.h(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.close,
                          size: context.w(8),
                          color: AppColors.white,
                        ),
                        SizedBox(width: context.w(8)),
                        Text(
                          '삭제하기',
                          style: AppTextStyles.smallBody.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
          '${widget.review.nickname} 님의 리뷰',
          style: AppTextStyles.large.copyWith(color: AppColors.white),
        ),
        centerTitle: true,
        actions:
            widget.isMyReview
                ? [
                  // 나의 리뷰인 경우 메뉴 아이콘 표시
                  Padding(
                    padding: EdgeInsets.only(right: context.w(20)),
                    child: Builder(
                      builder: (context) {
                        return GestureDetector(
                          onTap: () {
                            // 버튼의 위치를 계산
                            final RenderBox button =
                                context.findRenderObject() as RenderBox;
                            final Offset buttonPosition = button.localToGlobal(
                              Offset.zero,
                            );
                            _showReviewMenu(
                              context,
                              Offset(
                                buttonPosition.dx + button.size.width,
                                buttonPosition.dy + button.size.height,
                              ),
                            );
                          },
                          child: SizedBox(
                            width: context.w(40),
                            height: context.h(40),
                            child: Image.asset(
                              'assets/images/my/review_menu.png',
                              width: context.w(40),
                              height: context.h(40),
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ]
                : null,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: context.h(16), // 상단 영역보다 16 아래
          left: context.w(20),
          right: context.w(20),
          bottom: context.h(20),
        ),
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
                        backgroundImage: AssetImage(widget.review.profileImage),
                      ),
                      SizedBox(width: context.w(12)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.review.nickname,
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
                              Icon(
                                Icons.star,
                                color: Colors.white,
                                size: context.w(14),
                              ),
                              SizedBox(width: context.w(2)),
                              Text(
                                '${widget.review.rating}',
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
                    '좋아요 ${widget.review.likes}',
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
                children:
                    widget.review.tags.map((tag) {
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
                widget.review.content.replaceAll('...더보기', '') +
                    '\n그래서 말이죠 저희는 앞으로 이 항공사만 탈 것입니다 너무너무 좋고요 파리 갈 대 이것만 타겠습니다', // Extending content as per image
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
              if (widget.review.images.isNotEmpty)
                SizedBox(
                  height: context.w(100),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.review.images.length,
                    separatorBuilder: (context, index) => SizedBox(width: context.w(8)),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _showFullScreenImage(context, index);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(context.w(12)),
                          child: Container(
                            width: context.w(100),
                            height: context.w(100),
                            color: const Color(0xFF333333),
                            child: _buildReviewImage(widget.review.images[index]),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: context.h(24)),

              // Footer
              if (widget.isMyReview)
                // 나의 리뷰인 경우 날짜만 표시
                Text(
                  widget.review.date,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: context.fs(13),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8E8E93),
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
                        fontSize: context.fs(13),
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF555555),
                      ),
                    ),
                    Text(
                      widget.review.date,
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

  void _showFullScreenImage(BuildContext context, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) => _FullScreenImageViewer(
        images: widget.review.images,
        initialIndex: initialIndex,
      ),
    );
  }

  Widget _buildDetailRatingRow(
    BuildContext context,
    String label,
    double rating,
  ) {
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

class _FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenImageViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Image PageView
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: _buildFullImage(widget.images[index]),
              );
            },
          ),

          // Close Button
          Positioned(
            top: context.h(40), // 더 위로 (50 -> 40)
            right: context.w(20),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Image.asset(
                'assets/images/my/clear.png',
                width: context.w(32), // 크기 32
                height: context.h(32),
              ),
            ),
          ),

          // Left Arrow (Previous)
          if (_currentIndex > 0)
            Positioned(
              left: context.w(10),
              child: GestureDetector(
                onTap: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Image.asset(
                  'assets/images/search/back_arrow_icon.png',
                  width: context.w(32), // 크기 32
                  height: context.h(32),
                ),
              ),
            ),

          // Right Arrow (Next)
          if (_currentIndex < widget.images.length - 1)
            Positioned(
              right: context.w(10),
              child: GestureDetector(
                onTap: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Transform.scale(
                  scaleX: -1, // 좌우 반전
                  child: Image.asset(
                    'assets/images/search/back_arrow_icon.png',
                    width: context.w(32), // 크기 32
                    height: context.h(32),
                  ),
                ),
              ),
            ),
            
          // Page Indicator
          Positioned(
            bottom: context.h(60),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.w(12),
                vertical: context.h(6),
              ),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(context.w(20)),
              ),
              child: Text(
                '${_currentIndex + 1} / ${widget.images.length}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.fs(14),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Image.network(
            'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800&q=80', // 비행기 대체 이미지
            fit: BoxFit.contain,
          );
        },
      );
    } else if (imagePath.startsWith('assets/')) {
      return Image.asset(imagePath, fit: BoxFit.contain);
    } else {
      return Image.file(File(imagePath), fit: BoxFit.contain);
    }
  }
}

