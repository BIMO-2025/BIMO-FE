import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/responsive_extensions.dart';

/// 커스텀 토글 버튼
/// 
/// 스펙:
/// - 크기: 40 x 24
/// - 코너 래디어스: 50
/// - 활성화: 배경 0080FF (B1), 원 16x16 FFFFFF 100%
/// - 비활성화: 배경 FFFFFF 10%, 원 16x16 FFFFFF 100%
class CustomToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: context.w(40),
        height: context.h(24),
        decoration: BoxDecoration(
          color: value
              ? const Color(0xFF0080FF) // B1 컬러
              : AppColors.white.withOpacity(0.1), // FFFFFF 10%
          borderRadius: BorderRadius.circular(50),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: context.w(4)),
            width: context.w(16),
            height: context.h(16),
            decoration: const BoxDecoration(
              color: Colors.white, // FFFFFF 100%
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}


