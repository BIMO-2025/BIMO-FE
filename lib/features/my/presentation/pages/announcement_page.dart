import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_extensions.dart';

/// 공지사항 페이지
class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  // 확장된 항목 추적 (여러 개 동시 펼치기 가능)
  final Set<int> _expandedIndices = {};

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
          '공지사항',
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

              // 공지사항 아이템들
              _buildAnnouncementItem(
                context,
                index: 0,
                title: 'BIMO에 오신 것을 환영합니다!',
                date: '2024.11.09.',
                time: '23:09',
                content: "안녕하세요! 세상엔 없던 비행기 모드 \"BIMO\"를 찾아주셔서 감사합니다.\n\nBIMO는 장거리 비행을 위한 '스마트 비행 동반자'입니다. 신뢰할 수 있는 항공사 리뷰 탐색부터, AI 기반의 시차 적응 플랜, 오프라인 콘텐츠까지.\n\nBIMO와 함께 '잃어버린 하루'를 되찾고 완벽한 여정을 경험하세요!",
              ),
              SizedBox(height: context.h(4)),
              _buildAnnouncementItem(
                context,
                index: 1,
                title: '새로운 기능이 추가되었습니다',
                date: '2024.11.05.',
                time: '14:30',
                content: "BIMO에 새로운 기능이 추가되었습니다. 이제 더욱 편리하게 이용하실 수 있습니다.",
              ),
              SizedBox(height: context.h(4)),
              _buildAnnouncementItem(
                context,
                index: 2,
                title: '시스템 점검 안내',
                date: '2024.11.01.',
                time: '10:00',
                content: "시스템 점검으로 인해 일시적으로 서비스 이용이 제한될 수 있습니다.",
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 공지사항 아이템 위젯
  Widget _buildAnnouncementItem(
    BuildContext context, {
    required int index,
    required String title,
    required String date,
    required String time,
    String? content,
  }) {
    final isExpanded = _expandedIndices.contains(index);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedIndices.remove(index);
          } else {
            _expandedIndices.add(index);
          }
        });
      },
      child: Container(
        width: context.w(335),
        padding: EdgeInsets.only(
          top: context.h(15),
          left: context.w(20),
          right: context.w(20),
          bottom: context.h(15),
        ),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(context.w(14)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 (제목 + 날짜/시간 + 화살표)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목
                      Text(
                        title,
                        style: AppTextStyles.bigBody.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: context.h(4)),
                      // 날짜 및 시간
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: date,
                              style: AppTextStyles.smallBody.copyWith(
                                color: AppColors.white.withOpacity(0.5),
                              ),
                            ),
                            TextSpan(
                              text: '  $time',
                              style: AppTextStyles.smallBody.copyWith(
                                color: AppColors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // 화살표 아이콘 (펼쳐졌을 때 숨김)
                if (!isExpanded) ...[
                  SizedBox(width: context.w(8)),
                  Image.asset(
                    'assets/images/my/right arrow.png',
                    width: context.w(24),
                    height: context.h(24),
                    fit: BoxFit.contain,
                  ),
                ],
              ],
            ),

            // 본문 영역 (펼쳐졌을 때만 표시)
            if (isExpanded && content != null) ...[
              SizedBox(height: context.h(15)), // 날짜 아래 15px

              // 구분선
              Container(
                width: context.w(335),
                height: 1,
                color: AppColors.white.withOpacity(0.1),
              ),

              SizedBox(height: context.h(15)), // 선 아래 15px

              // 본문 텍스트
              Padding(
                padding: EdgeInsets.only(
                  left: context.w(10),
                  right: context.w(10),
                  bottom: context.h(15),
                ),
                child: Text(
                  content,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
