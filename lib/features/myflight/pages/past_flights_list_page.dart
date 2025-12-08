import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive_extensions.dart';
import '../widgets/flight_card_widget.dart';

/// 지난 비행 전체 리스트 페이지
class PastFlightsListPage extends StatelessWidget {
  const PastFlightsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 더미 데이터 (실제로는 FlightState에서 가져올 것)
    final pastFlights = _getDummyPastFlights();

    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 본문: 스크롤 가능한 리스트
            Positioned.fill(
              top: context.h(82), // 앱 바 높이
              child: pastFlights.isEmpty
                  ? _buildEmptyState(context)
                  : _buildFlightsList(context, pastFlights),
            ),
            // 커스텀 헤더
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildHeader(context),
            ),
          ],
        ),
      ),
    );
  }

  /// 헤더 (뒤로가기 + 타이틀)
  Widget _buildHeader(BuildContext context) {
    return Container(
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
            top: context.h(8),
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
          Center(
            child: Text(
              '지난 비행',
              style: AppTextStyles.medium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 비행 리스트
  Widget _buildFlightsList(BuildContext context, List<Map<String, dynamic>> flights) {
    return ListView.separated(
      padding: EdgeInsets.only(
        left: context.w(40),
        right: context.w(40),
        top: context.h(20),
        bottom: context.h(100),
      ),
      itemCount: flights.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final flight = flights[index];
        final hasRating = flight['rating'] != null;
        
        // 리스트 페이지는 모든 카드가 화이트 배경
        // 평점 있음 = 리뷰 완료 (노란 점 X)
        // 평점 없음 = 리뷰 미작성 ("리뷰 작성하고..." + 노란 점 O)
        
        return SizedBox(
          height: 247,
          child: FlightCardWidget(
            departureCode: flight['departureCode'],
            departureCity: flight['departureCity'],
            arrivalCode: flight['arrivalCode'],
            arrivalCity: flight['arrivalCity'],
            duration: flight['flightDuration'],
            departureTime: flight['departureTime'],
            arrivalTime: flight['arrivalTime'],
            date: flight['flightDate'],
            rating: flight['rating'],
            // 리스트 페이지는 항상 reviewText 설정 (화이트 배경용 -> 이제 isLightMode로 제어)
            // 평점 있으면 빈 문자열, 없으면 유도 텍스트
            reviewText: hasRating ? ' ' : '리뷰 작성하고 내 비행 기록하기',
            // 평점 없을 때만 노란 점
            hasEditNotification: !hasRating,
            // 리스트 페이지는 화이트 배경 사용
            isLightMode: true,
            onEditTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(hasRating ? '리뷰 수정 기능 준비 중입니다.' : '리뷰 작성 기능 준비 중입니다.'),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// 빈 상태 (비행이 없을 때)
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flight_takeoff,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          SizedBox(height: context.h(16)),
          Text(
            '지난 비행이 없습니다',
            style: AppTextStyles.body.copyWith(
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// 더미 데이터 (테스트용)
  List<Map<String, dynamic>> _getDummyPastFlights() {
    return [
      {
        'departureCode': 'DXB',
        'departureCity': '두바이',
        'arrivalCode': 'INC',
        'arrivalCity': '대한민국',
        'departureTime': '10:30 AM',
        'arrivalTime': '09:30 PM',
        'flightDuration': '13h 30m',
        'flightDate': '2025.11.26. (토)',
        'rating': 4.5,
        'airline': 'Emirates',
        // 평점 있음 = 리뷰 완료 (노란 점 X, 멘트 X)
      },
      {
        'departureCode': 'ICN',
        'departureCity': '인천',
        'arrivalCode': 'NRT',
        'arrivalCity': '도쿄',
        'departureTime': '08:00 AM',
        'arrivalTime': '10:30 AM',
        'flightDuration': '2h 30m',
        'flightDate': '2025.10.15. (수)',
        'rating': null, // 리뷰 미작성
        'airline': 'Korean Air',
        // 평점 없음 = 리뷰 미작성 ("리뷰 작성하고..." + 노란 점 O)
      },
      {
        'departureCode': 'LAX',
        'departureCity': '로스앤젤레스',
        'arrivalCode': 'ICN',
        'arrivalCity': '인천',
        'departureTime': '11:00 PM',
        'arrivalTime': '05:30 AM',
        'flightDuration': '13h 30m',
        'flightDate': '2025.09.20. (금)',
        'rating': 4.0,
        'airline': 'Asiana',
        // 평점 있음 = 리뷰 완료 (노란 점 X, 멘트 X)
      },
      {
        'departureCode': 'CDG',
        'departureCity': '파리',
        'arrivalCode': 'ICN',
        'arrivalCity': '인천',
        'departureTime': '03:00 PM',
        'arrivalTime': '10:00 AM',
        'flightDuration': '11h 30m',
        'flightDate': '2025.08.05. (화)',
        'rating': null, // 리뷰 미작성
        'airline': 'Air France',
        // 평점 없음 = 리뷰 미작성 ("리뷰 작성하고..." + 노란 점 O)
      },
    ];
  }
}
