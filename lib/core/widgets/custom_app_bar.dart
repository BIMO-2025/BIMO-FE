import 'package:flutter/material.dart';
import '../utils/responsive_extensions.dart';
import '../theme/app_colors.dart';

/// 커스텀 앱바 위젯
///
/// 디자인 스펙:
/// - 위치: 상태바 바로 밑
/// - 높이: 82px
/// - 너비: 375px (전체 화면)
/// - 왼쪽: 로고
/// - 오른쪽: 알림 아이콘 (안읽은 알림 있을 때 연두색 점 표시)
class CustomAppBar extends StatelessWidget {
  final bool hasUnreadNotifications;
  final VoidCallback? onNotificationTap;
  final bool showLogo;

  const CustomAppBar({
    super.key,
    this.hasUnreadNotifications = false,
    this.onNotificationTap,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.h(82),
      width: double.infinity,
      child: Stack(
        children: [
          // 왼쪽: 로고
          if (showLogo)
          Positioned(
            left: context.w(20), // 왼쪽 패딩 20px
            top: context.h(27.97), // 상단에서 27.97px 아래
            child: _buildLogo(context),
          ),
          // 오른쪽: 알림 아이콘
          Positioned(
            right: context.w(20), // 오른쪽 패딩 20px
            top: context.h(20), // 상단에서 20px 아래
            child: _buildNotificationIcon(context),
          ),
        ],
      ),
    );
  }

  /// 로고 위젯
  /// 크기: 82x26.07
  Widget _buildLogo(BuildContext context) {
    return SizedBox(
      width: context.w(82),
      height: context.h(26.07),
      child: Image.asset(
        'assets/images/home/TypoLogo.png',
        width: context.w(82),
        height: context.h(26.07),
        fit: BoxFit.contain,
      ),
    );
  }

  /// 알림 아이콘 위젯
  /// 크기: 42x42
  Widget _buildNotificationIcon(BuildContext context) {
    return GestureDetector(
      onTap: onNotificationTap,
      child: SizedBox(
        width: context.w(42),
        height: context.h(42),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // 알림 아이콘
            Image.asset(
              'assets/images/home/noti.png',
              width: context.w(42),
              height: context.h(42),
              fit: BoxFit.contain,
            ),
            // 안읽은 알림 점 (Y1 컬러, 8x8)
            // 상단에서 2px, 오른쪽에서 3px 위치
            if (hasUnreadNotifications)
              Positioned(
                right: context.w(3), // 오른쪽에서 3px
                top: context.h(2), // 상단에서 2px
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
    );
  }
}
