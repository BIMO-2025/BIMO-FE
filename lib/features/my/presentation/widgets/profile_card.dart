import 'dart:io'; // File 클래스 사용을 위해 추가
import 'dart:convert'; // Base64 디코딩을 위해 추가
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_extensions.dart';

/// 프로필 카드 위젯
class ProfileCard extends StatelessWidget {
  final String profileImageUrl;
  final String name;
  final String email;
  final VoidCallback onTap;
  final VoidCallback? onProfileImageTap;

  const ProfileCard({
    super.key,
    required this.profileImageUrl,
    required this.name,
    required this.email,
    required this.onTap,
    this.onProfileImageTap,
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
            // 프로필 이미지 (50x50) + 카메라 아이콘
            Stack(
              children: [
                ClipOval(
                  child: _buildProfileImage(context),
                ),

                // 카메라 아이콘 오버레이
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: onProfileImageTap,
                    child: Image.asset(
                      'assets/images/my/camera.png',
                      width: context.w(22),
                      height: context.w(22),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
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
            Image.asset(
              'assets/images/my/right arrow.png',
              width: context.w(24),
              height: context.h(24),
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildProfileImage(BuildContext context) {
    if (profileImageUrl.isEmpty) {
      return _buildDefaultImage(context);
    }

    if (profileImageUrl.startsWith('http')) {
      return Image.network(
        profileImageUrl,
        width: context.w(50),
        height: context.w(50),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultImage(context),
      );
    } else if (profileImageUrl.startsWith('/') || profileImageUrl.startsWith('file://')) {
      return Image.file(
        File(profileImageUrl),
        width: context.w(50),
        height: context.w(50),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultImage(context),
      );
    } else {
      // Base64 문자열 처리
      try {
        String base64String = profileImageUrl;
        // 데이터 URI 스키마 제거 (data:image/jpeg;base64,...)
        if (base64String.contains(',')) {
          base64String = base64String.split(',').last;
        }
        // 공백 및 줄바꿈 제거
        base64String = base64String.replaceAll(RegExp(r'\s+'), '');
        
        return Image.memory(
          base64Decode(base64String),
          width: context.w(50),
          height: context.w(50),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultImage(context),
        );
      } catch (e) {
        print('❌ Base64 이미지 디코딩 실패: $e');
        return _buildDefaultImage(context);
      }
    }
  }

  Widget _buildDefaultImage(BuildContext context) {
    return Image.asset(
      'assets/images/my/default_profile.png',
      width: context.w(50),
      height: context.w(50),
      fit: BoxFit.cover,
    );
  }
}
