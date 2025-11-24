import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// 목적지 검색 섹션 위젯
class DestinationSearchSection extends StatelessWidget {
  final String departureAirport;
  final String arrivalAirport;
  final String departureDate;
  final VoidCallback? onDepartureTap;
  final VoidCallback? onArrivalTap;
  final VoidCallback? onDateTap;
  final VoidCallback? onSwapAirports;

  const DestinationSearchSection({
    super.key,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureDate,
    this.onDepartureTap,
    this.onArrivalTap,
    this.onDateTap,
    this.onSwapAirports,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // TODO: 정확한 위치와 크기 적용
      padding: EdgeInsets.symmetric(
        horizontal: context.w(20),
        vertical: context.h(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 출발 공항
          GestureDetector(
            onTap: onDepartureTap,
            child: Container(
              padding: EdgeInsets.all(context.w(16)),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.w(12)),
              ),
              child: Text(
                '출발: $departureAirport',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: context.fs(16),
                ),
              ),
            ),
          ),
          SizedBox(height: context.h(12)),
          // 도착 공항
          GestureDetector(
            onTap: onArrivalTap,
            child: Container(
              padding: EdgeInsets.all(context.w(16)),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.w(12)),
              ),
              child: Text(
                '도착: $arrivalAirport',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: context.fs(16),
                ),
              ),
            ),
          ),
          SizedBox(height: context.h(12)),
          // 출발 날짜
          GestureDetector(
            onTap: onDateTap,
            child: Container(
              padding: EdgeInsets.all(context.w(16)),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.w(12)),
              ),
              child: Text(
                '날짜: $departureDate',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: context.fs(16),
                ),
              ),
            ),
          ),
          SizedBox(height: context.h(12)),
          // 출발/도착 교체 버튼
          GestureDetector(
            onTap: onSwapAirports,
            child: Container(
              padding: EdgeInsets.all(context.w(16)),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(context.w(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swap_vert,
                    color: AppColors.white,
                    size: context.s(24),
                  ),
                  SizedBox(width: context.w(8)),
                  Text(
                    '출발/도착 교체',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: context.fs(16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
