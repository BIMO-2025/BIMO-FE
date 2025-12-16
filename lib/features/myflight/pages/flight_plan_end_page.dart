import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_extensions.dart';
import '../../../core/utils/responsive.dart';
import '../widgets/flight_card_widget.dart';
import 'ticket_verification_camera_page.dart';
import 'review_write_page.dart';

/// 비행 종료 화면
class FlightPlanEndPage extends StatelessWidget {
  final String arrivalCity; // 도착 도시 (예: "파리")
  final String airline; // 항공사 (예: "에어프랑스항공")
  final String route; // 노선 (예: "INC→CDG")
  final String departureCode; // 출발지 코드 (예: "DXB")
  final String departureCity; // 출발지 도시 (예: "두바이")
  final String arrivalCode; // 도착지 코드 (예: "INC")
  final String arrivalCityName; // 도착지 도시명 (예: "대한민국")
  final String duration; // 비행 시간 (예: "13h 30m")
  final String departureTime; // 출발 시간 (예: "10:30 AM")
  final String arrivalTime; // 도착 시간 (예: "09:30 PM")
  final String date; // 날짜 (예: "2025.11.26. (토)")
  final String? flightNumber; // 항공편명 (예: "AF264")
  final double? rating; // 평점 (선택적)

  const FlightPlanEndPage({
    super.key,
    required this.arrivalCity,
    required this.airline,
    required this.route,
    required this.departureCode,
    required this.departureCity,
    required this.arrivalCode,
    required this.arrivalCityName,
    required this.duration,
    required this.departureTime,
    required this.arrivalTime,
    required this.date,
    this.flightNumber,
    this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 본문 영역
            Positioned.fill(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.w(20),
                    vertical: context.h(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 로고
                      _buildLogo(context),
                      SizedBox(height: context.h(24)),
                      // 메시지
                      _buildMessage(context),
                      SizedBox(height: context.h(32)),
                      // 티켓 카드
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: context.w(20)),
                        child: FlightCardWidget(
                          departureCode: departureCode,
                          departureCity: departureCity,
                          arrivalCode: arrivalCode,
                          arrivalCity: arrivalCityName,
                          duration: duration,
                          departureTime: departureTime,
                          arrivalTime: arrivalTime,
                          date: date, // 날짜 전달
                          reviewText: '리뷰 작성하고 내 비행 기록하기', // 리뷰 작성 텍스트 (평점 대신)
                          onReviewTap: () {
                            // 티켓 인증 페이지로 이동 (인증 후 자동으로 리뷰 작성 페이지로 이동)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TicketVerificationCameraPage(
                                  departureCode: departureCode,
                                  departureCity: departureCity,
                                  arrivalCode: arrivalCode,
                                  arrivalCity: arrivalCityName,
                                  flightNumber: flightNumber ?? 'Unknown',
                                  date: date,
                                  stopover: '직항', // TODO: 실제 경유 정보로 대체
                                ),
                              ),
                            );
                          },
                          hasEditNotification: true, // 편집 알림 활성화
                          isLightMode: true, // 티켓박스 화이트 이미지 사용
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 닫기 버튼 (우측 상단)
            Positioned(
              top: context.h(21),
              right: context.w(20),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
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
                        child: SvgPicture.asset(
                          'assets/images/myflight/x.svg',
                          width: 24,
                          height: 24,
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
            ),
          ],
        ),
      ),
    );
  }

  /// 로고
  Widget _buildLogo(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Image.asset(
          'assets/images/home/korean_air_logo.png',
          width: 30, // 로고 크기 조정 (컨테이너보다 작게)
          height: 30,
        ),
      ),
    );
  }

  /// 메시지 섹션
  Widget _buildMessage(BuildContext context) {
    return Column(
      children: [
        Text(
          '$arrivalCity에 도착하셨네요!',
          style: AppTextStyles.large.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.h(16)),
        Text(
          '$airline($route) 비행은 어떠셨나요?\n회원님의 소중한 경험을 공유해 주세요!',
          style: AppTextStyles.body.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
