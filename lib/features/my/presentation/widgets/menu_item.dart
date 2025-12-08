import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_extensions.dart';

/// 메뉴 아이템 위젯
class MenuItem extends StatefulWidget {
  final String title;
  final bool hasInfoIcon;
  final VoidCallback onTap;

  const MenuItem({
    super.key,
    required this.title,
    this.hasInfoIcon = false,
    required this.onTap,
  });

  @override
  State<MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  bool _showTooltip = false;
  Timer? _tooltipTimer;

  @override
  void dispose() {
    _tooltipTimer?.cancel();
    super.dispose();
  }

  void _toggleTooltip() {
    setState(() {
      _showTooltip = true;
    });

    // 3초 후 자동으로 닫기
    _tooltipTimer?.cancel();
    _tooltipTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showTooltip = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.title,
            style: AppTextStyles.body.copyWith(
              fontSize: context.fs(15),
              color: AppColors.white,
            ),
          ),
          if (widget.hasInfoIcon) ...[
            SizedBox(width: context.w(4)),
            // info 아이콘 + 툴팁
            Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: _toggleTooltip,
                  child: Image.asset(
                    'assets/images/my/info.png',
                    width: context.w(18),
                    height: context.h(18),
                    fit: BoxFit.contain,
                  ),
                ),

                // 툴팁 (i 아이콘 위 3.5) - Fade In/Out
                if (_showTooltip)
                  Positioned(
                    bottom: context.h(18 + 3.5), // 아이콘(18) + 위(3.5)
                    left: -3, // 왼쪽으로 2만큼 추가 이동
                    child: AnimatedOpacity(
                      opacity: _showTooltip ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(context.w(14)),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                          child: Container(
                            width: context.w(237), // 너비 235
                            padding: EdgeInsets.all(context.w(12)),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                context.w(14),
                              ),
                            ),
                            child: Text(
                              '이 콘텐츠는 다운로드 없이 비행기 모드에서\n언제든 이용할 수 있습니다.',
                              style: AppTextStyles.smallBody.copyWith(
                                fontSize: context.fs(13),
                                color: AppColors.white.withOpacity(
                                  0.5,
                                ), // FFFFFF 50%
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
