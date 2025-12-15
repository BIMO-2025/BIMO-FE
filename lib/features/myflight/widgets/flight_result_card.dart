import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../home/data/models/flight_search_response.dart';
import 'flight_card_widget.dart' show DashedLinePainter;

class FlightResultCard extends StatelessWidget {
  final FlightSearchData flight;
  final bool isSelected;
  final VoidCallback onTap;

  const FlightResultCard({
    super.key,
    required this.flight,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 세그먼트가 여러 개인 경우 경유편으로 처리
    final isLayover = flight.segments != null && flight.segments!.length > 1;
    final segments = flight.segments ?? [];
    
    // 경유지 정보 (첫 번째 경유지 기준)
    String layoverInfo = '';
    if (isLayover) {
      final firstSegment = segments[0];
      final secondSegment = segments[1];
      
      // 대기 시간 계산: (다음 비행 출발) - (이전 비행 도착)
      // 실제 데이터 형식에 따라 파싱 로직이 필요할 수 있음. 
      // 여기서는 DateTime 문자열(ISO 8601 등)이라고 가정하거나, 단순 시간 차이 계산
      
      try {
        final arrivalTime = DateTime.parse(firstSegment.arrivalTime);
        final departureTime = DateTime.parse(secondSegment.departureTime);
        final diff = departureTime.difference(arrivalTime);
        final hours = diff.inHours;
        final minutes = diff.inMinutes % 60;
        
        layoverInfo = '${hours.toString().padLeft(2, '0')}시간 ${minutes.toString().padLeft(2, '0')}분 ${firstSegment.arrivalAirport}';
      } catch (e) {
        // 날짜 파싱 실패 시 기본 표시
        layoverInfo = '경유 ${firstSegment.arrivalAirport}';
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(color: const Color(0xFF0080FF), width: 1.5)
              : null,
        ),
        child: Column(
          children: [
            // 상단: 항공사 로고 + 출발/도착 정보
            Row(
              children: [
                // 항공사 로고
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      flight.airline.logo,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.flight, color: Colors.blue));
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // 출발 정보
                _buildAirportTime(
                  code: flight.departure.airport,
                  time: _formatTime(flight.departure.time),
                  align: CrossAxisAlignment.center,
                ),
                
                const SizedBox(width: 16),
                
                // 중앙: 점선 + 비행기 + 소요시간
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Row(
                            children: [
                              _buildDot(),
                              Expanded(
                                child: CustomPaint(
                                  size: const Size(double.infinity, 1),
                                  painter: DashedLinePainter(color: Colors.white),
                                ),
                              ),
                              _buildDot(),
                            ],
                          ),
                          Image.asset(
                            'assets/images/myflight/airplane.png',
                            width: 20,
                            height: 20,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDuration(flight.duration),
                        style: AppTextStyles.smallBody.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      // 경유 정보 표시
                      if (isLayover)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            layoverInfo,
                            style: AppTextStyles.smallBody.copyWith(
                                color: const Color(0xFFFFB800), // 강조색 (노랑)
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // 도착 정보
                _buildAirportTime(
                  code: flight.arrival.airport,
                  time: _formatTime(flight.arrival.time),
                  align: CrossAxisAlignment.center,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(height: 1, color: Colors.white12),
            const SizedBox(height: 10),
            
            // 하단: 날짜, 편명
            Row(
              children: [
                Expanded(
                  child: _buildInfoColumn(
                    label: '날짜',
                    value: _formatDate(flight.departure.time),
                  ),
                ),
                Expanded(
                  child: _buildInfoColumn(
                    label: '편명',
                    value: flight.flightNumber, // 경유편인 경우 'KE081 / DL192' 처럼 표시될 수 있도록 데이터 처리 필요
                  ),
                ),
                // 직항/경유 여부
                Text(
                  isLayover ? '경유' : '직항',
                  style: AppTextStyles.body.copyWith(
                    color: isLayover ? const Color(0xFFFFB800) : Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAirportTime({
    required String code,
    required String time,
    required CrossAxisAlignment align,
  }) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          code,
          style: AppTextStyles.bigBody.copyWith(color: Colors.white),
        ),
        Text(
          time,
          style: AppTextStyles.smallBody.copyWith(
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoColumn({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.smallBody.copyWith(
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.smallBody.copyWith(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildDot() {
    return Container(
      width: 9,
      height: 9,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }

  // 시간 포맷 (예: 2024-05-20T10:30:00 -> 10:30)
  String _formatTime(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  // 날짜 포맷 (예: 2024-05-20T10:30:00 -> 2024.05.20)
  String _formatDate(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }
  
  // 소요시간 포맷 (예: 830 -> 13시간 50분)
  String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}시간 ${m.toString().padLeft(2, '0')}분';
  }
}
