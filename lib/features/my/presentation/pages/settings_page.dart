import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../../../core/widgets/custom_toggle.dart';

/// 설정 페이지
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotification = true; // 푸시 알림 (기본 켜짐)
  bool _flightModeNotification = false; // 비행 모드 알림 (기본 꺼짐)

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
          '설정',
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

              // 알림 섹션 제목
              Text(
                '알림',
                style: AppTextStyles.medium.copyWith(color: AppColors.white),
              ),

              SizedBox(height: context.h(16)),

              // 알림 설정 박스
              Container(
                width: context.w(335),
                padding: EdgeInsets.all(context.w(20)),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.w(14)),
                ),
                child: Column(
                  children: [
                    // 푸시 알림
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '푸시 알림',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        CustomToggle(
                          value: _pushNotification,
                          onChanged: (value) {
                            setState(() {
                              _pushNotification = value;
                            });
                          },
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

                    // 비행 모드 알림
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '비행 모드 알림',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        CustomToggle(
                          value: _flightModeNotification,
                          onChanged: (value) {
                            setState(() {
                              _flightModeNotification = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.h(13)),

              // 약관 및 정책 섹션 제목
              Text(
                '약관 및 정책',
                style: AppTextStyles.medium.copyWith(color: AppColors.white),
              ),

              SizedBox(height: context.h(13)),

              // 약관 및 정책 박스
              Container(
                width: context.w(335),
                padding: EdgeInsets.all(context.w(20)),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.w(14)),
                ),
                child: Column(
                  children: [
                    // 개인정보처리방침
                    GestureDetector(
                      onTap: () {
                        // TODO: 개인정보처리방침 페이지로 이동
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '개인정보처리방침',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
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

                    // 이용 약관
                    GestureDetector(
                      onTap: () {
                        // TODO: 이용 약관 페이지로 이동
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '이용 약관',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

