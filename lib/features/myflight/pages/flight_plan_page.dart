import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_extensions.dart';
import '../../../core/utils/responsive.dart';

/// 비행 플랜 페이지
class FlightPlanPage extends StatefulWidget {
  const FlightPlanPage({super.key});

  @override
  State<FlightPlanPage> createState() => _FlightPlanPageState();
}

class _FlightPlanPageState extends State<FlightPlanPage> {
  late List<TimelineEvent> _events;
  TimelineEvent? _selectedEvent; // 선택된 이벤트 (하나만)
  bool _showMoreOptions = false; // 더보기 옵션 메뉴 표시 여부
  late List<TimelineEvent> _initialEvents; // 초기 타임라인 (AI 초기화용)

  @override
  void initState() {
    super.initState();
    _events = _getTimelineEvents();
    _initialEvents = List.from(_events); // 초기 상태 저장
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 본문 영역
            Positioned.fill(child: _buildBody(context)),
            // 헤더
            Positioned(top: 0, left: 0, right: 0, child: _buildHeader(context)),
            // 더보기 옵션 메뉴 오버레이
            if (_showMoreOptions) _buildMoreOptionsOverlay(context),
            // 플로팅 액션 버튼
            Positioned(
              right: context.w(19), // 오른쪽에서 19px
              bottom:
                  context.h(32) +
                  Responsive.homeIndicatorHeight(context), // 하단 인디케이터 위로 32px
              child: _buildFloatingActionButton(context),
            ),
          ],
        ),
      ),
    );
  }

  /// 헤더 (뒤로가기 + 타이틀 + 더보기)
  Widget _buildHeader(BuildContext context) {
    return Container(
      height: context.h(82),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A1A1A), // 위쪽: #1A1A1A (100%)
            Color(0x001A1A1A), // 아래쪽: rgba(26, 26, 26, 0) (0%)
          ],
        ),
      ),
      child: Stack(
        children: [
          // 뒤로가기 버튼 (왼쪽)
          Positioned(
            left: context.w(20),
            top: context.h(21),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Center(
                      child: Image.asset(
                        'assets/images/myflight/back.png',
                        width: 24,
                        height: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 타이틀 (중앙)
          Positioned(
            left: 0,
            right: 0,
            top: context.h(31),
            child: Center(
              child: Text(
                '나의 비행 플랜',
                style: AppTextStyles.large.copyWith(color: Colors.white),
              ),
            ),
          ),
          // 더보기 버튼 (오른쪽)
          Positioned(
            right: context.w(20),
            top: context.h(21),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showMoreOptions = !_showMoreOptions;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Center(
                      child: Image.asset(
                        'assets/images/myflight/more.png',
                        width: 24,
                        height: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 메인 바디 영역
  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: context.w(20),
        right: context.w(20),
        top: context.h(82) + context.h(8), // 헤더 + 간격 8px
        bottom: context.h(100), // 하단 여백
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 비행 정보
          _buildFlightInfo(context),
          const SizedBox(height: 32),
          // 타임라인
          _buildTimeline(context),
        ],
      ),
    );
  }

  /// 비행 정보
  Widget _buildFlightInfo(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // DXB → ICN
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'DXB',
                    style: AppTextStyles.display.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 0),
                  Text(
                    '두바이',
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              SvgPicture.asset(
                'assets/images/myflight/arrow.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'ICN',
                    style: AppTextStyles.display.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 0),
                  Text(
                    '인천',
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 날짜 및 시간
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTextStyles.body.copyWith(color: Colors.white),
              children: [
                const TextSpan(text: '2025.11.25. (토) | '),
                TextSpan(
                  text: '14h 15m',
                  style: AppTextStyles.bigBody.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 타임라인
  Widget _buildTimeline(BuildContext context) {
    final events = _events;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          events.asMap().entries.map((entry) {
            final index = entry.key;
            final event = entry.value;
            final isSelected = _selectedEvent == event;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index < events.length - 1 ? context.h(4) : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: context.h(79), // 총 높이 79px 고정
                    child: Stack(
                      clipBehavior: Clip.none, // 원이 잘리지 않도록
                      children: [
                        // 타임라인 원과 선 (왼쪽)
                        Positioned(
                          left: 0,
                          top: 0,
                          child: SizedBox(
                            width: context.w(13),
                            height: context.h(79),
                            child: CustomPaint(
                              painter: TimelineLinePainter(
                                circleSize: context.w(13),
                                lineStartOffset: context.h(
                                  13 + 8,
                                ), // 원(13) + 간격(8)
                                lineEndOffset: context.h(
                                  79 - 8,
                                ), // 총 높이(79) - 박스 하단 여백(8)
                                isActive: event.isActive, // 새로 추가된 이벤트만 파란색
                                isEditable: event.isEditable,
                              ),
                            ),
                          ),
                        ),
                        // 이벤트 카드 (오른쪽)
                        Positioned(
                          left: context.w(13 + 16), // 원(13) + 간격(16)
                          top: 0,
                          child: _buildTimelineEvent(
                            context,
                            event,
                            isSelected,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 선택된 카드 아래에 버튼 표시
                  if (isSelected)
                    Padding(
                      padding: EdgeInsets.only(
                        top: 0, // 위 간격 0
                        bottom: context.h(8), // 아래 간격 8px
                      ),
                      child: _buildActionButtons(context, event),
                    ),
                ],
              ),
            );
          }).toList(),
    );
  }

  /// 타임라인 이벤트 카드
  Widget _buildTimelineEvent(
    BuildContext context,
    TimelineEvent event,
    bool isSelected,
  ) {
    // 375px 기준: 전체 너비(375) - 좌우 마진(20*2) - 원(13) - 간격(16) = 306px
    return GestureDetector(
      onTap: () {
        // 카드 클릭 시 선택 상태 변경 (하나만 선택)
        setState(() {
          if (_selectedEvent == event) {
            // 같은 카드를 다시 클릭하면 선택 해제
            _selectedEvent = null;
          } else {
            // 다른 카드 선택
            _selectedEvent = event;
          }
        });
      },
      child: Container(
        width: context.w(306), // 카드 너비 306px (375 - 20*2 - 13 - 16 = 306)
        height: context.h(72), // 박스 높이 72px 고정
        padding: EdgeInsets.symmetric(
          horizontal: context.w(24), // 좌우 패딩 24px
          vertical: context.h(14), // 상하 패딩 14px
        ),
        decoration: BoxDecoration(
          color:
              event.isActive
                  ? AppColors
                      .blue1 // 새로 추가/수정된 이벤트: 파란색 배경 (b1)
                  : Colors.white.withOpacity(0.1), // rgba(255,255,255,0.1)
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                event.isActive
                    ? AppColors
                        .blue1 // 새로 추가/수정된 이벤트: 파란색 테두리 (b1)
                    : (isSelected
                        ? Colors
                            .white // 선택된 상태: 흰색 테두리
                        : (event.isEditable
                            ? Colors.white.withOpacity(0.5) // 자유 시간: 흰색 50% 테두리
                            : Colors.transparent)), // 일반: 테두리 없음
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘 + 제목 + 시간 (상단 Row)
            Row(
              children: [
                if (event.icon != null) ...[
                  SizedBox(
                    width: context.w(24),
                    height: context.h(24),
                    child: Image.asset(
                      event.icon!,
                      width: context.w(24),
                      height: context.h(24),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: context.w(4)), // 아이콘과 제목 사이 간격 4px
                ],
                Expanded(
                  child: Text(
                    event.title,
                    style: AppTextStyles.bigBody.copyWith(color: Colors.white),
                  ),
                ),
                Text(
                  event.time,
                  style: AppTextStyles.smallBody.copyWith(
                    color: Colors.white.withOpacity(0.5), // opacity 0.5
                  ),
                ),
              ],
            ),
            SizedBox(height: context.h(4)), // 상단 Row와 설명 사이 간격 4px
            // 설명
            Expanded(
              child: Text(
                event.description,
                style: AppTextStyles.smallBody.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 액션 버튼 (수정하기, 삭제하기)
  Widget _buildActionButtons(BuildContext context, TimelineEvent event) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // 클릭 영역 확보
      onTap: () {}, // 빈 핸들러로 클릭 이벤트 차단
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // 오른쪽 정렬
        mainAxisSize: MainAxisSize.max,
        children: [
          // 수정하기 버튼
          _buildActionButton(
            context,
            icon: SizedBox(
              width: context.w(12),
              height: context.h(12),
              child: Image.asset(
                'assets/images/myflight/pencil.png',
                width: context.w(12),
                height: context.h(12),
                color: Colors.white,
              ),
            ),
            text: '수정하기',
            onTap: () {
              // 수정하기 기능
              _showEditPlanBottomSheet(context, event);
            },
          ),
          SizedBox(width: context.w(4)), // 버튼 사이 간격 4px
          // 삭제하기 버튼
          _buildActionButton(
            context,
            icon: Icon(Icons.close, size: context.w(12), color: Colors.white),
            text: '삭제하기',
            onTap: () {
              // 삭제하기 기능 - 모달 표시
              _showDeleteModal(context, event);
            },
          ),
        ],
      ),
    );
  }

  /// 액션 버튼 위젯
  Widget _buildActionButton(
    BuildContext context, {
    required Widget icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          SizedBox(width: context.w(4)), // 아이콘과 텍스트 사이 간격 4px
          Text(
            text,
            style: AppTextStyles.smallBody.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// 더보기 옵션 메뉴 오버레이
  Widget _buildMoreOptionsOverlay(BuildContext context) {
    // 더보기 버튼 위치 계산
    // 버튼: right: 20, top: 21, width: 40, height: 40
    // 메뉴의 왼쪽 끝이 버튼의 중앙에 맞춰야 함
    final buttonRight = context.w(20);
    final buttonTop = context.h(21);
    final buttonWidth = 40.0;
    final buttonHeight = 40.0;
    final menuWidth = context.w(120); // 메뉴 너비 120px
    final menuTop = buttonTop + buttonHeight + context.h(4); // 버튼 아래 4px
    // 버튼의 중앙 위치: buttonRight + (buttonWidth / 2)
    // 메뉴의 왼쪽 끝이 버튼 중앙에 맞춤: menuRight = buttonRight + (buttonWidth / 2)
    final menuRight = buttonRight + (buttonWidth / 2);

    return GestureDetector(
      onTap: () {
        // 메뉴 외부 클릭 시 닫기
        setState(() {
          _showMoreOptions = false;
        });
      },
      child: Container(
        color: Colors.transparent, // 전체 영역 클릭 가능하도록
        child: Stack(
          children: [
            // 메뉴
            Positioned(
              right: menuRight,
              top: menuTop,
              child: GestureDetector(
                onTap: () {}, // 메뉴 내부 클릭은 전파 방지
                child: Container(
                  width: menuWidth,
                  decoration: BoxDecoration(
                    color: const Color(0xFF313131), // #313131
                    borderRadius: BorderRadius.circular(12), // 모든 모서리 12px
                    boxShadow: [
                      BoxShadow(
                        offset: Offset.zero,
                        blurRadius: 10,
                        spreadRadius: 0,
                        color: const Color(0x40000000), // rgba(0, 0, 0, 0.25)
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 플랜 저장하기 (맨 위)
                      _buildOptionItem(
                        context,
                        text: '플랜 저장하기',
                        isFirst: true,
                        isLast: false,
                        onTap: () {
                          setState(() {
                            _showMoreOptions = false;
                          });
                          // 저장 기능 (나가지지 않음)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('플랜이 저장되었습니다.')),
                          );
                        },
                      ),
                      // AI 추천으로 초기화 (중간)
                      _buildOptionItem(
                        context,
                        text: 'AI 추천으로 초기화',
                        isFirst: false,
                        isLast: false,
                        onTap: () {
                          setState(() {
                            _showMoreOptions = false;
                          });
                          _showAIResetModal(context);
                        },
                      ),
                      // 비행 플랜 삭제 (맨 아래)
                      _buildOptionItem(
                        context,
                        text: '비행 플랜 삭제',
                        isFirst: false,
                        isLast: true,
                        onTap: () {
                          setState(() {
                            _showMoreOptions = false;
                          });
                          _showDeletePlanModal(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 옵션 아이템 위젯
  Widget _buildOptionItem(
    BuildContext context, {
    required String text,
    required VoidCallback onTap,
    required bool isFirst,
    required bool isLast,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, // width: 120px
        padding: EdgeInsets.symmetric(
          horizontal: context.w(10), // padding: 5px 10px
          vertical: context.h(5),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF313131), // background: #313131
          borderRadius: BorderRadius.only(
            topLeft: isFirst ? const Radius.circular(12) : Radius.zero,
            topRight: isFirst ? const Radius.circular(12) : Radius.zero,
            bottomLeft: isLast ? const Radius.circular(12) : Radius.zero,
            bottomRight: isLast ? const Radius.circular(12) : Radius.zero,
          ),
          border: Border(
            bottom: BorderSide(
              color:
                  isLast
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.1), // 흰색 10%
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // justify-content: center
          crossAxisAlignment: CrossAxisAlignment.center, // align-items: center
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: AppTextStyles.smallBody.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  /// 비행 플랜 삭제 모달 표시
  void _showDeletePlanModal(BuildContext context) {
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
                width: context.w(300),
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
                            '비행 플랜 삭제',
                            style: AppTextStyles.large.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: context.h(10)), // gap: 10px
                          // 본문
                          Padding(
                            padding: EdgeInsets.only(
                              left: context.w(14),
                              right: context.w(14),
                              top: context.h(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '이 비행 플랜을 완전히 삭제하시겠어요?',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '저장된 루틴이 모두 사라집니다.',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.h(16)), // gap: 16px
                    // 버튼들
                    Row(
                      children: [
                        // 삭제 버튼
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              // 초기화하고 나가기
                              setState(() {
                                _events = List.from(_initialEvents);
                                _selectedEvent = null;
                              });
                              Navigator.pop(context); // 페이지 나가기
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
                                  '삭제',
                                  style: AppTextStyles.buttonText.copyWith(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: context.w(16)), // 버튼 사이 간격 16px
                        // 취소 버튼
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
                                color: AppColors.blue1,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  '취소',
                                  style: AppTextStyles.buttonText.copyWith(
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

  /// AI 초기화 모달 표시
  void _showAIResetModal(BuildContext context) {
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
                width: context.w(300),
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
                            'AI 플랜으로 초기화',
                            style: AppTextStyles.large.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: context.h(10)), // gap: 10px
                          // 본문
                          Padding(
                            padding: EdgeInsets.only(
                              left: context.w(14),
                              right: context.w(14),
                              top: context.h(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'BIMO의 추천 루틴으로 되돌릴까요?',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '현재 수정된 내용은 모두 삭제됩니다.',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.h(16)), // gap: 16px
                    // 버튼들
                    Row(
                      children: [
                        // 초기화 버튼
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              // 초기 타임라인으로 복원
                              setState(() {
                                _events = List.from(_initialEvents);
                                _selectedEvent = null;
                              });
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
                                  '초기화',
                                  style: AppTextStyles.buttonText.copyWith(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: context.w(16)), // 버튼 사이 간격 16px
                        // 취소 버튼
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
                                color: AppColors.blue1,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  '취소',
                                  style: AppTextStyles.buttonText.copyWith(
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

  /// 삭제 확인 모달 표시 (타임라인 이벤트 삭제용)
  void _showDeleteModal(BuildContext context, TimelineEvent event) {
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
                width: context.w(300),
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
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // align-items: center
                  children: [
                    // 헤더 영역
                    Container(
                      width: double.infinity, // align-self: stretch
                      padding: EdgeInsets.only(
                        top: context.h(20), // padding: 20px 0 10px 0
                        bottom: context.h(10),
                      ),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // justify-content: center
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // align-items: center
                        children: [
                          // 제목
                          Text(
                            '플랜 삭제',
                            style: AppTextStyles.large.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: context.h(10)), // gap: 10px
                          // 질문 (본문 패딩 적용)
                          Padding(
                            padding: EdgeInsets.only(
                              left: context.w(14), // 좌 14px
                              right: context.w(14), // 우 14px
                              top: context.h(10), // 상 10px
                            ),
                            child: Text(
                              '"${event.title}" 항목을 삭제하시겠습니까?',
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.h(16)), // gap: 16px
                    // 버튼들
                    Row(
                      children: [
                        // 삭제 버튼
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                _events.remove(event);
                                _selectedEvent = null;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: context.h(16), // padding: 16px 0
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(
                                  0.1,
                                ), // rgba(255, 255, 255, 0.10)
                                borderRadius: BorderRadius.circular(
                                  30,
                                ), // border-radius: 30px
                              ),
                              child: Center(
                                child: Text(
                                  '삭제',
                                  style: AppTextStyles.buttonText.copyWith(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: context.w(16)), // 버튼 사이 간격 16px
                        // 취소 버튼
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: context.h(16), // padding: 16px 0
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.blue1, // B1 색상
                                borderRadius: BorderRadius.circular(
                                  30,
                                ), // border-radius: 30px
                              ),
                              child: Center(
                                child: Text(
                                  '취소',
                                  style: AppTextStyles.buttonText.copyWith(
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

  /// 플랜 추가 바텀시트 표시
  void _showAddPlanBottomSheet(BuildContext context) {
    final titleController = TextEditingController();
    final startTimeController = TextEditingController(text: '00:00 AM');
    final endTimeController = TextEditingController(text: '00:00 PM');
    final descriptionController = TextEditingController();

    // 시간 입력을 위한 상태 관리
    final startTimeState = ValueNotifier<String>('00:00 AM');
    final endTimeState = ValueNotifier<String>('00:00 PM');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // 뒷 배경 선명하게
      isScrollControlled: true,
      isDismissible: false, // 아래로 스크롤해야만 닫을 수 있음
      enableDrag: true, // 드래그 가능
      barrierColor: Colors.transparent, // 뒷 배경 가리지 않음
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5, // 초기 높이를 더 낮게 설정
          minChildSize: 0.1, // 최소 크기를 더 작게 하여 뒷 배경이 더 많이 보이도록
          maxChildSize: 0.85,
          snap: true, // 스냅 기능 활성화
          snapSizes: const [0.1, 0.5, 0.85], // 스냅 위치
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.black, // 스타일의 블랙
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1), // 흰색 10% 테두리
                  width: 1,
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: context.w(20),
                  right: context.w(20),
                  top: context.h(4), // 맨 꼭대기에서 4px
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch, // align-self: stretch
                  children: [
                    // iOS 드래그 인디케이터
                    Center(
                      child: Container(
                        width: context.w(40),
                        height: context.h(4),
                        margin: EdgeInsets.only(bottom: context.h(23)),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // 제목 (가운데 정렬)
                    Center(
                      child: Text(
                        '플랜 추가하기',
                        style: AppTextStyles.large.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: context.h(24)), // 제목 아래 간격 24px
                    // 입력 섹션들 (gap: 8px)
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch, // align-items: flex-start
                      children: [
                        // 플랜 제목 입력
                        TextField(
                          controller: titleController,
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: '플랜 제목을 입력해 보세요.',
                            hintStyle: AppTextStyles.body.copyWith(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                14,
                              ), // border-radius: 14px
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: context.w(16),
                              vertical: context.h(12),
                            ),
                          ),
                        ),
                        SizedBox(height: context.h(8)), // gap: 8px
                        // 시간 입력 (시작 시간, 종료 시간)
                        Row(
                          children: [
                            Expanded(
                              child: _buildTimeInputField(
                                context,
                                label: '시작 시간',
                                controller: startTimeController,
                                timeState: startTimeState,
                              ),
                            ),
                            SizedBox(width: context.w(8)), // 시간 박스 사이 간격 8px
                            Expanded(
                              child: _buildTimeInputField(
                                context,
                                label: '종료 시간',
                                controller: endTimeController,
                                timeState: endTimeState,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.h(8)), // gap: 8px
                        // 설명 입력
                        TextField(
                          controller: descriptionController,
                          maxLines: 3,
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: '어떤 플랜인지 자세히 입력해 보세요.',
                            hintStyle: AppTextStyles.body.copyWith(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                14,
                              ), // border-radius: 14px
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: context.w(16),
                              vertical: context.h(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.h(16)), // 적용하기 버튼 위 간격 16px
                    // 적용하기 버튼 (비행 등록 페이지의 다음 버튼과 동일한 스펙)
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          if (titleController.text.isNotEmpty) {
                            // 타임라인에 이벤트 추가
                            final newEvent = TimelineEvent(
                              title: titleController.text,
                              time:
                                  '${startTimeState.value} - ${endTimeState.value}',
                              description: descriptionController.text,
                              isActive: true, // 파란색으로 표시하기 위해 활성화
                            );
                            setState(() {
                              _events.add(newEvent);
                              _selectedEvent = newEvent; // 새로 추가된 이벤트 선택
                              // 시간 순으로 정렬
                              _events.sort((a, b) {
                                // 간단한 시간 비교 (실제로는 더 정교한 파싱 필요)
                                return a.time.compareTo(b.time);
                              });
                            });
                            Navigator.pop(context);
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              width: context.w(335),
                              height: context.h(50),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '적용하기',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height:
                          context.h(16) +
                          Responsive.homeIndicatorHeight(context),
                    ), // 하단 인디케이터 높이 + 16px
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 플랜 수정 바텀시트 표시
  void _showEditPlanBottomSheet(BuildContext context, TimelineEvent event) {
    // 기존 내용으로 컨트롤러 초기화
    final titleController = TextEditingController(text: event.title);
    final timeParts = event.time.split(' - ');
    final startTimeController = TextEditingController(
      text: timeParts.isNotEmpty ? timeParts[0] : '00:00 AM',
    );
    final endTimeController = TextEditingController(
      text: timeParts.length > 1 ? timeParts[1] : '00:00 PM',
    );
    final descriptionController = TextEditingController(
      text: event.description,
    );

    // 시간 입력을 위한 상태 관리
    final startTimeState = ValueNotifier<String>(
      timeParts.isNotEmpty ? timeParts[0] : '00:00 AM',
    );
    final endTimeState = ValueNotifier<String>(
      timeParts.length > 1 ? timeParts[1] : '00:00 PM',
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: true,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.1,
          maxChildSize: 0.85,
          snap: true,
          snapSizes: const [0.1, 0.5, 0.85],
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: context.w(20),
                  right: context.w(20),
                  top: context.h(4),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // iOS 드래그 인디케이터
                    Center(
                      child: Container(
                        width: context.w(40),
                        height: context.h(4),
                        margin: EdgeInsets.only(bottom: context.h(23)),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // 제목 (가운데 정렬)
                    Center(
                      child: Text(
                        '수정하기',
                        style: AppTextStyles.large.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: context.h(24)),
                    // 입력 섹션들 (gap: 8px)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 플랜 제목 입력
                        TextField(
                          controller: titleController,
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: '플랜 제목을 입력해 보세요.',
                            hintStyle: AppTextStyles.body.copyWith(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: context.w(16),
                              vertical: context.h(12),
                            ),
                          ),
                        ),
                        SizedBox(height: context.h(8)),
                        // 시간 입력 (시작 시간, 종료 시간)
                        Row(
                          children: [
                            Expanded(
                              child: _buildTimeInputField(
                                context,
                                label: '시작 시간',
                                controller: startTimeController,
                                timeState: startTimeState,
                              ),
                            ),
                            SizedBox(width: context.w(8)),
                            Expanded(
                              child: _buildTimeInputField(
                                context,
                                label: '종료 시간',
                                controller: endTimeController,
                                timeState: endTimeState,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.h(8)),
                        // 설명 입력
                        TextField(
                          controller: descriptionController,
                          maxLines: 3,
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: '어떤 플랜인지 자세히 입력해 보세요.',
                            hintStyle: AppTextStyles.body.copyWith(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: context.w(16),
                              vertical: context.h(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.h(16)),
                    // 적용하기 버튼
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          if (titleController.text.isNotEmpty) {
                            // 앵커 수면인지 확인하고 시간 범위가 줄어들었는지 확인
                            if (event.title == '앵커 수면') {
                              _checkAndHandleAnchorSleepEdit(
                                context,
                                event,
                                startTimeState.value,
                                endTimeState.value,
                                titleController.text,
                                descriptionController.text,
                              );
                            } else {
                              // 일반 수정
                              _updateEvent(
                                event,
                                titleController.text,
                                startTimeState.value,
                                endTimeState.value,
                                descriptionController.text,
                              );
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              width: context.w(335),
                              height: context.h(50),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '적용하기',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height:
                          context.h(16) +
                          Responsive.homeIndicatorHeight(context),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 앵커 수면 수정 시 확인 및 처리
  void _checkAndHandleAnchorSleepEdit(
    BuildContext context,
    TimelineEvent originalEvent,
    String newStartTime,
    String newEndTime,
    String newTitle,
    String newDescription,
  ) async {
    // 기존 시간 범위 파싱
    final originalTimeParts = originalEvent.time.split(' - ');
    final originalStart = _parseTimeToMinutes(originalTimeParts[0]);
    final originalEnd = _parseTimeToMinutes(originalTimeParts[1]);

    // 새로운 시간 범위 파싱
    final newStart = _parseTimeToMinutes(newStartTime);
    final newEnd = _parseTimeToMinutes(newEndTime);

    // 시간 범위가 줄어들었는지 확인
    final originalDuration = originalEnd - originalStart;
    final newDuration = newEnd - newStart;

    if (newDuration < originalDuration) {
      // 경고 팝업 표시
      final shouldProceed = await _showAnchorSleepWarningModal(context);
      if (!shouldProceed) {
        return; // 취소하면 수정하지 않음
      }

      // 나머지 시간을 자유 시간으로 변경
      _updateEventAndCreateFreeTime(
        originalEvent,
        newStartTime,
        newEndTime,
        newTitle,
        newDescription,
        originalStart,
        originalEnd,
        newStart,
        newEnd,
      );
    } else {
      // 시간 범위가 늘어났거나 같으면 그냥 수정
      _updateEvent(
        originalEvent,
        newTitle,
        newStartTime,
        newEndTime,
        newDescription,
      );
    }

    Navigator.pop(context); // 바텀시트 닫기
  }

  /// 시간 문자열을 분으로 변환 (예: "12:00 PM" -> 720)
  int _parseTimeToMinutes(String timeString) {
    try {
      final parts = timeString.split(' ');
      if (parts.length == 2) {
        final timePart = parts[0]; // "12:00"
        final period = parts[1]; // "AM" or "PM"

        final timeParts = timePart.split(':');
        if (timeParts.length == 2) {
          int hour = int.tryParse(timeParts[0]) ?? 0;
          final minute = int.tryParse(timeParts[1]) ?? 0;

          // 12시간 형식을 24시간 형식으로 변환
          if (period == 'PM' && hour != 12) {
            hour += 12;
          } else if (period == 'AM' && hour == 12) {
            hour = 0;
          }

          return hour * 60 + minute;
        }
      }
    } catch (e) {
      // 파싱 실패 시 기본값 반환
    }
    return 0;
  }

  /// 분을 시간 문자열로 변환 (예: 720 -> "12:00 PM")
  String _minutesToTimeString(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;

    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  /// 앵커 수면 경고 모달 표시
  Future<bool> _showAnchorSleepWarningModal(BuildContext context) async {
    bool? result = false;
    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: context.w(20)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: context.w(300),
                padding: EdgeInsets.only(
                  top: 0,
                  right: context.w(20),
                  bottom: context.w(20),
                  left: context.w(20),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 헤더
                    Padding(
                      padding: EdgeInsets.only(
                        top: context.h(20),
                        bottom: context.h(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '앵커 수면 수정',
                            style: AppTextStyles.large.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.h(16)),
                    // 본문
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.w(14)),
                      child: Text(
                        '나머지 앵커 수면 시간은\n비어있는 자유 시간으로 변경됩니다.',
                        style: AppTextStyles.body.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: context.h(16)),
                    // 버튼들
                    Row(
                      children: [
                        // 취소 버튼 (왼쪽)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              result = false;
                              Navigator.pop(context);
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
                                  '취소',
                                  style: AppTextStyles.buttonText.copyWith(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: context.w(16)),
                        // 확인 버튼 (오른쪽)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              result = true;
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: context.h(16),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.blue1,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  '확인',
                                  style: AppTextStyles.buttonText.copyWith(
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
    return result ?? false;
  }

  /// 이벤트 업데이트
  void _updateEvent(
    TimelineEvent event,
    String newTitle,
    String newStartTime,
    String newEndTime,
    String newDescription,
  ) {
    setState(() {
      event.title = newTitle;
      event.time = '$newStartTime - $newEndTime';
      event.description = newDescription;
      event.isActive = true; // 수정된 플랜은 파란색으로 표시
    });
  }

  /// 이벤트 업데이트 및 자유 시간 생성
  void _updateEventAndCreateFreeTime(
    TimelineEvent originalEvent,
    String newStartTime,
    String newEndTime,
    String newTitle,
    String newDescription,
    int originalStart,
    int originalEnd,
    int newStart,
    int newEnd,
  ) {
    setState(() {
      // 원본 이벤트 수정
      originalEvent.title = newTitle;
      originalEvent.time = '$newStartTime - $newEndTime';
      originalEvent.description = newDescription;
      originalEvent.isActive = true; // 수정된 플랜은 파란색으로 표시

      // 나머지 시간 범위 확인
      if (newStart > originalStart) {
        // 앞부분이 비어있음 - 앞부분을 자유 시간으로
        final freeTimeStart = _minutesToTimeString(originalStart);
        final freeTimeEnd = _minutesToTimeString(newStart);

        final freeTimeEvent = TimelineEvent(
          title: '자유 시간',
          time: '$freeTimeStart - $freeTimeEnd',
          description: '자유롭게 일정을 등록하실 수 있습니다.',
          isEditable: true,
        );

        // 원본 이벤트 앞에 삽입
        final originalIndex = _events.indexOf(originalEvent);
        _events.insert(originalIndex, freeTimeEvent);
      }

      if (newEnd < originalEnd) {
        // 뒷부분이 비어있음 - 뒷부분을 자유 시간으로
        final freeTimeStart = _minutesToTimeString(newEnd);
        final freeTimeEnd = _minutesToTimeString(originalEnd);

        final freeTimeEvent = TimelineEvent(
          title: '자유 시간',
          time: '$freeTimeStart - $freeTimeEnd',
          description: '자유롭게 일정을 등록하실 수 있습니다.',
          isEditable: true,
        );

        // 원본 이벤트 뒤에 삽입
        final originalIndex = _events.indexOf(originalEvent);
        _events.insert(originalIndex + 1, freeTimeEvent);
      }

      // 시간 순으로 정렬
      _events.sort((a, b) {
        return a.time.compareTo(b.time);
      });
    });
  }

  /// 시간 입력 필드 위젯
  Widget _buildTimeInputField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required ValueNotifier<String> timeState,
  }) {
    // 초기값 설정
    if (controller.text.isEmpty) {
      controller.text = timeState.value;
    }

    return ValueListenableBuilder<String>(
      valueListenable: timeState,
      builder: (context, value, child) {
        final hasValue =
            value.isNotEmpty && value != '00:00 AM' && value != '00:00 PM';

        // 컨트롤러와 상태 동기화
        if (controller.text != value) {
          controller.text = value;
        }

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.w(16),
            vertical: context.h(12),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14), // border-radius: 14px
          ),
          child: Row(
            children: [
              // 시계 아이콘 (항상 흰색)
              SizedBox(
                width: context.w(24),
                height: context.h(24),
                child: Image.asset(
                  'assets/images/myflight/clock.png',
                  width: context.w(24),
                  height: context.h(24),
                  color: Colors.white, // 항상 흰색
                ),
              ),
              SizedBox(width: context.w(12)),
              // 시간 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 라벨 (시작 시간/종료 시간)
                    Text(
                      label,
                      style: AppTextStyles.smallBody.copyWith(
                        color: Colors.white.withOpacity(0.5), // 비활성화: 흰색 50%
                      ),
                    ),
                    // 시간 텍스트 (탭하면 시간 피커 표시)
                    GestureDetector(
                      onTap: () {
                        _showTimePickerDialog(
                          context,
                          label,
                          timeState,
                          controller,
                        );
                      },
                      child: Text(
                        value.isEmpty ? '00:00 AM' : value,
                        style: AppTextStyles.body.copyWith(
                          color:
                              hasValue
                                  ? Colors.white
                                  : Colors.white.withOpacity(
                                    0.5,
                                  ), // 활성화: 흰색, 비활성화: 흰색 50%
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 시간 피커 다이얼로그 표시
  Future<void> _showTimePickerDialog(
    BuildContext context,
    String title,
    ValueNotifier<String> timeState,
    TextEditingController controller,
  ) async {
    // 현재 시간 파싱
    final currentTime = _parseTimeString(timeState.value);
    int selectedHour = currentTime.hour;
    int selectedMinute = currentTime.minute;
    bool isPM = selectedHour >= 12;

    // 12시간 형식으로 변환
    int displayHour =
        selectedHour == 0
            ? 12
            : (selectedHour > 12 ? selectedHour - 12 : selectedHour);

    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5), // 뒷 배경 검정 50%
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(horizontal: context.w(20)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    width: context.w(300),
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 헤더
                        Padding(
                          padding: EdgeInsets.only(
                            top: context.h(20),
                            bottom: context.h(10),
                          ),
                          child: Center(
                            child: Text(
                              title,
                              style: AppTextStyles.large.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: context.h(16)),
                        // 시간 선택 컬럼들
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // AM/PM 선택기
                            Expanded(
                              child: _buildPeriodPicker(
                                context,
                                isPM: isPM,
                                onChanged: (value) {
                                  setState(() {
                                    isPM = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: context.w(8)),
                            // 시간 선택기 (1-12)
                            Expanded(
                              child: _buildHourPicker(
                                context,
                                selectedHour: displayHour,
                                onChanged: (value) {
                                  setState(() {
                                    displayHour = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: context.w(8)),
                            // 분 선택기 (0-59)
                            Expanded(
                              child: _buildMinutePicker(
                                context,
                                selectedMinute: selectedMinute,
                                onChanged: (value) {
                                  setState(() {
                                    selectedMinute = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.h(16)),
                        // 버튼들
                        Row(
                          children: [
                            // 취소 버튼 (왼쪽)
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
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '취소',
                                      style: AppTextStyles.buttonText.copyWith(
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: context.w(16)), // 버튼 사이 간격 16px
                            // 적용 버튼 (오른쪽)
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  // 12시간 형식으로 변환
                                  final period = isPM ? 'PM' : 'AM';
                                  final formatted =
                                      '${displayHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')} $period';
                                  timeState.value = formatted;
                                  controller.text = formatted;
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: context.h(16),
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.blue1,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '적용',
                                      style: AppTextStyles.buttonText.copyWith(
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
      },
    );
  }

  /// AM/PM 선택기
  Widget _buildPeriodPicker(
    BuildContext context, {
    required bool isPM,
    required ValueChanged<bool> onChanged,
  }) {
    return SizedBox(
      height: context.h(200),
      child: ListWheelScrollView.useDelegate(
        itemExtent: context.h(40),
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          onChanged(index == 1); // 0: AM, 1: PM
        },
        controller: FixedExtentScrollController(initialItem: isPM ? 1 : 0),
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            final period = index == 0 ? '오전' : '오후';
            final isSelected = (isPM && index == 1) || (!isPM && index == 0);

            return Center(
              child: Text(
                period,
                style: AppTextStyles.body.copyWith(
                  color:
                      isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                ),
              ),
            );
          },
          childCount: 2,
        ),
      ),
    );
  }

  /// 시간 선택기 (1-12)
  Widget _buildHourPicker(
    BuildContext context, {
    required int selectedHour,
    required ValueChanged<int> onChanged,
  }) {
    return SizedBox(
      height: context.h(200),
      child: ListWheelScrollView.useDelegate(
        itemExtent: context.h(40),
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          onChanged(index + 1); // 1-12
        },
        controller: FixedExtentScrollController(initialItem: selectedHour - 1),
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            final hour = index + 1;
            final isSelected = hour == selectedHour;

            return Center(
              child: Text(
                hour.toString(),
                style: AppTextStyles.body.copyWith(
                  color:
                      isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                ),
              ),
            );
          },
          childCount: 12,
        ),
      ),
    );
  }

  /// 분 선택기 (0-59)
  Widget _buildMinutePicker(
    BuildContext context, {
    required int selectedMinute,
    required ValueChanged<int> onChanged,
  }) {
    return SizedBox(
      height: context.h(200),
      child: ListWheelScrollView.useDelegate(
        itemExtent: context.h(40),
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          onChanged(index); // 0-59
        },
        controller: FixedExtentScrollController(initialItem: selectedMinute),
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            final minute = index;
            final isSelected = minute == selectedMinute;

            return Center(
              child: Text(
                minute.toString().padLeft(2, '0'),
                style: AppTextStyles.body.copyWith(
                  color:
                      isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                ),
              ),
            );
          },
          childCount: 60,
        ),
      ),
    );
  }

  /// 시간 문자열을 TimeOfDay로 파싱
  TimeOfDay _parseTimeString(String timeString) {
    try {
      // "12:00 AM" 형식에서 시간과 분 추출
      final parts = timeString.split(' ');
      if (parts.length == 2) {
        final timePart = parts[0]; // "12:00"
        final period = parts[1]; // "AM" or "PM"

        final timeParts = timePart.split(':');
        if (timeParts.length == 2) {
          int hour = int.tryParse(timeParts[0]) ?? 0;
          final minute = int.tryParse(timeParts[1]) ?? 0;

          // 12시간 형식을 24시간 형식으로 변환
          if (period == 'PM' && hour != 12) {
            hour += 12;
          } else if (period == 'AM' && hour == 12) {
            hour = 0;
          }

          return TimeOfDay(hour: hour, minute: minute);
        }
      }
    } catch (e) {
      // 파싱 실패 시 기본값 반환
    }
    return const TimeOfDay(hour: 0, minute: 0);
  }

  /// 플로팅 액션 버튼
  Widget _buildFloatingActionButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showAddPlanBottomSheet(context);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50), // border-radius: 50px
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 15,
            sigmaY: 15,
          ), // backdrop-filter: blur(15px)
          child: Container(
            width: context.w(47), // width: 47px
            height: context.h(47), // height: 47px
            padding: EdgeInsets.only(
              top: context.h(8), // padding: 8px 9px 9px 8px
              right: context.w(9),
              bottom: context.h(9),
              left: context.w(8),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A), // background: #1A1A1A
              borderRadius: BorderRadius.circular(50), // border-radius: 50px
              border: Border.all(
                color: Colors.white.withOpacity(
                  0.5,
                ), // border: 1px solid rgba(255, 255, 255, 0.50)
                width: 1,
              ),
            ),
            child: Center(
              // justify-content: center, align-items: center
              child: SizedBox(
                width: context.w(24), // 플러스 아이콘 24x24
                height: context.h(24),
                child: SvgPicture.asset(
                  'assets/images/myflight/Plus.svg',
                  width: context.w(24),
                  height: context.h(24),
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 타임라인 이벤트 목록 (더미 데이터)
  List<TimelineEvent> _getTimelineEvents() {
    return [
      TimelineEvent(
        icon: 'assets/images/myflight/airplane.png',
        title: '이륙 및 안정',
        time: '09:00 - 11:00',
        description: 'BIMO와 함께 스마트한 비행을 시작합니다.',
      ),
      TimelineEvent(
        icon: 'assets/images/myflight/meal.png',
        title: '예상 저녁 식사',
        time: '11:00 - 12:00',
        description: '첫 번째 기내식이 제공될 예상 시간입니다.',
      ),
      TimelineEvent(
        icon: 'assets/images/myflight/moon.png',
        title: '앵커 수면',
        time: '12:00 - 17:00',
        description: '시차 적응을 위한 핵심 수면 시간입니다.',
      ),
      TimelineEvent(
        icon: null,
        title: '자유 시간',
        time: '17:00 - 21:00',
        description: '자유롭게 일정을 등록하실 수 있습니다.',
        isEditable: true, // 수정 권장
      ),
      TimelineEvent(
        icon: 'assets/images/myflight/meal.png',
        title: '예상 아침 식사',
        time: '21:00 - 22:00',
        description: '두 번째 기내식이 제공될 예상 시간입니다.',
      ),
      TimelineEvent(
        icon: 'assets/images/myflight/airplane.png',
        title: '착륙 및 안정',
        time: '23:00 - 01:00',
        description: 'BIMO와 함께 스마트한 비행을 마무리합니다.',
      ),
    ];
  }
}

/// 타임라인 이벤트 모델
class TimelineEvent {
  final String? icon;
  String title;
  String time;
  String description;
  final bool isEditable; // 수정 권장 여부 (자유 시간만 true)
  bool isActive; // 활성화 상태 (클릭해서 수정 중)

  TimelineEvent({
    this.icon,
    required this.title,
    required this.time,
    required this.description,
    this.isEditable = false,
    this.isActive = false,
  });
}

/// 타임라인 라인 Painter
class TimelineLinePainter extends CustomPainter {
  final double circleSize;
  final double lineStartOffset;
  final double lineEndOffset;
  final bool isActive; // 활성화 상태
  final bool isEditable; // 수정 권장 여부

  TimelineLinePainter({
    required this.circleSize,
    required this.lineStartOffset,
    required this.lineEndOffset,
    this.isActive = false,
    this.isEditable = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final circleRadius = circleSize / 2;
    final centerX = size.width / 2;

    // 타임라인 원 그리기
    if (isActive) {
      // 활성화된 상태: 칠해진 원 + 파란색 테두리 (새로 추가된 이벤트)
      final fillPaint =
          Paint()
            ..color = AppColors.blue1
            ..style = PaintingStyle.fill;

      final borderPaint =
          Paint()
            ..color = AppColors.blue1
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke;

      canvas.drawCircle(Offset(centerX, circleRadius), circleRadius, fillPaint);
      canvas.drawCircle(
        Offset(centerX, circleRadius),
        circleRadius,
        borderPaint,
      );
    } else {
      // 비활성화된 상태: 테두리만 (모두 흰색)
      final borderPaint =
          Paint()
            ..color =
                Colors
                    .white // 모든 원은 흰색 테두리
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke;

      canvas.drawCircle(
        Offset(centerX, circleRadius),
        circleRadius,
        borderPaint,
      );
    }

    // 타임라인 세로선
    final linePaint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(centerX, lineStartOffset),
      Offset(centerX, lineEndOffset),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant TimelineLinePainter oldDelegate) {
    return oldDelegate.isActive != isActive ||
        oldDelegate.isEditable != isEditable;
  }
}
