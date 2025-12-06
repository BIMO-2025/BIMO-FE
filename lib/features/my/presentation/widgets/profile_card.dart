import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_extensions.dart';

/// 프로필 카드 위젯
class ProfileCard extends StatelessWidget {
  final String profileImageUrl;
  final String name;
  final String email;
  final VoidCallback onTap;

  const ProfileCard({
    super.key,
    required this.profileImageUrl,
    required this.name,
    required this.email,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // 335 x 90(Hug)
        width: context.w(335),
        padding: EdgeInsets.all(context.w(20)),
        decoration: BoxDecoration(
          // FFFFFF 10%
          color: AppColors.white.withOpacity(0.1),
          // 코너 반경 14px
          borderRadius: BorderRadius.circular(context.w(14)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Y축 중앙 정렬
          children: [
            // 프로필 이미지 (50x50)
            ClipOval(
              child: Image.network(
                profileImageUrl,
                width: context.w(50),
                height: context.w(50),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: context.w(50),
                    height: context.w(50),
                    color: AppColors.textTertiary,
                    child: Icon(
                      Icons.person,
                      size: context.w(25),
                      color: AppColors.white,
                    ),
                  );
                },
              ),
            ),
            
            // 이미지 오른쪽 16 간격
            SizedBox(width: context.w(16)),
            
            // 이름 & 이메일
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 이름 - Large, FFFFFF
                  Text(
                    name,
                    style: AppTextStyles.large.copyWith(
                      fontSize: context.fs(19),
                      color: AppColors.white, // FFFFFF
                    ),
                  ),
                  // 이름과 이메일 사이 4 간격
                  SizedBox(height: context.h(4)),
                  // 이메일 - SmallBody, FFFFFF 50%
                  Text(
                    email,
                    style: AppTextStyles.smallBody.copyWith(
                      fontSize: context.fs(13),
                      color: AppColors.white.withOpacity(0.5), // FFFFFF 50%
                    ),
                  ),
                ],
              ),
            ),
            
            // 들어가기 화살표 아이콘 (24x24)
            // Y축 중앙 정렬, 오른쪽 끝에서 내부패딩만큼 안쪽
            Icon(
              Icons.chevron_right,
              size: context.w(24),
              color: AppColors.white,
            ),
          ],
        ),
      ),
    );
  }
}


