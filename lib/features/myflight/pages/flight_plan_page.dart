import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_extensions.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/state/flight_state.dart';
import '../../../core/state/timeline_state.dart';
import '../data/repositories/local_timeline_repository.dart';
import '../data/repositories/local_flight_repository.dart';
import '../data/models/local_timeline_event.dart';
import '../data/models/local_flight.dart';
import '../models/flight_model.dart';
import 'flight_plan_end_page.dart';
import 'myflight_page.dart';
import '../../../core/services/notification_service.dart'; // NotificationService import
import '../../../core/services/notification_service.dart'; // NotificationService import

/// 비행 플랜 페이지
class FlightPlanPage extends StatefulWidget {
  final String? flightId; // 표시할 비행 ID (null이면 최신 비행)
  final bool isReadOnly; // 읽기 전용 모드 (편집 불가)
  
  const FlightPlanPage({
    super.key,
    this.flightId,
    this.isReadOnly = false, // 기본값: 편집 가능
  });

  @override
  State<FlightPlanPage> createState() => _FlightPlanPageState();
}

class _FlightPlanPageState extends State<FlightPlanPage> {
  List<TimelineEvent> _events = []; // 빈 리스트로 초기화
  TimelineEvent? _selectedEvent; // 선택된 이벤트 (하나만)
  bool _showMoreOptions = false; // 더보기 옵션 메뉴 표시 여부
  List<TimelineEvent> _initialEvents = []; // 초기 타임라인 (AI 초기화용)
  LocalFlight? _currentFlight; // 현재 표시 중인 비행 정보
  List<LocalTimelineEvent> _localTimelineEvents = []; // Hive 원본 데이터 (시간 비교용)
  
  // 읽기 전용 모드 타이머
  Timer? _autoHighlightTimer;
  int _elapsedSeconds = 0;
  // int _debugTimeOffsetMinutes = 0; // 전역 상태 사용

  @override
  void initState() {
    super.initState();
    _loadTimelineFromHive();
    
    // 읽기 전용 모드일 때 자동 하이라이트 타이머 시작
    if (widget.isReadOnly) {
      _startAutoHighlightTimer();
    }
  }
  
  @override
  void dispose() {
    _autoHighlightTimer?.cancel();
    super.dispose();
  }
  
  /// 자동 하이라이트 타이머 시작
  void _startAutoHighlightTimer() {
    _autoHighlightTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
          _updateCurrentEventHighlight();
        });
      }
    });
  }
  
  
  /// 현재 진행 중인 이벤트 하이라이트 업데이트 (InFlightProgressWidget과 로직 통일)
  void _updateCurrentEventHighlight() {
    if (!widget.isReadOnly) return;
    if (_localTimelineEvents.isEmpty || _currentFlight == null) return;
    
    final now = DateTime.now().add(FlightState().debugTimeOffset);
    final departureTime = _currentFlight!.departureTime;
    
    // 경과 시간 계산 (초 단위)
    final diff = now.difference(departureTime).inSeconds;
    final elapsedSeconds = diff > 0 ? diff : 0;
    
    // 1. 비행 시작 전
    if (diff < 0) {
      for (int i = 0; i < _events.length; i++) {
         _events[i].isActive = (i == 0);
      }
      return;
    }
    
    // 2. 경과 시간에 따른 활성 인덱스 찾기
    int activeIndex = -1;
    int cumulativeMinutes = 0;
    
    for (int i = 0; i < _localTimelineEvents.length; i++) {
        // LocalTimelineEvent에는 duration 필드가 없으므로 start/end 차이로 계산
        final localEvent = _localTimelineEvents[i];
        
        // 날짜 무시하고 시간 차이로 Duration 반환
        int durationMinutes;
        try {
            // 시간 파싱 로직 이용하거나, 저장된 Times로 계산
             Duration d = localEvent.endTime.difference(localEvent.startTime);
             if (d.isNegative) { 
                 d += const Duration(days: 1); // 자정 넘김 처리
             }
             durationMinutes = d.inMinutes;
        } catch (_) {
            durationMinutes = 60; // fallback
        }

        // 범위 체크: cumulative <= elapsed < cumulative + duration
        if (elapsedSeconds < (cumulativeMinutes + durationMinutes) * 60) {
            activeIndex = i;
            break;
        }
        
        cumulativeMinutes += durationMinutes;
    }
    
    // 3. 만약 범위 내에 없다면 (모든 시간 지남) -> 마지막 항목 활성화
    if (activeIndex == -1) {
        activeIndex = _events.length - 1;
    }
    
    // 4. UI 적용
    for (int i = 0; i < _events.length; i++) {
        if (i < _events.length) {
            _events[i].isActive = (i == activeIndex);
        }
    }
  }
  
  /// 시간 문자열을 분 단위로 변환 (예: "6:55 AM - 7:55 AM" → 60)
  int _parseDurationToMinutes(String timeString) {
    final parts = timeString.split(' - ');
    if (parts.length != 2) return 0;
    
    try {
      final start = _parseTime(parts[0]);
      final end = _parseTime(parts[1]);
      return end.difference(start).inMinutes;
    } catch (e) {
      return 0;
    }
  }
  
  DateTime _parseTime(String time) {
    // "6:55 AM" 형식 파싱
    final cleaned = time.trim();
    final parts = cleaned.split(' ');
    final timeParts = parts[0].split(':');
    
    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final isPM = parts.length > 1 && parts[1].toUpperCase() == 'PM';
    
    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;
    
    return DateTime(2025, 1, 1, hour, minute);
  }
  
  /// Hive에서 타임라인 로드 (가장 최근 예정된 비행 우선)
  Future<void> _loadTimelineFromHive() async {
    try {
      // 1. 로컬 비행 저장소 초기화
      final localFlightRepo = LocalFlightRepository();
      await localFlightRepo.init();
      
      String? targetFlightId = widget.flightId;
      LocalFlight? targetFlight;
      
      // 2. flightId가 제공되지 않으면 가장 최근 비행 탐색
      if (targetFlightId == null) {
        final scheduledFlights = await localFlightRepo.getScheduledFlights();
        
        if (scheduledFlights.isEmpty) {
          print('⚠️ Hive에 예정된 비행 없음, TimelineState 사용');
          _events = _getTimelineEvents();
          _initialEvents = List.from(_events);
          if (mounted) setState(() {});
          return;
        }
        
        scheduledFlights.sort((a, b) => a.departureTime.compareTo(b.departureTime));
        targetFlight = scheduledFlights.first;
        targetFlightId = targetFlight.id;
      } else {
        // flightId로 비행 정보 가져오기
        targetFlight = await localFlightRepo.getFlight(targetFlightId);
      }
      
      // 3. 현재 비행 정보 저장
      _currentFlight = targetFlight;
      
      // 4. 해당 비행의 타임라인 로드
      final localTimelineRepo = LocalTimelineRepository();
      await localTimelineRepo.init();
      // 1. 저장된 타임라인 조회
    var localEvents = await localTimelineRepo.getTimeline(targetFlightId);
    
    // 2. 없으면 자동 생성
    if (localEvents.isEmpty && _currentFlight != null) {
      print('⚠️ 타임라인 데이터 없음: 자동 생성 시작 (${targetFlightId})');
      localEvents = await localTimelineRepo.generateDefaultTimeline(
        targetFlightId,
        _currentFlight!.departureTime,
        _currentFlight!.arrivalTime,
      );
    } 

    if (localEvents.isEmpty) {
      print('❌ 타임라인 생성 실패 또는 비행 정보 없음');
      return;
    }
    
    _localTimelineEvents = localEvents;

    // 3. 데이터 손상 확인 및 자동 복구    // [Self-Healing] 데이터 오염 감지 (모든 시간이 동일한 경우)
      if (localEvents.length > 1 && localEvents.every((e) => e.startTime.isAtSameMomentAs(localEvents[0].startTime))) {
          print('🚨 타임라인 데이터 오염 감지! 자동 복구를 시작합니다.');
          
          if (_currentFlight != null) {
            final flight = _currentFlight!;
            final durationMinutes = _parseDurationToMinutes(flight.totalDuration);
            final departureTime = flight.departureTime;
            final arrivalTime = departureTime.add(Duration(minutes: durationMinutes));
            
            final segmentDuration = durationMinutes ~/ localEvents.length;
            
            for (int i = 0; i < localEvents.length; i++) {
                 final start = departureTime.add(Duration(minutes: i * segmentDuration));
                 final end = (i == localEvents.length - 1) 
                     ? arrivalTime 
                     : start.add(Duration(minutes: segmentDuration));
                 
                 localEvents[i].startTime = start;
                 localEvents[i].endTime = end;
            }
            
            // 복구된 데이터 저장
            await localTimelineRepo.saveTimeline(targetFlightId, localEvents);
            print('✅ 타임라인 자동 복구 및 저장 완료');
          }
      }

      if (localEvents.isEmpty) {
        print('⚠️ 비행 $targetFlightId에 타임라인 없음, TimelineState 사용');
        _events = _getTimelineEvents();
      } else {
        // 5. LocalTimelineEvent → TimelineEvent 변환
        _events = localEvents.map((le) {
          final data = le.toTimelineEvent() as Map<String, dynamic>;
          
          // 시간 문자열 재구성 (복구된 시간 반영)
          final startStr = _minutesToTimeString(le.startTime.hour * 60 + le.startTime.minute);
          final endStr = _minutesToTimeString(le.endTime.hour * 60 + le.endTime.minute);
          final formattedTime = '$startStr - $endStr';
          
          return TimelineEvent(
            icon: data['icon'] as String?,
            title: data['title'] as String,
            time: formattedTime, // 재구성된 시간 사용
            description: data['description'] as String,
            isEditable: data['isEditable'] as bool? ?? false,
            isActive: data['isActive'] as bool? ?? false,
          );
        }).toList();
        print('✅ Hive에서 비행 $targetFlightId의 ${localEvents.length}개 타임라인 이벤트 로드');
      }
      

      
      _initialEvents = List.from(_events);
      
      // [Flicker Fix] 초기 로딩 직후 즉시 하이라이트 적용 (깜빡임 방지)
      if (widget.isReadOnly) {
          _updateCurrentEventHighlight();
      }
      
      // 알림 스케줄링
      _scheduleNotifications(_localTimelineEvents);

      if (mounted) setState(() {});
      
    } catch (e) {
      print('❌ Hive 타임라인 로드 실패: $e');
      _events = _getTimelineEvents();
      _initialEvents = List.from(_events);
      if (mounted) setState(() {});
    }
  }

  /// 타임라인 알림 스케줄링
  Future<void> _scheduleNotifications(List<LocalTimelineEvent> events) async {
    final notificationService = NotificationService();
    // 비행 ID가 있다면 해시코드로 사용, 없으면 0
    final flightIdHash = _currentFlight?.id.hashCode ?? 0;
    
    print('🔔 ${events.length}개 타임라인 알림 스케줄링 시작');
    
    for (int i = 0; i < events.length; i++) {
        final event = events[i];
        
        // 아이콘 추출 (LocalTimelineEvent -> UI Model 변환 활용)
        final uiEvent = event.toTimelineEvent() as Map<String, dynamic>;
        final iconPath = uiEvent['icon'] as String?;
        
        // 고유 ID 생성 (flightId hash ^ index)
        final notiId = (flightIdHash ^ i) & 0x7FFFFFFF;
        
        // 과거 이벤트는 예약 스킵 (선택 사항, NotificationService가 알아서 handle하겠지만)
        if (event.startTime.isBefore(DateTime.now())) continue;

        await notificationService.scheduleTimelineNotification(
            id: notiId,
            title: event.title,
            body: event.description,
            scheduledTime: event.startTime,
            iconAssetPath: iconPath,
        );
    }
  }

  /// Asset 경로를 IconType으로 역매핑 (저장용)
  String? _mapAssetToIconType(String? assetPath) {
    if (assetPath == null) return null;
    if (assetPath.contains('airplane')) return 'airplane';
    if (assetPath.contains('meal')) return 'meal';
    if (assetPath.contains('moon')) return 'moon';
    return null;
  }
  
  /// 현재 타임라인을 Hive에 저장
  Future<void> _saveTimelineToHive() async {
    if (_currentFlight == null) {
      print('⚠️ 현재 비행 정보 없음, Hive 저장 스킵');
      return;
    }
    
    try {
      final localTimelineRepo = LocalTimelineRepository();
      await localTimelineRepo.init();
      
      // TimelineEvent → LocalTimelineEvent 변환
      final localEvents = _events.asMap().entries.map((entry) {
        final index = entry.key;
        final event = entry.value;
        
        // 시간 파싱
        DateTime startTime;
        DateTime endTime;
        try {
            final parts = event.time.split(' - ');
            final startDt = _parseTime(parts[0]);
            final endDt = _parseTime(parts[1]);
            
            final baseDate = _currentFlight!.departureTime;
            startTime = DateTime(baseDate.year, baseDate.month, baseDate.day, startDt.hour, startDt.minute);
            endTime = DateTime(baseDate.year, baseDate.month, baseDate.day, endDt.hour, endDt.minute);
            
            // 종료 시간이 시작 시간보다 빠르면 다음날로 처리
            if (endTime.isBefore(startTime)) {
                endTime = endTime.add(const Duration(days: 1));
            }
        } catch (e) {
             print('⚠️ 시간 파싱 실패: ${event.time}, 현재 시간으로 대체');
             final now = DateTime.now();
             startTime = now;
             endTime = now.add(const Duration(hours: 1));
        }
        
        return LocalTimelineEvent(
          id: '${_currentFlight!.id}_$index',
          flightId: _currentFlight!.id,
          order: index,
          type: event.isEditable ? 'FREE_TIME' : 'CUSTOM',
          title: event.title,
          description: event.description,
          startTime: startTime,
          endTime: endTime,
          iconType: _mapAssetToIconType(event.icon),
          isEditable: event.isEditable,
          isCustom: true,
          isActive: event.isActive,
        );
      }).toList();
      
      // Hive에 전체 타임라인 저장
      await localTimelineRepo.saveTimeline(_currentFlight!.id, localEvents);
      print('✅ Hive에 타임라인 ${localEvents.length}개 저장 완료');
    } catch (e) {
      print('❌ Hive 타임라인 저장 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 본문 영역
            Positioned.fill(child: _buildBody(context)),
            // 헤더
            Positioned(top: 0, left: 0, right: 0, child: _buildHeader(context)),
            // 더보기 옵션 메뉴 오버레이
            if (_showMoreOptions) _buildMoreOptionsOverlay(context),
            // 플로팅 액션 버튼
            Positioned(
              right: context.w(19), // 오른쪽에서 19px
              bottom:
                  context.h(32) +
                  Responsive.homeIndicatorHeight(context), // 하단 인디케이터 위로 32px
              child: _buildFloatingActionButton(context),
            ),
          ],
        ),
      ),
    );
  }

  /// 헤더 (뒤로가기 + 타이틀 + 더보기)
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
            top: context.h(21),
            child: GestureDetector(
              onTap: () async {
                print('🔙 FlightPlanPage 뒤로가기 버튼 클릭');
                
                // 읽기 전용 모드에서는 바로 뒤로가기
                if (widget.isReadOnly) {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.goNamed('home', extra: {'initialIndex': 1});
                  }
                  return;
                }
                
                // 편집 모드에서만 저장 확인 모달
                final shouldSave = await _showSaveConfirmationModal(context);
                if (shouldSave != null) {
                  if (shouldSave) {
                    await _saveTimelineToHive();
                    if (context.mounted) {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        // 스택이 없는 경우 (직접 이동한 경우) 홈 > 마이플라이트로 이동
                        context.goNamed('home', extra: {'initialIndex': 1});
                      }
                    }
                  } else {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goNamed('home', extra: {'initialIndex': 1});
                    }
                  }
                }
              },
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
                '나의 비행 플랜',
                style: AppTextStyles.large.copyWith(color: Colors.white),
              ),
            ),
          ),
          // 더보기 버튼 (오른쪽) - 읽기 전용 모드에서는 숨김
          if (!widget.isReadOnly)
          Positioned(
            right: context.w(20),
            top: context.h(21),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showMoreOptions = !_showMoreOptions;
                });
              },
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
                        'assets/images/myflight/more.png',
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
          

        ],
      ),
    );
  }

  /// 메인 바디 영역
  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: context.w(20),
        right: context.w(20),
        top: context.h(82) + context.h(8), // 헤더 + 간격 8px
        bottom: context.h(100), // 하단 여백
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 비행 정보
          _buildFlightInfo(context),
          const SizedBox(height: 32),
          // 타임라인
          _buildTimeline(context),
        ],
      ),
    );
  }

  /// 공항 코드에서 도시 이름 추론
  String _getCityName(String airportCode) {
    const cityMap = {
      'ICN': '인천',
      'GMP': '김포',
      'PUS': '부산',
      'CJU': '제주',
      'NRT': '도쿄',
      'HND': '도쿄',
      'JFK': '뉴욕',
      'LAX': '로스앤젤레스',
      'YYZ': '토론토',
      'LHR': '런던',
      'CDG': '파리',
      'DXB': '두바이',
    };
    return cityMap[airportCode] ?? airportCode;
  }

  /// 요일 반환
  String _getWeekday(DateTime dateTime) {
    switch (dateTime.weekday) {
      case DateTime.monday:
        return '월';
      case DateTime.tuesday:
        return '화';
      case DateTime.wednesday:
        return '수';
      case DateTime.thursday:
        return '목';
      case DateTime.friday:
        return '금';
      case DateTime.saturday:
        return '토';
      case DateTime.sunday:
        return '일';
      default:
        return '';
    }
  }

  /// 비행 정보
  Widget _buildFlightInfo(BuildContext context) {
    // _currentFlight 사용 (Hive에서 로드한 실제 데이터)
    if (_currentFlight != null) {
      final origin = _currentFlight!.origin;
      final destination = _currentFlight!.destination;
      final totalDuration = _currentFlight!.totalDuration;
      
      // 날짜 포맷팅
      final dt = _currentFlight!.departureTime;
      final weekday = _getWeekday(dt);
      final date = '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}. ($weekday)';
      
      return Center(
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Column(children: [
              Text(origin, style: AppTextStyles.display.copyWith(color: Colors.white)),
              Text(_getCityName(origin), style: AppTextStyles.body.copyWith(color: Colors.white.withOpacity(0.5))),
            ]),
            const SizedBox(width: 16),
            SvgPicture.asset('assets/images/myflight/arrow.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
            const SizedBox(width: 16),
            Column(children: [
              Text(destination, style: AppTextStyles.display.copyWith(color: Colors.white)),
              Text(_getCityName(destination), style: AppTextStyles.body.copyWith(color: Colors.white.withOpacity(0.5))),
            ]),
          ]),
          const SizedBox(height: 8),
          RichText(textAlign: TextAlign.center, text: TextSpan(style: AppTextStyles.body.copyWith(color: Colors.white), children: [
            TextSpan(text: '$date | '),
            TextSpan(text: totalDuration, style: AppTextStyles.bigBody.copyWith(color: Colors.white)),
          ])),
        ]),
      );
    }
    
    // Fallback: TimelineState 또는 기본값
    final timelineData = TimelineState().timelineData;
    final flightInfo = timelineData?['flight_info'] as Map<String, dynamic>?;
    final flights = FlightState().scheduledFlights;
    final latestFlight = flights.isNotEmpty ? flights.last : null;
    
    final origin = flightInfo?['origin'] as String? ?? 'DXB';
    final destination = flightInfo?['destination'] as String? ?? 'ICN';
    final totalDuration = flightInfo?['total_duration'] as String? ?? '14h 15m';
    final date = latestFlight?.date ?? '2025.11.25. (토)';
    
    // 공항 코드에서 도시 이름 추론
    String getCityName(String airportCode) {
      const cityMap = {
        'ICN': '인천',
        'GMP': '김포',
        'PUS': '부산',
        'CJU': '제주',
        'NRT': '도쿄',
        'HND': '도쿄',
        'JFK': '뉴욕',
        'LAX': '로스앤젤레스',
        'YYZ': '토론토',
        'LHR': '런던',
        'CDG': '파리',
        'DXB': '두바이',
      };
      return cityMap[airportCode] ?? airportCode;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Origin → Destination
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    origin,
                    style: AppTextStyles.display.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 0),
                  Text(
                    getCityName(origin),
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              SvgPicture.asset(
                'assets/images/myflight/arrow.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    destination,
                    style: AppTextStyles.display.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 0),
                  Text(
                    getCityName(destination),
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 날짜 및 시간
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTextStyles.body.copyWith(color: Colors.white),
              children: [
                TextSpan(text: '$date | '),
                TextSpan(
                  text: totalDuration,
                  style: AppTextStyles.bigBody.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 타임라인
  Widget _buildTimeline(BuildContext context) {
    final events = _events;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          events.asMap().entries.map((entry) {
            final index = entry.key;
            final event = entry.value;
            final isSelected = _selectedEvent == event;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index < events.length - 1 ? context.h(8) : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 타임라인 원과 선 (왼쪽)
                        SizedBox(
                          width: context.w(13),
                          child: CustomPaint(
                            painter: TimelineLinePainter(
                              circleSize: context.w(13),
                              lineStartOffset: context.h(13 + 8), // 원(13) + 간격(8)
                              lineEndOffset: null, // 자동 계산
                              isActive: event.isActive,
                              isEditable: event.isEditable,
                              isSelected: isSelected,
                            ),
                          ),
                        ),
                        SizedBox(width: context.w(16)), // 간격 16px
                        // 이벤트 카드 (오른쪽)
                        Expanded(
                          child: _buildTimelineEvent(
                            context,
                            event,
                            isSelected,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 선택된 카드 아래에 버튼 표시
                  if (isSelected)
                    Padding(
                      padding: EdgeInsets.only(
                        top: context.h(4), // 위 간격 4px
                        bottom: context.h(8), // 아래 간격 8px
                      ),
                      child: _buildActionButtons(context, event),
                    ),
                ],
              ),
            );
          }).toList(),
    );
  }

  /// 타임라인 이벤트 카드
  Widget _buildTimelineEvent(
    BuildContext context,
    TimelineEvent event,
    bool isSelected,
  ) {
    // 375px 기준: 전체 너비(375) - 좌우 마진(20*2) - 원(13) - 간격(16) = 306px
    return GestureDetector(
      onTap: () {
        // 카드 클릭 시 선택 상태 변경 (하나만 선택)
        setState(() {
          if (_selectedEvent == event) {
            // 같은 카드를 다시 클릭하면 선택 해제
            _selectedEvent = null;
          } else {
            // 다른 카드 선택
            _selectedEvent = event;
          }
        });
      },
      child: Container(
        width: context.w(306), // 카드 너비 306px (375 - 20*2 - 13 - 16 = 306)
        constraints: BoxConstraints(
          minHeight: context.h(72), // 최소 높이 72px
        ),
        padding: EdgeInsets.symmetric(
          horizontal: context.w(24), // 좌우 패딩 24px
          vertical: context.h(14), // 상하 패딩 14px
        ),
        decoration: BoxDecoration(
          color: widget.isReadOnly && event.isActive
              ? AppColors.blue1.withOpacity(0.2) // 진행 중: 파란색 20% 배경
              : (widget.isReadOnly
                  ? Colors.white.withOpacity(0.1) // 기본: 흰색 10% 배경
                  : (event.isActive ? AppColors.blue1 : Colors.white.withOpacity(0.1))),
          borderRadius: BorderRadius.circular(14),
          border: widget.isReadOnly
              ? (event.isActive
                  ? Border.all(color: AppColors.blue1, width: 1) // 진행 중: 파란색 테두리
                  : null) // 기본: 테두리 없음
              : Border.all(
                  // 편집 모드 테두리 로직
                  color: isSelected
                      ? Colors.white
                      : (event.isEditable
                          ? Colors.white.withOpacity(0.5)
                          : Colors.transparent),
                  width: 1,
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘 + 제목 + 시간 (상단 Row)
            Row(
              children: [
                if (event.icon != null) ...[
                  SizedBox(
                    width: context.w(24),
                    height: context.h(24),
                    child: Image.asset(
                      event.icon!,
                      width: context.w(24),
                      height: context.h(24),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: context.w(4)), // 아이콘과 제목 사이 간격 4px
                ],
                Expanded(
                  child: Text(
                    event.title,
                    style: AppTextStyles.bigBody.copyWith(color: Colors.white),
                  ),
                ),
                Text(
                  event.time,
                  style: AppTextStyles.smallBody.copyWith(
                    color: Colors.white.withOpacity(0.5), // opacity 0.5
                  ),
                ),
              ],
            ),
            SizedBox(height: context.h(4)), // 상단 Row와 설명 사이 간격 4px
            // 설명 - Expanded 제거하고 자동 높이
            Text(
              event.description,
              style: AppTextStyles.smallBody.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  /// 액션 버튼 (수정하기, 삭제하기)
  Widget _buildActionButtons(BuildContext context, TimelineEvent event) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // 클릭 영역 확보
      onTap: () {}, // 빈 핸들러로 클릭 이벤트 차단
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // 오른쪽 정렬
        mainAxisSize: MainAxisSize.max,
        children: [
          // 수정하기 버튼
          _buildActionButton(
            context,
            icon: SizedBox(
              width: context.w(12),
              height: context.h(12),
              child: Image.asset(
                'assets/images/myflight/pencil.png',
                width: context.w(12),
                height: context.h(12),
                color: Colors.white,
              ),
            ),
            text: '수정하기',
            onTap: () {
              // 수정하기 기능
              _showEditPlanBottomSheet(context, event);
            },
          ),
          SizedBox(width: context.w(4)), // 버튼 사이 간격 4px
          // 삭제하기 버튼
          _buildActionButton(
            context,
            icon: Icon(Icons.close, size: context.w(12), color: Colors.white),
            text: '삭제하기',
            onTap: () {
              // 삭제하기 기능 - 모달 표시
              _showDeleteModal(context, event);
            },
          ),
        ],
      ),
    );
  }

  /// 액션 버튼 위젯
  Widget _buildActionButton(
    BuildContext context, {
    required Widget icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          SizedBox(width: context.w(4)), // 아이콘과 텍스트 사이 간격 4px
          Text(
            text,
            style: AppTextStyles.smallBody.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// 더보기 옵션 메뉴 오버레이
  Widget _buildMoreOptionsOverlay(BuildContext context) {
    // 더보기 버튼 위치 계산
    // 버튼: right: 20, top: 21, width: 40, height: 40
    // 메뉴의 왼쪽 끝이 버튼의 중앙에 맞춰야 함
    final buttonRight = context.w(20);
    final buttonTop = context.h(21);
    final buttonWidth = 40.0;
    final buttonHeight = 40.0;
    final menuWidth = context.w(145); // 메뉴 너비 145px (텍스트 오버플로우 방지)
    final menuTop = buttonTop + buttonHeight + context.h(4); // 버튼 아래 4px
    // 버튼의 중앙 위치: buttonRight + (buttonWidth / 2)
    // 메뉴의 왼쪽 끝이 버튼 중앙에 맞춤: menuRight = buttonRight + (buttonWidth / 2)
    final menuRight = buttonRight + (buttonWidth / 2);

    return GestureDetector(
      onTap: () {
        // 메뉴 외부 클릭 시 닫기
        setState(() {
          _showMoreOptions = false;
        });
      },
      child: Container(
        color: Colors.transparent, // 전체 영역 클릭 가능하도록
        child: Stack(
          children: [
            // 메뉴
            Positioned(
              right: menuRight,
              top: menuTop,
              child: GestureDetector(
                onTap: () {}, // 메뉴 내부 클릭은 전파 방지
                child: Container(
                  width: menuWidth,
                  decoration: BoxDecoration(
                    color: const Color(0xFF313131), // #313131
                    borderRadius: BorderRadius.circular(12), // 모든 모서리 12px
                    boxShadow: [
                      BoxShadow(
                        offset: Offset.zero,
                        blurRadius: 10,
                        spreadRadius: 0,
                        color: const Color(0x40000000), // rgba(0, 0, 0, 0.25)
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 비행 종료 테스트 (테스트용)
                      _buildOptionItem(
                        context,
                        text: '비행 종료 테스트',
                        isFirst: true,
                        isLast: false,
                        onTap: () {
                          setState(() {
                            _showMoreOptions = false;
                          });
                          
                          if (_currentFlight != null) {
                            // 실제 비행 데이터를 FlightPlanEndPage에 전달
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FlightPlanEndPage(
                                  arrivalCity: _getCityName(_currentFlight!.destination),
                                  airline: '대한항공', // TODO: 항공사 정보 추가 필요
                                  route: '${_currentFlight!.origin}→${_currentFlight!.destination}',
                                  departureCode: _currentFlight!.origin,
                                  departureCity: _getCityName(_currentFlight!.origin),
                                  arrivalCode: _currentFlight!.destination,
                                  arrivalCityName: _getCityName(_currentFlight!.destination),
                                  duration: _currentFlight!.totalDuration,
                                  departureTime: '${_currentFlight!.departureTime.hour.toString().padLeft(2, '0')}:${_currentFlight!.departureTime.minute.toString().padLeft(2, '0')}',
                                  arrivalTime: '${_currentFlight!.arrivalTime.hour.toString().padLeft(2, '0')}:${_currentFlight!.arrivalTime.minute.toString().padLeft(2, '0')}',
                                  date: '${_currentFlight!.departureTime.year}.${_currentFlight!.departureTime.month.toString().padLeft(2, '0')}.${_currentFlight!.departureTime.day.toString().padLeft(2, '0')}. (${_getWeekday(_currentFlight!.departureTime)})',
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('비행 정보를 불러올 수 없습니다.')),
                            );
                          }
                        },
                      ),
                      // 플랜 저장하기
                      _buildOptionItem(
                        context,
                        text: '플랜 저장하기',
                        isFirst: false,
                        isLast: false,
                        onTap: () {
                          print('🔍 [DEBUG] 플랜 저장하기 버튼 클릭');
                          setState(() {
                            _showMoreOptions = false;
                          });
                          
                          print('🔍 [DEBUG] 네비게이션 전 - context.go(\'/home\') 호출 예정');
                          print('🔍 [DEBUG] context.go(\'/home\') 호출 시작');
                          
                          // 홈으로 이동 (탭바 유지)
                          context.go('/home');
                          
                          print('🔍 [DEBUG] context.go(\'/home\') 호출 완료');
                          
                          // 저장 성공 메시지
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('플랜이 저장되었습니다.')),
                          );
                        },
                      ),
                      // AI 추천으로 초기화 (중간)
                      _buildOptionItem(
                        context,
                        text: 'AI 추천으로 초기화',
                        isFirst: false,
                        isLast: false,
                        onTap: () {
                          setState(() {
                            _showMoreOptions = false;
                          });
                          _showAIResetModal(context);
                        },
                      ),
                      // 진행 중으로 테스트 (테스트용)
                      _buildOptionItem(
                        context,
                        text: '🧪 진행 중으로 테스트',
                        isFirst: false,
                        isLast: false,
                        onTap: () async {
                          setState(() {
                            _showMoreOptions = false;
                          });
                          
                          if (_currentFlight != null) {
                            // 먼저 모든 비행의 forceInProgress를 false로 설정
                            final repo = LocalFlightRepository();
                            await repo.init();
                            final allFlights = await repo.getAllFlights();
                            for (var flight in allFlights) {
                              if (flight.forceInProgress == true) {
                                flight.forceInProgress = false;
                                await repo.saveFlight(flight);
                              }
                            }
                            
                            // 현재 비행만 forceInProgress를 true로 설정
                            _currentFlight!.forceInProgress = true;
                            await repo.saveFlight(_currentFlight!);
                            
                            // [Simulation] 디버그 시간 오프셋 설정: 현재 시간을 비행 출발 시간으로 맞춤
                            // now + offset = departureTime  => offset = departureTime - now
                            FlightState().debugTimeOffset = _currentFlight!.departureTime.difference(DateTime.now());
                            
                            print('🧪 forceInProgress 설정: ${_currentFlight!.id}');
                            print('⏱️ 시뮬레이션 시간 동기화 완료: Offset ${FlightState().debugTimeOffset}');
                            
                            // 새로고침
                            if (mounted) {
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            }
                          }
                        },
                      ),
                      // 비행 플랜 삭제 (맨 아래)
                      _buildOptionItem(
                        context,
                        text: '비행 플랜 삭제',
                        isFirst: false,
                        isLast: true,
                        onTap: () {
                          setState(() {
                            _showMoreOptions = false;
                          });
                          _showDeletePlanModal(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 옵션 아이템 위젯
  Widget _buildOptionItem(
    BuildContext context, {
    required String text,
    required VoidCallback onTap,
    required bool isFirst,
    required bool isLast,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, // width: 120px
        padding: EdgeInsets.symmetric(
          horizontal: context.w(10), // padding: 5px 10px
          vertical: context.h(5),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF313131), // background: #313131
          borderRadius: BorderRadius.only(
            topLeft: isFirst ? const Radius.circular(12) : Radius.zero,
            topRight: isFirst ? const Radius.circular(12) : Radius.zero,
            bottomLeft: isLast ? const Radius.circular(12) : Radius.zero,
            bottomRight: isLast ? const Radius.circular(12) : Radius.zero,
          ),
          border: Border(
            bottom: BorderSide(
              color:
                  isLast
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.1), // 흰색 10%
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // justify-content: center
          crossAxisAlignment: CrossAxisAlignment.center, // align-items: center
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: AppTextStyles.smallBody.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  /// 비행 플랜 삭제 모달 표시
  void _showDeletePlanModal(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5), // 뒷 배경 검정 50%
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: context.w(20)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: context.w(300),
                padding: EdgeInsets.only(
                  top: 0,
                  right: context.w(20),
                  bottom: context.w(20),
                  left: context.w(20),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A), // #1A1A1A
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1), // 흰색 10%
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 헤더 영역
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(
                        top: context.h(20),
                        bottom: context.h(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 제목
                          Text(
                            '비행 플랜 삭제',
                            style: AppTextStyles.large.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: context.h(10)), // gap: 10px
                          // 본문
                          Padding(
                            padding: EdgeInsets.only(
                              left: context.w(14),
                              right: context.w(14),
                              top: context.h(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '이 비행 플랜을 완전히 삭제하시겠어요?',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '저장된 루틴이 모두 사라집니다.',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.h(16)), // gap: 16px
                    // 버튼들
                    Row(
                      children: [
                        // 삭제 버튼
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              Navigator.pop(context);
                              
                              // Hive에서 비행 및 타임라인 삭제
                              try {
                                final localFlightRepo = LocalFlightRepository();
                                await localFlightRepo.init();
                                final scheduledFlights = await localFlightRepo.getScheduledFlights();
                                
                                if (scheduledFlights.isNotEmpty) {
                                  scheduledFlights.sort((a, b) => a.departureTime.compareTo(b.departureTime));
                                  final latestFlight = scheduledFlights.first;
                                  
                                  // 타임라인 삭제
                                  final localTimelineRepo = LocalTimelineRepository();
                                  await localTimelineRepo.init();
                                  await localTimelineRepo.deleteTimeline(latestFlight.id);
                                  
                                  // 비행 삭제
                                  await localFlightRepo.deleteFlight(latestFlight.id);
                                  
                                  print('✅ Hive에서 비행 ${latestFlight.id} 삭제 완료');
                                }
                              } catch (e) {
                                print('❌ Hive 삭제 실패: $e');
                              }
                              
                              // 초기화하고 나가기
                              setState(() {
                                _events = List.from(_initialEvents);
                                _selectedEvent = null;
                              });
                              Navigator.pop(context); // 페이지 나가기
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: context.h(16),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  '삭제',
                                  style: AppTextStyles.buttonText.copyWith(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: context.w(16)), // 버튼 사이 간격 16px
                        // 취소 버튼
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: context.h(16),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.blue1,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  '취소',
                                  style: AppTextStyles.buttonText.copyWith(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// AI 초기화 모달 표시
  void _showAIResetModal(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5), // 뒷 배경 검정 50%
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: context.w(20)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: context.w(300),
                padding: EdgeInsets.only(
                  top: 0,
                  right: context.w(20),
                  bottom: context.w(20),
                  left: context.w(20),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A), // #1A1A1A
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1), // 흰색 10%
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 헤더 영역
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(
                        top: context.h(20),
                        bottom: context.h(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 제목
                          Text(
                            'AI 플랜으로 초기화',
                            style: AppTextStyles.large.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: context.h(10)), // gap: 10px
                          // 본문
                          Padding(
                            padding: EdgeInsets.only(
                              left: context.w(14),
                              right: context.w(14),
                              top: context.h(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'BIMO의 추천 루틴으로 되돌릴까요?',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '현재 수정된 내용은 모두 삭제됩니다.',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.h(16)), // gap: 16px
                    // 버튼들
                    Row(
                      children: [
                        // 초기화 버튼
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              print('🔄 AI 초기화 버튼 클릭');
                              print('📊 현재 이벤트 수: ${_events.length}');
                              print('📊 초기 이벤트 수: ${_initialEvents.length}');
                              
                              Navigator.pop(context);
                              
                              // 초기 타임라인으로 복원
                              setState(() {
                                _events = List.from(_initialEvents);
                                _selectedEvent = null;
                                print('✅ setState 완료 - 새 이벤트 수: ${_events.length}');
                              });
                              
                              // Hive에 저장
                              await _saveTimelineToHive();
                              
                              // 성공 메시지
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('AI 추천 플랜으로 초기화되었습니다.')),
                                );
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: context.h(16),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  '초기화',
                                  style: AppTextStyles.buttonText.copyWith(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: context.w(16)), // 버튼 사이 간격 16px
                        // 취소 버튼
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: context.h(16),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.blue1,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  '취소',
                                  style: AppTextStyles.buttonText.copyWith(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 플랜 저장 확인 모달 표시
  Future<bool?> _showSaveConfirmationModal(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 바깥 영역 클릭 시 닫히지 않음
      barrierColor: Colors.black.withOpacity(0.3), // 배경 어둡게
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: context.w(300),
              padding: EdgeInsets.only(
                top: 0,
                right: context.w(20),
                bottom: context.w(20),
                left: context.w(20),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A), // #1A1A1A
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1), // 흰색 10%
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 헤더 영역
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      top: context.h(20),
                      bottom: context.h(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 제목
                        Text(
                          '플랜 저장',
                          style: AppTextStyles.large.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: context.h(10)),
                        // 질문
                        Padding(
                          padding: EdgeInsets.only(
                            left: context.w(14),
                            right: context.w(14),
                            top: context.h(10),
                          ),
                          child: Text(
                            '플랜을 저장하시겠습니까?',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.h(16)),
                  // 버튼들
                  Row(
                    children: [
                      // 저장 안 함 버튼
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context, false); // 저장하지 않음
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: context.h(16),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                '저장 안 함',
                                style: AppTextStyles.buttonText.copyWith(
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: context.w(16)),
                      // 저장 버튼
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context, true); // 저장함
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: context.h(16),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.blue1,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                '저장',
                                style: AppTextStyles.buttonText.copyWith(
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 삭제 확인 모달 표시 (타임라인 이벤트 삭제용)
  void _showDeleteModal(BuildContext context, TimelineEvent event) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5), // 뒷 배경 검정 50%
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: context.w(20)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: context.w(300),
                padding: EdgeInsets.only(
                  top: 0,
                  right: context.w(20),
                  bottom: context.w(20),
                  left: context.w(20),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A), // #1A1A1A
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1), // 흰색 10%
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // align-items: center
                  children: [
                    // 헤더 영역
                    Container(
                      width: double.infinity, // align-self: stretch
                      padding: EdgeInsets.only(
                        top: context.h(20), // padding: 20px 0 10px 0
                        bottom: context.h(10),
                      ),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // justify-content: center
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // align-items: center
                        children: [
                          // 제목
                          Text(
                            '플랜 삭제',
                            style: AppTextStyles.large.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: context.h(10)), // gap: 10px
                          // 질문 (본문 패딩 적용)
                          Padding(
                            padding: EdgeInsets.only(
                              left: context.w(14), // 좌 14px
                              right: context.w(14), // 우 14px
                              top: context.h(10), // 상 10px
                            ),
                            child: Text(
                              '"${event.title}" 항목을 삭제하시겠습니까?',
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.h(16)), // gap: 16px
                    // 버튼들
                    Row(
                      children: [
                        // 삭제 버튼
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              Navigator.pop(context);
                              setState(() {
                                // 삭제 대신 자유 시간으로 변경
                                final index = _events.indexOf(event);
                                if (index != -1) {
                                  _events[index] = TimelineEvent(
                                    title: '자유 시간',
                                    time: event.time,
                                    description: '자유롭게 일정을 등록하실 수 있습니다.',
                                    isEditable: true,
                                  );
                                  _selectedEvent = null;
                                }
                              });
                              
                              // Hive에 저장
                              await _saveTimelineToHive();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: context.h(16), // padding: 16px 0
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(
                                  0.1,
                                ), // rgba(255, 255, 255, 0.10)
                                borderRadius: BorderRadius.circular(
                                  30,
                                ), // border-radius: 30px
                              ),
                              child: Center(
                                child: Text(
                                  '삭제',
                                  style: AppTextStyles.buttonText.copyWith(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: context.w(16)), // 버튼 사이 간격 16px
                        // 취소 버튼
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: context.h(16), // padding: 16px 0
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.blue1, // B1 색상
                                borderRadius: BorderRadius.circular(
                                  30,
                                ), // border-radius: 30px
                              ),
                              child: Center(
                                child: Text(
                                  '취소',
                                  style: AppTextStyles.buttonText.copyWith(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 플랜 추가 바텀시트 표시
  void _showAddPlanBottomSheet(BuildContext context) {
    final titleController = TextEditingController();
    final startTimeController = TextEditingController(text: '00:00 AM');
    final endTimeController = TextEditingController(text: '00:00 PM');
    final descriptionController = TextEditingController();

    // 시간 입력을 위한 상태 관리
    final startTimeState = ValueNotifier<String>('00:00 AM');
    final endTimeState = ValueNotifier<String>('00:00 PM');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // 뒷 배경 선명하게
      isScrollControlled: true,
      isDismissible: false, // 아래로 스크롤해야만 닫을 수 있음
      enableDrag: true, // 드래그 가능
      barrierColor: Colors.transparent, // 뒷 배경 가리지 않음
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5, // 초기 높이를 더 낮게 설정
          minChildSize: 0.1, // 최소 크기를 더 작게 하여 뒷 배경이 더 많이 보이도록
          maxChildSize: 0.85,
          snap: true, // 스냅 기능 활성화
          snapSizes: const [0.1, 0.5, 0.85], // 스냅 위치
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.black, // 스타일의 블랙
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1), // 흰색 10% 테두리
                  width: 1,
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: context.w(20),
                  right: context.w(20),
                  top: context.h(4), // 맨 꼭대기에서 4px
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch, // align-self: stretch
                  children: [
                    // iOS 드래그 인디케이터
                    Center(
                      child: Container(
                        width: context.w(40),
                        height: context.h(4),
                        margin: EdgeInsets.only(bottom: context.h(23)),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // 제목 (가운데 정렬)
                    Center(
                      child: Text(
                        '플랜 추가하기',
                        style: AppTextStyles.large.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: context.h(24)), // 제목 아래 간격 24px
                    // 입력 섹션들 (gap: 8px)
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch, // align-items: flex-start
                      children: [
                        // 플랜 제목 입력
                        TextField(
                          controller: titleController,
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: '플랜 제목을 입력해 보세요.',
                            hintStyle: AppTextStyles.body.copyWith(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                14,
                              ), // border-radius: 14px
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: context.w(16),
                              vertical: context.h(12),
                            ),
                          ),
                        ),
                        SizedBox(height: context.h(8)), // gap: 8px
                        // 시간 입력 (시작 시간, 종료 시간)
                        Row(
                          children: [
                            Expanded(
                              child: _buildTimeInputField(
                                context,
                                label: '시작 시간',
                                controller: startTimeController,
                                timeState: startTimeState,
                              ),
                            ),
                            SizedBox(width: context.w(8)), // 시간 박스 사이 간격 8px
                            Expanded(
                              child: _buildTimeInputField(
                                context,
                                label: '종료 시간',
                                controller: endTimeController,
                                timeState: endTimeState,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.h(8)), // gap: 8px
                        // 설명 입력
                        TextField(
                          controller: descriptionController,
                          maxLines: 3,
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: '어떤 플랜인지 자세히 입력해 보세요.',
                            hintStyle: AppTextStyles.body.copyWith(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                14,
                              ), // border-radius: 14px
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: context.w(16),
                              vertical: context.h(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.h(16)), // 적용하기 버튼 위 간격 16px
                    // 적용하기 버튼 (비행 등록 페이지의 다음 버튼과 동일한 스펙)
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          if (titleController.text.isNotEmpty) {
                            _checkOverlapAndProceed(
                              context,
                              title: titleController.text,
                              startTime: startTimeState.value,
                              endTime: endTimeState.value,
                              description: descriptionController.text,
                            );
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              width: context.w(335),
                              height: context.h(50),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '적용하기',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height:
                          context.h(16) +
                          Responsive.homeIndicatorHeight(context),
                    ), // 하단 인디케이터 높이 + 16px
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 플랜 수정 바텀시트 표시
  void _showEditPlanBottomSheet(BuildContext context, TimelineEvent event) {
    // 기존 내용으로 컨트롤러 초기화
    final titleController = TextEditingController(text: event.title);
    final timeParts = event.time.split(' - ');
    final startTimeController = TextEditingController(
      text: timeParts.isNotEmpty ? timeParts[0] : '00:00 AM',
    );
    final endTimeController = TextEditingController(
      text: timeParts.length > 1 ? timeParts[1] : '00:00 PM',
    );
    final descriptionController = TextEditingController(
      text: event.description,
    );

    // 시간 입력을 위한 상태 관리
    final startTimeState = ValueNotifier<String>(
      timeParts.isNotEmpty ? timeParts[0] : '00:00 AM',
    );
    final endTimeState = ValueNotifier<String>(
      timeParts.length > 1 ? timeParts[1] : '00:00 PM',
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: true,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.1,
          maxChildSize: 0.85,
          snap: true,
          snapSizes: const [0.1, 0.5, 0.85],
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: context.w(20),
                  right: context.w(20),
                  top: context.h(4),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // iOS 드래그 인디케이터
                    Center(
                      child: Container(
                        width: context.w(40),
                        height: context.h(4),
                        margin: EdgeInsets.only(bottom: context.h(23)),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // 제목 (가운데 정렬)
                    Center(
                      child: Text(
                        '수정하기',
                        style: AppTextStyles.large.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: context.h(24)),
                    // 입력 섹션들 (gap: 8px)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 플랜 제목 입력
                        TextField(
                          controller: titleController,
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: '플랜 제목을 입력해 보세요.',
                            hintStyle: AppTextStyles.body.copyWith(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: context.w(16),
                              vertical: context.h(12),
                            ),
                          ),
                        ),
                        SizedBox(height: context.h(8)),
                        // 시간 입력 (시작 시간, 종료 시간)
                        Row(
                          children: [
                            Expanded(
                              child: _buildTimeInputField(
                                context,
                                label: '시작 시간',
                                controller: startTimeController,
                                timeState: startTimeState,
                              ),
                            ),
                            SizedBox(width: context.w(8)),
                            Expanded(
                              child: _buildTimeInputField(
                                context,
                                label: '종료 시간',
                                controller: endTimeController,
                                timeState: endTimeState,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.h(8)),
                        // 설명 입력
                        TextField(
                          controller: descriptionController,
                          maxLines: 3,
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: '어떤 플랜인지 자세히 입력해 보세요.',
                            hintStyle: AppTextStyles.body.copyWith(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: context.w(16),
                              vertical: context.h(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.h(16)),
                    // 적용하기 버튼
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          if (titleController.text.isNotEmpty) {
                            _checkOverlapAndProceed(
                              context,
                              originalEvent: event,
                              title: titleController.text,
                              startTime: startTimeState.value,
                              endTime: endTimeState.value,
                              description: descriptionController.text,
                            );
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              width: context.w(335),
                              height: context.h(50),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '적용하기',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height:
                          context.h(16) +
                          Responsive.homeIndicatorHeight(context),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 플랜 추가/수정 시 겹침 확인 및 처리
  Future<void> _checkOverlapAndProceed(
    BuildContext context, {
    TimelineEvent? originalEvent, // 수정일 경우 원본 이벤트
    required String title,
    required String startTime,
    required String endTime,
    required String description,
  }) async {
    final newStart = _parseTimeToMinutes(startTime);
    final newEnd = _parseTimeToMinutes(endTime);

    if (newStart >= newEnd) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('종료 시간은 시작 시간보다 늦어야 합니다.')),
      );
      return;
    }

    // 경고 팝업에 표시할 이벤트 이름들
    final List<String> affectedEventNames = [];

    // 수정 모드: 원본 이벤트의 시간이 변경되는지 확인
    if (originalEvent != null) {
      final parts = originalEvent.time.split(' - ');
      if (parts.length == 2) {
        final origStart = _parseTimeToMinutes(parts[0]);
        final origEnd = _parseTimeToMinutes(parts[1]);

        // 시간이 변경되어 남는 부분이 생기는 경우
        if (origStart < newStart || origEnd > newEnd) {
          affectedEventNames.add(originalEvent.title);
        }
      }
    }

    // 겹치는 이벤트 찾기
    final overlappingEvents = <TimelineEvent>[];
    for (final event in _events) {
      if (event == originalEvent) continue; // 수정 중인 자기 자신은 제외

      final parts = event.time.split(' - ');
      if (parts.length != 2) continue;

      final start = _parseTimeToMinutes(parts[0]);
      final end = _parseTimeToMinutes(parts[1]);

      // 겹침 조건: (NewStart < ExistingEnd) && (NewEnd > ExistingStart)
      if (newStart < end && newEnd > start) {
        overlappingEvents.add(event);
        // 고정 이벤트(수정 불가능한 이벤트)만 경고 이름에 추가
        if (!event.isEditable) {
          affectedEventNames.add(event.title);
        }
      }
    }

    // 경고 팝업 표시 (원본 이벤트 변경 또는 다른 고정 이벤트와 겹침)
    if (affectedEventNames.isNotEmpty) {
      final eventNames = affectedEventNames.join(', ');
      final shouldProceed = await _showOverlapWarningDialog(
        context,
        eventNames,
      );
      if (!shouldProceed) return;
    }

    // 겹림 처리 및 이벤트 추가/수정
    _processAndSaveTimeline(
      originalEvent: originalEvent,
      title: title,
      startTime: startTime,
      endTime: endTime,
      description: description,
      newStart: newStart,
      newEnd: newEnd,
      overlappingEvents: overlappingEvents,
    );

    Navigator.pop(context); // 바텀시트 닫기
  }

  /// 겹침 경고 다이얼로그
  Future<bool> _showOverlapWarningDialog(
    BuildContext context,
    String eventNames,
  ) async {
    bool? result = false;
    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: context.w(20)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: context.w(300),
                padding: EdgeInsets.all(context.w(20)),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '일정 겹침 알림',
                      style: AppTextStyles.large.copyWith(color: Colors.white),
                    ),
                    SizedBox(height: context.h(16)),
                    Text(
                      '$eventNames 플랜이\n새로운 일정으로 대체됩니다.\n남은 시간은 자유 시간으로 변경됩니다.',
                      style: AppTextStyles.body.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.h(24)),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              result = false;
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: context.h(16),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  '취소',
                                  style: AppTextStyles.buttonText.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: context.w(16)),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              result = true;
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: context.h(16),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.blue1,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  '확인',
                                  style: AppTextStyles.buttonText.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    return result ?? false;
  }

  /// 플랜 업데이트  /// 겹침 처리 후 이벤트 추가 및 Hive 저장
  Future<void> _processAndSaveTimeline({
    TimelineEvent? originalEvent,
    required String title,
    required String startTime,
    required String endTime,
    required String description,
    required int newStart,
    required int newEnd,
    required List<TimelineEvent> overlappingEvents,
  }) async {
    setState(() {
      // 1. 수정 모드일 경우 원본 이벤트의 남는 시간 처리
      if (originalEvent != null) {
        final parts = originalEvent.time.split(' - ');
        if (parts.length == 2) {
          final origStart = _parseTimeToMinutes(parts[0]);
          final origEnd = _parseTimeToMinutes(parts[1]);

          // 원본 이벤트를 먼저 제거
          _events.remove(originalEvent);

          // 원본의 앞부분이 남으면 자유 시간 생성
          if (origStart < newStart) {
            _events.add(
              TimelineEvent(
                title: '자유 시간',
                time:
                    '${_minutesToTimeString(origStart)} - ${_minutesToTimeString(newStart)}',
                description: '자유롭게 일정을 등록하실 수 있습니다.',
                isEditable: true,
              ),
            );
          }

          // 원본의 뒷부분이 남으면 자유 시간 생성
          if (origEnd > newEnd) {
            _events.add(
              TimelineEvent(
                title: '자유 시간',
                time:
                    '${_minutesToTimeString(newEnd)} - ${_minutesToTimeString(origEnd)}',
                description: '자유롭게 일정을 등록하실 수 있습니다.',
                isEditable: true,
              ),
            );
          }
        }
      }

      // 2. 겹치는 이벤트들 처리 (삭제 및 남은 부분 자유 시간 생성)
      for (final event in overlappingEvents) {
        final parts = event.time.split(' - ');
        final start = _parseTimeToMinutes(parts[0]);
        final end = _parseTimeToMinutes(parts[1]);

        _events.remove(event);

        // 앞부분이 남으면 자유 시간 생성
        if (start < newStart) {
          _events.add(
            TimelineEvent(
              title: '자유 시간',
              time:
                  '${_minutesToTimeString(start)} - ${_minutesToTimeString(newStart)}',
              description: '자유롭게 일정을 등록하실 수 있습니다.',
              isEditable: true,
            ),
          );
        }

        // 뒷부분이 남으면 자유 시간 생성
        if (end > newEnd) {
          _events.add(
            TimelineEvent(
              title: '자유 시간',
              time:
                  '${_minutesToTimeString(newEnd)} - ${_minutesToTimeString(end)}',
              description: '자유롭게 일정을 등록하실 수 있습니다.',
              isEditable: true,
            ),
          );
        }
      }

      // 3. 새 이벤트 생성 (수정/추가 모두)
      final newEvent = TimelineEvent(
        title: title,
        time: '$startTime - $endTime',
        description: description,
        isActive: true,
      );
      _events.add(newEvent);
      _selectedEvent = newEvent;

      // 4. 시간 순 정렬
      _events.sort((a, b) {
        final startA = _parseTimeToMinutes(a.time.split(' - ')[0]);
        final startB = _parseTimeToMinutes(b.time.split(' - ')[0]);
        return startA.compareTo(startB);
      });
    });
    
    //  Hive에 저장 (setState 밖에서)
    await _saveTimelineToHive();
  }

  /// 시간 문자열을 분으로 변환 (예: "12:00 PM" -> 720)
  int _parseTimeToMinutes(String timeString) {
    try {
      final parts = timeString.split(' ');
      if (parts.length == 2) {
        final timePart = parts[0]; // "12:00"
        final period = parts[1]; // "AM" or "PM"

        final timeParts = timePart.split(':');
        if (timeParts.length == 2) {
          int hour = int.tryParse(timeParts[0]) ?? 0;
          final minute = int.tryParse(timeParts[1]) ?? 0;

          // 12시간 형식을 24시간 형식으로 변환
          if (period == 'PM' && hour != 12) {
            hour += 12;
          } else if (period == 'AM' && hour == 12) {
            hour = 0;
          }

          return hour * 60 + minute;
        }
      }
    } catch (e) {
      // 파싱 실패 시 기본값 반환
    }
    return 0;
  }

  /// 분을 시간 문자열로 변환 (예: 720 -> "12:00 PM")
  String _minutesToTimeString(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;

    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  /// 앵커 수면 경고 모달 표시
  Future<bool> _showAnchorSleepWarningModal(BuildContext context) async {
    bool? result = false;
    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: context.w(20)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: context.w(300),
                padding: EdgeInsets.only(
                  top: 0,
                  right: context.w(20),
                  bottom: context.w(20),
                  left: context.w(20),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 헤더
                    Padding(
                      padding: EdgeInsets.only(
                        top: context.h(20),
                        bottom: context.h(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '앵커 수면 수정',
                            style: AppTextStyles.large.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.h(16)),
                    // 본문
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.w(14)),
                      child: Text(
                        '나머지 앵커 수면 시간은\n비어있는 자유 시간으로 변경됩니다.',
                        style: AppTextStyles.body.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: context.h(16)),
                    // 버튼들
                    Row(
                      children: [
                        // 취소 버튼 (왼쪽)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              result = false;
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: context.h(16),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  '취소',
                                  style: AppTextStyles.buttonText.copyWith(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: context.w(16)),
                        // 확인 버튼 (오른쪽)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              result = true;
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: context.h(16),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.blue1,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  '확인',
                                  style: AppTextStyles.buttonText.copyWith(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    return result ?? false;
  }

  /// 이벤트 업데이트
  void _updateEvent(
    TimelineEvent event,
    String newTitle,
    String newStartTime,
    String newEndTime,
    String newDescription,
  ) {
    setState(() {
      event.title = newTitle;
      event.time = '$newStartTime - $newEndTime';
      event.description = newDescription;
      event.isActive = true; // 수정된 플랜은 파란색으로 표시
    });
  }

  /// 이벤트 업데이트 및 자유 시간 생성
  void _updateEventAndCreateFreeTime(
    TimelineEvent originalEvent,
    String newStartTime,
    String newEndTime,
    String newTitle,
    String newDescription,
    int originalStart,
    int originalEnd,
    int newStart,
    int newEnd,
  ) {
    setState(() {
      // 원본 이벤트 수정
      originalEvent.title = newTitle;
      originalEvent.time = '$newStartTime - $newEndTime';
      originalEvent.description = newDescription;
      originalEvent.isActive = true; // 수정된 플랜은 파란색으로 표시

      // 나머지 시간 범위 확인
      if (newStart > originalStart) {
        // 앞부분이 비어있음 - 앞부분을 자유 시간으로
        final freeTimeStart = _minutesToTimeString(originalStart);
        final freeTimeEnd = _minutesToTimeString(newStart);

        final freeTimeEvent = TimelineEvent(
          title: '자유 시간',
          time: '$freeTimeStart - $freeTimeEnd',
          description: '자유롭게 일정을 등록하실 수 있습니다.',
          isEditable: true,
        );

        // 원본 이벤트 앞에 삽입
        final originalIndex = _events.indexOf(originalEvent);
        _events.insert(originalIndex, freeTimeEvent);
      }

      if (newEnd < originalEnd) {
        // 뒷부분이 비어있음 - 뒷부분을 자유 시간으로
        final freeTimeStart = _minutesToTimeString(newEnd);
        final freeTimeEnd = _minutesToTimeString(originalEnd);

        final freeTimeEvent = TimelineEvent(
          title: '자유 시간',
          time: '$freeTimeStart - $freeTimeEnd',
          description: '자유롭게 일정을 등록하실 수 있습니다.',
          isEditable: true,
        );

        // 원본 이벤트 뒤에 삽입
        final originalIndex = _events.indexOf(originalEvent);
        _events.insert(originalIndex + 1, freeTimeEvent);
      }

      // 시간 순으로 정렬
      _events.sort((a, b) {
        return a.time.compareTo(b.time);
      });
    });
  }

  /// 시간 입력 필드 위젯
  Widget _buildTimeInputField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required ValueNotifier<String> timeState,
  }) {
    // 초기값 설정
    if (controller.text.isEmpty) {
      controller.text = timeState.value;
    }

    return ValueListenableBuilder<String>(
      valueListenable: timeState,
      builder: (context, value, child) {
        final hasValue =
            value.isNotEmpty && value != '00:00 AM' && value != '00:00 PM';

        // 컨트롤러와 상태 동기화
        if (controller.text != value) {
          controller.text = value;
        }

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.w(16),
            vertical: context.h(12),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14), // border-radius: 14px
          ),
          child: Row(
            children: [
              // 시계 아이콘 (항상 흰색)
              SizedBox(
                width: context.w(24),
                height: context.h(24),
                child: Image.asset(
                  'assets/images/myflight/clock.png',
                  width: context.w(24),
                  height: context.h(24),
                  color: Colors.white, // 항상 흰색
                ),
              ),
              SizedBox(width: context.w(12)),
              // 시간 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 라벨 (시작 시간/종료 시간)
                    Text(
                      label,
                      style: AppTextStyles.smallBody.copyWith(
                        color: Colors.white.withOpacity(0.5), // 비활성화: 흰색 50%
                      ),
                    ),
                    // 시간 텍스트 (탭하면 시간 피커 표시)
                    GestureDetector(
                      onTap: () {
                        _showTimePickerDialog(
                          context,
                          label,
                          timeState,
                          controller,
                        );
                      },
                      child: Text(
                        value.isEmpty ? '00:00 AM' : value,
                        style: AppTextStyles.body.copyWith(
                          color:
                              hasValue
                                  ? Colors.white
                                  : Colors.white.withOpacity(
                                    0.5,
                                  ), // 활성화: 흰색, 비활성화: 흰색 50%
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 시간 피커 다이얼로그 표시
  Future<void> _showTimePickerDialog(
    BuildContext context,
    String title,
    ValueNotifier<String> timeState,
    TextEditingController controller,
  ) async {
    // 현재 시간 파싱
    final currentTime = _parseTimeString(timeState.value);
    int selectedHour = currentTime.hour;
    int selectedMinute = currentTime.minute;
    bool isPM = selectedHour >= 12;

    // 12시간 형식으로 변환
    int displayHour =
        selectedHour == 0
            ? 12
            : (selectedHour > 12 ? selectedHour - 12 : selectedHour);

    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5), // 뒷 배경 검정 50%
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(horizontal: context.w(20)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    width: context.w(300),
                    padding: EdgeInsets.only(
                      top: 0,
                      right: context.w(20),
                      bottom: context.w(20),
                      left: context.w(20),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A), // #1A1A1A
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1), // 흰색 10%
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 헤더
                        Padding(
                          padding: EdgeInsets.only(
                            top: context.h(20),
                            bottom: context.h(10),
                          ),
                          child: Center(
                            child: Text(
                              title,
                              style: AppTextStyles.large.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: context.h(16)),
                        // 시간 선택 컬럼들
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // AM/PM 선택기
                            Expanded(
                              child: _buildPeriodPicker(
                                context,
                                isPM: isPM,
                                onChanged: (value) {
                                  setState(() {
                                    isPM = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: context.w(8)),
                            // 시간 선택기 (1-12)
                            Expanded(
                              child: _buildHourPicker(
                                context,
                                selectedHour: displayHour,
                                onChanged: (value) {
                                  setState(() {
                                    displayHour = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: context.w(8)),
                            // 분 선택기 (0-59)
                            Expanded(
                              child: _buildMinutePicker(
                                context,
                                selectedMinute: selectedMinute,
                                onChanged: (value) {
                                  setState(() {
                                    selectedMinute = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.h(16)),
                        // 버튼들
                        Row(
                          children: [
                            // 취소 버튼 (왼쪽)
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: context.h(16),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '취소',
                                      style: AppTextStyles.buttonText.copyWith(
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: context.w(16)), // 버튼 사이 간격 16px
                            // 적용 버튼 (오른쪽)
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  // 12시간 형식으로 변환
                                  final period = isPM ? 'PM' : 'AM';
                                  final formatted =
                                      '${displayHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')} $period';
                                  timeState.value = formatted;
                                  controller.text = formatted;
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: context.h(16),
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.blue1,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '적용',
                                      style: AppTextStyles.buttonText.copyWith(
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// AM/PM 선택기
  Widget _buildPeriodPicker(
    BuildContext context, {
    required bool isPM,
    required ValueChanged<bool> onChanged,
  }) {
    return SizedBox(
      height: context.h(200),
      child: ListWheelScrollView.useDelegate(
        itemExtent: context.h(40),
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          onChanged(index == 1); // 0: AM, 1: PM
        },
        controller: FixedExtentScrollController(initialItem: isPM ? 1 : 0),
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            final period = index == 0 ? '오전' : '오후';
            final isSelected = (isPM && index == 1) || (!isPM && index == 0);

            return Center(
              child: Text(
                period,
                style: AppTextStyles.body.copyWith(
                  color:
                      isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                ),
              ),
            );
          },
          childCount: 2,
        ),
      ),
    );
  }

  /// 시간 선택기 (1-12)
  Widget _buildHourPicker(
    BuildContext context, {
    required int selectedHour,
    required ValueChanged<int> onChanged,
  }) {
    return SizedBox(
      height: context.h(200),
      child: ListWheelScrollView.useDelegate(
        itemExtent: context.h(40),
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          onChanged(index + 1); // 1-12
        },
        controller: FixedExtentScrollController(initialItem: selectedHour - 1),
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            final hour = index + 1;
            final isSelected = hour == selectedHour;

            return Center(
              child: Text(
                hour.toString(),
                style: AppTextStyles.body.copyWith(
                  color:
                      isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                ),
              ),
            );
          },
          childCount: 12,
        ),
      ),
    );
  }

  /// 분 선택기 (0-59)
  Widget _buildMinutePicker(
    BuildContext context, {
    required int selectedMinute,
    required ValueChanged<int> onChanged,
  }) {
    return SizedBox(
      height: context.h(200),
      child: ListWheelScrollView.useDelegate(
        itemExtent: context.h(40),
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          onChanged(index); // 0-59
        },
        controller: FixedExtentScrollController(initialItem: selectedMinute),
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            final minute = index;
            final isSelected = minute == selectedMinute;

            return Center(
              child: Text(
                minute.toString().padLeft(2, '0'),
                style: AppTextStyles.body.copyWith(
                  color:
                      isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                ),
              ),
            );
          },
          childCount: 60,
        ),
      ),
    );
  }

  /// 시간 문자열을 TimeOfDay로 파싱
  TimeOfDay _parseTimeString(String timeString) {
    try {
      // "12:00 AM" 형식에서 시간과 분 추출
      final parts = timeString.split(' ');
      if (parts.length == 2) {
        final timePart = parts[0]; // "12:00"
        final period = parts[1]; // "AM" or "PM"

        final timeParts = timePart.split(':');
        if (timeParts.length == 2) {
          int hour = int.tryParse(timeParts[0]) ?? 0;
          final minute = int.tryParse(timeParts[1]) ?? 0;

          // 12시간 형식을 24시간 형식으로 변환
          if (period == 'PM' && hour != 12) {
            hour += 12;
          } else if (period == 'AM' && hour == 12) {
            hour = 0;
          }

          return TimeOfDay(hour: hour, minute: minute);
        }
      }
    } catch (e) {
      // 파싱 실패 시 기본값 반환
    }
    return const TimeOfDay(hour: 0, minute: 0);
  }

  /// 플로팅 액션 버튼
  Widget _buildFloatingActionButton(BuildContext context) {
    if (widget.isReadOnly) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        _showAddPlanBottomSheet(context);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50), // border-radius: 50px
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 15,
            sigmaY: 15,
          ), // backdrop-filter: blur(15px)
          child: Container(
            width: context.w(47), // width: 47px
            height: context.h(47), // height: 47px
            padding: EdgeInsets.only(
              top: context.h(8), // padding: 8px 9px 9px 8px
              right: context.w(9),
              bottom: context.h(9),
              left: context.w(8),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A), // background: #1A1A1A
              borderRadius: BorderRadius.circular(50), // border-radius: 50px
              border: Border.all(
                color: Colors.white.withOpacity(
                  0.5,
                ), // border: 1px solid rgba(255, 255, 255, 0.50)
                width: 1,
              ),
            ),
            child: Center(
              // justify-content: center, align-items: center
              child: SizedBox(
                width: context.w(24), // 플러스 아이콘 24x24
                height: context.h(24),
                child: SvgPicture.asset(
                  'assets/images/myflight/Plus.svg',
                  width: context.w(24),
                  height: context.h(24),
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 타임라인 이벤트 목록 (더미 데이터)
  List<TimelineEvent> _getTimelineEvents() {
    // TimelineState에서 API 응답 가져오기
    final timelineData = TimelineState().timelineData;
    
    if (timelineData == null || timelineData['timeline_events'] == null) {
      // API 데이터가 없으면 빈 리스트 반환
      return [];
    }
    
    final events = timelineData['timeline_events'] as List<dynamic>;
    
    return events.map((event) {
      final iconType = event['icon_type'] as String?;
      final type = event['type'] as String?;
      
      // icon_type을 asset 경로로 매핑
      String? iconPath;
      if (iconType != null) {
        iconPath = _mapIconTypeToAsset(iconType, type);
      }
      
      // isEditable 판단 (자유 시간만 true)
      final isEditable = type == 'FREE_TIME';
      
      return TimelineEvent(
        icon: iconPath,
        title: event['title'] as String? ?? '',
        time: event['display_time'] as String? ?? '',
        description: event['description'] as String? ?? '',
        isEditable: isEditable,
        isActive: false,
      );
    }).toList();
  }
  
  /// icon_type을 asset 경로로 매핑
  String? _mapIconTypeToAsset(String iconType, String? eventType) {
    // FREE_TIME은 아이콘 없음
    if (eventType == 'FREE_TIME') {
      return null;
    }
    
    switch (iconType.toLowerCase()) {
      case 'airplane_takeoff':
      case 'airplane_landing':
      case 'airplane':
        return 'assets/images/myflight/airplane.png';
      case 'meal':
        return 'assets/images/myflight/meal.png';
      case 'moon':
      case 'sleep':
        return 'assets/images/myflight/moon.png';
      default:
        return null;
    }
  }
}

/// 타임라인 이벤트 모델
class TimelineEvent {
  final String? icon;
  String title;
  String time;
  String description;
  final bool isEditable; // 수정 권장 여부 (자유 시간만 true)
  bool isActive; // 활성화 상태 (클릭해서 수정 중)

  TimelineEvent({
    this.icon,
    required this.title,
    required this.time,
    required this.description,
    this.isEditable = false,
    this.isActive = false,
  });
}

/// 타임라인 라인 Painter
class TimelineLinePainter extends CustomPainter {
  final double circleSize;
  final double lineStartOffset;
  final double? lineEndOffset; // nullable로 변경
  final bool isActive; // 활성화 상태
  final bool isEditable; // 수정 권장 여부
  final bool isSelected; // 선택 상태

  TimelineLinePainter({
    required this.circleSize,
    required this.lineStartOffset,
    this.lineEndOffset, // required 제거
    this.isActive = false,
    this.isEditable = false,
    this.isSelected = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final circleRadius = circleSize / 2;
    final centerX = size.width / 2;

    // 타임라인 원 그리기
    if (isActive) {
      // 활성화된 상태: 칠해진 원 + 파란색 테두리 (새로 추가된 이벤트)
      final fillPaint =
          Paint()
            ..color = AppColors.blue1
            ..style = PaintingStyle.fill;

      final borderPaint =
          Paint()
            ..color = AppColors.blue1
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke;

      canvas.drawCircle(Offset(centerX, circleRadius), circleRadius, fillPaint);
      canvas.drawCircle(
        Offset(centerX, circleRadius),
        circleRadius,
        borderPaint,
      );
    } else if (isSelected) {
      // 선택된 상태: 흰색으로 칠해진 원 + 흰색 테두리
      final fillPaint =
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;

      final borderPaint =
          Paint()
            ..color = Colors.white
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke;

      canvas.drawCircle(Offset(centerX, circleRadius), circleRadius, fillPaint);
      canvas.drawCircle(
        Offset(centerX, circleRadius),
        circleRadius,
        borderPaint,
      );
    } else {
      // 비활성화된 상태: 테두리만 (모두 흰색)
      final borderPaint =
          Paint()
            ..color =
                Colors
                    .white // 모든 원은 흰색 테두리
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke;

      canvas.drawCircle(
        Offset(centerX, circleRadius),
        circleRadius,
        borderPaint,
      );
    }

    // 타임라인 세로선 - lineEndOffset이 null이면 전체 높이 사용
    final linePaint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(centerX, lineStartOffset),
      Offset(centerX, lineEndOffset ?? size.height),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant TimelineLinePainter oldDelegate) {
    return oldDelegate.isActive != isActive ||
        oldDelegate.isEditable != isEditable ||
        oldDelegate.isSelected != isSelected;
  }
}
