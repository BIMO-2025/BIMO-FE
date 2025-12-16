import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_extensions.dart';

/// 수면/집중력 콘텐츠 카드 위젯
class ContentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isPlaying;

  const ContentCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.w(160), // 160 x 100
        height: context.h(100), // 96 → 100 (4픽셀 증가)
        padding: EdgeInsets.all(context.w(15)), // 내부 패딩 15
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A).withOpacity(0.8), // 1A1A1A 80%
          borderRadius: BorderRadius.circular(context.w(10)), // 코너 10
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 제목 (BigBody, 화이트)
                Text(
                  title,
                  style: AppTextStyles.bigBody.copyWith(
                    fontSize: context.fs(15),
                    color: AppColors.white,
                  ),
                ),
                
                SizedBox(height: context.h(10)), // 제목 아래 10
                
                // 부제목 (SmallBody, 화이트)
                Text(
                  subtitle,
                  style: AppTextStyles.smallBody.copyWith(
                    fontSize: context.fs(13),
                    color: AppColors.white,
                    height: 1.4,
                  ),
                ),
              ],
            ),
            
            // 재생/정지 아이콘 (20 x 20) - 상단 0, 오른쪽 0
            Positioned(
              top: 0,
              right: 0,
              child: Image.asset(
                isPlaying
                    ? 'assets/images/my/playing.png' // 재생 중일 때 (멈춤 아이콘?)
                    : 'assets/images/my/pause.png', // 멈춘 상태일 때 (재생 아이콘?)
                width: context.w(20),
                height: context.h(20),
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


