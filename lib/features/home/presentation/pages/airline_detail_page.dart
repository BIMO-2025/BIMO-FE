import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../../../core/utils/airline_name_mapper.dart'; // AirlineNameMapper import
import '../../domain/models/airline.dart';
import '../../data/datasources/airline_api_service.dart';
import '../../data/models/airline_detail_response.dart';
import '../../data/models/airline_info_response.dart';
import '../../data/models/airline_summary_response.dart';
import 'airline_review_page.dart';

class AirlineDetailPage extends StatefulWidget {
  final Airline airline;

  const AirlineDetailPage({
    super.key,
    required this.airline,
  });

  @override
  State<AirlineDetailPage> createState() => _AirlineDetailPageState();
}

class _AirlineDetailPageState extends State<AirlineDetailPage> {
  final AirlineApiService _apiService = AirlineApiService();
  
  AirlineDetailResponse? _airlineStatistics; // 통계 정보 (평점)
  AirlineInfoResponse? _airlineInfo; // 기본 정보 (alliance, type, country 등)
  AirlineSummaryResponse? _airlineSummary; // BIMO 요약 (Good/Bad 포인트)
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAirlineDetail();
  }

  Future<void> _loadAirlineDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. 기본 정보 API (BIMO 요약 포함)
      try {
        _airlineInfo = await _apiService.getAirlineDetail(
          airlineCode: widget.airline.code,
        );
        
        // BIMO 요약 정보 할당 (기본 정보에 없으면 별도 API 호출)
        if (_airlineInfo?.bimoSummary != null) {
          _airlineSummary = _airlineInfo!.bimoSummary;
          print('✅ BIMO 요약 정보 로드 완료 (from AirlineInfo)');
        } else {
          print('ℹ️ 기본 정보에 요약 없음 -> 요약 API 별도 호출 시도');
          try {
            _airlineSummary = await _apiService.getAirlineSummary(
              airlineCode: widget.airline.code,
            );
            print('✅ BIMO 요약 정보 로드 완료 (from Summary API)');
          } catch (e) {
            print('⚠️ BIMO 요약 API 호출 실패: $e');
          }
        }
      } catch (e) {
        print('⚠️ 기본 정보 API 실패: $e');
      }
      
      // 통계 API 호출 제거 (백엔드 통합 또는 Mock 사용)
      // _airlineStatistics = ...; 
      
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('⚠️ 전체 API 호출 실패: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = null; // 에러 표시 안함, mock 데이터 사용
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313), // Dark background
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
          AirlineNameMapper.toKorean(widget.airline.name), // 한국어 변환
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: context.fs(17),
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadAirlineDetail,
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    // API 데이터 사용 (우선순위: 기본 정보 API의 averageRatings > 기본 정보 API overallRating > mock 데이터)
    final infoAverageRatings = _airlineInfo?.averageRatings;
    final infoRating = _airlineInfo?.overallRating;
    
    final rating = (infoRating != null && infoRating > 0)
            ? infoRating
            : (infoAverageRatings != null && infoAverageRatings.overall > 0)
                ? infoAverageRatings.overall
                : widget.airline.rating;
    
    final infoReviews = _airlineInfo?.totalReviews;
    final reviewCount = (infoReviews != null && infoReviews > 0)
            ? infoReviews
            : widget.airline.reviewCount;
    
    print('⭐ 평점 계산:');
    print('  - 기본 정보 API overallRating: ${_airlineInfo?.overallRating}');
    print('  - 기본 정보 API averageRatings.overall: ${_airlineInfo?.averageRatings?.overall}');
    print('  - mock 데이터: ${widget.airline.rating}');
    print('  - 최종 rating: $rating');
    print('  - 최종 reviewCount: $reviewCount');
    
    // 태그 생성 (API 데이터 우선)
    final tags = <String>[];
    if (_airlineInfo?.alliance.isNotEmpty == true) {
      tags.add(_airlineInfo!.alliance);
    }
    if (_airlineInfo?.type.isNotEmpty == true) {
      tags.add(_airlineInfo!.type);
    }
    // API 데이터가 없으면 mock 데이터 사용
    if (tags.isEmpty) {
      tags.addAll(widget.airline.tags);
    }
    
    // 이미지 URL (API 데이터 우선)
    String? imageUrl;
    bool isPngLogo = false; // PNG 로고 여부
    
    if (_airlineInfo?.images.isNotEmpty == true) {
      // images 배열의 두 번째 이미지 사용 (400x200)
      imageUrl = _airlineInfo!.images.length > 1 
          ? _airlineInfo!.images[1] 
          : _airlineInfo!.images[0];
      // PNG 로고인지 확인 (pics.avs.io URL)
      isPngLogo = imageUrl?.contains('pics.avs.io') ?? false;
    } else if (_airlineInfo?.logoUrl.isNotEmpty == true) {
      imageUrl = _airlineInfo!.logoUrl;
      isPngLogo = imageUrl?.contains('pics.avs.io') ?? false;
    }
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: context.h(24)),
          // 1. Airline Image (API 이미지 사용)
          Container(
            width: double.infinity,
            height: context.h(110),
            margin: EdgeInsets.symmetric(horizontal: context.w(20)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14), // 14로 고정
              color: isPngLogo 
                  ? Colors.white  // PNG 로고는 흰색 배경
                  : const Color(0xFF1A1A1A), // 일반 이미지는 어두운 배경
            ),
            child: imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14), // 14로 고정
                    child: Image.network(
                      imageUrl,
                      fit: isPngLogo ? BoxFit.contain : BoxFit.cover, // PNG는 contain, 일반은 cover
                      errorBuilder: (context, error, stackTrace) {
                        // 로딩 실패 시 mock 이미지
                        return Image.asset(
                          widget.airline.imagePath,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  )
                : Image.asset(
                    widget.airline.imagePath,
                    fit: BoxFit.cover,
                  ),
          ),
          
          SizedBox(height: context.h(20)),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Tags (API 데이터 사용)
                Row(
                  children: tags.map((tag) {
                    final isSkyTeam = tag == 'SkyTeam' || tag == 'Sky Team';
                    final isFSC = tag == 'FSC';
                    Color bgColor = const Color(0xFF333333);
                    Color textColor = Colors.white;

                    if (isFSC) {
                      bgColor = const Color(0xFF0080FF); // Blue1
                    }

                    return Container(
                      margin: EdgeInsets.only(right: context.w(6)),
                      padding: EdgeInsets.symmetric(
                        horizontal: context.w(10),
                        vertical: context.h(6),
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(context.w(8)),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: context.fs(12),
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: context.h(12)),

                // 3. Airline Name (한국어)
                Text(
                  AirlineNameMapper.toKorean(widget.airline.name),
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: context.fs(24),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: context.h(4)),
                // 영어 이름 (원본 유지)
                Text(
                  widget.airline.englishName,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: context.fs(14),
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: context.h(12)),

                // 4. Rating Row (API 데이터 사용)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AirlineReviewPage(airline: widget.airline),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.white, size: context.w(16)),
                      SizedBox(width: context.w(4)),
                      Text(
                        '${rating.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: context.fs(13),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '/5.0',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: context.fs(13),
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      SizedBox(width: context.w(8)),
                      Text(
                        '(${_formatNumber(reviewCount)})',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: context.fs(14),
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.white, size: context.w(20)),
                    ],
                  ),
                ),

                SizedBox(height: context.h(24)),

                // 5. Detail Ratings (API 데이터 사용)
                if (_airlineInfo?.averageRatings != null) ...[
                  _buildDetailRatingRow(context, '좌석 편안함', _airlineInfo!.averageRatings!.seatComfort),
                  _buildDetailRatingRow(context, '기내식 및 음료', _airlineInfo!.averageRatings!.inflightMeal),
                  _buildDetailRatingRow(context, '서비스', _airlineInfo!.averageRatings!.service),
                  _buildDetailRatingRow(context, '청결도', _airlineInfo!.averageRatings!.cleanliness),
                  _buildDetailRatingRow(context, '시간 준수도 및 수속', _airlineInfo!.averageRatings!.checkIn),
                ] else ...[
                  _buildDetailRatingRow(context, '좌석 편안함', widget.airline.detailRating.seatComfort),
                  _buildDetailRatingRow(context, '기내식 및 음료', widget.airline.detailRating.foodAndBeverage),
                  _buildDetailRatingRow(context, '서비스', widget.airline.detailRating.service),
                  _buildDetailRatingRow(context, '청결도', widget.airline.detailRating.cleanliness),
                  _buildDetailRatingRow(context, '시간 준수도 및 수속', widget.airline.detailRating.punctuality),
                ],

                SizedBox(height: context.h(32)),

                // 6. BIMO Summary (mock 데이터 사용 - 나중에 별도 API 연결)
                Row(
                  children: [
                    Icon(Icons.flight_takeoff, color: Colors.white, size: context.w(20)),
                    SizedBox(width: context.w(8)),
                    Text(
                      'BIMO 요약',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: context.fs(17),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: context.w(8)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: context.w(8), vertical: context.h(4)),
                      decoration: BoxDecoration(
                        color: AppColors.yellow1,
                        borderRadius: BorderRadius.circular(context.w(8)),
                      ),
                      child: Text(
                        'AI 리뷰 분석',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: context.fs(11),
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.h(12)),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(context.w(20)),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(context.w(16)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: context.fs(15),
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: context.h(12)),
                            // API 데이터 우선 사용
                            ...(_airlineSummary?.goodPoints.isNotEmpty == true
                                ? _airlineSummary!.goodPoints
                                : widget.airline.reviewSummary.goodPoints
                            ).map((point) => Padding(
                              padding: EdgeInsets.only(bottom: context.h(4)),
                              child: Text(
                                point,
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: context.fs(13),
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFCCCCCC),
                                  height: 1.4,
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                      SizedBox(width: context.w(20)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bad',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: context.fs(15),
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: context.h(12)),
                            // API 데이터 우선 사용
                            ...(_airlineSummary?.badPoints.isNotEmpty == true
                                ? _airlineSummary!.badPoints
                                : widget.airline.reviewSummary.badPoints
                            ).map((point) => Padding(
                              padding: EdgeInsets.only(bottom: context.h(4)),
                              child: Text(
                                point,
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: context.fs(13),
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFCCCCCC),
                                  height: 1.4,
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.h(32)),

                // 7. Basic Info (mock 데이터 사용)
                Text(
                  '기본 정보',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: context.fs(17),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: context.h(12)),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(context.w(20)),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(context.w(16)),
                  ),
                  child: Column(
                    children: [
                      _buildBasicInfoRow(
                        context,
                        '본사 위치',
                        _airlineInfo?.country.isNotEmpty == true
                            ? _airlineInfo!.country
                            : '정보 없음',
                      ),
                      SizedBox(height: context.h(12)),
                      _buildBasicInfoRow(
                        context,
                        '허브 공항',
                        _airlineInfo?.hubAirportName?.isNotEmpty == true
                            ? _airlineInfo!.hubAirportName!
                            : (_airlineInfo?.hubAirport?.isNotEmpty == true
                                ? _airlineInfo!.hubAirport!
                                : '정보 없음'),
                      ),
                      SizedBox(height: context.h(12)),
                      _buildBasicInfoRow(
                        context,
                        '항공 동맹',
                        _airlineInfo?.alliance.isNotEmpty == true
                            ? _airlineInfo!.alliance
                            : '정보 없음',
                      ),
                      SizedBox(height: context.h(12)),
                      _buildBasicInfoRow(
                        context,
                        '운항 클래스',
                        _airlineInfo?.operatingClasses.isNotEmpty == true
                            ? _airlineInfo!.operatingClasses.join(', ')
                            : '정보 없음',
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: context.h(40)),
              ],
            ),
          ),
        ],
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

  Widget _buildBasicInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: context.w(80),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: context.fs(14),
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: context.fs(14),
              fontWeight: FontWeight.w400,
              color: const Color(0xFFCCCCCC),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }
}
