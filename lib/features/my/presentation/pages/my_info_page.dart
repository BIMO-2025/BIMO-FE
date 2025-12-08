import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_extensions.dart';
import 'nickname_edit_page.dart';

/// 내 정보 페이지
class MyInfoPage extends StatelessWidget {
  const MyInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131313),
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: context.w(60),
        leading: Padding(
          padding: EdgeInsets.only(left: context.w(20)),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: SizedBox(
              width: context.w(40),
              height: context.h(40),
              child: Image.asset(
                'assets/images/search/back_arrow_icon.png',
                width: context.w(40),
                height: context.h(40),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        title: Text(
          '내 정보',
          style: AppTextStyles.large.copyWith(color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: context.h(16)),

              // 사용자 정보 박스
              Container(
                width: context.w(335),
                padding: EdgeInsets.all(context.w(20)),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.w(14)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 닉네임
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '닉네임',
                          style: AppTextStyles.bigBody.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(width: context.w(4)),
                        Text(
                          '여행조아',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.white.withOpacity(0.8),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NicknameEditPage(),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.w(12),
                              vertical: context.h(6),
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              '변경하기',
                              style: AppTextStyles.smallBody.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: context.h(10)),

                    // 구분선
                    Center(
                      child: Container(
                        width: context.w(295),
                        height: 1,
                        color: AppColors.white.withOpacity(0.1),
                      ),
                    ),

                    SizedBox(height: context.h(10)),

                    // 연결된 SNS 계정
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '연결된 SNS 계정',
                          style: AppTextStyles.bigBody.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(width: context.w(4)),
                        Text(
                          '카카오톡',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.white.withOpacity(0.8),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            // TODO: 로그아웃 기능 구현
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.w(12),
                              vertical: context.h(6),
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              '로그아웃',
                              style: AppTextStyles.smallBody.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: context.h(10)),

                    // 구분선
                    Center(
                      child: Container(
                        width: context.w(295),
                        height: 1,
                        color: AppColors.white.withOpacity(0.1),
                      ),
                    ),

                    SizedBox(height: context.h(10)),

                    // 이메일
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '이메일',
                          style: AppTextStyles.bigBody.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'hyerim6215@kakao.com',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.h(16)),

              // BIMO 탈퇴하기 버튼
              Center(
                child: GestureDetector(
                  onTap: () {
                    // TODO: 탈퇴하기 기능 구현
                  },
                  child: Text(
                    'BIMO 탈퇴하기',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
