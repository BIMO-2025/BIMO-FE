import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 인기 항공사 섹션 위젯
class PopularAirlinesSection extends StatelessWidget {
  final String weekLabel; // 예: "[10월 1주]"
  final VoidCallback? onMoreTap;
  final List<AirlineData> airlines;

  const PopularAirlinesSection({
    super.key,
    required this.weekLabel,
    required this.airlines,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: context.h(24), // 검색창 아래 24px
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Row(
            crossAxisAlignment: CrossAxisAlignment.center, // 텍스트 중앙 높이에 맞춤
            children: [
              // 텍스트 (왼쪽 20px 패딩)
              Padding(
                padding: EdgeInsets.only(
                  left: context.w(20), // 왼쪽 패딩 20
                ),
                child: Text(
                  '$weekLabel\n가장 인기 있는 항공사',
                  style: AppTextStyles.medium.copyWith(
                    fontSize: context.fs(17), // 반응형 폰트 크기
                    color: AppColors.white, // 화이트 100%
                  ),
                ),
              ),
              const Spacer(),
              // 아이콘 (오른쪽 20px 패딩)
              Padding(
                padding: EdgeInsets.only(
                  right: context.w(20), // 화면 오른쪽에서 20px 패딩
                ),
                child: SizedBox(
                  width: context.w(24),
                  height: context.h(24),
                  child: Image.asset(
                    'assets/images/home/chevron_right.png',
                    width: context.w(24),
                    height: context.h(24),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(14)), // 제목 아래 14px
          // 항공사 리스트
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(20)),
            child: Column(
              children: [
                ...airlines.asMap().entries.map((entry) {
                  final index = entry.key;
                  final airline = entry.value;
                  return Transform.translate(
                    offset: Offset(
                      0,
                      index == 1 ? -context.h(4) : 0,
                    ), // 두 번째 카드는 4px 위로
                    child: Padding(
                      padding: EdgeInsets.only(bottom: context.h(12)),
                      child: AirlineCard(
                        rank: index + 1,
                        airline: airline,
                        rotation: index == 1 ? -1.5 : 0, // 두 번째 카드만 -1.5도 회전
                        isSelected: index == 1, // 두 번째 카드는 Blue1 색상
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 항공사 데이터 모델 (임시)
class AirlineData {
  final String name;
  final double rating;
  final String logoPath;

  AirlineData({
    required this.name,
    required this.rating,
    required this.logoPath,
  });
}

/// 개별 항공사 카드 위젯
///
/// 디자인 스펙:
/// - 크기: 335x90 Hug (최소 높이 90)
/// - 좌우 패딩: 20px
/// - 텍스트 영역 박스: 120x41, 왼쪽 20px 패딩, 상하 중앙 정렬
/// - 항공사 이름: 박스 맨 상단, 왼쪽 6px
/// - 숫자: 항공사 이름 아래, 왼쪽 6px (16x25 박스)
/// - 평점: 항공사 이름 아래 4px, 숫자 오른쪽 16px
/// - 이미지: 상하 20px 패딩, 오른쪽 20px 패딩, 맨 오른쪽
class AirlineCard extends StatelessWidget {
  final int rank;
  final AirlineData airline;
  final bool isSelected;
  final double rotation; // 회전 각도 (도 단위)

  const AirlineCard({
    super.key,
    required this.rank,
    required this.airline,
    this.isSelected = false,
    this.rotation = 0, // 기본값: 회전 없음
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation * (3.14159 / 180), // 도를 라디안으로 변환
      child: Container(
        width: context.w(335),
        height: context.h(90), // 고정 높이 90
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.blue1 : AppColors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(context.w(12)),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // 텍스트 영역 박스 (120x41, 왼쪽 패딩 20, 상하 중앙 정렬)
            Positioned(
              left: context.w(20), // 왼쪽 패딩 20
              top: context.h((90 - 41) / 2), // 상하 중앙 정렬: (90 - 41) / 2 = 24.5
              child: SizedBox(
                width: context.w(120),
                height: context.h(41),
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // 순위 번호 (박스 맨 상단, 왼쪽 6px)
                    Positioned(
                      left: context.w(6),
                      top: 0,
                      child: SizedBox(
                        width: context.w(16),
                        height: context.h(25),
                        child: Text(
                          '$rank',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: context.fs(25),
                            fontWeight: FontWeight.w600, // SemiBold
                            height: 1.0, // 100% line height
                            letterSpacing: -context.fs(0.5), // -2% of 25
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    // 항공사 이름 (숫자 오른쪽 16px, 같은 줄)
                    Positioned(
                      left:
                          context.w(6) +
                          context.w(16) +
                          context.w(16), // 왼쪽(6) + 숫자 박스(16) + 간격(16)
                      top: 0, // 같은 줄
                      child: Text(
                        airline.name,
                        style: AppTextStyles.bigBody.copyWith(
                          fontSize: context.fs(15), // 반응형
                          color: AppColors.white, // 화이트 100%
                        ),
                      ),
                    ),
                    // 평점 (항공사 이름 아래 4px, 항공사 이름과 같은 x축)
                    // BigBody: 15pt, line-height 150% = 항공사 이름 높이
                    Positioned(
                      left:
                          context.w(6) +
                          context.w(16) +
                          context.w(16), // 항공사 이름과 같은 x축
                      top:
                          context.fs(15) * 1.5 +
                          context.h(4), // 항공사 이름 높이 + 4px 아래
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.smallBody.copyWith(
                            fontSize: context.fs(13), // 반응형
                          ),
                          children: [
                            TextSpan(
                              text: '${airline.rating}',
                              style: AppTextStyles.smallBody.copyWith(
                                fontSize: context.fs(13),
                                color: AppColors.white, // 화이트 100%
                              ),
                            ),
                            TextSpan(
                              text: '/5.0',
                              style: AppTextStyles.smallBody.copyWith(
                                fontSize: context.fs(13),
                                color: AppColors.white.withOpacity(
                                  0.5,
                                ), // 화이트 50%
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 항공사 로고 (상하 20px 패딩, 오른쪽 20px 패딩, 맨 오른쪽)
            Positioned(
              right: context.w(20), // 컨테이너 오른쪽에서 20px (패딩)
              top: context.h(20), // 상단 20px 패딩
              child: SizedBox(
                width: context.w(50), // 90 - 20*2 = 50
                height: context.h(50),
                child: Image.asset(airline.logoPath, fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ), // Container 닫기
    ); // Transform.rotate 닫기
  }
}
