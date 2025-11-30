import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_tab_bar.dart';
import '../widgets/flight_card_widget.dart';
import '../models/flight_model.dart';
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

  /// 예정된 비행 데이터 가져오기 (실제로는 상태 관리)
  List<Flight> _getScheduledFlights() {
    return <Flight>[]; // 빈 상태 테스트용
  }

  /// 지난 비행 데이터 가져오기 (실제로는 상태 관리)
  List<Flight> _getPastFlights() {
    return <Flight>[]; // 빈 상태 테스트용
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
                // Plus 버튼 (24x24)
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('비행 추가 기능 준비 중입니다.')),
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/images/myflight/Plus.svg',
                    width: 24,
                    height: 24,
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
                      margin: const EdgeInsets.symmetric(horizontal: 4),
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
                Transform.scale(
                  scaleX: -1, // 좌우 반전
                  child: Image.asset(
                    'assets/images/myflight/back.png',
                    width: 24,
                    height: 24,
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
                      child: SizedBox(
                        height: 247, // 지난 비행 카드 높이 고정
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
                          hasEditNotification: true, // 편집 알림 활성화 (테스트용)
                          onEditTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('편집 기능 준비 중입니다.')),
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
            if (pastFlights.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pastFlights.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
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
