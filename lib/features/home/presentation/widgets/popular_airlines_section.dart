import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 인기 항공사 섹션 위젯
class PopularAirlinesSection extends StatelessWidget {
  final String weekLabel; // 예: "[10월 1주]"
  final VoidCallback? onMoreTap;
  final List<AirlineData> airlines;
  final Function(AirlineData)? onItemTap;

  const PopularAirlinesSection({
    super.key,
    required this.weekLabel,
    required this.airlines,
    this.onMoreTap,
    this.onItemTap,
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
                child: GestureDetector(
                  onTap: onMoreTap,
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
              ),
            ],
          ),
          // 항공사 리스트
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(20)),
            child: SizedBox(
              height: context.h(
                14 + 90 * 3 + 12 * 2 - 34,
              ), // 제목 간격 + 카드들 높이 + 간격 - 티웨이 올라간 거리
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 대한항공 (맨 뒤)
                  if (airlines.isNotEmpty)
                    _buildAirlineCard(context, 0, airlines[0], 0.0, 0),
                  // 아시아나 (중간)
                  if (airlines.length > 1)
                    _buildAirlineCard(context, 1, airlines[1], 1.5, -21),
                  // 티웨이 (맨 앞, 블러 효과)
                  if (airlines.length > 2)
                    _buildAirlineCard(
                      context,
                      2,
                      airlines[2],
                      -1.5,
                      -42,
                      hasBlur: true,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 항공사 카드 빌드 헬퍼
  Widget _buildAirlineCard(
    BuildContext context,
    int index,
    AirlineData airline,
    double rotation,
    double offsetY, {
    bool hasBlur = false,
  }) {
    return Positioned(
      top:
          context.h(14) +
          (index * context.h(90)) +
          (index * context.h(12)) +
          offsetY,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {
          onItemTap?.call(airline);
        },
        child: AirlineCard(
          rank: index + 1,
          airline: airline,
          rotation: rotation,
          isSelected: index == 1, // 아시아나만 Blue1 색상
          hasBlur: hasBlur,
        ),
      ),
    );
  }
}

/// 항공사 데이터 모델 (임시)
class AirlineData {
  final String id;
  final String code;
  final String name;
  final double rating;
  final String logoPath;

  AirlineData({
    required this.id,
    required this.code,
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
  final bool hasBlur; // 백그라운드 블러 여부

  const AirlineCard({
    super.key,
    required this.rank,
    required this.airline,
    this.isSelected = false,
    this.rotation = 0, // 기본값: 회전 없음
    this.hasBlur = false, // 기본값: 블러 없음
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation * (3.14159 / 180), // 도를 라디안으로 변환
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.w(12)),
        child: BackdropFilter(
          filter:
              hasBlur
                  ? ImageFilter.blur(sigmaX: 40, sigmaY: 40)
                  : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            width: context.w(335),
            height: context.h(90), // 고정 높이 90
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? AppColors.blue1
                      : AppColors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.w(12)),
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // 텍스트 영역 박스 (120x41, 왼쪽 패딩 20, 상하 중앙 정렬)
                Positioned(
                  left: context.w(20), // 왼쪽 패딩 20
                  top: context.h(
                    (90 - 41) / 2,
                  ), // 상하 중앙 정렬: (90 - 41) / 2 = 24.5
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
                    child: _buildAirlineLogo(context, airline.logoPath),
                  ),
                ),
              ],
            ),
          ), // Container 닫기
        ), // BackdropFilter 닫기
      ), // ClipRRect 닫기
    ); // Transform.rotate 닫기
  }

  /// 항공사 로고 이미지 빌드 (네트워크 URL 또는 로컬 asset)
  Widget _buildAirlineLogo(BuildContext context, String logoPath) {
    // URL인지 확인 (http 또는 https로 시작)
    final isNetworkImage = logoPath.startsWith('http://') || 
                          logoPath.startsWith('https://');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white, // 흰색 배경
        borderRadius: BorderRadius.circular(context.w(14)), // 코너 반경 14
      ),
      padding: EdgeInsets.all(context.w(8)), // 내부 패딩
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.w(6)), // 이미지도 살짝 둥글게
        child: isNetworkImage
            ? Image.network(
                logoPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // 네트워크 이미지 로딩 실패 시 기본 아이콘 표시
                  return Icon(
                    Icons.flight,
                    color: AppColors.white.withOpacity(0.3),
                    size: context.w(30),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      color: AppColors.blue1,
                    ),
                  );
                },
              )
            : Image.asset(
                logoPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Asset 로딩 실패 시 기본 아이콘 표시
                  return Icon(
                    Icons.flight,
                    color: AppColors.white.withOpacity(0.3),
                    size: context.w(30),
                  );
                },
              ),
      ),
    );
  }
}
