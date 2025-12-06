import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_extensions.dart';

/// 메뉴 섹션 컨테이너
class MenuSection extends StatelessWidget {
  final List<Widget> children;

  const MenuSection({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 335 x 265(Hug)
      width: context.w(335),
      padding: EdgeInsets.all(context.w(20)),
      decoration: BoxDecoration(
        // FFFFFF 10% (프로필 카드와 동일)
        color: AppColors.white.withOpacity(0.1),
        // 코너 반경 14px
        borderRadius: BorderRadius.circular(context.w(14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

