import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboarding & login/bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // 메인 컨텐츠
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 170), // 스테이터스 바 아래 170px

                // 로고 그룹 (스플래시와 동일)
                _buildLogoGroup(),

                const Spacer(), // 배지+버튼을 하단으로 보내기

                // 소셜 로그인 버튼들 (배지 포함)
                _buildSocialLoginButtons(),

                const SizedBox(height: 36), // 하단 여백
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 로고 그룹 (스플래시와 동일)
  Widget _buildLogoGroup() {
    return SizedBox(
      width: 146,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 로고 이미지 (박스 없이)
          Image.asset(
            'assets/images/onboarding & login/bimo_logo_on.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),

          const SizedBox(height: 24),

          // 텍스트 섹션
          Column(
            children: [
              // "세상에 없던 비행기 모드"
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: -0.32,
                    color: Color(0xFFFFFFFF),
                  ),
                  children: [
                    const TextSpan(text: '세상에 없던 비'),
                    TextSpan(
                      text: '행기',
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.5),
                      ),
                    ),
                    const TextSpan(text: ' 모'),
                    TextSpan(
                      text: '드',
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.5),
                      ),
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
          ),
        ],
      ),
    );
  }

  /// "3초만에 빠른 회원가입" 배지
  Widget _buildQuickSignupBadge() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '⚡️',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 6),
              Text(
                '3초만에 빠른 회원가입',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  color: AppColors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 소셜 로그인 버튼들
  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        // "3초만에 빠른 회원가입" 배지
        _buildQuickSignupBadge(),
        
        const SizedBox(height: 24), // 배지와 버튼 사이 24px
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Apple 로그인 (특별 처리: Apple만 bold)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Apple 로그인
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1A1A1A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/onboarding & login/apple_logo.png',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 8),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 15,
                            letterSpacing: -0.3,
                            color: Color(0xFF1A1A1A),
                          ),
                          children: [
                            TextSpan(
                              text: 'Apple',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: '로 계속하기',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Google 로그인
              _buildLoginButton(
                icon: 'assets/images/onboarding & login/google_logo.png',
                text: '구글로 계속하기',
                backgroundColor: Colors.white,
                textColor: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500,
                onPressed: () {
                  // TODO: Google 로그인
                },
              ),

              const SizedBox(height: 8),

              // Kakao 로그인
              _buildLoginButton(
                icon: 'assets/images/onboarding & login/kakao_logo.png',
                text: '카카오로 계속하기',
                backgroundColor: const Color(0xFFFEE500),
                textColor: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500,
                onPressed: () {
                  // TODO: Kakao 로그인
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 로그인 버튼 위젯
  Widget _buildLoginButton({
    required String icon,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required FontWeight fontWeight,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 15,
                fontWeight: fontWeight,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
