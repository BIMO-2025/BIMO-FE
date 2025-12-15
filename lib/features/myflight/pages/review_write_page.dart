import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_extensions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/auth_token_storage.dart';
import '../../../core/network/router/route_names.dart';
import '../widgets/flight_card_widget.dart' show DashedLinePainter;

/// 리뷰 작성 페이지
class ReviewWritePage extends StatefulWidget {
  final String departureCode;
  final String departureCity;
  final String arrivalCode;
  final String arrivalCity;
  final String flightNumber;
  final String date;
  final String stopover;

  const ReviewWritePage({
    super.key,
    required this.departureCode,
    required this.departureCity,
    required this.arrivalCode,
    required this.arrivalCity,
    required this.flightNumber,
    required this.date,
    required this.stopover,
  });

  @override
  State<ReviewWritePage> createState() => _ReviewWritePageState();
}

class _ReviewWritePageState extends State<ReviewWritePage> {
  final TextEditingController _reviewController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final ApiClient _apiClient = ApiClient();
  List<XFile> _selectedImages = [];
  
  // 각 카테고리별 별점 (0-5)
  int _seatRating = 0;
  int _foodRating = 0;
  int _serviceRating = 0;
  int _cleanlinessRating = 0;
  int _punctualityRating = 0;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  /// 리뷰 제출
  Future<void> _submitReview() async {
    // 유효성 검사
    if (_seatRating == 0 || _foodRating == 0 || _serviceRating == 0 || 
        _cleanlinessRating == 0 || _punctualityRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 항목에 별점을 매겨주세요.')),
      );
      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('리뷰 내용을 입력해주세요.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 사용자 정보 가져오기
      final storage = AuthTokenStorage();
      final userInfo = await storage.getUserInfo();
      final userId = userInfo['userId'];
      final userNickname = userInfo['name'] ?? '사용자';

      if (userId == null || userId.isEmpty) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      // 항공사 코드 추출 (flightNumber에서 앞 2자리)
      final airlineCode = widget.flightNumber.length >= 2 
          ? widget.flightNumber.substring(0, 2).toUpperCase()
          : 'KE';

      // 항공사 이름 매핑 (간단한 예시, 나중에 확장 가능)
      final airlineName = _getAirlineName(airlineCode);

      // 평균 별점 계산
      final overallRating = (_seatRating + _foodRating + _serviceRating + 
          _cleanlinessRating + _punctualityRating) / 5.0;

      // 경로
      final route = '${widget.departureCode}-${widget.arrivalCode}';

      // TODO: 사진 업로드 처리
      // 사진이 선택되었다면, 먼저 업로드 API를 통해 URL을 받아야 함
      // 현재는 사진 업로드 API 엔드포인트가 필요함
      String? imageUrl;
      if (_selectedImages.isNotEmpty) {
        // 예시: 첫 번째 이미지만 업로드
        // final uploadedUrl = await _uploadImage(_selectedImages[0]);
        // imageUrl = uploadedUrl;
        print('⚠️ 사진 ${_selectedImages.length}개 선택됨 - 업로드 API 필요');
      }

      // API 요청 데이터
      final requestData = {
        'airlineCode': airlineCode,
        'airlineName': airlineName,
        'overallRating': overallRating,
        'ratings': {
          'checkIn': _punctualityRating,
          'cleanliness': _cleanlinessRating,
          'inflightMeal': _foodRating,
          'seatComfort': _seatRating,
          'service': _serviceRating,
        },
        'route': route,
        'flightNumber': widget.flightNumber, // 편명 추가
        'text': _reviewController.text.trim(),
        'userId': userId,
        'userNickname': userNickname,
      };

      // 이미지 URL이 있으면 추가
      if (imageUrl != null && imageUrl.isNotEmpty) {
        requestData['imageUrl'] = imageUrl;
      }

      print('🚀 리뷰 제출: $requestData');

      // API 호출 (ngrok 헤더 명시적 추가)
      final response = await _apiClient.post(
        '/reviews',
        data: requestData,
        options: Options(
          headers: {
            'ngrok-skip-browser-warning': 'true',
          },
        ),
      );

      print('✅ 리뷰 제출 성공: ${response.data}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('리뷰가 등록되었습니다!')),
      );

      // 홈 화면으로 이동
      context.go(RouteNames.home);
    } catch (e) {
      print('❌ 리뷰 제출 실패: $e');
      
      // DioException인 경우 응답 데이터 확인
      if (e.toString().contains('DioException')) {
        try {
          final dioError = e as dynamic;
          if (dioError.response != null) {
            print('❌ 서버 응답 상태: ${dioError.response.statusCode}');
            print('❌ 서버 응답 데이터: ${dioError.response.data}');
          }
        } catch (_) {}
      }
      
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('리뷰 등록 실패: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// 항공사 코드 -> 이름 매핑
  String _getAirlineName(String code) {
    final Map<String, String> airlineNames = {
      'KE': '대한항공',
      'OZ': '아시아나항공',
      'TW': '티웨이항공',
      'LJ': '진에어',
      '7C': '제주항공',
      'ZE': '이스타항공',
      'RS': '에어서울',
      'BX': '에어부산',
      // 추가 항공사...
    };
    return airlineNames[code] ?? code;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 스크롤 가능한 컨텐츠
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: context.w(20),
                right: context.w(20),
                top: context.h(82) + context.h(8), // 헤더 + 간격 8px
                bottom: context.h(100), // 하단 여백
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 항공편 정보 카드
                  _buildFlightInfoCard(),
                  
                  SizedBox(height: context.h(24)),
                  
                  // 질문
                  Center(
                    child: Text(
                      '이 비행은 어떠셨나요?',
                      style: AppTextStyles.bigBody.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: context.h(16)),
                  
                  // 별점 카테고리들
                  _buildRatingCategory('좌석 편안함', _seatRating, (rating) {
                    setState(() => _seatRating = rating);
                  }),
                  
                  _buildRatingCategory('기내식 및 음료', _foodRating, (rating) {
                    setState(() => _foodRating = rating);
                  }),
                  
                  _buildRatingCategory('서비스', _serviceRating, (rating) {
                    setState(() => _serviceRating = rating);
                  }),
                  
                  _buildRatingCategory('청결도', _cleanlinessRating, (rating) {
                    setState(() => _cleanlinessRating = rating);
                  }),
                  
                  _buildRatingCategory('시간 준수도 및 수속', _punctualityRating, (rating) {
                    setState(() => _punctualityRating = rating);
                  }),
                  
                  SizedBox(height: context.h(24)),
                  
                  // 텍스트 입력 필드
              Container(
                padding: EdgeInsets.all(context.w(15)),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _reviewController,
                  minLines: 6,
                  maxLines: null, // 자동으로 늘어남
                  style: AppTextStyles.body.copyWith(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '더 자세한 경험을 공유해 주세요.',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: Colors.white.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
                  
                  SizedBox(height: context.h(16)),
                  
                  // 선택된 사진 리스트 (가로 스크롤)
                  if (_selectedImages.isNotEmpty) ...[ 
                    _buildPhotoList(),
                    SizedBox(height: context.h(16)),
                  ],
                  
                  // 사진 추가 버튼
                  _buildPhotoButton(),
                  
                  SizedBox(height: context.h(120)), // 버튼 공간 확보
                ],
              ),
            ),
          ),
          
          // 리뷰 작성하기 버튼 (플로팅)
          Positioned(
            bottom: 34,
            left: 0,
            right: 0,
            child: Center(
              child: _buildSubmitButton(),
            ),
          ),
          
          // 헤더 (뒤로가기 + 타이틀) - 마지막에 배치하여 항상 위에 표시
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: context.h(82),
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1A1A1A), // 위쪽: #1A1A1A (100%)
                    Color(0x001A1A1A), // 아래쪽: rgba(26, 26, 26, 0) (0%)
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // 뒤로가기 버튼 (왼쪽)
                  Positioned(
                    left: context.w(20),
                    top: context.h(21),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                            child: Center(
                              child: Image.asset(
                                'assets/images/myflight/back.png',
                                width: 24,
                                height: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 타이틀 (중앙)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: context.h(31),
                    child: Center(
                      child: Text(
                        '리뷰 작성하기',
                        style: AppTextStyles.large.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  /// 항공편 정보 카드 (AddFlightPage 스타일)
  Widget _buildFlightInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // 상단 섹션 (패딩 적용)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                // 항공사 로고
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/images/home/korean_air_logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.flight, color: Colors.blue);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 출발 정보
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.departureCode,
                      style: AppTextStyles.bigBody.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 0),
                    Text(
                      '09:00',
                      style: AppTextStyles.smallBody.copyWith(
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // 중앙: 점선 + 비행기 + 시간
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 점선 + 비행기
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // 점선과 원
                          Row(
                            children: [
                              // 왼쪽 원
                              Container(
                                width: 9,
                                height: 9,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              // 점선
                              Expanded(
                                child: CustomPaint(
                                  size: const Size(double.infinity, 1),
                                  painter: DashedLinePainter(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              // 오른쪽 원
                              Container(
                                width: 9,
                                height: 9,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          // 비행기 아이콘
                          Image.asset(
                            'assets/images/myflight/airplane.png',
                            width: 20,
                            height: 20,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // 비행 시간
                      Text(
                        '14h 30m',
                        style: AppTextStyles.smallBody.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // 도착 정보
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.arrivalCode,
                      style: AppTextStyles.bigBody.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 0),
                    Text(
                      '19:40',
                      style: AppTextStyles.smallBody.copyWith(
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 구분선 (전체 너비)
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
          
          // 하단 섹션 (패딩 적용)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 날짜
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '날짜',
                        style: AppTextStyles.smallBody.copyWith(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.date,
                        style: AppTextStyles.smallBody.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 편명
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '편명',
                        style: AppTextStyles.smallBody.copyWith(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.flightNumber,
                        style: AppTextStyles.smallBody.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 경유 여부
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '경유 여부 (1편)',
                        style: AppTextStyles.smallBody.copyWith(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.stopover,
                        style: AppTextStyles.smallBody.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 별점 카테고리
  Widget _buildRatingCategory(String label, int rating, Function(int) onRatingChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.h(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: Colors.white,
            ),
          ),
          Row(
            children: List.generate(5, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  left: index > 0 ? 2.936 : 0,
                ),
                child: GestureDetector(
                  onTap: () => onRatingChanged(index + 1),
                  child: SvgPicture.asset(
                    'assets/images/myflight/star.svg',
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      index < rating ? AppColors.yellow1 : Colors.grey,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 사진 추가 버튼
  Widget _buildPhotoButton() {
    return GestureDetector(
      onTap: _pickImagesFromGallery,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: context.h(15)),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/myflight/camera.png',
              width: 24,
              height: 24,
              color: Colors.white,
            ),
            SizedBox(width: context.w(8)),
            Text(
              '사진 추가',
              style: AppTextStyles.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 갤러리에서 사진 선택
  Future<void> _pickImagesFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      if (!mounted) return;
      // 시뮬레이터에서는 image_picker가 작동하지 않을 수 있습니다
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('실제 기기에서 사진을 선택할 수 있습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// 선택된 사진 리스트 (가로 스크롤)
  Widget _buildPhotoList() {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        separatorBuilder: (context, index) => SizedBox(width: 8),
        itemBuilder: (context, index) {
          return Stack(
            children: [
              // 사진 카드
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 105,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Image.file(
                    File(_selectedImages[index].path),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // 삭제 버튼
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImages.removeAt(index);
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 리뷰 작성하기 버튼 (AddFlightPage 다음 버튼 스타일)
  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isSubmitting ? null : _submitReview,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: 335,
            height: 50,
            decoration: BoxDecoration(
              color: _isSubmitting 
                  ? Colors.white.withOpacity(0.03)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Center(
              child: _isSubmitting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      '리뷰 작성하기',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
