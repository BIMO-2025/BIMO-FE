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
  final VoidCallback? onSearchTap; // Added
  final bool isDepartureSelected;
  final bool isArrivalSelected;

  const DestinationSearchSection({
    super.key,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureDate,
    this.onDepartureTap,
    this.onArrivalTap,
    this.onDateTap,
    this.onSwapAirports,
    this.onSearchTap, // Added
    this.isDepartureSelected = false,
    this.isArrivalSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: context.h(8), // 검색 탭 선택기 아래 8px
        left: context.w(20),
        right: context.w(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 출발/도착 공항 카드 (가로 배치) + Swap 아이콘
          Stack(
            alignment: Alignment.center,
            children: [
              // 출발/도착 공항 카드 Row (IntrinsicHeight로 높이 동기화)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 출발 공항 카드
                    Expanded(
                      child: GestureDetector(
                        onTap: onDepartureTap,
                        child: _buildAirportCard(
                          context,
                          label: '출발 공항',
                          airport: departureAirport,
                          isSelected: isDepartureSelected,
                        ),
                      ),
                    ),
                    SizedBox(width: context.w(10)), // 카드 사이 간격 10
                    // 도착 공항 카드
                    Expanded(
                      child: GestureDetector(
                        onTap: onArrivalTap,
                        child: _buildAirportCard(
                          context,
                          label: '도착 공항',
                          airport: arrivalAirport,
                          isSelected: isArrivalSelected,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Swap 아이콘 (중앙)
              GestureDetector(
                onTap: onSwapAirports,
                child: Container(
                  width: context.w(40),
                  height: context.h(40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.background, // 배경색
                  ),
                  child: Image.asset(
                    'assets/images/home/swap_airports.png',
                    width: context.w(40),
                    height: context.h(40),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(8)), // 공항 카드 아래 8px
          // Date Card
        GestureDetector(
          onTap: onDateTap,
          child: Container(
            width: context.w(335),
            height: context.h(87),
            padding: EdgeInsets.symmetric(
              horizontal: context.w(20),
              vertical: context.h(15),
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.1), // FFFFFF 10%
              borderRadius: BorderRadius.circular(context.w(14)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                Text(
                  '출발 날짜',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: context.fs(15), // BigBody
                    fontWeight: FontWeight.w600, // SemiBold
                    height: 1.5, // 150%
                    letterSpacing: -context.fs(0.3), // -2%
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: context.h(10)),
                // Date Value or Placeholder
                Text(
                  departureDate.isEmpty ? '날짜를 선택해주세요' : departureDate,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: context.fs(13), // Body
                    fontWeight: FontWeight.w400, // Regular
                    height: 1.5,
                    letterSpacing: -context.fs(0.26),
                    color: departureDate.isEmpty
                        ? AppColors.white.withOpacity(0.5)
                        : AppColors.white,
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

  /// 공항 카드 위젯 (출발/도착)
  Widget _buildAirportCard(
    BuildContext context, {
    required String label,
    required String airport,
    required bool isSelected,
  }) {
    return Container(
      constraints: BoxConstraints(
        minHeight: context.h(87), // 최소 높이 87
      ),
      padding: EdgeInsets.symmetric(
        horizontal: context.w(20),
        vertical: context.h(15),
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.1), // FFFFFF 10%
        borderRadius: BorderRadius.circular(context.w(14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 라벨 (출발 공항 / 도착 공항)
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: context.fs(15), // BigBody
              fontWeight: FontWeight.w600, // SemiBold
              height: 1.5, // 150% line height
              letterSpacing: -context.fs(0.3), // -2% of 15
              color: AppColors.white, // FFFFFF 100%
            ),
          ),
          SizedBox(height: context.h(10)), // 라벨 아래 10px
          // 공항 정보 (인천 (INC)) - 자동 줄바꿈
          Text(
            airport,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: context.fs(13), // Body
              fontWeight: FontWeight.w400, // Regular
              height: 1.5, // 150% line height
              letterSpacing: -context.fs(0.26), // -2% of 13
              color: isSelected
                  ? AppColors.white // 선택됨: FFFFFF 100%
                  : AppColors.white.withOpacity(0.5), // 선택 안됨: FFFFFF 50%
            ),
          ),
        ],
      ),
    );
  }

  /// 기본 날짜 (현재 날짜) 반환
  String _getDefaultDate() {
    final now = DateTime.now();
    return '${now.year}년 ${now.month}월 ${now.day}일';
  }
}




