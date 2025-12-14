import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_extensions.dart';

/// FAQ 페이지
class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
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
          'FAQ',
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

              // 비행 플랜 섹션
              _buildSectionTitle('비행 플랜'),
              SizedBox(height: context.h(13)),
              _buildFaqItem(
                0,
                "BIMO의 '비행 플랜'은 어떻게 생성되나요?",
                answer: "BIMO는 회원님이 입력하신 비행 정보, 평소 수면 패턴, 그리고 선택하신 비행 목표(시차 적응 등)를 종합하여, AI가 최적의 스케줄을 자동으로 생성해 드립니다.",
              ),
              SizedBox(height: context.h(4)),
              _buildFaqItem(
                1,
                "'앵커 수면'이 무엇인가요?",
                answer: "앵커 수면은 시차 적응을 돕기 위한 핵심 수면 시간대입니다. 일정한 시간에 짧은 수면을 취함으로써 생체 리듬을 안정적으로 유지할 수 있습니다.",
              ),
              SizedBox(height: context.h(4)),
              _buildFaqItem(
                2,
                "비행이 지연되면 플랜은 어떻게 되나요?",
                answer: "비행이 지연되더라도 플랜은 자동으로 업데이트됩니다. 새로운 출발/도착 시간에 맞춰 최적화된 스케줄을 다시 제공해 드립니다.\n\n만약 업데이트가 되지 않았다면 밀린 시간만큼 수동으로 입력할 수 있습니다. 그러면 자동으로 밀려서 다시 타임라인이 적용됩니다.",
              ),

              SizedBox(height: context.h(13)),

              // 항공사 리뷰 섹션
              _buildSectionTitle('항공사 리뷰'),
              SizedBox(height: context.h(13)),
              _buildFaqItem(
                3,
                "리뷰의 신뢰도를 어떻게 보장하나요?",
                answer: "실제 탑승권을 인증한 사용자만 리뷰를 작성할 수 있으며, AI가 부적절하거나 허위 리뷰를 자동으로 필터링합니다.",
              ),
              SizedBox(height: context.h(4)),
              _buildFaqItem(
                4,
                "'AI 리뷰 요약'은 무엇인가요?",
                answer: "수백 개의 리뷰를 AI가 분석하여 핵심 내용을 요약해 드립니다. 빠르게 항공사의 장단점을 파악할 수 있습니다.",
              ),

              SizedBox(height: context.h(13)),

              // 오프라인 콘텐츠 섹션
              _buildSectionTitle('오프라인 콘텐츠'),
              SizedBox(height: context.h(13)),
              _buildFaqItem(
                5,
                "'기본 콘텐츠'가 무엇인가요?",
                answer: "다운로드 없이 비행기 모드에서도 이용할 수 있는 기본 콘텐츠입니다. 집중, 수면, 자연 사운드 등이 포함됩니다.",
              ),
              SizedBox(height: context.h(4)),
              _buildFaqItem(
                6,
                "저장된 플랜은 언제 삭제 되나요?",
                answer: "비행이 종료되면 자동으로 삭제됩니다.",
              ),

              SizedBox(height: context.h(50)), // 하단 여백
            ],
          ),
        ),
      ),
    );
  }

  /// 섹션 제목 위젯
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.medium.copyWith(color: AppColors.white),
    );
  }

  /// FAQ 아이템 위젯 (아코디언)
  Widget _buildFaqItem(int index, String question, {String? answer}) {
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
        padding: EdgeInsets.all(context.w(20)),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(context.w(14)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 질문 영역
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
                SizedBox(width: context.w(8)),
                Image.asset(
                  isExpanded
                      ? 'assets/images/my/chevron_up.png'
                      : 'assets/images/my/chevron_down.png',
                  width: context.w(18),
                  height: context.h(18),
                  fit: BoxFit.contain,
                ),
              ],
            ),

            // 답변 영역 (펼쳐졌을 때만 표시)
            if (isExpanded && answer != null) ...[
              SizedBox(height: context.h(20)), // 질문 아래 20px

              Container(
                padding: EdgeInsets.all(context.w(20)),
                decoration: BoxDecoration(
                  color: Colors.black, // 앱컬러 블랙
                  borderRadius: BorderRadius.circular(context.w(14)),
                ),
                child: Text(
                  answer,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.white.withOpacity(0.8), // FFFFFF 80%
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

