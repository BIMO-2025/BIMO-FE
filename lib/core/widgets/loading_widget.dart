import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 공통 로딩 위젯
/// 비행기 아이콘이 원형으로 회전하는 로딩 화면
class LoadingWidget extends StatefulWidget {
  const LoadingWidget({super.key});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.darkTheme.scaffoldBackgroundColor,
      child: Center(
        child: _buildRotatingAirplane(),
      ),
    );
  }

  /// 회전하는 비행기 아이콘 (원형 궤적 따라 이동)
  Widget _buildRotatingAirplane() {
    // 비행기 아이콘 크기 (34x34)
    const double airplaneSize = 34.0;
    // 원형 경로의 반지름
    const double circleRadius = 33.0;
    // 컨테이너 크기
    const double containerSize = (circleRadius + airplaneSize / 2) * 2;

    return SizedBox(
      width: containerSize,
      height: containerSize,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // CircularProgressIndicator로 원형 진행 표시
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return SizedBox(
                width: circleRadius * 2,
                height: circleRadius * 2,
                child: CircularProgressIndicator(
                  value: _rotationController.value,
                  strokeWidth: 2.0,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              );
            },
          ),
          // 비행기 아이콘 (궤적 위에 배치)
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              // 12시 방향에서 시작하여 시계 방향으로 진행
              final startAngle = -math.pi / 2;
              final angle = startAngle + (_rotationController.value * 2 * math.pi);
              final centerX = containerSize / 2;
              final centerY = containerSize / 2;
              
              // 비행기 아이콘 중심 위치 계산
              final x = centerX + circleRadius * math.cos(angle);
              final y = centerY + circleRadius * math.sin(angle);
              
              return Positioned(
                left: x - airplaneSize / 2,
                top: y - airplaneSize / 2,
                child: Transform.rotate(
                  angle: angle + math.pi / 2,
                  child: Image.asset(
                    'assets/images/myflight/airplane.png',
                    width: airplaneSize,
                    height: airplaneSize,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
