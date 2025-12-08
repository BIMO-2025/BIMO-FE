import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_extensions.dart';

/// 티켓 인증 팝업 (카메라 진입 전)
class TicketVerificationDialog extends StatelessWidget {
  const TicketVerificationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 배경 (흐릿한 효과)
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ),
        
        // 닫기 버튼 (오른쪽 위)
        Positioned(
          top: context.h(21) + MediaQuery.of(context).padding.top,
          right: context.w(20),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
        
        // 중앙 컨텐츠
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 티켓 아이콘
              Container(
                width: context.w(100),
                height: context.h(100),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Icon(
                    Icons.airline_seat_recline_normal,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              
              SizedBox(height: context.h(24)),
              
              // 안내 텍스트
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(40)),
                child: Text(
                  '탑승을 인증하기 위해,\n탑승권(실물 또는 모바일)을\n촬영해 주세요.',
                  style: AppTextStyles.bigBody.copyWith(
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// 티켓 인증 다이얼로그 표시
  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (context) => const TicketVerificationDialog(),
    );
  }
}
