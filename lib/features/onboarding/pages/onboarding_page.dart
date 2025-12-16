import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  
  // Slide Button State
  double _dragValue = 0.0;
  final double _maxWidth = 335.0 - 50.0; // Button Width - Icon Width (approx)

  final List<OnboardingContent> _pages = [
    OnboardingContent(
      title: '비모는 왜 사용해야 하나요?',
      description: '장거리 비행은 단순히 이동이 아닙니다.\n비모와 함께라면 최적의 컨디션으로 목적지에\n도착하는 과정이 됩니다.',
      imagePath: 'assets/images/onboarding_login/onboarding_1.png',
    ),
    OnboardingContent(
      title: '한국인 실사용자 후기',
      description: '항공편명만 입력하면 인증된 탑승객들의\n생생한 기내식 사진, 최적의 좌석 꿀팁을\n미리 확인하고 후회 없는 선택을 도와드립니다.',
      imagePath: 'assets/images/onboarding_login/onboarding_2.png',
    ),
    OnboardingContent(
      title: '하늘 위 스마트 비서',
      description: '맞춤형 최적 비행 타임라인을 제공합니다.\n와이파이 없이도 완벽하게 작동하여\n시차 적응, 휴식, 업무를 스마트하게 관리합니다.',
      imagePath: 'assets/images/onboarding_login/onboarding_3.png',
    ),
    OnboardingContent(
      title: '나의 경험이 곧 새로운 가치',
      description: '나만의 비행을 기록하세요.\n당신의 소중한 후기는 다음 여행자를 돕는\n가장 가치 있는 정보 자산이 됩니다.',
      imagePath: 'assets/images/onboarding_login/onboarding_4.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragValue = (_dragValue + details.delta.dx).clamp(0.0, _maxWidth);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragValue > _maxWidth * 0.7) {
      // Trigger Action (Navigate)
      setState(() {
        _dragValue = _maxWidth;
      });
      // Navigate to next screen
      context.go(RouteNames.login);
      print("Slide Completed!");
    } else {
      // Reset
      setState(() {
        _dragValue = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboarding_login/bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // 메인 컨텐츠 (중앙 정렬)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 420,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildOnboardingContent(_pages[index]);
                    },
                  ),
                ),
                const SizedBox(height: 36),
                _buildPageIndicator(),
              ],
            ),
          ),

          // 시작하기 버튼 (하단 고정)
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: _buildGlassButton(),
          ),
        ],
      ),
    );
  }

  /// 온보딩 컨텐츠
  Widget _buildOnboardingContent(OnboardingContent content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            content.imagePath,
            width: 250,
            height: 250,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          Text(
            content.title,
            style: AppTextStyles.large.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            content.description,
            style: AppTextStyles.body.copyWith(
              color: AppColors.white.withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Page Indicator
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? AppColors.white
                : AppColors.white.withOpacity(0.1),
          ),
        ),
      ),
    );
  }

  /// 아이폰 스타일 유리 효과 버튼 (Slide to Start)
  Widget _buildGlassButton() {
    return Center(
      child: Container(
        width: 335,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(56),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          color: Colors.white.withOpacity(0.05),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(56),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // 텍스트 & 화살표 (Fade Out on Drag)
                Opacity(
                  opacity: (1 - (_dragValue / _maxWidth)).clamp(0.0, 1.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 중앙 텍스트
                      const Center(
                        child: Text(
                          '시작하기',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            height: 1.2,
                            letterSpacing: -0.225,
                          ),
                        ),
                      ),
                      // 오른쪽 화살표
                      Positioned(
                        right: 20,
                        child: Image.asset(
                          'assets/images/onboarding_login/triple_arrow.png',
                          height: 12,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),

                // 슬라이드 아이콘 (비행기)
                Positioned(
                  left: 4 + _dragValue,
                  child: GestureDetector(
                    onHorizontalDragUpdate: _onDragUpdate,
                    onHorizontalDragEnd: _onDragEnd,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/onboarding_login/airplane.png',
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 온보딩 컨텐츠 모델
class OnboardingContent {
  final String title;
  final String description;
  final String imagePath;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}
