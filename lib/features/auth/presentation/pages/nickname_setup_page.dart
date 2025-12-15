import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/network/services/user_service.dart';
import '../../../../core/network/router/app_router.dart';
import '../../../../core/network/router/route_names.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/storage/auth_token_storage.dart';

/// 회원가입 후 닉네임 설정 페이지
class NicknameSetupPage extends StatefulWidget {
  final String userId;
  final String? prefillNickname;
  
  const NicknameSetupPage({
    super.key, 
    required this.userId,
    this.prefillNickname,
  });

  @override
  State<NicknameSetupPage> createState() => _NicknameSetupPageState();
}

class _NicknameSetupPageState extends State<NicknameSetupPage> {
  late final TextEditingController _nicknameController;
  final UserService _userService = UserService();
  
  bool _hasText = false;
  bool _isDuplicate = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.prefillNickname);
    _hasText = _nicknameController.text.isNotEmpty;
    
    // 텍스트 변경 리스너 추가
    _nicknameController.addListener(() {
      setState(() {
        _hasText = _nicknameController.text.isNotEmpty;
        _isDuplicate = false; // 입력 변경 시 중복 상태 초기화
      });
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _checkNicknameAndSave() async {
    if (_isLoading) return;
    
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) return;

    setState(() {
      _isLoading = true;
      _isDuplicate = false;
    });

    try {
      // 닉네임 업데이트
      final success = await _userService.updateNickname(widget.userId, nickname);
      
      if (success && mounted) {
        print('✅ 닉네임 설정 완료: $nickname');
        // 닉네임 설정 성공 시 로컬 저장소에도 이름 저장 (완료 마킹)
        final storage = AuthTokenStorage();
        await storage.saveUserInfo(name: nickname);
            
        // 수면 패턴 설정 페이지로 이동
        context.go(RouteNames.sleepPattern);
      } else if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('닉네임 설정에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      print('❌ 닉네임 설정 오류: $e');
       if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('오류가 발생했습니다: $e')),
           );
        }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131313),
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false, // 백버튼 숨김 (필수 과정)
        title: Text(
          '닉네임 설정',
          style: AppTextStyles.large.copyWith(color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.w(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: context.h(20)),
          
                        // 닉네임 라벨 (안내 문구 제거됨)
                        Text(
                          '닉네임',
                          style: AppTextStyles.medium.copyWith(color: AppColors.white),
                        ),
          
                        SizedBox(height: context.h(13)),
          
                        // 닉네임 입력 박스
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: context.w(20),
                            vertical: context.h(20),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(context.w(14)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _nicknameController,
                                  autofocus: true, // 키보드 자동 올림
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.white,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    hintText: '비모에서 사용할 닉네임을 입력해주세요',
                                    hintStyle: AppTextStyles.body.copyWith(
                                      color: AppColors.white.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: context.w(8)),
                              Opacity(
                                opacity: _hasText ? 1.0 : 0.0,
                                child: GestureDetector(
                                  onTap: _hasText
                                      ? () {
                                          _nicknameController.clear();
                                        }
                                      : null,
                                  child: Image.asset(
                                    'assets/images/my/clear.png',
                                    width: context.w(24),
                                    height: context.h(24),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
          
                        // 중복 에러 메시지
                        if (_isDuplicate) ...[
                          SizedBox(height: context.h(4)),
                          Padding(
                            padding: EdgeInsets.only(left: context.w(13)),
                            child: Text(
                              '이미 사용 중인 닉네임입니다.',
                              style: AppTextStyles.smallBody.copyWith(
                                color: AppColors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              
              // 시작하기 버튼 (키보드 위로 올라오도록 처리)
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: context.w(20), 
                    right: context.w(20), 
                    bottom: context.h(10)
                  ),
                  child: PrimaryButton(
                    text: '비모 시작하기',
                    isEnabled: _hasText && !_isLoading,
                    onTap: _checkNicknameAndSave,
                  ),
                ),
              ),
            ],
          ),
          
          // 로딩 인디케이터 (전체 화면)
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
