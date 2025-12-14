import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_extensions.dart';

/// 수면/집중력 콘텐츠 카드 위젯
class ContentCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const ContentCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  State<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard> {
  bool _isPlaying = false;

  void _togglePlayState() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayState,
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
                  widget.title,
                  style: AppTextStyles.bigBody.copyWith(
                    fontSize: context.fs(15),
                    color: AppColors.white,
                  ),
                ),
                
                SizedBox(height: context.h(10)), // 제목 아래 10
                
                // 부제목 (SmallBody, 화이트)
                Text(
                  widget.subtitle,
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
                _isPlaying
                    ? 'assets/images/my/playing.png'
                    : 'assets/images/my/pause.png',
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


