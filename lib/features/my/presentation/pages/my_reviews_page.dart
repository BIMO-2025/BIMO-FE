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
import '../../../home/presentation/widgets/review_card.dart'; // ReviewCard 추가

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
            // 날짜 포맷팅 (ISO 8601 -> YYYY.MM.DD)
            String formattedDate = reviewData['createdAt'] ?? '';
            if (formattedDate.length >= 10) {
              formattedDate = formattedDate.substring(0, 10).replaceAll('-', '.');
            }

            // 태그 생성: route + flightNumber
            final tags = <String>[];
            if (reviewData['route'] != null && reviewData['route'].toString().isNotEmpty) {
              tags.add(reviewData['route']);
            }
            if (reviewData['flightNumber'] != null && reviewData['flightNumber'].toString().isNotEmpty) {
              tags.add(reviewData['flightNumber']);
            }

            return Review(
              nickname: _nickname, // 서버 데이터 대신 최신 내 정보 사용
              profileImage: _profileImage, // 서버 데이터 대신 최신 내 정보 사용
              rating: (reviewData['overallRating'] ?? 0).toDouble(),
              date: formattedDate,
              likes: reviewData['likes'] ?? 0,
              tags: tags,
              content: reviewData['text'] ?? '',
              images: (reviewData['imageUrls'] as List?)?.cast<String>() ?? [],
              detailRatings: reviewData['ratings'] as Map<String, dynamic>?, // 세부 평점 추가
              reviewId: reviewData['id'], // 리뷰 ID 매핑
              userId: reviewData['userId'], // 사용자 ID 매핑
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
                        return GestureDetector(
                          onTap: () {
                            print('👉 [MyReviewsPage] 상세 이동 시도');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewDetailPage(
                                  review: review,
                                  isMyReview: true,
                                ),
                              ),
                            ).then((result) {
                              print('🔙 [MyReviewsPage] 복귀 (then). result: $result');
                              if (result == true && mounted) {
                                print('💨 마이페이지로 탈출 (pop)');
                                Navigator.pop(context);
                              } else {
                                print('👀 단순 조회 종료 (pop 안함)');
                              }
                            });
                          },
                          child: ReviewCard(
                            review: review,
                            isMyReview: true, // 나의 리뷰이므로 신고하기 버튼 숨김
                          ),
                        );
                      },
                    ),
    );
  }
}
