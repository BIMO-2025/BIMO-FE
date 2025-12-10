import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/responsive_extensions.dart';
import '../utils/responsive.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// 커스텀 탭바 위젯
///
/// 디자인 스펙:
/// - 위치: Home Indicator 위 18px
/// - 크기: 287 x 60 (Hug)
/// - 코너 레디어스: 30px
/// - 내부 패딩: 좌우 15px, 상하 10px
/// - 갭: 16px
/// - 외부 패딩: 좌우 44px
/// - 배경: FFFFFF 5%
/// - 스트로크: FFFFFF 10%, 두께 1px
class CustomTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onToggleOffline; // 오프라인 모드 토글
  final bool isOnline;

  const CustomTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onToggleOffline,
    this.isOnline = true, // 기본값: 온라인
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Home Indicator 위 18px + Home Indicator 높이
      padding: EdgeInsets.only(
        bottom:
            Responsive.height(context, 18.0) +
            Responsive.homeIndicatorHeight(context),
        left: context.w(44),
        right: context.w(44),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.w(30)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            // 탭바 컨테이너: 287 x 60 (Hug)
            width: context.w(287),
            decoration: BoxDecoration(
              // 배경: FFFFFF 5%
              color: AppColors.white.withOpacity(0.05),
              // 코너 레디어스: 30px
              borderRadius: BorderRadius.circular(context.w(30)),
              // 스트로크: FFFFFF 10%, 두께 1px
              border: Border.all(color: AppColors.white.withOpacity(0.1), width: 1),
            ),
            // 내부 패딩: 좌우 15px, 상하 8px (2px 오버플로우 방지)
            padding: EdgeInsets.symmetric(
              horizontal: context.w(15),
              vertical: context.h(8),
            ),
            constraints: BoxConstraints(
              maxHeight: context.h(60), // 최대 높이 제한
            ),
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 글래스 아이콘 (온라인/오프라인)
            _buildGlassIcon(context),
            // 갭: 16px
            SizedBox(width: context.w(16)),
            // 홈 아이콘 (40x40)
            _buildTabIcon(
              context: context,
              index: 0,
              iconPath: 'home',
              isEnabled: isOnline, // 온라인일 때만 접속 가능
            ),
            // 갭: 16px
            SizedBox(width: context.w(16)),
            // 나의비행 아이콘 (40x40)
            _buildTabIcon(
              context: context,
              index: 1,
              iconPath: 'my_flight',
              isEnabled: true,
            ),
            // 갭: 16px
            SizedBox(width: context.w(16)),
            // 마이 아이콘 (40x40)
            _buildTabIcon(
              context: context,
              index: 2,
              iconPath: 'my',
              isEnabled: true,
            ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  /// 글래스 아이콘 (온라인/오프라인 상태)
  /// 크기: 89x40 (내부 패딩 고려하여 실제 38px 높이 사용)
  Widget _buildGlassIcon(BuildContext context) {
    return GestureDetector(
      onTap: onToggleOffline,
      child: SizedBox(
        width: context.w(89),
        height: context.h(38),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.hardEdge,
          children: [
            // 글래스 아이콘 배경 이미지
            Image.asset(
              'assets/images/tabbar/Glass.png',
              width: context.w(89),
              height: context.h(38),
              fit: BoxFit.cover,
            ),
            // 온라인/오프라인 텍스트 (바디, 흰색)
            Text(
              isOnline ? 'Online' : 'Offline',
              style: AppTextStyles.body.copyWith(
                color: AppColors.white,
                fontSize: context.fs(15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 탭 아이콘 (홈, 나의비행, 마이)
  /// 크기: 40x40 (내부 패딩 고려하여 실제 38px 사용)
  Widget _buildTabIcon({
    required BuildContext context,
    required int index,
    required String iconPath,
    required bool isEnabled,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: isEnabled ? () => onTap(index) : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: SizedBox(
          width: context.w(38),
          height: context.h(38),
          child: Image.asset(
            'assets/images/tabbar/${iconPath}_${isSelected ? 'on' : 'off'}.png',
            width: context.w(38),
            height: context.h(38),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
