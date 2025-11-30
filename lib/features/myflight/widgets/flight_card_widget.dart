import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive_extensions.dart';

/// 비행 카드 위젯
///
/// 디자인 스펙:
/// - Frame 높이: 103px
/// - 패딩: 좌우 20px, 상하 26px
/// - 내부 간격: 16px
/// - 배경: 어두운 카드 배경
/// - 보더 레디어스: 16px (추정)
class FlightCardWidget extends StatelessWidget {
  final String departureCode; // 출발지 코드 (예: "DXB")
  final String departureCity; // 출발지 도시 (예: "두바이")
  final String arrivalCode; // 도착지 코드 (예: "INC")
  final String arrivalCity; // 도착지 도시 (예: "대한민국")
  final String duration; // 비행 시간 (예: "13h 30m")
  final String departureTime; // 출발 시간 (예: "10:30 AM")
  final String arrivalTime; // 도착 시간 (예: "09:30 PM")
  final double? rating; // 평점 (지난 비행용, null이면 표시 안 함)
  final String? date; // 날짜 (지난 비행용, 예: "2025.11.26. (토)")
  final VoidCallback? onEditTap; // 편집 버튼 탭
  final bool hasEditNotification; // 편집 알림 활성화 여부

  const FlightCardWidget({
    super.key,
    required this.departureCode,
    required this.departureCity,
    required this.arrivalCode,
    required this.arrivalCity,
    required this.duration,
    required this.departureTime,
    required this.arrivalTime,
    this.rating,
    this.date,
    this.onEditTap,
    this.hasEditNotification = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);

    // 지난 비행일 경우 티켓 박스 SVG 배경 사용
    if (rating != null && date != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(context.w(14)), // 14px
        child: content,
      );
    }

    // 예정된 비행일 경우 일반 카드
    return Container(
      decoration: BoxDecoration(
        color: const Color(
          0xFF1A1A1A,
        ).withOpacity(0.5), // rgba(26, 26, 26, 0.50)
        borderRadius: BorderRadius.circular(context.w(14)), // 14px
      ),
      child: content,
    );
  }

  /// 카드 내용 (공통)
  Widget _buildContent(BuildContext context) {
    // 높이 계산: 지난 비행일 경우 티켓 박스 이미지 크기(247px), 예정된 비행은 계산된 높이
    final double contentHeight =
        (rating != null && date != null)
            ? 247 // 티켓 박스 이미지 높이
            : context.h(92) +
                context.h(30) +
                context.h(
                  20,
                ); // Timeline top + Timeline height + bottom padding

    return SizedBox(
      height: contentHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 지난 비행일 경우 티켓 박스 SVG 배경
          if (rating != null && date != null)
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/images/myflight/ticket box.svg',
                fit: BoxFit.fill,
              ),
            ),

          // 출발지 / 도착지 (맨 위, 패딩 20에 맞춰 top: 20)
          Positioned(
            top: context.h(20),
            left: context.w(20),
            right: context.w(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 출발지
                _buildAirportInfo(
                  context,
                  code: departureCode,
                  city: departureCity,
                ),

                // 도착지
                _buildAirportInfo(
                  context,
                  code: arrivalCode,
                  city: arrivalCity,
                ),
              ],
            ),
          ),

          // BIMO TIME (아래에 배치, top: 30px - 겹침)
          Positioned(
            top: context.h(30),
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'BIMO TIME',
                    style: AppTextStyles.bigBody.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 0), // 세로 간격 0
                  Text(
                    duration,
                    style: AppTextStyles.largeLight.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 타임라인 (시간 - 비행기 - 시간, top: 92px)
          Positioned(
            top: context.h(92),
            left: context.w(20),
            right: context.w(20),
            child: Row(
              children: [
                // 출발 시간
                Text(
                  departureTime,
                  style: AppTextStyles.smallBody.copyWith(
                    color: AppColors.white,
                  ),
                ),

                const SizedBox(width: 16),

                // 점선 + 비행기 아이콘 + 점선
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 점선과 원
                      Row(
                        children: [
                          // 왼쪽 원
                          Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          // 점선
                          Expanded(
                            child: CustomPaint(
                              size: const Size(double.infinity, 1),
                              painter: DashedLinePainter(
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          // 오른쪽 원
                          Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),

                      // 비행기 아이콘
                      Image.asset(
                        'assets/images/myflight/airplane.png',
                        width: context.w(20),
                        height: context.h(20),
                        color: AppColors.white,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // 도착 시간
                Text(
                  arrivalTime,
                  style: AppTextStyles.smallBody.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),

          // 지난 비행일 경우 평점 정보 (배경 이미지 하단에서 27px 위에 배치)
          if (rating != null && date != null)
            Positioned(
              bottom: 27,
              left: context.w(20),
              right: context.w(20),
              child: Row(
                children: [
                  // 항공사 이미지
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Icon(Icons.flight, color: Colors.blue),
                    ),
                  ),

                  SizedBox(width: context.w(12)),

                  // 평점 + 날짜
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            rating.toString(),
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          SvgPicture.asset(
                            'assets/images/myflight/star.svg',
                            width: 14,
                            height: 14,
                          ),
                        ],
                      ),
                      Text(
                        date!,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // 편집 버튼
                  if (onEditTap != null)
                    GestureDetector(
                      onTap: onEditTap,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.white.withOpacity(0.05),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: ClipOval(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 2,
                                    sigmaY: 2,
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/myflight/pencil.png',
                                      width: 24,
                                      height: 24,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // 편집 알림 점 (Y1 컬러, 8x8)
                            // 상단에서 1px, 오른쪽에서 2px 위치
                            if (hasEditNotification)
                              Positioned(
                                right: context.w(2), // 오른쪽에서 2px
                                top: context.h(1), // 상단에서 1px
                                child: Container(
                                  width: context.w(8), // 점 크기 8x8
                                  height: context.h(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.yellow1, // Y1 컬러
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 공항 정보 위젯 (코드 + 도시명)
  Widget _buildAirportInfo(
    BuildContext context, {
    required String code,
    required String city,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          code,
          style: AppTextStyles.bigBody.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: 0), // 세로 간격 0
        Text(
          city,
          style: AppTextStyles.smallBody.copyWith(
            color: AppColors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

/// 점선 Painter
class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;

  DashedLinePainter({
    required this.color,
    this.dashWidth = 4,
    this.dashSpace = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.round;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
