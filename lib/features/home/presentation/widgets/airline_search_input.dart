import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 항공사 검색 입력 위젯
///
/// 디자인 스펙:
/// - 위치: SearchTabSelector 아래 8px
/// - 크기: 335 x 50 Hug (최소 높이 50)
/// - 코너 레디어스: 14
/// - 색상: 화이트 10%
/// - 플레이스홀더: "어떤 항공사를 이용하시나요?" (화이트 50%, 바디 스타일)
/// - 패딩: 양옆 15px, 상하 중앙 정렬
class AirlineSearchInput extends StatelessWidget {
  final TextEditingController controller;

  const AirlineSearchInput({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: context.h(8), // SearchTabSelector 아래 8px
      ),
      padding: EdgeInsets.symmetric(
        horizontal: context.w(20), // 화면 양옆 패딩
      ),
      child: Container(
        width: context.w(335),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.1), // 화이트 10%
          borderRadius: BorderRadius.circular(context.w(14)), // 코너 레디어스 14
        ),
        padding: EdgeInsets.symmetric(
          horizontal: context.w(15), // 양옆 15px 패딩
          vertical: context.h(15), // 상하 패딩 (50 - 20) / 2 = 15
        ),
        constraints: BoxConstraints(
          minHeight: context.h(50), // 최소 높이 50
        ),
        child: TextField(
          controller: controller,
          style: AppTextStyles.body.copyWith(
            color: AppColors.white, // 화이트 100%
          ),
          minLines: 1,
          maxLines: 2,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: '어떤 항공사를 이용하시나요?',
            hintStyle: AppTextStyles.body.copyWith(
              color: AppColors.white.withOpacity(0.5), // 화이트 50%
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}




