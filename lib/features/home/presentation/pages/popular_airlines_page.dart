import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../data/datasources/airline_api_service.dart';
import '../../data/models/popular_airline_response.dart';
import '../../../../core/utils/airline_name_mapper.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/airline.dart';

/// 인기 항공사 전체 목록 페이지
class PopularAirlinesPage extends StatefulWidget {
  const PopularAirlinesPage({super.key});

  @override
  State<PopularAirlinesPage> createState() => _PopularAirlinesPageState();
}

class _PopularAirlinesPageState extends State<PopularAirlinesPage> {
  final AirlineApiService _apiService = AirlineApiService();
  List<PopularAirlineResponse> _airlines = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPopularAirlines();
  }

  /// 평점 순 정렬된 항공사 로드 (상위 10개)
  Future<void> _loadPopularAirlines() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 평점 순 정렬 항공사 API 호출
      final airlines = await _apiService.getSortedAirlines();

      // 상위 10개만 선택
      final top10 = airlines.take(10).toList();

      setState(() {
        _airlines = top10;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '인기 항공사를 불러오는데 실패했습니다: $e';
          _isLoading = false;
        });
      }
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
          '인기 항공사',
          style: AppTextStyles.large.copyWith(color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage != null) {
      return Center(
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadPopularAirlines,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    if (_airlines.isEmpty) {
      return Center(
        child: Text(
          '인기 항공사 정보가 없습니다.',
          style: AppTextStyles.body.copyWith(color: AppColors.white),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(20),
        vertical: context.h(16),
      ),
      itemCount: _airlines.length,
      separatorBuilder: (context, index) => SizedBox(height: context.h(12)),
      itemBuilder: (context, index) {
        final airline = _airlines[index];
        return _buildAirlineItem(airline, index + 1);
      },
    );
  }

  /// 항공사 아이템 위젯
  Widget _buildAirlineItem(PopularAirlineResponse airline, int rank) {
    return GestureDetector(
      onTap: () => _navigateToAirlineDetail(airline),
      child: Container(
        width: context.w(335),
        height: context.h(90), 
        padding: EdgeInsets.symmetric(
          horizontal: context.w(20),
          vertical: context.h(16),
        ),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(context.w(12)),
        ),
        child: Row(
          children: [
            // 텍스트 영역 (순위 + 항공사 정보)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 순위 번호
                  SizedBox(
                    width: context.w(30),
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: context.fs(25), 
                        fontWeight: FontWeight.w600, 
                        height: 1.0,
                        letterSpacing: -context.fs(0.5), 
                        color:
                            rank <= 3
                                ? AppColors.yellow1 
                                : AppColors.white,
                      ),
                    ),
                  ),

                  SizedBox(width: context.w(16)),

                  // 항공사 정보 (이름 + 평점)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 항공사 이름
                        Text(
                          AirlineNameMapper.toKorean(airline.name), 
                          style: AppTextStyles.bigBody.copyWith(
                            fontSize: context.fs(15), 
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(height: context.h(4)),
                        // 평점
                        RichText(
                          text: TextSpan(
                            style: AppTextStyles.smallBody.copyWith(
                              fontSize: context.fs(13), 
                            ),
                            children: [
                              TextSpan(
                                text: '${airline.rating}',
                                style: AppTextStyles.smallBody.copyWith(
                                  fontSize: context.fs(13),
                                  color: AppColors.white, 
                                ),
                              ),
                              TextSpan(
                                text: '/5.0',
                                style: AppTextStyles.smallBody.copyWith(
                                  fontSize: context.fs(13),
                                  color: AppColors.white.withOpacity(0.5), 
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: context.w(12)),

            // 항공사 로고
            Container(
              width: context.w(50),
              height: context.h(50),
              decoration: BoxDecoration(
                color: AppColors.white, // 흰색 배경
                borderRadius: BorderRadius.circular(context.w(14)), // 코너 반경 14
              ),
              padding: EdgeInsets.all(context.w(8)), // 내부 패딩
              child: airline.logoUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(context.w(6)),
                      child: Image.network(
                        airline.logoUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.flight,
                            color: AppColors.white.withOpacity(0.3),
                            size: context.w(24),
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.flight,
                      color: AppColors.white.withOpacity(0.3),
                      size: context.w(24),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAirlineDetail(PopularAirlineResponse data) {
    // PopularAirlineResponse -> Airline 변환
    final airline = Airline(
      name: data.name,
      code: data.code,
      englishName: '', 
      logoPath: data.logoUrl,
      imagePath: '',
      tags: [],
      rating: data.rating,
      reviewCount: data.reviewCount,
      detailRating: const AirlineDetailRating(seatComfort: 0, foodAndBeverage: 0, service: 0, cleanliness: 0, punctuality: 0),
      reviewSummary: const AirlineReviewSummary(goodPoints: [], badPoints: []),
      basicInfo: const AirlineBasicInfo(headquarters: '', hubAirport: '', alliance: '', classes: ''),
    );

    context.pushNamed(
      'airline-detail',
      extra: airline,
    );
  }
}
