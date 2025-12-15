import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive_extensions.dart';
import '../data/models/local_flight.dart';
import '../data/models/local_timeline_event.dart';

/// 진행 중인 비행 타임라인 페이지 (가사 보기 스타일)
class InFlightTimelinePage extends StatefulWidget {
  final LocalFlight flight;
  final List<LocalTimelineEvent> timeline;

  const InFlightTimelinePage({
    super.key,
    required this.flight,
    required this.timeline,
  });

  @override
  State<InFlightTimelinePage> createState() => _InFlightTimelinePageState();
}

class _InFlightTimelinePageState extends State<InFlightTimelinePage> {
  late ScrollController _scrollController;
  late Timer _autoScrollTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeTimeline();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  /// 타임라인 초기화
  void _initializeTimeline() {
    _currentIndex = _findCurrentEventIndex();
    print('📍 초기 이벤트 인덱스: $_currentIndex');
    
    // 초기 스크롤 위치 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollToIndex(_currentIndex, animate: false);
      }
    });
  }

  /// 자동 스크롤 시작
  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final newIndex = _findCurrentEventIndex();
      if (newIndex != _currentIndex) {
        print('⏭️ 다음 이벤트로 이동: $_currentIndex → $newIndex');
        setState(() {
          _currentIndex = newIndex;
        });
        _scrollToIndex(newIndex);
      }
    });
  }

  /// 현재 시간 기준으로 진행 중인 이벤트 찾기
  int _findCurrentEventIndex() {
    final now = DateTime.now();
    for (int i = 0; i < widget.timeline.length; i++) {
      if (now.isAfter(widget.timeline[i].startTime) &&
          now.isBefore(widget.timeline[i].endTime)) {
        return i;
      }
    }
    // 현재 시간이 모든 이벤트 이전이면 첫 번째
    if (now.isBefore(widget.timeline.first.startTime)) {
      return 0;
    }
    // 현재 시간이 모든 이벤트 이후면 마지막
    return widget.timeline.length - 1;
  }

  /// 특정 인덱스로 스크롤
  void _scrollToIndex(int index, {bool animate = true}) {
    if (!_scrollController.hasClients) return;

    final screenHeight = MediaQuery.of(context).size.height;
    final itemHeight = 120.0; // 각 타임라인 아이템 높이
    final centerOffset = screenHeight / 2 - itemHeight / 2;
    
    // 실제 인덱스 (패딩 고려)
    final targetOffset = (index * itemHeight) - centerOffset;

    if (animate) {
      _scrollController.animateTo(
        targetOffset.clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _scrollController.jumpTo(
        targetOffset.clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            _buildHeader(context),
            
            // 비행 정보
            _buildFlightInfo(context),
            
            // 타임라인 리스트
            Expanded(
              child: _buildTimeline(context),
            ),
          ],
        ),
      ),
    );
  }

  /// 헤더 (뒤로가기 + 타이틀)
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.w(20)),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: SvgPicture.asset(
              'assets/images/home/arrow_left.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '진행 중인 비행',
            style: AppTextStyles.large.copyWith(color: Colors.white),
          ),
          const Spacer(),
          const SizedBox(width: 24), // 균형 맞춤
        ],
      ),
    );
  }

  /// 비행 정보
  Widget _buildFlightInfo(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.w(20)),
      padding: EdgeInsets.all(context.w(20)),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // 출발-도착
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.flight.origin,
                    style: AppTextStyles.display.copyWith(color: Colors.white),
                  ),
                  Text(
                    _formatTime(widget.flight.departureTime),
                    style: AppTextStyles.body.copyWith(color: Colors.white70),
                  ),
                ],
              ),
              Icon(Icons.arrow_forward, color: Colors.white70),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.flight.destination,
                    style: AppTextStyles.display.copyWith(color: Colors.white),
                  ),
                  Text(
                    _formatTime(widget.flight.arrivalTime),
                    style: AppTextStyles.body.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: context.h(16)),
          // 진행바
          _buildProgressBar(context),
        ],
      ),
    );
  }

  /// 진행바
  Widget _buildProgressBar(BuildContext context) {
    final now = DateTime.now();
    final total = widget.flight.arrivalTime.difference(widget.flight.departureTime).inSeconds;
    final elapsed = now.difference(widget.flight.departureTime).inSeconds;
    final progress = (elapsed / total).clamp(0.0, 1.0);

    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white10,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.blue1),
        ),
        SizedBox(height: context.h(8)),
        Text(
          '${(progress * 100).toInt()}% 완료',
          style: AppTextStyles.small.copyWith(color: Colors.white70),
        ),
      ],
    );
  }

  /// 타임라인 리스트
  Widget _buildTimeline(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // 사용자가 스크롤을 멈췄을 때
        if (notification is ScrollEndNotification) {
          // 1초 후 현재 이벤트로 snap-back
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              _scrollToIndex(_currentIndex);
            }
          });
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          vertical: screenHeight / 2 - 60, // 위아래 패딩
        ),
        itemCount: widget.timeline.length,
        itemBuilder: (context, index) {
          final event = widget.timeline[index];
          final isActive = index == _currentIndex;
          
          return _buildTimelineItem(context, event, isActive);
        },
      ),
    );
  }

  /// 타임라인 아이템
  Widget _buildTimelineItem(BuildContext context, LocalTimelineEvent event, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(
        horizontal: context.w(20),
        vertical: context.h(8),
      ),
      padding: EdgeInsets.all(context.w(isActive ? 20 : 16)),
      decoration: BoxDecoration(
        color: isActive ? AppColors.blue1 : const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타이틀
          Text(
            event.title,
            style: isActive
                ? AppTextStyles.large.copyWith(color: Colors.white)
                : AppTextStyles.body.copyWith(color: Colors.white70),
          ),
          // 진행 중일 때만 설명 표시
          if (isActive) ...[
            SizedBox(height: context.h(8)),
            Text(
              event.description,
              style: AppTextStyles.small.copyWith(color: Colors.white90),
            ),
            SizedBox(height: context.h(8)),
            Text(
              '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
              style: AppTextStyles.small.copyWith(color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }

  /// 시간 포맷
  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
