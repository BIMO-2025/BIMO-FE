import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/primary_button.dart';

/// 닉네임 변경 페이지
class NicknameEditPage extends StatefulWidget {
  const NicknameEditPage({super.key});

  @override
  State<NicknameEditPage> createState() => _NicknameEditPageState();
}

class _NicknameEditPageState extends State<NicknameEditPage> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _hasText = true; // 초기값이 '여행조아'이므로 true
  bool _isDuplicate = false; // 닉네임 중복 여부
  final List<String> _existingNicknames = ['유자']; // TODO: 백엔드에서 가져올 기존 닉네임 리스트
  final String _originalNickname = '여행조아'; // 기존 닉네임

  @override
  void initState() {
    super.initState();
    // TODO: 백엔드에서 현재 닉네임 가져오기
    _nicknameController.text = _originalNickname;

    // 텍스트 변경 리스너 추가
    _nicknameController.addListener(() {
      setState(() {
        _hasText = _nicknameController.text.isNotEmpty;
        // 실시간 중복 검사
        _isDuplicate = _existingNicknames.contains(
          _nicknameController.text.trim(),
        );
      });
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
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
      body: SingleChildScrollView(
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
                isEnabled: _isButtonEnabled(),
                onTap: () {
                  // TODO: 닉네임 변경 API 호출
                  Navigator.pop(context);
                },
              ),

              // 버튼 아래 여백 (하단 인디케이터 고려)
              SizedBox(
                height: Responsive.bottomSafeArea(context) + context.h(36),
              ),
            ],
          ),
        ),
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
