import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/primary_button.dart';

/// 수면 패턴 설정 페이지
class SleepPatternPage extends StatefulWidget {
  const SleepPatternPage({super.key});

  @override
  State<SleepPatternPage> createState() => _SleepPatternPageState();
}

class _SleepPatternPageState extends State<SleepPatternPage> {
  // 선택된 탭 (0: 취침 시간, 1: 기상 시간)
  int _selectedTab = 0;

  // 취침 시간
  int _bedtimeHour = 23;
  int _bedtimeMinute = 0;

  // 기상 시간
  int _wakeupHour = 6;
  int _wakeupMinute = 0;

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
          '수면 패턴 설정',
          style: AppTextStyles.large.copyWith(color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: context.w(20),
            right: context.w(20),
            top: context.h(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              Text(
                '완벽한\n여정의 첫 걸음',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: context.fs(24),
                  fontWeight: FontWeight.w700, // Bold
                  height: 1.2, // 120%
                  letterSpacing: -0.48, // -2% of 24
                  color: AppColors.white,
                ),
              ),

              SizedBox(height: context.h(16)),

              // 설명
              Text(
                'BIMO가 회원님의 평소 수면 패턴에 맞춰\n최적의 비행을 준비할게요.',
                style: AppTextStyles.body.copyWith(color: AppColors.white),
              ),

              SizedBox(height: context.h(48)),

              // 수면 패턴 선택 박스 (탭 + 피커)
              _buildSleepPatternBox(context),

              SizedBox(height: context.h(32)),

              // 수정하기 버튼
              PrimaryButton(
                text: '수정하기',
                isEnabled: true,
                onTap: () {
                  // TODO: 수면 패턴 저장 로직
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '취침 시간: ${_bedtimeHour.toString().padLeft(2, '0')}:${_bedtimeMinute.toString().padLeft(2, '0')}\n'
                        '기상 시간: ${_wakeupHour.toString().padLeft(2, '0')}:${_wakeupMinute.toString().padLeft(2, '0')}',
                      ),
                    ),
                  );
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

  /// 수면 패턴 선택 박스 (탭 + 피커)
  Widget _buildSleepPatternBox(BuildContext context) {
    return Container(
      width: context.w(335),
      height: context.h(300),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.w(30)),
      ),
      child: Column(
        children: [
          SizedBox(height: context.h(18)),

          // 탭 선택 (취침 시간 / 기상 시간)
          Center(
            child: Container(
              width: context.w(280),
              height: context.h(45),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(context.w(14)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTab = 0;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              _selectedTab == 0
                                  ? AppColors.white.withOpacity(0.1)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(context.w(14)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '취침 시간',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: context.fs(15),
                            fontWeight: FontWeight.w600, // 세미볼드
                            height: 1.2, // 120%
                            letterSpacing: -0.225, // -1.5% of 15
                            color:
                                _selectedTab == 0
                                    ? AppColors.white
                                    : AppColors.white.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTab = 1;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              _selectedTab == 1
                                  ? AppColors.white.withOpacity(0.1)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(context.w(14)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '기상 시간',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: context.fs(15),
                            fontWeight: FontWeight.w600, // 세미볼드
                            height: 1.2, // 120%
                            letterSpacing: -0.225, // -1.5% of 15
                            color:
                                _selectedTab == 1
                                    ? AppColors.white
                                    : AppColors.white.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: context.h(16)),

          // 시간 피커
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 피커
                  _buildTimePicker(context),
                  // 선택 영역 박스 (중앙)
                  IgnorePointer(
                    child: Container(
                      width: context.w(280),
                      height: context.h(44),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.white.withOpacity(0.1),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(context.w(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: context.h(20)),
        ],
      ),
    );
  }

  /// 시간 피커
  Widget _buildTimePicker(BuildContext context) {
    final currentHour = _selectedTab == 0 ? _bedtimeHour : _wakeupHour;
    final currentMinute = _selectedTab == 0 ? _bedtimeMinute : _wakeupMinute;

    return Row(
      children: [
        // 시간 선택
        Expanded(
          child: CupertinoPicker(
            scrollController: FixedExtentScrollController(
              initialItem: currentHour,
            ),
            itemExtent: 44,
            backgroundColor: Colors.transparent,
            onSelectedItemChanged: (int index) {
              setState(() {
                if (_selectedTab == 0) {
                  _bedtimeHour = index;
                } else {
                  _wakeupHour = index;
                }
              });
            },
            children: List.generate(24, (index) {
              return Center(
                child: Text(
                  '${index.toString().padLeft(2, '0')} 시',
                  style: AppTextStyles.large.copyWith(color: AppColors.white),
                ),
              );
            }),
          ),
        ),
        // 분 선택
        Expanded(
          child: CupertinoPicker(
            scrollController: FixedExtentScrollController(
              initialItem: currentMinute ~/ 5,
            ),
            itemExtent: 44,
            backgroundColor: Colors.transparent,
            onSelectedItemChanged: (int index) {
              setState(() {
                if (_selectedTab == 0) {
                  _bedtimeMinute = index * 5;
                } else {
                  _wakeupMinute = index * 5;
                }
              });
            },
            children: List.generate(12, (index) {
              final minute = index * 5;
              return Center(
                child: Text(
                  '${minute.toString().padLeft(2, '0')} 분',
                  style: AppTextStyles.large.copyWith(color: AppColors.white),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
