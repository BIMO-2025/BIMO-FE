import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive_extensions.dart';

/// 비행 지연 시 출발 시간을 조정하는 모달
class FlightDelayModal extends StatefulWidget {
  final DateTime currentDepartureTime;
  final Function(DateTime) onConfirm;

  const FlightDelayModal({
    super.key,
    required this.currentDepartureTime,
    required this.onConfirm,
  });

  @override
  State<FlightDelayModal> createState() => _FlightDelayModalState();
}

class _FlightDelayModalState extends State<FlightDelayModal> {
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  int get _totalMinutes {
    final hours = int.tryParse(_hoursController.text) ?? 0;
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    return hours * 60 + minutes;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: context.w(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: context.w(335),
            padding: EdgeInsets.all(context.w(20)),
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
                // 제목
                Text(
                  '비행이 지연되었나요?',
                  style: AppTextStyles.large.copyWith(
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: context.h(10)),
                
                // 설명
                Text(
                  '출발 시간을 조정해 주세요',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: context.h(24)),
                
                // 시간 및 분 입력
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 시간 입력
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.w(16),
                        vertical: context.h(12),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '+',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: context.w(8)),
                          SizedBox(
                            width: 40,
                            child: TextField(
                              controller: _hoursController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(width: context.w(8)),
                          Text(
                            '시간',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(width: context.w(12)),
                    
                    // 분 입력
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.w(16),
                        vertical: context.h(12),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '+',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: context.w(8)),
                          SizedBox(
                            width: 40,
                            child: TextField(
                              controller: _minutesController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(width: context.w(8)),
                          Text(
                            '분',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: context.h(24)),
                
                // 버튼들
                Row(
                  children: [
                    // 취소 버튼
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1), // 어두운 배경
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              '취소',
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: context.w(12)),
                    
                    // 확인 버튼
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          final newTime = widget.currentDepartureTime.add(
                            Duration(minutes: _totalMinutes),
                          );
                          widget.onConfirm(newTime);
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.blue1,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              '확인',
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white,
                              ),
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
  }
}
