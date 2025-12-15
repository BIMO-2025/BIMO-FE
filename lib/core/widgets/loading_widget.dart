import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

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
    // 원형 경로의 반지름 (CircularProgressIndicator의 실제 반지름)
    const double circleRadius = 33.0;
    // 컨테이너 크기 (원형 경로 + 비행기 아이콘 크기 고려)
    const double containerSize = (circleRadius + airplaneSize / 2) * 2;

    return SizedBox(
      width: containerSize,
      height: containerSize,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 원형 테두리 (회색, stroke만)
          SizedBox(
            width: circleRadius * 2,
            height: circleRadius * 2,
            child: CircularProgressIndicator(
              value: 0.75, // 270도 (3/4 원)
              strokeWidth: 2,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF999999), // 회색
              ),
            ),
          ),
          // 회전하는 비행기 아이콘
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              final angle = _rotationController.value * 2 * 3.141592653589793;
              final x = circleRadius * (1 - (angle / (2 * 3.141592653589793)).cos());
              final y = circleRadius * (angle / (2 * 3.141592653589793)).sin();

              return Transform.translate(
                offset: Offset(x, y),
                child: Transform.rotate(
                  angle: angle + 3.141592653589793 / 2,
                  child: Container(
                    width: airplaneSize,
                    height: airplaneSize,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.airplanemode_active,
                      size: 20,
                      color: Colors.black,
                    ),
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
