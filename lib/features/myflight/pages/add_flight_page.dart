import 'dart:ui';
import '../../../core/services/notification_service.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_extensions.dart';
import '../widgets/flight_card_widget.dart' show DashedLinePainter;
import 'flight_plan_page.dart';
import '../../home/presentation/widgets/destination_search_section.dart';
import '../../home/presentation/widgets/airport_search_bottom_sheet.dart';
import '../../home/presentation/widgets/date_selection_bottom_sheet.dart';
import '../../home/domain/models/airport.dart';
import '../presentation/viewmodels/add_flight_view_model.dart';
import '../widgets/flight_result_card.dart';
import '../../home/data/models/flight_search_response.dart';
import '../data/models/create_flight_request.dart';
import '../data/models/timeline_request.dart';
import '../../../core/storage/auth_token_storage.dart';
import '../data/repositories/flight_repository.dart';
import '../models/flight_model.dart';
import '../../../core/state/flight_state.dart';
import '../../../core/state/timeline_state.dart';
import 'package:go_router/go_router.dart';
import '../data/models/local_flight.dart';
import '../data/models/local_timeline_event.dart';
import '../data/repositories/local_flight_repository.dart';
import '../data/repositories/local_timeline_repository.dart';
// import '../../home/data/datasources/airline_api_service.dart'; // Removed

/// 비행 등록 페이지
class AddFlightPage extends StatefulWidget {
  const AddFlightPage({super.key});

  @override
  State<AddFlightPage> createState() => _AddFlightPageState();
}

class _AddFlightPageState extends State<AddFlightPage> with SingleTickerProviderStateMixin {
  // 현재 단계 (1, 2, 3)
  int _currentStep = 1;
  
  // 출발지/도착지
  String? _departureCode;
  String? _departureCity;
  String? _arrivalCode;
  String? _arrivalCity;
  
  // 출발 날짜
  DateTime? _departureDate;
  
  // 경유편 여부
  bool _hasLayover = false;
  
  // ViewModel
  late final AddFlightViewModel _viewModel;

  // 검색 관련 (2단계)
  final TextEditingController _flightNumberController = TextEditingController();
  
  // 로딩 상태 (ViewModel에서 관리하지만 UI 로컬 상태로도 싱크 맞춤)
  bool _isLoading = false; 
  AnimationController? _rotationController;

  // 3단계: 좌석 등급 및 비행 목표
  String? _selectedSeatClass; // 선택된 좌석 등급
  String? _selectedFlightGoal; // 선택된 비행 목표
  
  @override
  void initState() {
    super.initState();
    _viewModel = AddFlightViewModel();
    _viewModel.addListener(_onViewModelChanged);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }
  
  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _flightNumberController.dispose();
    _rotationController?.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    setState(() {
      // 로딩 상태에 따라 애니메이션 제어
      if (_viewModel.isLoading) {
        _rotationController?.repeat();
      } else {
        _rotationController?.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 중일 때는 앱 바와 버튼 없이 로딩 화면만 표시
    // 로딩 중일 때는 앱 바와 버튼 없이 로딩 화면만 표시
    // 로딩 중일 때는 앱 바와 버튼 없이 로딩 화면만 표시
    if (_viewModel.isLoading || _isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
        body: _buildLoadingScreen(),
      );
    }
    
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 본문 영역
            Positioned.fill(
              child: _buildBody(),
            ),
            // 커스텀 헤더
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildHeader(),
            ),
            // 진행 바 (앱바 아래 8px)
            Positioned(
              top: context.h(82) + context.h(8),
              left: context.w(20),
              right: context.w(20),
              child: _buildProgressBar(),
            ),
            // 다음 버튼 (하단)
            Positioned(
              bottom: context.h(50),
              left: context.w(20),
              right: context.w(20),
              child: _buildNextButton(),
            ),
          ],
        ),
      ),
    );
  }

  /// 헤더 (뒤로가기 + 타이틀)
  Widget _buildHeader() {
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
              onTap: _handleBackButton,
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
                '비행 등록',
                style: AppTextStyles.large.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 메인 바디 영역
  Widget _buildBody() {
    // 단계에 따라 다른 UI 표시
    if (_currentStep == 1) {
      return _buildStep1Body();
    } else if (_currentStep == 2) {
      return _buildStep2Body();
    } else if (_currentStep == 2) {
      return _buildStep2Body();
    } else if (_currentStep == 3) {
      return _buildStep3Body();
    } else {
      return _buildStep1Body(); // 기본값
    }
  }
  
  /// 1단계 바디 (공항/날짜 선택)
  Widget _buildStep1Body() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: context.h(82) + context.h(8) + context.h(24) + context.h(16), // 앱바 + 진행바 + 간격(24px) + 텍스트 아래 간격(16px)
        bottom: context.h(100), // 하단 여백
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 안내 텍스트
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(20)),
            child: _buildInstructionText(),
          ),
          
          SizedBox(height: context.h(8)),
          
          // 초기화 버튼 (오른쪽 정렬)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(20)),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _resetForm,
                child: Text(
                  '초기화',
                  style: AppTextStyles.smallBody.copyWith(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          
          SizedBox(height: context.h(0)), // DestinationSearchSection has top margin 8
          
          // 출발/도착 공항 및 날짜 섹션 (DestinationSearchSection 재사용)
          DestinationSearchSection(
            departureAirport: _departureCity != null 
                ? '$_departureCity ($_departureCode)' 
                : '공항 선택',
            arrivalAirport: _arrivalCity != null 
                ? '$_arrivalCity ($_arrivalCode)' 
                : '공항 선택',
            departureDate: _departureDate != null 
                ? '${_departureDate!.year}년 ${_departureDate!.month}월 ${_departureDate!.day}일'
                : '',
            isDepartureSelected: _departureCode != null,
            isArrivalSelected: _arrivalCode != null,
            onDepartureTap: () => _selectAirport(isDeparture: true),
            onArrivalTap: () => _selectAirport(isDeparture: false),
            onDateTap: _selectDepartureDate,
            onSwapAirports: _swapAirports,
          ),
          
          SizedBox(height: 16),
          
          // 경유편 체크박스
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(20)),
            child: _buildLayoverCheckbox(),
          ),
        ],
      ),
    );
  }
  
  /// 2단계 바디 (비행편 검색 및 선택)
  Widget _buildStep2Body() {
    // ViewModel 결과 + 로컬 필터링 (편명 검색 + 경유편 필터)
    final results = _viewModel.flightResults.where((flight) {
      // 1. 편명 검색
      final query = _flightNumberController.text.trim().toUpperCase();
      bool matchesQuery = true;
      if (query.isNotEmpty) {
        matchesQuery = flight.flightNumber.toUpperCase().contains(query);
      }
      
      // 2. 경유편 필터 (체크되면 경유편만, 해제되면 직항만)
      bool matchesLayover = true;
      final isLayover = (flight.segments?.length ?? 0) > 1;
      
      if (_hasLayover) {
        // 체크됨 -> 경유편만 표시
        matchesLayover = isLayover;
      } else {
        // 해제됨 -> 직항만 표시
        matchesLayover = !isLayover;
      }

      return matchesQuery && matchesLayover;
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: context.w(20),
        right: context.w(20),
        top: context.h(82) + context.h(8) + context.h(24) + context.h(16), // 앱바 + 진행바 + 간격(24px) + 텍스트 아래 간격(16px)
        bottom: context.h(100), // 하단 여백
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 안내 텍스트 (2단계용)
          _buildStep2InstructionText(),
          
          const SizedBox(height: 16),
          
          // 검색 필드 및 경유편 체크박스
          _buildSearchSection(),
          
          const SizedBox(height: 16),
          
          // 에러 메시지 표시
          if (_viewModel.error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  _viewModel.error!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(color: Colors.white70),
                ),
              ),
            ),

          // 비행편 목록
          if (results.isNotEmpty)
            ...results.map((flight) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FlightResultCard(
                flight: flight,
                isSelected: _viewModel.selectedFlight == flight,
                onTap: () => _viewModel.selectFlight(flight),
              ),
            ))
          else if (_viewModel.error == null)
            Center(
               child: Padding(
                 padding: const EdgeInsets.only(top: 40),
                 child: Text(
                   '검색 결과가 없습니다.',
                   style: AppTextStyles.body.copyWith(color: Colors.white54),
                 ),
               ),
            ),
        ],
      ),
    );
  }
  
  /// 3단계 바디 (좌석 등급 및 비행 목표 선택)
  Widget _buildStep3Body() {
    // 더미 데이터: 좌석 등급 목록 (실제로는 비행 정보에서 받아와야 함)
    // final List<String> seatClasses = ['이코노미', '프리미엄 이코노미', '비즈니스', '퍼스트']; // 제거됨
    
    // 비행 목표 목록
    final List<String> flightGoals = ['시차적응', '학습/업무 집중', '완전한 휴식'];
    
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: context.w(20),
        right: context.w(20),
        top: context.h(82) + context.h(8) + context.h(24) + context.h(16), // 앱바 + 진행바 + 간격(24px) + 텍스트 아래 간격(16px)
        bottom: context.h(100), // 하단 여백
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /* 좌석 등급 선택 섹션 제거됨
          Text(
            '탑승하실 좌석 등급을 선택해 주세요.',
            style: AppTextStyles.bigBody.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          // 좌석 등급 선택 버튼들 (가로 스크롤)
          SizedBox(
            height: 33, // 버튼 높이 고정
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: seatClasses.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final seatClass = seatClasses[index];
                final isSelected = _selectedSeatClass == seatClass;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSeatClass = seatClass;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.blue1 // B1 컬러
                          : Colors.white.withOpacity(0.1), // 흰색 10%
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        seatClass,
                        style: AppTextStyles.body.copyWith(
                          color: isSelected
                              ? Colors.white // 파란색 박스 안 글씨는 흰색
                              : Colors.white.withOpacity(0.5), // 흰색 10% 박스 안 글씨는 흰색 50%
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          */
          
          // 비행 목표 선택 섹션
          Text(
            '이번 비행의 주된 목표는 무엇인가요?',
            style: AppTextStyles.bigBody.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          // 비행 목표 선택 버튼들 (가로 스크롤)
          SizedBox(
            height: 33, // 버튼 높이 고정
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: flightGoals.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final flightGoal = flightGoals[index];
                final isSelected = _selectedFlightGoal == flightGoal;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFlightGoal = flightGoal;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.blue1 // B1 컬러
                          : Colors.white.withOpacity(0.1), // 흰색 10%
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        flightGoal,
                        style: AppTextStyles.body.copyWith(
                          color: isSelected
                              ? Colors.white // 파란색 박스 안 글씨는 흰색
                              : Colors.white.withOpacity(0.5), // 흰색 10% 박스 안 글씨는 흰색 50%
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 진행 표시 바
  Widget _buildProgressBar() {
    // 진행도 계산 (0% = 첫 단계, 100% = 두 번째 단계 완료 시점이나, 여기서는 2단계 진입 시 50%? 혹은 100%?)
    // UI상 2단계에서 이미 바가 다 차있어야 하는지, 아니면 2단계 완료 후 차는지?
    // 기존: 1->0%, 2->33%, 3->66%
    // 변경(2단계): 1->0%, 2->100% (비행기 끝까지)
    // 진행도 계산 (0% = 첫 단계, 50% = 두 번째 단계, 100% = 세 번째 단계)
    final double progress = _currentStep == 1 
        ? 0.0 
        : (_currentStep - 1) / 2.0;
    
    final double barWidth = context.w(335); // 전체 너비
    final double filledWidth = barWidth * progress; // 채워진 너비
    final double airplanePosition = (filledWidth - context.w(12)).clamp(0.0, barWidth - context.w(24)); // 비행기 위치 (채워진 끝에, 최소 0)
    
    return Container(
      height: context.h(24), // 비행기 아이콘 높이 고려
      width: barWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 배경 바 (흰색, opacity 0.5)
          Positioned(
            left: 0,
            top: context.h(10), // 비행기 아이콘 중앙에 맞춤
            child: Container(
              width: barWidth,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          // 채워진 바 (파란색)
          if (filledWidth > 0)
            Positioned(
              left: 0,
              top: context.h(10),
              child: Container(
                width: filledWidth,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF0080FF), // B1 컬러
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          // 비행기 아이콘 (진행에 따라 이동)
          Positioned(
            left: airplanePosition, // 비행기 왼쪽 위치
            top: 0,
            child: Image.asset(
              'assets/images/myflight/airplane.png',
              width: 24,
              height: 24,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 안내 텍스트 (1단계)
  Widget _buildInstructionText() {
    return Text(
      '탑승하실 항공편 정보를 입력해 주세요.\nBIMO가 최적의 비행 플랜을 준비해 드릴게요.',
      style: AppTextStyles.bigBody.copyWith(color: Colors.white),
    );
  }
  
  /// 안내 텍스트 (2단계)
  Widget _buildStep2InstructionText() {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.bigBody.copyWith(color: Colors.white),
        children: [
          const TextSpan(text: '조회된 비행편이 맞는지 확인해 주세요.\n'),
          TextSpan(
            text: '원하는 결과가 안 나오나요? 경유편이 있는지 확인해 주세요.',
            style: AppTextStyles.bigBody.copyWith(
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 검색 섹션 (검색 필드 + 경유편 체크박스)
  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 검색 필드 (전체 너비)
        Container(
          width: double.infinity,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/myflight/search.svg',
                  width: 24,
                  height: 24,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _flightNumberController,
                  style: AppTextStyles.body.copyWith(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '편명을 입력해 주세요.',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: Colors.white.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    setState(() {}); // 검색어 변경 시 필터링을 위해 리빌드
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16), // 검색 필드 아래 16px 간격
        // 경유편 체크박스 (오른쪽 정렬)
        Align(
          alignment: Alignment.centerRight,
          child: _buildLayoverCheckboxCompact(),
        ),
      ],
    );
  }
  
  /// 경유편 체크박스 (컴팩트 버전, 2단계용)
  Widget _buildLayoverCheckboxCompact() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _hasLayover = !_hasLayover;
              // 경유 체크박스 상태 변경 시 재검색
              if (_currentStep == 2 && _departureCode != null && _arrivalCode != null && _departureDate != null) {
                _viewModel.searchFlights(
                  origin: _departureCode!,
                  destination: _arrivalCode!,
                  departureDate: _departureDate!,
                  hasLayover: _hasLayover,
                );
              }
            });
          },
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _hasLayover
                  ? AppColors.blue1
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _hasLayover
                ? Center(
                    child: Image.asset(
                      'assets/images/myflight/check.png',
                      width: 10,
                      height: 8,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '경유편이 있어요',
          style: AppTextStyles.body.copyWith(color: Colors.white),
        ),
      ],
    );
  }
  
  /// 뒤로 가기 버튼 처리
  void _handleBackButton() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }




  /// 경유편 체크박스
  Widget _buildLayoverCheckbox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _hasLayover = !_hasLayover;
            });
          },
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _hasLayover
                  ? AppColors.blue1 // B1 컬러
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: _hasLayover
                  ? null
                  : null, // 체크 안 되면 테두리 없음
            ),
            child: _hasLayover
                ? Center(
                    child: Image.asset(
                      'assets/images/myflight/check.png',
                      width: 10,
                      height: 8,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
        ),
        SizedBox(width: 8),
        Text(
          '경유편이 있어요',
          style: AppTextStyles.body.copyWith(color: Colors.white),
        ),
      ],
    );
  }

  /// 공항 선택
  void _selectAirport({required bool isDeparture}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      isScrollControlled: true,
      builder: (context) => AirportSearchBottomSheet(
        onAirportSelected: (Airport airport) {
          setState(() {
            if (isDeparture) {
              _departureCode = airport.airportCode;
              _departureCity = airport.cityName;
            } else {
              _arrivalCode = airport.airportCode;
              _arrivalCity = airport.cityName;
            }
          });
        },
      ),
    );
  }

  /// 공항 스왑
  void _swapAirports() {
    setState(() {
      final tempCode = _departureCode;
      final tempCity = _departureCity;
      _departureCode = _arrivalCode;
      _departureCity = _arrivalCity;
      _arrivalCode = tempCode;
      _arrivalCity = tempCity;
    });
  }

  /// 출발 날짜 선택
  Future<void> _selectDepartureDate() async {
    final DateTime? picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      isScrollControlled: true,
      builder: (context) => const DateSelectionBottomSheet(),
    );
    
    if (picked != null) {
      setState(() {
        _departureDate = picked;
      });
    }
  }

  /// 다음 버튼
  Widget _buildNextButton() {
    final bool isEnabled = _isNextButtonEnabled();
    final String buttonText = _currentStep == 3 ? '확인 및 플랜 생성' : '다음';
    
    return GestureDetector(
      onTap: isEnabled ? _goToNext : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: 335,
              height: 50,
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
                  buttonText,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// 다음 버튼 활성화 여부 확인
         bool _isNextButtonEnabled() {
           if (_currentStep == 1) {
             // 1단계: 공항과 날짜가 모두 선택되어야 함
             return _departureCode != null &&
                 _departureCity != null &&
                 _arrivalCode != null &&
                 _arrivalCity != null &&
                 _departureDate != null;
           } else if (_currentStep == 2) {
             // 2단계: 비행편이 선택되어야 함
             return _viewModel.selectedFlight != null;
           } else if (_currentStep == 3) {
             // 3단계: 비행 목표가 선택되어야 함 (좌석 등급 제거됨)
             return _selectedFlightGoal != null;
           }
           return false;
         }

  /// 다음 페이지로 이동
  void _goToNext() {
    if (_currentStep == 1) {
      // 1단계에서 2단계로 이동
      setState(() {
        _currentStep = 2;
        // 비행편 검색 실행 (ViewModel)
        _viewModel.searchFlights(
          origin: _departureCode!,
          destination: _arrivalCode!,
          departureDate: _departureDate!,
          hasLayover: _hasLayover,
        );
      });
    } else if (_currentStep == 2) {
      // 2단계에서 3단계로 이동
      setState(() {
        _currentStep = 3;
      });
    } else if (_currentStep == 3) {
      _goToFinish();
    }
  }

  void _goToFinish() async {
      // 중복 호출 방지
      if (_isLoading) {
        print('⚠️ 이미 처리 중입니다.');
        return;
      }
      
      // 로딩 화면 표시
      setState(() {
        _isLoading = true;
        _rotationController?.repeat(); // 애니메이션 시작
      });
      _rotationController?.repeat();
      
      try {
        // 1. 사용자 ID 가져오기
        final storage = AuthTokenStorage();
        final userInfo = await storage.getUserInfo();
        final userId = userInfo['userId'];
        
        if (userId == null || userId.isEmpty) {
          throw Exception('사용자 ID를 찾을 수 없습니다.');
        }
        
        // 2. 선택된 비행 정보 확인
        final selectedFlight = _viewModel.selectedFlight;
        if (selectedFlight == null) {
          throw Exception('선택된 비행편이 없습니다.');
        }
        
        // 3. 비행 저장 API 호출
        final flightRepository = FlightRepository();
        final createRequest = CreateFlightRequest.fromFlightSearchData(selectedFlight);
        // 서버에서 생성된 ID 받기
        final serverFlightId = await flightRepository.saveFlight(userId, createRequest);
        print('✅ 비행 저장 완료 (Server ID: $serverFlightId)');
        
        // 4. 로컬에 비행 즉시 저장 (FlightState)
        // 4. 로컬에 비행 즉시 저장 (FlightState)
        final flightId = '${selectedFlight.departure.airport}_${selectedFlight.arrival.airport}_${DateTime.now().millisecondsSinceEpoch}';
        final newFlight = _convertToLocalFlight(selectedFlight, flightId);
        FlightState().addFlight(newFlight);
        print('✅ 로컬 비행 저장 완료 (FlightState)');
        
        // 4-1. Hive에도 비행 저장 (앱 재시작 후에도 유지)
        final localFlight = LocalFlight(
          id: flightId,
          origin: selectedFlight.departure.airport,
          destination: selectedFlight.arrival.airport,
          departureTime: DateTime.parse(selectedFlight.departure.time),
          arrivalTime: DateTime.parse(selectedFlight.arrival.time),
          totalDuration: '${selectedFlight.duration ~/ 60}h ${selectedFlight.duration % 60}m',
          status: 'scheduled',
          lastModified: DateTime.now(),
          flightGoal: _selectedFlightGoal ?? '시차적응',
          seatClass: 'ECONOMY',
        );
        final localFlightRepo = LocalFlightRepository();
        await localFlightRepo.init();
        await localFlightRepo.saveFlight(localFlight);
        print('✅ Hive에 비행 저장 완료');
        
        // 5. 타임라인 생성 API 호출 (실패해도 계속 진행)
        bool timelineSuccess = false;
        try {
          final timelineRequest = TimelineRequest.fromFlightSearchData(
            data: selectedFlight,
            seatClass: 'ECONOMY',
            flightGoal: _selectedFlightGoal ?? '시차적응',
          );
          // 변경된 API 호출: userId, serverFlightId 전달
          final timelineData = await flightRepository.generateTimeline(userId, serverFlightId, timelineRequest);
          
          if (timelineData != null) {
            print('✅ 타임라인 생성 완료');
            TimelineState().timelineData = timelineData;
            timelineSuccess = true;
            
            // Hive에 타임라인 저장 (비행은 이미 저장됨)
            final timelineEvents = (timelineData['timeline_events'] as List<dynamic>)
                .map((e) => LocalTimelineEvent.fromApiResponse(
                      e as Map<String, dynamic>,
                      localFlight.id,
                    ))
                .toList();
            
            final localTimelineRepo = LocalTimelineRepository();
            await localTimelineRepo.init();
            await localTimelineRepo.saveTimeline(localFlight.id, timelineEvents);
            
            // 원본도 저장 (AI 초기화용) - 별도 인스턴스 생성
            final originalEvents = (timelineData['timeline_events'] as List<dynamic>)
                .map((e) => LocalTimelineEvent.fromApiResponse(
                      e as Map<String, dynamic>,
                      localFlight.id,
                    ))
                .toList();
            await localTimelineRepo.saveOriginalTimeline(localFlight.id, originalEvents);
            print('✅ 타임라인 로컬 저장 완료: ${localFlight.id} (${timelineEvents.length}개)');

            // [Notification] 비행 3시간 전 알림 스케줄링
            try {
              final scheduledTime = localFlight.departureTime.subtract(const Duration(hours: 3));
              final flightName = '${localFlight.origin} ✈️ ${localFlight.destination}';
              
              await NotificationService().scheduleFlightReminder(
                flightNumber: flightName,
                scheduledTime: scheduledTime,
              );
              print('✅ 알림 스케줄링 등록: $flightName (3시간 전: $scheduledTime)');
            } catch (e) {
              print('⚠️ 알림 스케줄링 실패: $e');
            }
          }
        } catch (e) {
          print('⚠️ 타임라인 생성 실패 (비행은 저장됨): $e');
        }
        
        // 6. 성공 여부에 따라 페이지 이동
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _rotationController?.stop(); // 애니메이션 중지
          
          // 타임라인 성공 시 FlightPlanPage, 실패 시 MyFlight
          if (timelineSuccess) {
            // 타임라인 페이지로 이동 (Flight ID 전달)
            context.goNamed('flight-plan', extra: {'flightId': flightId});
          } else {
            // 실패 시 목록으로 이동
            context.goNamed('home', extra: {'initialIndex': 1});
          }
        }
      } catch (e) {
        // 에러 처리
        print('❌ 비행 등록 실패: $e');
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _rotationController?.stop();
          
          // 에러 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('비행 등록에 실패했습니다'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  
  /// FlightSearchData를 Flight 모델로 변환 (로컬 저장용)
  Flight _convertToLocalFlight(FlightSearchData data, String flightId) {
    // 공항 코드에서 도시 이름 추론
    String getCityName(String airportCode) {
      const cityMap = {
        // 한국
        'ICN': '인천',
        'GMP': '김포',
        'PUS': '부산',
        'CJU': '제주',
        // 일본
        'NRT': '도쿄',
        'HND': '도쿄',
        'KIX': '오사카',
        'NGO': '나고야',
        // 미국
        'JFK': '뉴욕',
        'LAX': '로스앤젤레스',
        'ORD': '시카고',
        'SFO': '샌프란시스코',
        'SEA': '시애틀',
        'IAH': '휴스턴',
        'MIA': '마이애미',
        'BOS': '보스턴',
        'LAS': '라스베이거스',
        // 캐나다
        'YYZ': '토론토',
        'YVR': '밴쿠버',
        // 유럽
        'LHR': '런던',
        'CDG': '파리',
        'FRA': '프랑크푸르트',
        'AMS': '암스테르담',
        'FCO': '로마',
        'BCN': '바르셀로나',
        // 중동/아시아
        'DXB': '두바이',
        'SIN': '싱가포르',
        'BKK': '방콕',
        'HKG': '홍콩',
        'PVG': '상하이',
        'PEK': '베이징',
      };
      return cityMap[airportCode] ?? airportCode;
    }
    
    // Duration 포맷
    String formatDuration(int minutes) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '${hours}h ${mins}m';
    }
    
    // 시간 포맷 (HH:MM AM/PM)
    String formatTime(String isoTime) {
      try {
        final dt = DateTime.parse(isoTime.endsWith('Z') ? isoTime : '${isoTime}Z');
        final hour = dt.hour;
        final minute = dt.minute;
        final period = hour >= 12 ? 'PM' : 'AM';
        final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
      } catch (e) {
        return isoTime;
      }
    }
    
    // 날짜 포맷 (YYYY.MM.DD. (요일))
    String formatDate(String isoTime) {
      try {
        final dt = DateTime.parse(isoTime.endsWith('Z') ? isoTime : '${isoTime}Z');
        const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
        final weekday = weekdays[dt.weekday % 7];
        return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}. ($weekday)';
      } catch (e) {
        return '';
      }
    }
    
    return Flight(
      departureCode: data.departure.airport,
      departureCity: getCityName(data.departure.airport),
      arrivalCode: data.arrival.airport,
      arrivalCity: getCityName(data.arrival.airport),
      duration: formatDuration(data.duration),
      departureTime: formatTime(data.departure.time),
      arrivalTime: formatTime(data.arrival.time),
      rating: null,
      date: formatDate(data.departure.time),
      id: flightId, // ID 추가
    );
  }
  
  
  /// 로딩 화면
  Widget _buildLoadingScreen() {
    return Container(
      color: AppTheme.darkTheme.scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 회전하는 비행기 아이콘 (잔상 효과)
            _buildRotatingAirplane(),
            // 텍스트 제거 - 모든 로딩에서 동일한 UI 사용
          ],
        ),
      ),
    );
  }
  
  /// 회전하는 비행기 아이콘 (원형 궤적 따라 이동)
  Widget _buildRotatingAirplane() {
    if (_rotationController == null) return const SizedBox();
    
    // 비행기 아이콘 크기 (34x34)
    const double airplaneSize = 34.0;
    // 원형 경로의 반지름 (CircularProgressIndicator의 실제 반지름)
    const double circleRadius = 33.0;
    // 컨테이너 크기 (원형 경로 + 비행기 아이콘 크기 고려)
    const double containerSize = (circleRadius + airplaneSize / 2) * 2;
    
    return SizedBox(
      width: containerSize,
      height: containerSize,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // CircularProgressIndicator로 원형 진행 표시 (그라데이션 포함)
          AnimatedBuilder(
            animation: _rotationController!,
            builder: (context, child) {
              return SizedBox(
                width: circleRadius * 2,
                height: circleRadius * 2,
                child: CircularProgressIndicator(
                  value: _rotationController!.value,
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              );
            },
          ),
          // 비행기 아이콘 (궤적 위에 배치)
          AnimatedBuilder(
            animation: _rotationController!,
            builder: (context, child) {
              // CircularProgressIndicator는 12시 방향(-π/2)에서 시작하여 시계 방향으로 진행
              final startAngle = -math.pi / 2;
              final angle = startAngle + (_rotationController!.value * 2 * math.pi);
              final centerX = containerSize / 2;
              final centerY = containerSize / 2;
              
              // 비행기 아이콘 중심 위치 계산 (원형 경로 위)
              final x = centerX + circleRadius * math.cos(angle);
              final y = centerY + circleRadius * math.sin(angle);
              
              return Positioned(
                left: x - airplaneSize / 2, // 비행기 아이콘 중심 기준
                top: y - airplaneSize / 2,
                child: Transform.rotate(
                  angle: angle + math.pi / 2, // 비행기가 궤적을 따라 향하도록
                  child: Image.asset(
                    'assets/images/myflight/airplane.png',
                    width: airplaneSize,
                    height: airplaneSize,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  // _searchFlights, _filterFlights 제거됨 (ViewModel이 처리)
  
  /// 날짜 포맷팅
  String _formatDate(DateTime date) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}. ($weekday)';
  }

  /// 폼 초기화
  void _resetForm() {
    setState(() {
      _departureCode = null;
      _departureCity = null;
      _arrivalCode = null;
      _arrivalCity = null;
      _departureDate = null;
      _hasLayover = false;
    });
  }
}

