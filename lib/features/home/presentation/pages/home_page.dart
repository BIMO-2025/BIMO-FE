import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_tab_bar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../widgets/search_tab_selector.dart';
import '../widgets/airline_search_input.dart';
import '../widgets/destination_search_section.dart';
import '../widgets/popular_airlines_section.dart';

/// 홈 화면 메인 페이지
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Bottom tab bar index
  int _searchTabIndex = 0; // Search tab index (0: Airline, 1: Destination)
  final TextEditingController _airlineSearchController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      extendBody: true, // 본문이 탭바 영역까지 확장됨
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 커스텀 앱바 (높이 82px)
            CustomAppBar(
              hasUnreadNotifications: false, // TODO: 알림 상태 받아와서 확인할 게 있으면 상태 변경
              onNotificationTap: () {
                // TODO: 알림 화면으로 이동
              },
            ),
            // 본문 영역
            Expanded(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(
                    context,
                  ).unfocus(); // Dismiss keyboard on tap outside
                },
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  @override
  void dispose() {
    _airlineSearchController.dispose();
    super.dispose();
  }

  /// 메인 바디 영역
  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchTabSelector(
            selectedIndex: _searchTabIndex,
            onTap: (index) {
              setState(() {
                _searchTabIndex = index;
              });
            },
          ),
          if (_searchTabIndex == 0)
            AirlineSearchInput(controller: _airlineSearchController)
          else
            DestinationSearchSection(
              departureAirport: '인천 (INC)',
              arrivalAirport: '파리 (CDG)',
              departureDate: '', // 빈 문자열로 현재 날짜 플레이스홀더 표시
              onDepartureTap: () {
                // TODO: 출발 공항 선택 화면으로 이동
              },
              onArrivalTap: () {
                // TODO: 도착 공항 선택 화면으로 이동
              },
              onDateTap: () {
                // TODO: 날짜 선택 화면으로 이동
              },
              onSwapAirports: () {
                // TODO: 출발/도착 공항 교체
              },
            ),
          PopularAirlinesSection(
            weekLabel: '[10월 1주]',
            airlines: [
              AirlineData(
                name: '대한항공',
                rating: 4.3,
                logoPath: 'assets/images/home/korean_air_logo.png',
              ),
              AirlineData(
                name: '아시아나항공',
                rating: 4.3,
                logoPath: 'assets/images/home/asiana_logo.png',
              ),
              AirlineData(
                name: '티웨이항공',
                rating: 4.0,
                logoPath: 'assets/images/home/tway_logo.png',
              ),
            ],
            onMoreTap: () {
              // TODO: 인기 항공사 전체 목록 화면으로 이동
            },
          ),
        ],
      ),
    );
  }

  /// 하단 네비게이션 바
  Widget _buildBottomNavigationBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: CustomTabBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // TODO: 탭별 화면 전환 구현
        },
      ),
    );
  }
}
