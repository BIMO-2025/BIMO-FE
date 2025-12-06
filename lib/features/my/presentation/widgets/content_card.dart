import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_extensions.dart';

/// 수면/집중력 콘텐츠 카드 위젯
class ContentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ContentCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
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
            
            // 아이콘 (20 x 20) - 상단 0, 오른쪽 0
            Positioned(
              top: 0,
              right: 0,
              child: Icon(
                Icons.pause_circle_outline,
                size: context.w(20),
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

