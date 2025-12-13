import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../data/datasources/airline_api_service.dart';
import '../../data/models/popular_airline_response.dart';

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

  /// 전체 인기 항공사 로드
  Future<void> _loadPopularAirlines() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final airlines = await _apiService.getPopularAirlines(limit: 10);

      setState(() {
        _airlines = airlines;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '인기 항공사를 불러오는데 실패했습니다: $e';
        _isLoading = false;
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
    return Container(
      width: context.w(335),
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
          // 순위
          SizedBox(
            width: context.w(30),
            child: Text(
              '$rank',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: context.fs(20),
                fontWeight: FontWeight.w600,
                color:
                    rank <= 3
                        ? const Color(0xFFFFCC00) // 1-3위는 노란색
                        : AppColors.white,
              ),
            ),
          ),

          SizedBox(width: context.w(16)),

          // 항공사 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 항공사 이름
                Text(
                  airline.name,
                  style: AppTextStyles.bigBody.copyWith(color: AppColors.white),
                ),
                SizedBox(height: context.h(4)),
                // 평점
                Row(
                  children: [
                    Text(
                      '${airline.rating}',
                      style: AppTextStyles.smallBody.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      '/5.0',
                      style: AppTextStyles.smallBody.copyWith(
                        color: AppColors.white.withOpacity(0.5),
                      ),
                    ),
                    SizedBox(width: context.w(8)),
                    Text(
                      '리뷰 ${airline.reviewCount}개',
                      style: AppTextStyles.smallBody.copyWith(
                        color: AppColors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 항공사 로고
          if (airline.logoUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                airline.logoUrl,
                width: context.w(50),
                height: context.h(50),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: context.w(50),
                    height: context.h(50),
                    color: AppColors.white.withOpacity(0.1),
                    child: Icon(
                      Icons.flight,
                      color: AppColors.white.withOpacity(0.3),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              width: context.w(50),
              height: context.h(50),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.flight,
                color: AppColors.white.withOpacity(0.3),
              ),
            ),
        ],
      ),
    );
  }
}
