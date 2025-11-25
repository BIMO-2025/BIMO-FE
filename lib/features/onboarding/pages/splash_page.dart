import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import 'onboarding_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _isLogoOn = false;

  @override
  void initState() {
    super.initState();
    _startLogoAnimation();
    _navigateToNext();
  }

  Future<void> _startLogoAnimation() async {
    // 0.5초 후에 로고 켜기
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isLogoOn = true;
      });
    }
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboarding & login/bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // 배경 데코레이션 벡터들
          _buildBackgroundDecorations(),

          // 중앙 컨텐츠
          Center(
            child: SizedBox(
              width: 146,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 로고 컨테이너 (120x120)
                  _buildLogoContainer(),

                  const SizedBox(height: 24),

                  // 텍스트 섹션
                  _buildTextSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 배경 데코레이션 벡터
  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        // 오른쪽 하단 벡터
        Positioned(
          right: -62,
          bottom: -57,
          child: Transform.rotate(
            angle: 1.5708, // 90도
            child: Container(
              width: 320,
              height: 299,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.white.withOpacity(0.03),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.8],
                ),
              ),
            ),
          ),
        ),
        // 왼쪽 상단 벡터
        Positioned(
          left: -72,
          top: 109,
          child: Transform.rotate(
            angle: 1.5708, // 90도
            child: Container(
              width: 320,
              height: 299,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.white.withOpacity(0.03),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.8],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 로고 컨테이너 (흰색 라운드 배경 + 토글 애니메이션)
  Widget _buildLogoContainer() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(child: _buildToggleAnimation()),
    );
  }

  /// 토글 애니메이션 (배경색 + 비행기 이동)
  Widget _buildToggleAnimation() {
    return SizedBox(
      width: 77.34,
      height: 37.5,
      child: Stack(
        children: [
          // 토글 배경 (회색 → 파란색)
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            width: 77.34,
            height: 37.5,
            decoration: BoxDecoration(
              color: _isLogoOn ? AppColors.blue1 : const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(18.75),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 7.9,
                  spreadRadius: -3.96,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
          // 비행기 아이콘 (왼쪽 → 오른쪽)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            left: _isLogoOn ? 36 : 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 41.34,
              alignment: Alignment.center,
              child: Image.asset(
                'assets/images/onboarding & login/airplane.png',
                width: 28.69,
                height: 26.84,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 텍스트 섹션 (멘트 + BIMO 타이포로고)
  Widget _buildTextSection() {
    return Column(
      children: [
        // "세상에 없던 비행기 모드" 텍스트
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w600, // SemiBold
              height: 1.2, // 120%
              letterSpacing: -0.32,
              color: Color(0xFFFFFFFF),
            ),
            children: [
              const TextSpan(text: '세상에 없던 비'),
              TextSpan(
                text: '행기',
                style: TextStyle(color: AppColors.white.withOpacity(0.5)),
              ),
              const TextSpan(text: ' 모'),
              TextSpan(
                text: '드',
                style: TextStyle(color: AppColors.white.withOpacity(0.5)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // BIMO 타이포로고
        SvgPicture.asset(
          'assets/images/onboarding & login/TypoLogo.svg',
          width: 110,
          height: 35,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}
