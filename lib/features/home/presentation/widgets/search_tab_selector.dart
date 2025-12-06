import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 검색 탭 선택 위젯 (항공사 / 목적지)
///
/// 디자인 스펙:
/// - 전체 컨테이너: 170x40, 코너 레디어스 50, 갭 4, 내부 패딩 2씩
/// - 항공사 선택: 81x36, 코너 레디어스 40, Y1 색, "항공사" 텍스트 (바디, 블랙)
/// - 목적지: 81x36, 투명, "목적지" 텍스트 (바디, 화이트 50%)
class SearchTabSelector extends StatelessWidget {
  final int selectedIndex; // 0: 항공사, 1: 목적지
  final ValueChanged<int> onTap;
  final VoidCallback? onSearchTap; // Added

  const SearchTabSelector({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // TODO: 정확한 위치 적용
      padding: EdgeInsets.symmetric(
        horizontal: context.w(20),
        vertical: context.h(16),
      ),
      child: Row(
        children: [
          // 탭 컨테이너 (170x40)
          _buildTabContainer(context),
          SizedBox(width: context.w(125)), // 탭 컨테이너 오른쪽으로 125px 간격
          // 검색 아이콘 (40x40, 같은 높이 선상)
          GestureDetector(
            onTap: onSearchTap,
            child: SizedBox(
              width: context.w(40),
              height: context.h(40),
              child: Image.asset(
                'assets/images/home/search.png',
                width: context.w(40),
                height: context.h(40),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 탭 컨테이너 (170x40, 코너 레디어스 50)
  Widget _buildTabContainer(BuildContext context) {
    return Container(
      width: context.w(170),
      height: context.h(40),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.1), // 배경 (필요시)
        borderRadius: BorderRadius.circular(context.w(50)),
      ),
      child: Stack(
        children: [
          // Y1 컬러 박스 (81x36, 코너 레디어스 40)
          // 40 높이에 36 높이 박스 = 자동으로 상하 2px씩 공간
          // 선택된 탭에 따라 왼쪽/오른쪽으로 이동
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            left:
                selectedIndex == 0
                    ? context.w(2) // 항공사: 왼쪽 2px 공간
                    : context.w(170) -
                        context.w(81) -
                        context.w(
                          2,
                        ), // 목적지: 오른쪽 2px 공간 (전체 170 - 박스 81 - 오른쪽 패딩 2)
            top: context.h((40 - 36) / 2), // 세로 중앙: (40 - 36) / 2 = 2
            child: Container(
              width: context.w(81),
              height: context.h(36),
              decoration: BoxDecoration(
                color: AppColors.yellow1, // Y1 컬러
                borderRadius: BorderRadius.circular(context.w(40)),
              ),
            ),
          ),
          // 탭 버튼들
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(context.w(2)), // 내부 패딩 2씩
              child: Row(
                children: [
                  // 항공사 탭
                  _buildTabButton(
                    context: context,
                    label: '항공사',
                    index: 0,
                    width: context.w(81),
                    height: context.h(36),
                  ),
                  SizedBox(width: context.w(4)), // 갭 4
                  // 목적지 탭
                  _buildTabButton(
                    context: context,
                    label: '목적지',
                    index: 1,
                    width: context.w(81),
                    height: context.h(36),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required BuildContext context,
    required String label,
    required int index,
    required double width,
    required double height,
  }) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color:
                isSelected
                    ? AppColors
                        .black // 선택됨: 블랙
                    : AppColors.white.withOpacity(0.5), // 미선택: 화이트 50%
          ),
        ),
      ),
    );
  }
}




