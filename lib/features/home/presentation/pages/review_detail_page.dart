import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../domain/models/review_model.dart'; // Review 모델 import
import '../../data/datasources/airline_api_service.dart'; // API Service import
import '../../../myflight/pages/review_write_page.dart'; // ReviewWritePage import
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
  final AirlineApiService _apiService = AirlineApiService();
  late Review _currentReview; // 현재 리뷰 데이터 (수정 반영을 위해 State로 관리)
  late int _currentLikes; // 현재 좋아요 수
  bool _isLiking = false; // 좋아요 처리 중
  bool _isEdited = false; // 수정 여부

  @override
  void initState() {
    super.initState();
    _currentReview = widget.review;
    _currentLikes = widget.review.likes;
  }

  // 좋아요 처리
  Future<void> _handleLike() async {
    if (widget.isMyReview || _isLiking || widget.review.reviewId == null) {
      return; // 본인 리뷰거나 처리 중이거나 reviewId가 없으면 무시
    }

    setState(() {
      _isLiking = true;
    });

    try {
      final updatedLikes = await _apiService.addReviewLike(
        reviewId: widget.review.reviewId!,
      );

      if (mounted) {
        setState(() {
          _currentLikes = updatedLikes;
          _isLiking = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('좋아요가 추가되었습니다.'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('❌ 좋아요 실패: $e');
      if (mounted) {
        setState(() {
          _isLiking = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('좋아요 추가 실패: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // 메뉴 버튼을 표시하는 메서드
  void _showReviewMenu(BuildContext context, Offset buttonPosition) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx - context.w(102), // 20만큼 오른쪽으로
        buttonPosition.dy + context.h(1),
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(context.w(12)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                // 수정하기 버튼
                _buildActionButton(
                  context,
                  icon: SizedBox(
                    width: context.w(12),
                    height: context.h(12),
                    child: Image.asset(
                      'assets/images/myflight/pencil.png',
                      width: context.w(12),
                      height: context.h(12),
                      color: Colors.white,
                    ),
                  ),
                  text: '수정하기',
                  onTap: () async {
                    Navigator.pop(context);
                    // 리뷰 수정 페이지로 이동 (ReviewWritePage를 수정 모드로 사용)
                    // 결과를 받아와서 화면 갱신
                    final updatedData = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewWritePage(
                          flightNumber: _currentReview.tags.length > 1 ? _currentReview.tags[1] : '',
                          departureCode: _currentReview.tags.isNotEmpty 
                              ? _currentReview.tags[0].split('-')[0] 
                              : '',
                          arrivalCode: _currentReview.tags.isNotEmpty && _currentReview.tags[0].contains('-')
                              ? _currentReview.tags[0].split('-')[1] 
                              : '',
                          isEditMode: true,
                          existingReview: _currentReview,
                        ),
                      ),
                    );

                    // 수정된 데이터가 있으면 바로 목록으로 이동하며 갱신 요청
                    if (updatedData != null && mounted) {
                      print('🔄 리뷰 수정 완료 -> 마이페이지로 이동 (강제 2단계 POP)');
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('리뷰가 수정되었습니다.')),
                      );
                      
                      // 강제로 2단계 뒤로 이동 (ReviewDetail -> MyReviews -> MyPage)
                      int count = 0;
                      Navigator.of(context).popUntil((route) {
                        return count++ == 2;
                      });
                    }
                  },
                ),
                // 구분선
                Container(
                  height: 1,
                  color: AppColors.white.withOpacity(0.2),
                ),
                // 삭제하기 버튼
                _buildActionButton(
                  context,
                  icon: Icon(
                    Icons.close,
                    size: context.w(12),
                    color: Colors.white,
                  ),
                  text: '삭제하기',
                  onTap: () {
                    Navigator.pop(context); // 메뉴 닫기
                    _showDeleteConfirmDialog(context);
                  },
                ),
              ],
            ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 액션 버튼 위젯
  Widget _buildActionButton(
    BuildContext context, {
    required Widget icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(12),
          vertical: context.h(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            SizedBox(width: context.w(4)),
            Text(
              text,
              style: AppTextStyles.smallBody.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
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
            onTap: () => Navigator.pop(context, _isEdited),
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
          widget.isMyReview ? '나의 리뷰' : '${_currentReview.nickname} 님의 리뷰',
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
                        backgroundImage: AssetImage(_currentReview.profileImage),
                      ),
                      SizedBox(width: context.w(12)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentReview.nickname,
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
                                '${_currentReview.rating}',
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
                  // 좋아요 표시 (본인 리뷰는 회색으로 비활성화, 다른 사람 리뷰는 클릭 가능)
                  if (!widget.isMyReview)
                    GestureDetector(
                      onTap: _handleLike,
                      child: Text(
                        '좋아요 $_currentLikes',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: context.fs(14),
                          fontWeight: FontWeight.w500,
                          color: _isLiking 
                              ? AppColors.yellow1.withOpacity(0.5) 
                              : AppColors.yellow1,
                        ),
                      ),
                    )
                  else
                    Text(
                      '좋아요 $_currentLikes',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: context.fs(14),
                        fontWeight: FontWeight.w500,
                        color: AppColors.yellow1, // 연두색으로 표시
                      ),
                    ),
                ],
              ),
              SizedBox(height: context.h(16)),

              // Tags
              Row(
                children:
                    _currentReview.tags.map((tag) {
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

              // Detail Ratings (실제 데이터 매핑)
              if (_currentReview.detailRatings != null) ...[
                _buildDetailRatingRow(
                  context,
                  '좌석 편안함',
                  (_currentReview.detailRatings!['seatComfort'] ?? 0).toDouble(),
                ),
                _buildDetailRatingRow(
                  context,
                  '기내식 및 음료',
                  (_currentReview.detailRatings!['inflightMeal'] ?? 0).toDouble(),
                ),
                _buildDetailRatingRow(
                  context,
                  '서비스',
                  (_currentReview.detailRatings!['service'] ?? 0).toDouble(),
                ),
                _buildDetailRatingRow(
                  context,
                  '청결도',
                  (_currentReview.detailRatings!['cleanliness'] ?? 0).toDouble(),
                ),
                _buildDetailRatingRow(
                  context,
                  '시간 준수도 및 수속',
                  (_currentReview.detailRatings!['checkIn'] ?? 0).toDouble(),
                ),
              ],


              SizedBox(height: context.h(24)),

              // Content
              Text(
                _currentReview.content.replaceAll('...더보기', ''),
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
              if (_currentReview.images.isNotEmpty)
                SizedBox(
                  height: context.w(100),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _currentReview.images.length,
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
                            child: _buildReviewImage(_currentReview.images[index]),
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
                  _currentReview.date,
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
                      _currentReview.date,
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
        images: _currentReview.images,
        initialIndex: initialIndex,
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: context.w(20)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: context.w(320),
                padding: EdgeInsets.only(
                  top: 0,
                  right: context.w(20),
                  bottom: context.w(20),
                  left: context.w(20),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 헤더 영역
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(
                        top: context.h(20),
                        bottom: context.h(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 제목
                          Text(
                            '리뷰 삭제',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: context.fs(19),
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: context.h(10)),
                          // 본문
                          Padding(
                            padding: EdgeInsets.only(
                              left: context.w(14),
                              right: context.w(14),
                              top: context.h(10),
                            ),
                            child: Text(
                              '삭제된 리뷰는 복구할 수 없습니다.\n정말 삭제하시겠어요?',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: context.fs(15),
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.h(16)),
                    // 버튼들
                    Row(
                      children: [
                        // 삭제 버튼 (왼쪽, 회색 배경)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                               Navigator.pop(context); // 다이얼로그 닫기
                               _deleteReview(); 
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: context.h(16),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  '삭제',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: context.fs(16),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: context.w(16)),
                        // 취소 버튼 (오른쪽, 파란색 강조)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: context.h(16),
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF007AFF),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  '취소',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: context.fs(16),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 실제 삭제 로직 분리
  Future<void> _deleteReview() async {
    print('🗑️ 리뷰 삭제 시도. reviewId: ${_currentReview.reviewId}');
    try {
      if (_currentReview.reviewId != null) {
        await _apiService.deleteReview(reviewId: _currentReview.reviewId!);
        
        if (mounted) {
          print('✅ 리뷰 삭제 성공함. 마이페이지로 이동 (강제 2단계 POP)');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('리뷰가 삭제되었습니다.')),
          );
          
          // 강제로 2단계 뒤로 이동 (ReviewDetail -> MyReviews -> MyPage)
          int count = 0;
          Navigator.of(context).popUntil((route) {
            return count++ == 2;
          });
        }
      } else {
          print('❌ 리뷰 ID가 null임.');
          throw Exception('Review ID is null');
      }
    } catch (e) {
      print('❌ 리뷰 삭제 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('리뷰 삭제 실패: $e')),
        );
      }
    }
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

