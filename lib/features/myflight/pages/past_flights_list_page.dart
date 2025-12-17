import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive_extensions.dart';
import '../widgets/flight_card_widget.dart';
import '../../../core/state/flight_state.dart';
import '../models/flight_model.dart';
import 'ticket_verification_camera_page.dart';
import '../data/repositories/local_flight_repository.dart';

/// 지난 비행 전체 리스트 페이지
class PastFlightsListPage extends StatelessWidget {
  const PastFlightsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // FlightState 구독 (데이터 변경 시 자동 갱신)
    return ListenableBuilder(
      listenable: FlightState(),
      builder: (context, child) {
        final pastFlights = FlightState().pastFlights;

        return Scaffold(
          backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
          extendBody: true,
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                // 본문: 스크롤 가능한 리스트
                Positioned.fill(
                  child: pastFlights.isEmpty
                      ? _buildEmptyState(context)
                      : _buildFlightsList(context, pastFlights),
                ),
                // 커스텀 헤더
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildHeader(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 헤더 (뒤로가기 + 타이틀)
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
                '지난 비행',
                style: AppTextStyles.large.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 비행 목록 빌더
  Widget _buildFlightsList(BuildContext context, List<Flight> flights) {
    return ListView.builder(
      padding: EdgeInsets.only(
        top: context.h(82) + context.h(20), // 헤더 높이 + 간격
        left: context.w(20),
        right: context.w(20),
        bottom: context.h(100), // 하단 여백
      ),
      itemCount: flights.length,
      itemBuilder: (context, index) {
        final flight = flights[index];
        // hasReview 값으로 리뷰 작성 여부 판단 (없으면 false로 간주)
        final hasReview = flight.hasReview ?? false;
        
        // 고유 키 생성 (삭제 시 필요)
        final key = Key('${flight.departureCode}_${flight.arrivalCode}_${flight.date}');
        
        return Padding(
          padding: EdgeInsets.only(bottom: context.h(16)),
          child: Dismissible(
            key: key,
            direction: DismissDirection.endToStart,
            dismissThresholds: const {DismissDirection.endToStart: 0.3},
            movementDuration: const Duration(milliseconds: 200),
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: context.w(20)),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
                size: 32,
              ),
            ),
            confirmDismiss: (direction) async {
              // 삭제 확인 다이얼로그 (리뷰 삭제 팝업과 동일한 스타일)
              return await showDialog<bool>(
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
                          width: context.w(320),
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
                                      '비행 삭제',
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: context.fs(19),
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: context.h(10)),
                                    // 본문
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: context.w(14),
                                        right: context.w(14),
                                        top: context.h(10),
                                      ),
                                      child: Text(
                                        '${flight.departureCode} → ${flight.arrivalCode} 비행을\n삭제하시겠습니까?',
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontSize: context.fs(15),
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: context.h(16)),
                              // 버튼들
                              Row(
                                children: [
                                  // 삭제 버튼 (왼쪽, 회색 배경)
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => Navigator.of(context).pop(true),
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
                                            style: TextStyle(
                                              fontFamily: 'Pretendard',
                                              fontSize: context.fs(16),
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: context.w(16)),
                                  // 취소 버튼 (오른쪽, 파란색 강조)
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => Navigator.of(context).pop(false),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: context.h(16),
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF007AFF),
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '취소',
                                            style: TextStyle(
                                              fontFamily: 'Pretendard',
                                              fontSize: context.fs(16),
                                              fontWeight: FontWeight.w600,
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
              ) ?? false;
            },
            onDismissed: (direction) async {
              try {
                final repository = LocalFlightRepository();
                await repository.init();
                
                final flightId = flight.id ?? '${flight.departureCode}_${flight.arrivalCode}';
                await repository.deleteFlight(flightId);
                
                print('✅ 비행 삭제 완료: $flightId');
                
                // Hive에서 다시 조회하여 FlightState 업데이트 (총 비행 시간 재계산)
                if (context.mounted) {
                  final updatedFlights = await repository.getPastFlights();
                  final flightModels = updatedFlights.map((lf) => Flight(
                    date: '${lf.departureTime.year}.${lf.departureTime.month.toString().padLeft(2, '0')}.${lf.departureTime.day.toString().padLeft(2, '0')}.',
                    departureCode: lf.origin,
                    arrivalCode: lf.destination,
                    departureCity: lf.origin,
                    arrivalCity: lf.destination,
                    departureTime: '${lf.departureTime.hour}:${lf.departureTime.minute}',
                    arrivalTime: '${lf.arrivalTime.hour}:${lf.arrivalTime.minute}',
                    duration: lf.totalDuration,
                    rating: null,
                    id: lf.id,
                  )).toList();
                  
                  FlightState().pastFlights = flightModels;
                }
              } catch (e) {
                print('❌ 비행 삭제 실패: $e');
              }
            },
            child: FlightCardWidget(
              departureCode: flight.departureCode,
              departureCity: flight.departureCity,
              arrivalCode: flight.arrivalCode,
              arrivalCity: flight.arrivalCity,
              duration: flight.duration,
              departureTime: flight.departureTime,
              arrivalTime: flight.arrivalTime,
              date: flight.date ?? '',
              rating: flight.rating,
              // hasReview 값으로 텍스트 결정
              reviewText: hasReview ? ' ' : '리뷰 작성하고 내 비행 기록하기',
              // 리뷰 없을 때만 노란 점
              hasEditNotification: !hasReview,
              // 리스트 페이지는 화이트 배경 사용
              isLightMode: true,
              onEditTap: () async {
                print('🔘 리뷰 작성 버튼 클릭! hasReview: $hasReview');
                if (hasReview) {
                  // 리뷰가 이미 있으면 수정 기능 (준비 중)
                  print('📝 리뷰 수정 모드');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('리뷰 수정 기능 준비 중입니다.')),
                  );
                } else {
                  // 리뷰가 없으면 티켓 검증 카메라로 이동
                  print('📸 티켓 검증 카메라로 이동');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TicketVerificationCameraPage(
                        departureCode: flight.departureCode,
                        departureCity: flight.departureCity,
                        arrivalCode: flight.arrivalCode,
                        arrivalCity: flight.arrivalCity,
                        flightNumber: 'KE001', // TODO: 실제 비행 번호로 교체
                        date: flight.date ?? '',
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  /// 빈 상태 (비행이 없을 때)
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flight_takeoff,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          SizedBox(height: context.h(16)),
          Text(
            '지난 비행이 없습니다',
            style: AppTextStyles.body.copyWith(
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }


}
