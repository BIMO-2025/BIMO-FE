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
import '../../../../core/services/notification_service.dart'; // NotificationService import
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
import '../data/models/local_timeline_event.dart';
import '../data/models/local_flight.dart';
import '../data/repositories/local_timeline_repository.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../../../core/storage/auth_token_storage.dart';
import '../data/repositories/flight_repository.dart';
import '../data/repositories/local_timeline_repository.dart'; // LocalTimelineRepository import

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

  String _totalFlightTime = "0h 0m"; // [NEW] 총 비행 시간

  @override
  void initState() {
    super.initState();
    // FlightState 변경 감지
    FlightState().addListener(_onFlightStateChanged);
    _loadScheduledFlights();
    _loadPastFlights();
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
  
  void _refreshData() {
    if (mounted) {
      _loadScheduledFlights();
      _loadPastFlights();
      setState(() {});
    }
  }

  /// 예정된 비행 목록 불러오기 (Hive 우선, API 보조)
  Future<void> _loadScheduledFlights() async {
    try {
      // Hive 초기화 대기
      await Future.delayed(const Duration(milliseconds: 500));
      
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
            departureTime: _formatTimeToAmPm(lf.departureTime),
            arrivalTime: _formatTimeToAmPm(lf.arrivalTime),
            duration: lf.totalDuration,
            rating: null,
            id: lf.id,
          ));
        }
        
        FlightState().scheduledFlights = flights;
        print('✅ Hive에서 ${localFlights.length}개 비행 로드 완료');
        return;
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
    return FlightState().pastFlights.take(5).toList();
  }
  
  Future<void> _loadPastFlights() async {
    try {
      print('🔄 [Past] 지난 비행 로드 시작');
      final repo = LocalFlightRepository();
      await repo.init();
      final localFlights = await repo.getPastFlights();
      
      print('📦 [Past] Repository 반환 개수: ${localFlights.length}');
      
      // [NEW] 총 비행 시간 계산
      int totalMinutes = 0;
      for (final f in localFlights) {
        totalMinutes += _parseDurationToMinutes(f.totalDuration);
      }
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      final formattedTotalTime = '${hours}h ${minutes}m';

      if (localFlights.isEmpty) {
        print('⚠️ [Past] 로컬 비행 데이터 없음');
        FlightState().pastFlights = [];
        // [NEW] 초기화
        _totalFlightTime = "0h 0m"; 
        if (mounted) setState(() {});
        return;
      }
      
      // API로부터 hasReview 정보 가져오기
      Map<String, bool> hasReviewMap = {};
      try {
        final storage = AuthTokenStorage();
        final userInfo = await storage.getUserInfo();
        final userId = userInfo['userId'];
        
        if (userId != null && userId.isNotEmpty) {
          final repository = FlightRepository();
          hasReviewMap = await repository.getFlightSegmentsHasReview(userId, status: 'completed');
          print('✅ [Past] hasReview 정보 로드 완료: ${hasReviewMap.length}개');
        }
      } catch (e) {
        print('⚠️ [Past] hasReview 정보 로드 실패: $e');
      }
      
      final flights = <Flight>[];
      for (final lf in localFlights) {
        try {
          // 비행 ID로 hasReview 확인
          final hasReview = hasReviewMap[lf.id] ?? false;
          
          flights.add(Flight(
            date: '${lf.departureTime.year}.${lf.departureTime.month.toString().padLeft(2, '0')}.${lf.departureTime.day.toString().padLeft(2, '0')}. (${_getWeekday(lf.departureTime)})',
            departureCode: lf.origin,
            arrivalCode: lf.destination,
            departureCity: _getCityName(lf.origin),
            arrivalCity: _getCityName(lf.destination),
            departureTime: _formatTimeToAmPm(lf.departureTime),
            arrivalTime: _formatTimeToAmPm(lf.arrivalTime),
            duration: lf.totalDuration,
            rating: null,
            id: lf.id,
            hasReview: hasReview, // API에서 가져온 hasReview 정보
          ));
        } catch (e) {
          print('❌ [Past] 비행 변환 오류 (${lf.id}): $e');
        }
      }
      
      print('✅ [Past] UI용 변환 완료: ${flights.length}개');
      FlightState().pastFlights = flights;
      
      // [NEW] UI 상태 업데이트
      _totalFlightTime = formattedTotalTime;

      if (mounted) {
        print('🔄 [Past] setState 호출 (Total Time: $_totalFlightTime)');
        setState(() {});
      } else {
        print('⚠️ [Past] mounted 아님, setState 건너뜀');
      }
    } catch (e) {
      print('❌ Past flights load error: $e');
    }
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
            _totalFlightTime, // [FIX] 계산된 시간 사용
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
                // 진행 중 비행 클릭 → FlightPlanPage (읽기 전용 모드)
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlightPlanPage(
                      isReadOnly: true,
                      flightId: flight.id,
                    ),
                  ),
                );
                // 돌아오면 새로고침 (테스트 비행 설정 등이 있을 수 있음)
                _refreshData();
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
                flightId: flight.id, // flightId 전달
                onFlightEnded: _refreshData, // 비행 종료 시 새로고침
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
      
      var events = await localTimelineRepo.getTimeline(flightId);

      // 데이터가 없으면 자동 생성
      if (events.isEmpty) {
        final flightRepo = LocalFlightRepository();
        await flightRepo.init();
        final flight = await flightRepo.getFlight(flightId);
        if (flight != null) {
          print('⚠️ 타임라인 데이터 없음: 자동 생성 시작 ($flightId)');
          events = await localTimelineRepo.generateDefaultTimeline(
            flightId, 
            flight.departureTime, 
            flight.arrivalTime
          );
        }
      }

      // 데이터 손상 확인 및 자동 복구 (모든 이벤트 시간이 같을 경우)
      if (events.length > 1) {
        bool allSame = true;
        final firstStart = events[0].startTime;
        for (int i = 1; i < events.length; i++) {
          if (events[i].startTime != firstStart) {
            allSame = false;
            break;
          }
        }
        
        if (allSame) {
          await _repairTimeline(flightId, events);
        }
      }
      
      print('📅 타임라인 로드: ${events.length}개 이벤트');
      
      // LocalTimelineEvent → Map 변환
      return events.map((e) {
        // startTime과 endTime으로 duration 계산 (분 단위)
        final duration = e.endTime.difference(e.startTime).inMinutes;
        print('   [Timeline] ${e.title}: ${e.startTime.hour}:${e.startTime.minute} ~ ${e.endTime.hour}:${e.endTime.minute}');
        return {
          'title': e.title,
          'duration': duration,
        };
      }).toList();
    } catch (e) {
      print('⚠️ 타임라인 로드 실패: $e');
      return [];
    }
  }

  /// 타임라인 자동 복구 (시간 재분배)
  Future<void> _repairTimeline(String flightId, List<LocalTimelineEvent> events) async {
    print('⚠️ 타임라인 데이터 오류 감지: 자동 복구 시작 ($flightId)');
    
    try {
      final flightRepo = LocalFlightRepository();
      await flightRepo.init();
      final flight = await flightRepo.getFlight(flightId);
      
      if (flight == null) {
        print('❌ 비행 정보를 찾을 수 없어 복구 실패');
        return;
      }
      
      final totalDuration = flight.arrivalTime.difference(flight.departureTime);
      final eventCount = events.length;
      if (eventCount == 0) return;
      
      // 이벤트를 균등하게 분배 (단순화된 복구 로직)
      final durationPerEvent = totalDuration.inMinutes ~/ eventCount;
      
      final timelineRepo = LocalTimelineRepository();
      await timelineRepo.init();
      
      DateTime currentStart = flight.departureTime;
      
      for (int i = 0; i < eventCount; i++) {
        events[i].startTime = currentStart;
        events[i].endTime = currentStart.add(Duration(minutes: durationPerEvent));
        
        // 마지막 이벤트는 도착 시간으로 맞춤
        if (i == eventCount - 1) {
          events[i].endTime = flight.arrivalTime;
        }
        
        currentStart = events[i].endTime;
        
        // 업데이트 저장
        await timelineRepo.updateEvent(flightId, events[i].id, events[i]);
      }
      print('✅ 타임라인 자동 복구 완료 (균등 분배)');
      
    } catch (e) {
      print('❌ 타임라인 복구 중 에러: $e');
    }
  }
  
  /// 진행 중인 비행 가져오기
  Future<LocalFlight?> _getInProgressFlight() async {
    try {
      final localFlightRepo = LocalFlightRepository();
      await localFlightRepo.init();
      return await localFlightRepo.getInProgressFlight();
    } catch (e) {
      print('❌ 진행 중 비행 로드 실패: $e');
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
                          onTap: () async {
                            // 1. 타임라인 페이지로 이동
                            // 단순 조회/수정이므로 setInProgressFlight는 호출하지 않음 (사용자 요청)
                            final flightId = scheduledFlights[index].id;

                            // 2. 타임라인 페이지로 이동
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FlightPlanPage(
                                  isReadOnly: false,
                                  flightId: flightId ?? '', // 해당 비행 ID 전달
                                ),
                              ),
                            );
                            // 3. 돌아오면 새로고침
                            _refreshData();
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

            const SizedBox(height: 16),


          ],
        ],
      ),
    );
  }

  /// 지난 비행 섹션
  Widget _buildPastFlightsSection() {
    // 더미 데이터 (실제로는 상태 관리)
    final pastFlights = _getPastFlights();
    print('🎨 [UI] 지난 비행 섹션 빌드: ${pastFlights.length}개');
    
    // 데이터가 없어도 섹션은 보여주되 (0개로 표시), 
    // 여기서는 디자인상 0개면 안 보여주는지 확인 필요.
    // 현재 코드: pastFlights.length 사용
    
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
                          onEditTap: () async {
                            final hasReview = pastFlights[index].hasReview ?? false;
                            print('🔘 [MyFlight] 리뷰 작성 버튼 클릭! hasReview: $hasReview');
                            
                            if (hasReview) {
                              // 리뷰가 이미 있으면 수정 기능 (준비 중)
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('리뷰 수정 기능 준비 중입니다.')),
                              );
                            } else {
                              // 리뷰가 없으면 티켓 검증 카메라로 이동
                              print('📸 [MyFlight] 티켓 검증 카메라로 이동');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TicketVerificationCameraPage(
                                    departureCode: pastFlights[index].departureCode,
                                    departureCity: pastFlights[index].departureCity,
                                    arrivalCode: pastFlights[index].arrivalCode,
                                    arrivalCity: pastFlights[index].arrivalCity,
                                    flightNumber: 'KE001', // TODO: 실제 비행 번호로 교체
                                    date: pastFlights[index].date ?? '',
                                  ),
                                ),
                              );
                            }
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
