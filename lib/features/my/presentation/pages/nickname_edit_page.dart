import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/network/api/user_api_service.dart';
import '../../../../core/storage/auth_token_storage.dart';

/// 닉네임 변경 페이지
/// 닉네임 변경 페이지
class NicknameEditPage extends StatefulWidget {
  final String currentNickname;

  const NicknameEditPage({
    super.key,
    this.currentNickname = '', // 기본값
  });

  @override
  State<NicknameEditPage> createState() => _NicknameEditPageState();
}

class _NicknameEditPageState extends State<NicknameEditPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final UserApiService _userApiService = UserApiService(); // API 서비스
  final AuthTokenStorage _tokenStorage = AuthTokenStorage(); // 저장소

  bool _hasText = false;
  bool _isDuplicate = false; // 닉네임 중복 여부
  bool _isSaving = false; // 저장 중 상태
  final List<String> _existingNicknames = ['유자']; // TODO: 백엔드에서 가져올 기존 닉네임 리스트
  late String _originalNickname; // 기존 닉네임

  @override
  void initState() {
    super.initState();
    _originalNickname = widget.currentNickname;
    _nicknameController.text = _originalNickname;
    _hasText = _nicknameController.text.isNotEmpty;

    // 텍스트 변경 리스너 추가
    _nicknameController.addListener(() {
      setState(() {
        final inputNickname = _nicknameController.text.trim();
        _hasText = inputNickname.isNotEmpty;
        
        // 실시간 중복 검사
        if (inputNickname == _originalNickname) {
          _isDuplicate = false; // 본인 닉네임이면 중복 아님
        } else {
          _isDuplicate = _existingNicknames.contains(inputNickname);
        }
      });
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _saveNickname() async {
    final newNickname = _nicknameController.text.trim();
    if (newNickname.isEmpty || newNickname == _originalNickname) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // 1. API 호출
      final response = await _userApiService.updateNickname(newNickname);
      
      // 2. 성공 시 로컬 저장소 업데이트
      // 응답 구조: { success: true, user: { display_name: "새닉네임", ... } }
      if (response['success'] == true) {
        final user = response['user'] as Map<String, dynamic>;
        final updatedNickname = user['display_name'] as String?;
        
        if (updatedNickname != null) {
          await _tokenStorage.saveUserInfo(name: updatedNickname);
        }
        
        if (!mounted) return;
        Navigator.pop(context); // 페이지 닫기 (MyInfoPage로 돌아감)
      } else {
        throw Exception(response['message'] ?? '닉네임 변경에 실패했습니다.');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
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
          '닉네임 변경',
          style: AppTextStyles.large.copyWith(color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.w(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: context.h(13)),

                  // 닉네임 라벨
                  Text(
                    '닉네임',
                    style: AppTextStyles.medium.copyWith(color: AppColors.white),
                  ),

                  SizedBox(height: context.h(13)),

                  // 닉네임 입력 박스
                  Container(
                    width: context.w(335),
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
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.white,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              hintText: '닉네임을 변경해주세요.',
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
                            onTap:
                                _hasText
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

                  // 버튼 위 여백
                  SizedBox(height: context.h(450)),

                  // 저장하기 버튼
                  PrimaryButton(
                    text: '저장하기',
                    isEnabled: _isButtonEnabled() && !_isSaving,
                    onTap: _saveNickname,
                  ),

                  // 버튼 아래 여백 (하단 인디케이터 고려)
                  SizedBox(
                    height: Responsive.bottomSafeArea(context) + context.h(36),
                  ),
                ],
              ),
            ),
          ),
          
          // 로딩 인디케이터
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.white),
              ),
            ),
        ],
      ),
    );
  }

  /// 저장 버튼 활성화 조건
  bool _isButtonEnabled() {
    final currentNickname = _nicknameController.text.trim();
    return currentNickname.isNotEmpty &&
        !_isDuplicate &&
        currentNickname != _originalNickname;
  }
}
