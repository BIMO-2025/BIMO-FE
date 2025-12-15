import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/router/route_names.dart';
import '../../../../core/storage/auth_token_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_extensions.dart';
import 'nickname_edit_page.dart';

/// 내 정보 페이지
class MyInfoPage extends StatefulWidget {
  const MyInfoPage({super.key});

  @override
  State<MyInfoPage> createState() => _MyInfoPageState();
}

class _MyInfoPageState extends State<MyInfoPage> {
  String _name = '사용자';
  String _email = '';
  // String _snsProvider = '카카오톡'; // TODO: 저장된 Provider 정보가 있다면 로드

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final storage = AuthTokenStorage();
    final userInfo = await storage.getUserInfo();

    if (mounted) {
      setState(() {
        _name = userInfo['name'] ?? '사용자';
        _email = userInfo['email'] ?? '';
      });
    }
  }

  Future<void> _logout() async {
    // 1. 저장소에서 토큰/정보 삭제
    final storage = AuthTokenStorage();
    await storage.deleteAllTokens();

    if (!mounted) return;
    
    // 2. 로그인 화면으로 이동 (스택 초기화)
    context.go(RouteNames.login);
  }

  void _showLogoutModal(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5), // 뒷 배경 검정 50%
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: context.w(20)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: context.w(320),
                padding: EdgeInsets.only(
                  top: 0,
                  right: context.w(20),
                  bottom: context.w(20),
                  left: context.w(20),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A), // #1A1A1A
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1), // 흰색 10%
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 헤더 영역
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(
                        top: context.h(20),
                        bottom: context.h(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 제목
                          Text(
                            '로그아웃',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: context.fs(19),
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: context.h(10)),
                          // 본문
                          Padding(
                            padding: EdgeInsets.only(
                              left: context.w(14),
                              right: context.w(14),
                              top: context.h(10),
                            ),
                            child: Text(
                              '로그아웃하면 서비스를 사용할 수 없어요.\n계속하시겠어요?',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: context.fs(15),
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.h(16)),
                    // 버튼들
                    Row(
                      children: [
                        // 로그아웃 버튼 (삭제 스타일: 회색)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              _logout(); // 로그아웃 실행
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: context.h(16),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  '로그아웃',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: context.fs(16),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: context.w(16)),
                        // 취소 버튼 (강조 스타일: 파란색)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: context.h(16),
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF007AFF), // AppColors.blue1
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  '취소',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: context.fs(16),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

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
                          _name,
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
                                builder: (context) => NicknameEditPage(
                                  currentNickname: _name,
                                ),
                              ),
                            ).then((_) {
                                // 닉네임 변경 후 돌아왔을 때 갱신
                                _loadUserInfo();
                            });
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
                          '로그인 계정', // 식별이 어려우므로 일반 텍스트로
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.white.withOpacity(0.8),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _showLogoutModal(context), // 팝업 연결
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
                          _email,
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
