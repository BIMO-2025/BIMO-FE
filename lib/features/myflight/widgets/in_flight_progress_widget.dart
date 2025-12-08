import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive_extensions.dart';
import 'flight_card_widget.dart'; // For DashedLinePainter
import 'flight_delay_modal.dart';

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
          _elapsedSeconds++;
        });
      }
    });
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
        onConfirm: (newTime) {
          setState(() {
            _adjustedDepartureTime = newTime;
            _elapsedSeconds = 0; // 타이머 리셋
          });
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

  List<String> get _activityList {
    // 현재, 다음, 다다음 활동 반환
    final activities = <String>[];
    int cumulativeMinutes = 0;
    int currentIndex = -1;

    // 현재 활동 인덱스 찾기
    for (int i = 0; i < widget.timeline.length; i++) {
      final duration = widget.timeline[i]['duration'] as int;
      if (_elapsedSeconds < (cumulativeMinutes + duration) * 60) {
        currentIndex = i;
        break;
      }
      cumulativeMinutes += duration;
    }

    if (currentIndex == -1) currentIndex = widget.timeline.length - 1;

    // 이전, 현재, 다음 활동 가져오기
    if (currentIndex > 0) {
      activities.add(widget.timeline[currentIndex - 1]['title'] as String);
    }
    activities.add(widget.timeline[currentIndex]['title'] as String);
    if (currentIndex < widget.timeline.length - 1) {
      activities.add(widget.timeline[currentIndex + 1]['title'] as String);
    }

    return activities;
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
                  // Pause/Play 버튼
                  GestureDetector(
                    onTap: _togglePause,
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
                        _isPaused ? Icons.play_arrow : Icons.pause,
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
                          widget.departureTime,
                          style: AppTextStyles.smallBody.copyWith(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        Text(
                          'AM',
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
                        Text(
                          'PM',
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

                // 현재 활동
                Column(
                  children: [
                    Text(
                      '비행기 탑승',
                      style: AppTextStyles.smallBody.copyWith(
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    SizedBox(height: context.h(4)),
                    Text(
                      _currentActivity ?? '이륙 및 안정',
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
