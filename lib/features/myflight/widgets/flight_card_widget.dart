import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive_extensions.dart';
import '../../../core/services/notification_service.dart'; // NotificationService import

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
  final bool hasReview; // 리뷰 작성 여부 (리뷰 없으면 노란색 알림 표시)
  final String? reviewText; // 리뷰 작성 텍스트 (비행 종료 화면용)
  final VoidCallback? onReviewTap; // 리뷰 작성 버튼 탭
  final VoidCallback? onTap; // 카드 전체 탭
  final bool? hasEditNotification; // 편집 알림 표시 여부 (지난 비행용)
  final bool isLightMode; // 라이트 모드 여부 (리스트 페이지용 = true, 내 비행 페이지용 = false)

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
    this.onReviewTap,
    this.reviewText,
    this.hasReview = false,
    this.hasEditNotification,
    this.onTap,
    this.isLightMode = false, // 기본값은 다크 모드 (내 비행 페이지)
  });

  @override
  Widget build(BuildContext context) {
    // Figma 기준 비율에 따른 높이 계산
    // 335:247 = width:height
    final double contentHeight =
        (MediaQuery.of(context).size.width - 40) * (247 / 335);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: contentHeight,
        child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 배경 이미지 선택 (isLightMode에 따라 결정)
          // date가 있는 지난 비행의 경우에만 적용
          // 배경 이미지 선택 (isLightMode에 따라 결정)
          // date가 있는 지난 비행의 경우에만 SVG 배경 적용
          if (date != null)
            Positioned.fill(
              child: SvgPicture.asset(
                isLightMode
                    ? 'assets/images/myflight/ticketbox_white.svg'
                    : 'assets/images/myflight/ticket box.svg',
                fit: BoxFit.fill,
              ),
            )
          else
            // 예정된 비행 (date == null)인 경우 단순 배경 적용
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(26, 26, 26, 0.50),
                  borderRadius: BorderRadius.circular(14),
                ),
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

          // 지난 비행일 경우 평점 정보 또는 리뷰 섹션 (배경 이미지 하단에서 27px 위에 배치)
          // 평점/날짜 또는 리뷰 작성 섹션 (리뷰 영역)
          // rating이 있으면 평점+날짜, reviewText가 있으면 리뷰 작성 텍스트
          if (rating != null || reviewText != null || date != null)
            Positioned(
              bottom: context.h(20),
              left: context.w(20),
              right: context.w(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 항공사 로고 (지난 비행일 경우)
                  // date가 있고 rating이 있을 때만(리뷰 작성 완료) 표시
                  if (rating != null && date != null)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.flight,
                          color: AppColors.blue1,
                        ),
                      ),
                    ),

                  if (rating != null && date != null)
                    SizedBox(width: context.w(12)),

                  // 평점 + 날짜 또는 리뷰 작성 텍스트
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 평점이 있으면 평점 표시
                        if (rating != null)
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

                        // reviewText가 있고 공백이 아닐 때만 표시
                        if (reviewText != null && reviewText!.trim().isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(bottom: rating == null ? 4.0 : 0),
                            child: Text(
                              reviewText!,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        // reviewText가 없지만 평점도 없는 경우 (MyFlightPage 등에서 자동 표시)
                        else if (rating == null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              '리뷰 작성하고 내 비행 기록하기',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                        // 날짜 (지난 비행이면 항상 표시)
                        // rating이 없을 때는 reviewText 아래에 위치
                        if (date != null)
                          Text(
                            date!,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.white,
                            ),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8), // 텍스트와 버튼 사이 최소 간격

                  // 편집 버튼
                  if (onEditTap != null || onReviewTap != null)
                    GestureDetector(
                      onTap: onReviewTap ?? onEditTap,
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
                            // hasEditNotification이 true일 때만 표시
                            if (hasEditNotification == true)
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
