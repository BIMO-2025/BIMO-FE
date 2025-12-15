import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    
    // 경유지 정보 계산
    String layoverInfo = '';
    if (isLayover) {
      final List<String> layoverDetails = [];
      
      for (int i = 0; i < segments.length - 1; i++) {
        final prevArrival = DateTime.parse(segments[i].arrivalTime);
        final nextDeparture = DateTime.parse(segments[i + 1].departureTime);
        final diff = nextDeparture.difference(prevArrival);
        
        final hours = diff.inHours;
        final minutes = diff.inMinutes % 60;
        final airportCode = segments[i].arrivalAirport;
        
        layoverDetails.add('${hours.toString().padLeft(2, '0')}시간 ${minutes.toString().padLeft(2, '0')}분 $airportCode');
      }
      
      layoverInfo = layoverDetails.join('\n');
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(color: Colors.white.withOpacity(0.5), width: 1.5)
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
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _buildLogo(flight.airline.logo),
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
            // 하단: 날짜, 편명, 경유 정보
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 날짜
                Expanded(
                  flex: 1,
                  child: _buildInfoColumn(
                    label: '날짜',
                    value: _formatDate(flight.departure.time), 
                  ),
                ),
                // 편명
                Expanded(
                  flex: 1,
                  child: _buildInfoColumn(
                    label: '편명',
                    value: segments.isNotEmpty
                        ? segments.map((s) {
                            // 편명 중복 방지 (예: carrier='PR', number='PR0127' -> 'PR0127')
                            if (s.number.startsWith(s.carrierCode)) {
                              return s.number;
                            }
                            return '${s.carrierCode}${s.number}';
                          }).join(' / ')
                        : flight.flightNumber,
                  ),
                ),
                // 경유 여부
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                        Text(
                          '경유 여부 (${isLayover ? segments.length - 1 : 0}번)',
                          style: AppTextStyles.smallBody.copyWith(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isLayover ? layoverInfo : '직항',
                          style: AppTextStyles.smallBody.copyWith(
                             color: Colors.white,
                             fontWeight: FontWeight.bold // 강조
                          ),
                          textAlign: TextAlign.end,
                        ),
                    ],
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

  // 날짜 포맷 (예: 2024-05-20T10:30:00 -> 2024.05.20. (월))
  String _formatDate(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
      final weekday = weekdays[dt.weekday - 1];
      return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}. ($weekday)';
    } catch (e) {
      return dateTimeStr;
    }
  }
  
  // 소요시간 포맷 (예: 830 -> 13h 50m)
  String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }

  Widget _buildLogo(String url) {
    if (url.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        url,
        fit: BoxFit.cover,
        placeholderBuilder: (BuildContext context) => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Center(child: Icon(Icons.flight, color: Colors.blue));
      },
    );
  }
}
