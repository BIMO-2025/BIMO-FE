import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/responsive_extensions.dart';

/// 기본 Primary 버튼
/// 
/// 스펙:
/// - 크기: 335 x 50
/// - 코너 래디어스: 30
/// - 배경: FFFFFF 5%, 백그라운드 블러
/// - 테두리: FFFFFF 10%, 두께 1 (inside)
/// - 텍스트: 폰트 크기 15, 라인하이트 120%, 레터 스페이싱 -1.5, 미디움 웨이트
/// - 비활성화: FFFFFF 50%
/// - 활성화: FFFFFF 100%
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isEnabled;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.w(30)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            width: context.w(335),
            height: context.h(50),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(context.w(30)),
              border: Border.all(
                color: AppColors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: context.fs(15),
                  fontWeight: FontWeight.w500, // Medium
                  height: 1.2, // 120%
                  letterSpacing: -1.5,
                  color: AppColors.white.withOpacity(isEnabled ? 1.0 : 0.5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


