import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/router/route_names.dart';
import '../../../../core/storage/auth_token_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_extensions.dart';
import 'nickname_edit_page.dart';
import 'sleep_pattern_page.dart';

import '../../data/repositories/user_repository_impl.dart';

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
  
  TimeOfDay? _sleepStart;
  TimeOfDay? _sleepEnd;
  final _userRepository = UserRepositoryImpl();

  Future<void> _saveSleepPattern() async {
    if (_sleepStart == null || _sleepEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('취침 시간과 기상 시간을 모두 선택해주세요.')),
      );
      return;
    }

    try {
      final startStr = '${_sleepStart!.hour.toString().padLeft(2, '0')}:${_sleepStart!.minute.toString().padLeft(2, '0')}';
      final endStr = '${_sleepEnd!.hour.toString().padLeft(2, '0')}:${_sleepEnd!.minute.toString().padLeft(2, '0')}';

      final storage = AuthTokenStorage();
      final userInfo = await storage.getUserInfo();
      final userId = userInfo['userId'];

      if (userId == null || userId.isEmpty) {
        throw Exception('사용자 ID를 찾을 수 없습니다.');
      }

      await _userRepository.updateSleepPattern(
        userId: userId,
        sleepPatternStart: startStr,
        sleepPatternEnd: endStr,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('수면 패턴이 저장되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    }
  }

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

    // API에서 최신 정보(수면 패턴 포함) 조회
    try {
      final profile = await _userRepository.getUserProfile();
      if (mounted) {
        setState(() {
          // 이름/이메일 최신화
          if (profile['name'] != null) _name = profile['name'];
          if (profile['email'] != null) _email = profile['email'];

          // 수면 패턴 설정
          if (profile['sleepPatternStart'] != null) {
            final parts = (profile['sleepPatternStart'] as String).split(':');
            if (parts.length == 2) {
              _sleepStart = TimeOfDay(
                hour: int.parse(parts[0]),
                minute: int.parse(parts[1]),
              );
            }
          }
          if (profile['sleepPatternEnd'] != null) {
            final parts = (profile['sleepPatternEnd'] as String).split(':');
            if (parts.length == 2) {
              _sleepEnd = TimeOfDay(
                hour: int.parse(parts[0]),
                minute: int.parse(parts[1]),
              );
            }
          }
        });
      }
    } catch (e) {
      print('프로필 로드 실패: $e');
    }
  }

  Future<void> _logout() async {
    try {
      // 1. 백엔드 로그아웃 API 호출
      final response = await _userRepository.logout();
      print('✅ 로그아웃 API 호출 성공: $response');
    } catch (e) {
      print('❌ 로그아웃 API 호출 실패: $e');
      // API 실패해도 로컬 토큰은 삭제
    }

    // 2. 저장소에서 토큰/정보 삭제
    final storage = AuthTokenStorage();
    await storage.deleteAllTokens();

    if (!mounted) return;
    
    // 3. 로그인 화면으로 이동 (스택 초기화)
    context.go(RouteNames.login);
  }

  Future<void> _updateSleepPattern(TimeOfDay? start, TimeOfDay? end) async {
    if (start == null || end == null) return;

    try {
      final startStr = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
      final endStr = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';

      final storage = AuthTokenStorage();
      final userInfo = await storage.getUserInfo();
      final userId = userInfo['userId'];

      if (userId == null || userId.isEmpty) {
        throw Exception('사용자 ID를 찾을 수 없습니다.');
      }

      await _userRepository.updateSleepPattern(
        userId: userId,
        sleepPatternStart: startStr,
        sleepPatternEnd: endStr,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('수면 패턴이 저장되었습니다.'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    }
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

  Widget _buildTimeRow(
    String label,
    TimeOfDay? time,
    Function(TimeOfDay) onTimeSelected,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.white.withOpacity(0.8),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () async {
            final pickedTime = await showTimePicker(
              context: context,
              initialTime: time ?? TimeOfDay.now(),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: Color(0xFF007AFF),
                      onPrimary: Colors.white,
                      surface: Color(0xFF1A1A1A),
                      onSurface: Colors.white,
                    ),
                    dialogBackgroundColor: const Color(0xFF1A1A1A),
                  ),
                  child: child!,
                );
              },
            );
            if (pickedTime != null) {
              onTimeSelected(pickedTime);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(12),
              vertical: context.h(8),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.white.withOpacity(0.1),
              ),
            ),
            child: Text(
              time != null
                  ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
                  : '선택',
              style: AppTextStyles.body.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
