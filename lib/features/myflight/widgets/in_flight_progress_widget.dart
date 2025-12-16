import 'dart:async';
import '../../../core/services/notification_service.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive_extensions.dart';
import 'flight_card_widget.dart';
import 'flight_delay_modal.dart';
import '../data/repositories/local_flight_repository.dart';
import '../data/repositories/local_timeline_repository.dart';
import '../../../core/state/flight_state.dart';
import '../pages/flight_plan_end_page.dart';
import '../data/models/local_flight.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

/// 진행 중인 비행 위젯 (오프라인 모드)
class InFlightProgressWidget extends StatefulWidget {
  final String departureCode;
  final String departureCity;
  final String arrivalCode;
  final String arrivalCity;
  final String departureTime;
  final String arrivalTime;
  final int totalDurationMinutes; // 총 비행 시간 (분)
  final DateTime departureDateTime; // 출발 시간
  final List<Map<String, dynamic>> timeline; // 타임라인 이벤트
  final String flightId; // 비행 ID (DB 업데이트용)
  final VoidCallback? onFlightEnded; // 비행 종료 시 콜백

  const InFlightProgressWidget({
    super.key,
    required this.departureCode,
    required this.departureCity,
    required this.arrivalCode,
    required this.arrivalCity,
    required this.departureTime,
    required this.arrivalTime,
    required this.totalDurationMinutes,
    required this.departureDateTime,
    required this.timeline,
    this.flightId = '',
    this.onFlightEnded,
  });

  @override
  State<InFlightProgressWidget> createState() => _InFlightProgressWidgetState();
}

class _InFlightProgressWidgetState extends State<InFlightProgressWidget> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isPaused = false;
  DateTime? _adjustedDepartureTime;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko_KR', null);
    _adjustedDepartureTime = widget.departureDateTime;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          // 전역 디버그 시간을 반영하여 경과 시간 계산
          final now = DateTime.now().add(FlightState().debugTimeOffset);
          final departure = _adjustedDepartureTime ?? widget.departureDateTime;
          
          final diff = now.difference(departure).inSeconds;
          _elapsedSeconds = diff > 0 ? diff : 0;
          
          // [AUTO END] 비행 시간 종료 시 자동 종료 화면 이동
          final totalSeconds = widget.totalDurationMinutes * 60;
          if (_elapsedSeconds >= totalSeconds) {
             _endFlight();
          }
        });
      }
    });
  }

  /// 비행 종료 처리 및 페이지 이동
  Future<void> _endFlight() async {
    _timer?.cancel();
    _timer = null;

    final repo = LocalFlightRepository();
    await repo.init();
    
    // widget.flightId가 있으면 그것을, 없으면 진행 중 비행 조회
    LocalFlight? flight;
    if (widget.flightId.isNotEmpty) {
      flight = await repo.getFlight(widget.flightId);
    } else {
      flight = await repo.getInProgressFlight();
    }
    
    if (flight != null) {
      flight.status = 'past';
      flight.forceInProgress = false; // 테스트 플래그 초기화
      flight.lastModified = DateTime.now();
      await repo.saveFlight(flight);
      print('✅ 비행 종료 처리 완료: ${flight.id}');
      
      if (mounted) {
        // 비행 종료 페이지로 이동
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FlightPlanEndPage(
              arrivalCity: widget.arrivalCity,
              airline: 'Korean Air', // 임시 하드코딩 (나중에 DB 연동)
              route: '${widget.departureCode}→${widget.arrivalCode}',
              departureCode: widget.departureCode,
              departureCity: widget.departureCity,
              arrivalCode: widget.arrivalCode,
              arrivalCityName: widget.arrivalCity,
              duration: '${widget.totalDurationMinutes ~/ 60}h ${widget.totalDurationMinutes % 60}m',
              departureTime: widget.departureTime,
              arrivalTime: widget.arrivalTime,
              date: DateFormat('yyyy.MM.dd. (E)', 'ko_KR').format(widget.departureDateTime),
            ),
          ),
        );
        
        // 종료 페이지에서 돌아오면 홈 데이터 갱신
        widget.onFlightEnded?.call();
      }
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _showDelayModal() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => FlightDelayModal(
        currentDepartureTime: _adjustedDepartureTime ?? widget.departureDateTime,
        onConfirm: (newTime) async {
          // 지연 시간 계산
          final originalTime = _adjustedDepartureTime ?? widget.departureDateTime;
          final delay = newTime.difference(originalTime);
          
          if (delay.inMinutes != 0) {
            // 1. 비행 시간 지연 적용
            final flightRepo = LocalFlightRepository();
            await flightRepo.init();
            await flightRepo.delayFlight(widget.flightId, delay);
            
            // 2. 타임라인 시간 일괄 조정
            final timelineRepo = LocalTimelineRepository();
            await timelineRepo.init();
            await timelineRepo.shiftTimelineEvents(widget.flightId, delay);
            
            // 3. UI 업데이트 및 상위 페이지 새로고침
            if (mounted) {
              setState(() {
                _adjustedDepartureTime = newTime;
                // 경과 시간은 유지하거나, 필요 시 조정 (여기선 유지)
              });
              
              // MyFlightPage 데이터 리로드 트리거 (선택사항)
               widget.onFlightEnded?.call(); 
               // 주의: onFlightEnded는 이름이 좀 그렇지만 _refreshData()를 가리킴.
               // 정확히는 onDataChanged 같은 콜백이 필요하지만, 현재는 이것을 재사용.
            }
          }
        },
      ),
    );
  }

  double get _progress {
    final totalSeconds = widget.totalDurationMinutes * 60;
    if (totalSeconds == 0) return 0;
    return (_elapsedSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  String get _formattedElapsedTime {
    final hours = _elapsedSeconds ~/ 3600;
    final minutes = (_elapsedSeconds % 3600) ~/ 60;
    final seconds = _elapsedSeconds % 60;
    
    // 1시간 미만: MM:SS, 1시간 이상: HH:MM:SS
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String? get _currentActivity {
    // 현재 경과 시간에 해당하는 활동 찾기
    int cumulativeMinutes = 0;
    for (var event in widget.timeline) {
      final duration = event['duration'] as int; // 분 단위
      if (_elapsedSeconds < (cumulativeMinutes + duration) * 60) {
        return event['title'] as String;
      }
      cumulativeMinutes += duration;
    }
    return widget.timeline.isNotEmpty ? widget.timeline.last['title'] as String : null;
  }

  int get _currentActivityIndex {
    // 현재 진행 중인 활동의 인덱스 찾기
    int cumulativeMinutes = 0;
    for (int i = 0; i < widget.timeline.length; i++) {
      final duration = widget.timeline[i]['duration'] as int;
      if (_elapsedSeconds < (cumulativeMinutes + duration) * 60) {
        return i;
      }
      cumulativeMinutes += duration;
    }
    return widget.timeline.length - 1; // 마지막 항목
  }

  List<Widget> _buildTimelineItems() {
    if (widget.timeline.isEmpty) {
      // 타임라인 없으면 기본 표시
      return [
        Text(
          '이륙 및 안정',
          style: AppTextStyles.body.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.h(4)),
        Text(
          '첫 번째 가능한 활동 (비빔밥 or 볼로기)',
          style: AppTextStyles.smallBody.copyWith(
            color: Colors.white.withOpacity(0.3),
          ),
        ),
      ];
    }
    
    final currentIndex = _currentActivityIndex;
    final items = <Widget>[];
    
    // 현재 항목 (흰색, 굵게)
    items.add(
      Text(
        widget.timeline[currentIndex]['title'] as String,
        style: AppTextStyles.body.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    
    items.add(SizedBox(height: context.h(4)));
    
    // 다음 항목 (옅은 회색)
    if (currentIndex < widget.timeline.length - 1) {
      items.add(
        Text(
          widget.timeline[currentIndex + 1]['title'] as String,
          style: AppTextStyles.smallBody.copyWith(
            color: Colors.white.withOpacity(0.3),
          ),
        ),
      );
    }
    
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(20)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더: 제목 + delay 버튼 + pause 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '진행 중인 비행',
                style: AppTextStyles.medium.copyWith(color: Colors.white),
              ),
              Row(
                children: [
                  // Delay 버튼
                  GestureDetector(
                    onTap: _showDelayModal,
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
                      child: Icon(
                        Icons.schedule,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  SizedBox(width: context.w(8)),
                  // 디버그: +1시간 버튼
                  // [DEBUG] Start
                GestureDetector(
                  onTap: () {
                    final diff = widget.departureDateTime.difference(DateTime.now());
                    FlightState().setDebugTimeOffset(diff + const Duration(minutes: 5));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('Start', style: AppTextStyles.smallBody.copyWith(fontSize: 10, color: Colors.white)),
                  ),
                ),
                SizedBox(width: 4),
                // [DEBUG] Next Event
                GestureDetector(
                  onTap: () {
                    final currentIndex = _currentActivityIndex;
                    if (currentIndex < widget.timeline.length - 1) {
                      // 다음 이벤트 찾기
                      final nextEvent = widget.timeline[currentIndex + 1];
                      
                      // 다음 이벤트 시작 시간까지의 분 계산
                      int nextEventStartMinutes = 0;
                      for (int i = 0; i <= currentIndex; i++) {
                        nextEventStartMinutes += widget.timeline[i]['duration'] as int;
                      }
                      
                      // 현재 비행 경과 시간과 목표 시간의 차이 계산
                      // 목표: 다음 이벤트 시작 후 5초 지점
                      final now = DateTime.now();
                      final flightStartTime = widget.departureDateTime;
                      final targetTime = flightStartTime.add(Duration(minutes: nextEventStartMinutes, seconds: 5));
                      
                      final newOffset = targetTime.difference(now);
                      
                      // 시간 업데이트
                      FlightState().setDebugTimeOffset(newOffset);
                      
                      // 즉시 알림 발송
                      final title = nextEvent['title'] as String;
                      final icon = nextEvent['icon'] as String?;
                      
                      NotificationService().showInstantNotification(
                        title,
                        '지금 시작되었습니다!',
                        payload: 'flight_timeline_${currentIndex + 1}', // 고유 ID 시뮬레이션
                        iconAssetPath: icon != null ? 'assets/images/myflight/$icon' : null,
                      );
                      
                      print('✅ [Debug] 다음 이벤트로 점프: $title');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('Next', style: AppTextStyles.smallBody.copyWith(fontSize: 10, color: Colors.white)),
                  ),
                ),
                SizedBox(width: 4),
                // [DEBUG] Reset
                GestureDetector(
                  onTap: () {
                    FlightState().setDebugTimeOffset(Duration.zero);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('Reset', style: AppTextStyles.smallBody.copyWith(fontSize: 10, color: Colors.white)),
                  ),
                ),
                SizedBox(width: 8),
                  // 종료 버튼
                  GestureDetector(
                    onTap: () async {
                      // 종료 확인 다이얼로그
                      final shouldEnd = await showDialog<bool>(
                        context: context,
                        barrierColor: Colors.black.withOpacity(0.8),
                        builder: (BuildContext context) {
                          return Dialog(
                            backgroundColor: Colors.transparent,
                            child: Container(
                              padding: EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '비행을 종료하시겠습니까?',
                                    style: AppTextStyles.body.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 24),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => Navigator.pop(context, false),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(vertical: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '취소',
                                                style: AppTextStyles.smallBody.copyWith(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => Navigator.pop(context, true),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(vertical: 12),
                                            decoration: BoxDecoration(
                                              color: AppColors.blue1,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '종료',
                                                style: AppTextStyles.smallBody.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
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
                          );
                        },
                      );

                      if (shouldEnd == true) {
                        await _endFlight();
                      }
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
                      child: Icon(
                        Icons.power_settings_new,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: context.h(16)),

          // 비행 경로 (animated)
          Container(
            padding: EdgeInsets.all(context.w(16)),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // DXB - 진행바 - INC를 한 줄에 세로 중앙정렬
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // DXB + 09:00 + AM (왼쪽)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.departureCode,
                          style: AppTextStyles.bigBody.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.departureTime, // 이미 AM/PM 포함
                          style: AppTextStyles.smallBody.copyWith(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(width: context.w(12)),

                    // 점선 + 비행기 + 경과 시간 (중앙, 확장)
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final availableWidth = constraints.maxWidth;
                          // 동그라미 없이 전체 너비 사용
                          final airplanePosition = availableWidth * _progress;
                          
                          return SizedBox(
                            height: 40, // 비행기와 시간을 위한 충분한 높이
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // 점선만 (동그라미 제거)
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  top: 20, // 중앙 정렬
                                  child: CustomPaint(
                                    size: const Size(double.infinity, 1),
                                    painter: DashedLinePainter(
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),

                                // 비행기 아이콘 (progress에 따라 이동)
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                  left: airplanePosition - (context.w(20) / 2), // 비행기 정확한 중심
                                  top: 10, // 점선 위
                                  child: Image.asset(
                                    'assets/images/myflight/airplane.png',
                                    width: context.w(20),
                                    height: context.h(20),
                                    color: AppColors.white,
                                  ),
                                ),

                                // 경과 시간 (비행기 4px 아래, 중앙정렬)
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                  left: airplanePosition - 30, // 시간 텍스트 중앙 (60px 너비)
                                  top: 10 + context.h(20) + 4, // 비행기 top + 높이 + 4px
                                  child: SizedBox(
                                    width: 60, // HH:MM:SS 형식을 위한 너비 증가
                                    child: Center(
                                      child: Text(
                                        _formattedElapsedTime,
                                        style: AppTextStyles.smallBody.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(width: context.w(12)),

                    // INC + 19:40 + PM (오른쪽)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.arrivalCode,
                          style: AppTextStyles.bigBody.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.arrivalTime,
                          style: AppTextStyles.smallBody.copyWith(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: context.h(16)),

                // 구분선
                Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.1),
                ),

                SizedBox(height: context.h(16)),

                // 가사 보기 스타일 타임라인
                Column(
                  children: [
                    // 이전 항목 (옅은 회색)
                    if (_currentActivityIndex > 0)
                      Text(
                        widget.timeline[_currentActivityIndex - 1]['title'] as String,
                        style: AppTextStyles.smallBody.copyWith(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      )
                    else 
                       // 첫 번째 항목인 경우 '비행 시작' 등으로 표시하거나 숨김
                       Text(
                        '비행 시작',
                        style: AppTextStyles.smallBody.copyWith(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      
                    SizedBox(height: context.h(8)),
                    // 타임라인 항목들 (가사처럼 흐름)
                    ..._buildTimelineItems(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
