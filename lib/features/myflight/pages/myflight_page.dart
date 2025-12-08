import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_tab_bar.dart';
import '../../../../core/state/flight_state.dart';
import '../widgets/flight_card_widget.dart';
import '../widgets/in_flight_progress_widget.dart';
import '../models/flight_model.dart';
import 'add_flight_page.dart';
import 'flight_plan_page.dart';
import 'past_flights_list_page.dart';
import 'ticket_verification_camera_page.dart';
import '../../home/presentation/pages/home_page.dart';
import '../../../../core/utils/responsive_extensions.dart';

/// MyFlight 메인 페이지
class MyFlightPage extends StatefulWidget {
  const MyFlightPage({super.key});

  @override
  State<MyFlightPage> createState() => _MyFlightPageState();
}

class _MyFlightPageState extends State<MyFlightPage> {
  int _selectedTabIndex = 1; // MyFlight 탭 (index 1)
  int _currentScheduledPage = 0; // 예정된 비행 현재 페이지
  int _currentPastPage = 0; // 지난 비행 현재 페이지
  final bool _hasUnreadNotifications = false; // 알림 상태 (홈과 동일하게 관리)
  bool _isOfflineMode = true; // 오프라인 모드 (테스트용)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 본문 영역 (전체 화면)
            Positioned.fill(child: _buildBody()),

            // 커스텀 앱바 (위에 고정, 알림 아이콘만)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CustomAppBar(
                showLogo: false, // 로고 숨김
                hasUnreadNotifications:
                    _hasUnreadNotifications, // 알림 상태 (홈과 동일하게)
                onNotificationTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('알림 기능 준비 중입니다.')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// 예정된 비행 데이터 가져오기 (FlightState에서)
  List<Flight> _getScheduledFlights() {
    return FlightState().scheduledFlights;
  }

  /// 지난 비행 데이터 가져오기 (실제로는 상태 관리)
  List<Flight> _getPastFlights() {
    // 더미 데이터 - PastFlightsListPage와 동일한 데이터 사용
    // 실제로는 FlightState에서 가져와서 최대 5개만 표시
    final allPastFlights = [
      const Flight(
        departureCode: 'DXB',
        departureCity: '두바이',
        arrivalCode: 'INC',
        arrivalCity: '대한민국',
        duration: '13h 30m',
        departureTime: '10:30 AM',
        arrivalTime: '09:30 PM',
        rating: 4.5,
        date: '2025.11.26. (토)',
        // 평점 있음 = 리뷰 완료
      ),
      const Flight(
        departureCode: 'ICN',
        departureCity: '인천',
        arrivalCode: 'NRT',
        arrivalCity: '도쿄',
        duration: '2h 30m',
        departureTime: '08:00 AM',
        arrivalTime: '10:30 AM',
        rating: null, // 리뷰 미작성
        date: '2025.10.15. (수)',
        // 평점 없음 = 리뷰 미작성 ("리뷰 작성하고..." + 노란 점 O)
      ),
      const Flight(
        departureCode: 'LAX',
        departureCity: '로스앤젤레스',
        arrivalCode: 'ICN',
        arrivalCity: '인천',
        duration: '13h 30m',
        departureTime: '11:00 PM',
        arrivalTime: '05:30 AM',
        rating: 4.0,
        date: '2025.09.20. (금)',
        // 평점 있음 = 리뷰 완료
      ),
      const Flight(
        departureCode: 'CDG',
        departureCity: '파리',
        arrivalCode: 'ICN',
        arrivalCity: '인천',
        duration: '11h 30m',
        departureTime: '03:00 PM',
        arrivalTime: '10:00 AM',
        rating: null, // 리뷰 미작성
        date: '2025.08.05. (화)',
        // 평점 없음 = 리뷰 미작성 ("리뷰 작성하고..." + 노란 점 O)
      ),
    ];
    
    return allPastFlights.take(5).toList(); // 최대 5개까지만 표시
  }

  /// 메인 바디 영역
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 88, // AppBar 높이(82) + 간격(6)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타이틀: "BIMO와 함께한 시간" (body 스타일)
          Text(
            'BIMO와 함께한 시간',
            style: AppTextStyles.body.copyWith(color: Colors.white),
          ),

          const SizedBox(height: 4), // 간격 4px
          // 총 비행 시간 (display 스타일)
          Text(
            '65h 30m',
            style: AppTextStyles.display.copyWith(color: Colors.white),
          ),

          const SizedBox(height: 32),

          // 진행 중인 비행 섹션 (오프라인 모드 시만 표시)
          if (_isOfflineMode) ...[
            _buildInFlightSection(),
            const SizedBox(height: 32),
          ],

          // 예정된 비행 섹션
          _buildScheduledFlightsSection(),

          // 예정 비행과 지난 비행 사이 간격
          SizedBox(
            height:
                _getScheduledFlights().isEmpty && _getPastFlights().isEmpty
                    ? 24
                    : 32,
          ),

          // 지난 비행 섹션
          _buildPastFlightsSection(),

          const SizedBox(height: 100), // 하단 여백 (탭바 공간)
        ],
      ),
    );
  }

  /// 진행 중인 비행 섹션 (오프라인 모드)
  Widget _buildInFlightSection() {
    // 더미 데이터 (실제로는 FlightState에서 가져와야 함)
    return InFlightProgressWidget(
      departureCode: 'DXB',
      departureCity: '두바이',
      arrivalCode: 'INC',
      arrivalCity: '인천',
      departureTime: '09:00',
      arrivalTime: '19:40',
      totalDurationMinutes: 870, // 14h 30m
      departureDateTime: DateTime.now(), // 실제로는 비행 출발 시간
      timeline: [
        {'title': '비행기 탑승', 'duration': 30},
        {'title': '이륙 및 안정', 'duration': 60},
        {'title': '첫 번째 가능한 활동 (비빔밥 or 볼로기)', 'duration': 90},
        {'title': '휴식 시간', 'duration': 120},
        {'title': '영화 감상', 'duration': 90},
        {'title': '두 번째 식사', 'duration': 60},
        {'title': '착륙 준비', 'duration': 420},
      ],
    );
  }

  /// 예정된 비행 섹션
  Widget _buildScheduledFlightsSection() {
    // 더미 데이터 (실제로는 상태 관리)
    final scheduledFlights = _getScheduledFlights();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 26),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1), // 흰색 10%
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더: "예정된 비행" + 노란 배지 + "+" 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // "예정된 비행" (medium 스타일)
                    Text(
                      '예정된 비행',
                      style: AppTextStyles.medium.copyWith(color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    // 노란 동그라미 배지 (개수 표시)
                    Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDDFF66), // Y1: #DF6
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          scheduledFlights.length.toString(),
                          style: AppTextStyles.smallBody.copyWith(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Plus 버튼 (원형)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddFlightPage(),
                      ),
                    );
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: SvgPicture.asset(
                      'assets/images/myflight/Plus.svg',
                      width: 18,
                      height: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 데이터가 있을 때만 카드와 인디케이터 표시
          if (scheduledFlights.isNotEmpty) ...[
            const SizedBox(height: 16),

            // 비행 카드 (PageView)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: context.h(140), // 카드 높이 조정 (200 -> 140)
                child: PageView.builder(
                  itemCount: scheduledFlights.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentScheduledPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 0), // 카드 간격
                      child: SizedBox(
                        height: 131, // 예정된 비행 카드 높이 고정
                        child: FlightCardWidget(
                          departureCode: scheduledFlights[index].departureCode,
                          departureCity: scheduledFlights[index].departureCity,
                          arrivalCode: scheduledFlights[index].arrivalCode,
                          arrivalCity: scheduledFlights[index].arrivalCity,
                          duration: scheduledFlights[index].duration,
                          departureTime: scheduledFlights[index].departureTime,
                          arrivalTime: scheduledFlights[index].arrivalTime,
                          onTap: () {
                            // 타임라인 페이지로 이동
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FlightPlanPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 페이지 인디케이터
            if (scheduledFlights.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    scheduledFlights.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _currentScheduledPage == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// 지난 비행 섹션
  Widget _buildPastFlightsSection() {
    // 더미 데이터 (실제로는 상태 관리)
    final pastFlights = _getPastFlights();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 26),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1), // 흰색 10%
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더: "지난 비행" + ">" 아이콘
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '지난 비행',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // > 버튼 (원형)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PastFlightsListPage(),
                      ),
                    );
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Transform.scale(
                      scaleX: -1, // 좌우 반전
                      child: Image.asset(
                        'assets/images/myflight/back.png',
                        width: 12,
                        height: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 데이터가 있을 때만 카드와 인디케이터 표시
          if (pastFlights.isNotEmpty) ...[
            const SizedBox(height: 16),

            // 비행 카드 (PageView)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 247, // 지난 비행 카드 높이 고정 (Figma 기준)
                child: PageView.builder(
                  itemCount: pastFlights.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPastPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 0), // 카드 간격
                        child: FlightCardWidget(
                          departureCode: pastFlights[index].departureCode,
                          departureCity: pastFlights[index].departureCity,
                          arrivalCode: pastFlights[index].arrivalCode,
                          arrivalCity: pastFlights[index].arrivalCity,
                          duration: pastFlights[index].duration,
                          departureTime: pastFlights[index].departureTime,
                          arrivalTime: pastFlights[index].arrivalTime,
                          rating: pastFlights[index].rating,
                          date: pastFlights[index].date,
                          // 평점 없음 = 리뷰 미작성 (노란 점 표시)
                          hasEditNotification: pastFlights[index].rating == null,
                          onEditTap: () {
                            // 리뷰 수정 페이지로 이동
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('리뷰 수정 기능 준비 중입니다.')),
                            );
                          },
                        ),
                      );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 페이지 인디케이터 (최대 5개)
            if (pastFlights.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pastFlights.length, // 최대 5개까지만 표시
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _currentPastPage == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// 하단 네비게이션 바
  Widget _buildBottomNavigationBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: CustomTabBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (index == 1) {
            // Already here
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('준비 중인 기능입니다.')));
          }
          setState(() {
            _selectedTabIndex = index;
          });
        },
      ),
    );
  }
}
