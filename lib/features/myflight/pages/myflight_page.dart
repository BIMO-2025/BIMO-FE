import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/router/route_names.dart';
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
import '../../home/presentation/pages/airline_search_result_page.dart';
import '../../home/presentation/pages/airline_review_page.dart';
import '../data/repositories/local_flight_repository.dart';
import '../data/models/local_flight.dart';
import '../data/repositories/local_timeline_repository.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../../../core/storage/auth_token_storage.dart';
import '../data/repositories/flight_repository.dart';

/// MyFlight 메인 페이지
class MyFlightPage extends StatefulWidget {
  const MyFlightPage({super.key});

  @override
  State<MyFlightPage> createState() => _MyFlightPageState();
}

class _MyFlightPageState extends State<MyFlightPage> {
  int _selectedTabIndex = 0; // 0: 마이 플라이트, 1: 지난 비행
  Map<int, String> _flightIdMap = {}; // 인덱스 → 비행 ID 매핑
  int _currentScheduledPage = 0; // 예정된 비행 현재 페이지
  int _currentPastPage = 0; // 지난 비행 현재 페이지
  final bool _hasUnreadNotifications = false; // 알림 상태 (홈과 동일하게 관리)
  bool _isOfflineMode = true; // 오프라인 모드 (테스트용)
  bool _isLoading = false; // 로딩 상태

  @override
  void initState() {
    super.initState();
    // FlightState 변경 감지
    FlightState().addListener(_onFlightStateChanged);
    _loadScheduledFlights();
  }
  
  @override
  void dispose() {
    FlightState().removeListener(_onFlightStateChanged);
    super.dispose();
  }
  
  void _onFlightStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// 예정된 비행 목록 불러오기 (Hive 우선, API 보조)
  Future<void> _loadScheduledFlights() async {
    try {
      // Hive 초기화 대기 (main.dart에서 초기화 중일 수 있음)
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 1. Hive에서 로드 (오프라인 가능)
      final localFlightRepo = LocalFlightRepository();
      await localFlightRepo.init();
      final localFlights = await localFlightRepo.getScheduledFlights();
      
      if (localFlights.isNotEmpty) {
        // Hive에서 Flight 모델로 변환 + ID 매핑 저장
        _flightIdMap.clear();
        final flights = <Flight>[];
        
        for (int i = 0; i < localFlights.length; i++) {
          final lf = localFlights[i];
          _flightIdMap[i] = lf.id; // 인덱스 → ID 매핑
          
          flights.add(Flight(
            date: '${lf.departureTime.year}.${lf.departureTime.month.toString().padLeft(2, '0')}.${lf.departureTime.day.toString().padLeft(2, '0')}. (${_getWeekday(lf.departureTime)})',
            departureCode: lf.origin,
            arrivalCode: lf.destination,
            departureCity: _getCityName(lf.origin), // 한국어 도시명
            arrivalCity: _getCityName(lf.destination), // 한국어 도시명
            departureTime: _formatTimeToAmPm(lf.departureTime), // AM/PM 형식
            arrivalTime: _formatTimeToAmPm(lf.arrivalTime), // AM/PM 형식
            duration: lf.totalDuration,
            rating: null,
          ));
        }
        
        FlightState().scheduledFlights = flights;
        print('✅ Hive에서 ${localFlights.length}개 비행 로드 완료');
        return; // 성공하면 API 조회 스킵
      }
    } catch (e) {
      print('⚠️ Hive 로드 실패, API 조회로 전환: $e');
    }
    
    // 2. Hive 실패 시 API에서 조회
    await _loadFromAPI();
  }
  
  /// API에서 비행 로드 (백업용)
  Future<void> _loadFromAPI() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final storage = AuthTokenStorage();
      final userInfo = await storage.getUserInfo();
      final userId = userInfo['userId'];

      if (userId != null && userId.isNotEmpty) {
        final repository = FlightRepository();
        final flights = await repository.getMyFlights(userId, status: 'scheduled');
        
        // FlightState 업데이트
        FlightState().scheduledFlights = flights;
        
        print('✅ ${flights.length}개 예정된 비행 로드 완료');
      }
    } catch (e) {
      print('❌ 비행 목록 로드 실패: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
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
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: context.h(82) + 8, // 앱바 아래 8px 간격
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

          // 진행 중인 비행 섹션 (항상 표시 - offline 조건 제거)
          _buildInFlightSection(),
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
  
  /// 진행 중인 비행 섹션 (오프라인 모드)
  Widget _buildInFlightSection() {
    return FutureBuilder<LocalFlight?>(
      future: _getInProgressFlight(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink(); // 진행 중인 비행 없으면 숨김
        }
        
        final flight = snapshot.data!;
        
        // 타임라인 데이터 로드
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _loadTimelineForFlight(flight.id),
          builder: (context, timelineSnapshot) {
            final timeline = timelineSnapshot.data ?? [];
            
            return GestureDetector(
              onTap: () async {
                // 진행 중 비행 클릭 → 읽기 전용 FlightPlanPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlightPlanPage(
                      isReadOnly: true, // 편집 불가 모드
                      flightId: flight.id,
                    ),
                  ),
                );
              },
              child: InFlightProgressWidget(
                departureCode: flight.origin,
                departureCity: _getCityName(flight.origin),
                arrivalCode: flight.destination,
                arrivalCity: _getCityName(flight.destination),
                departureTime: _formatTimeToAmPm(flight.departureTime),
                arrivalTime: _formatTimeToAmPm(flight.arrivalTime),
                totalDurationMinutes: _parseDurationToMinutes(flight.totalDuration),
                departureDateTime: flight.departureTime,
                timeline: timeline,
              ),
            );
          },
        );
      },
    );
  }
  
  /// 비행의 타임라인 데이터 로드
  Future<List<Map<String, dynamic>>> _loadTimelineForFlight(String flightId) async {
    try {
      final localTimelineRepo = LocalTimelineRepository();
      await localTimelineRepo.init();
      final events = await localTimelineRepo.getTimeline(flightId);
      
      print('📅 타임라인 로드: ${events.length}개 이벤트');
      
      // LocalTimelineEvent → Map 변환
      return events.map((e) => {
        'title': e.title,
        'duration': e.duration,
      }).toList();
    } catch (e) {
      print('⚠️ 타임라인 로드 실패: $e');
      return [];
    }
  }
  
  /// 진행 중인 비행 가져오기
  Future<LocalFlight?> _getInProgressFlight() async {
    try {
      print('🔍 진행 중 비행 검색 시작');
      final localFlightRepo = LocalFlightRepository();
      await localFlightRepo.init();
      final flights = await localFlightRepo.getAllFlights();
      
      print('🔍 전체 비행 수: ${flights.length}');
      
      // status가 inProgress이거나 forceInProgress인 비행 찾기
      for (var flight in flights) {
        final status = flight.calculateStatus();
        print('🔍 비행 ${flight.id}: status=$status, forceInProgress=${flight.forceInProgress}');
        
        if (status == 'inProgress') {
          print('✅ 진행 중 비행 발견: ${flight.id}');
          return flight;
        }
      }
      
      print('⚠️ 진행 중 비행 없음');
      return null;
    } catch (e) {
      print('⚠️ 진행 중 비행 로드 실패: $e');
      return null;
    }
  }
  
  /// Duration 문자열을 분으로 변환 (예: "13h 0m" → 780)
  int _parseDurationToMinutes(String duration) {
    final parts = duration.split(' ');
    int totalMinutes = 0;
    
    for (var part in parts) {
      if (part.contains('h')) {
        totalMinutes += int.parse(part.replaceAll('h', '')) * 60;
      } else if (part.contains('m')) {
        totalMinutes += int.parse(part.replaceAll('m', ''));
      }
    }
    
    return totalMinutes;
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
                                builder: (context) => FlightPlanPage(
                                  flightId: _flightIdMap[index], // 해당 비행 ID 전달
                                ),
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
        isOnline: !_isOfflineMode,
        onToggleOffline: () {
          setState(() {
            _isOfflineMode = !_isOfflineMode;
          });
        },
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          if (index == 0) {
            context.go(RouteNames.home);
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
  
  /// 요일 변환 헬퍼
  String _getWeekday(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[date.weekday - 1];
  }
  
  /// 공항 코드 → 한국어 도시명 변환
  String _getCityName(String airportCode) {
    const cityMap = {
      'ICN': '인천',
      'GMP': '김포',
      'PUS': '부산',
      'CJU': '제주',
      'YYZ': '토론토',
      'JFK': '뉴욕',
      'LAX': '로스앤젤레스',
      'LHR': '런던',
      'CDG': '파리',
      'NRT': '도쿄',
      'HND': '도쿄',
      'PVG': '상하이',
      'HKG': '홍콩',
      'SIN': '싱가포르',
      'BKK': '방콕',
      'SYD': '시드니',
      'DXB': '두바이',
      'FRA': '프랑크푸르트',
      'AMS': '암스테르담',
      'ORD': '시카고',
      'SFO': '샌프란시스코',
    };
    return cityMap[airportCode] ?? airportCode;
  }
  
  /// 시간을 AM/PM 형식으로 변환
  String _formatTimeToAmPm(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}
