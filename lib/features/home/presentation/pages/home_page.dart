import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_tab_bar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../widgets/search_tab_selector.dart';
import '../widgets/airline_search_input.dart';
import '../widgets/destination_search_section.dart';
import '../widgets/popular_airlines_section.dart';
import '../widgets/airport_search_bottom_sheet.dart';
import '../widgets/date_selection_bottom_sheet.dart';
import 'airline_search_result_page.dart';
import 'popular_airlines_page.dart';
import '../../domain/models/airport.dart';
import '../../domain/models/airline.dart'; // Airline 모델 import
import '../../data/datasources/airline_api_service.dart';
import '../../data/models/popular_airline_response.dart';
import '../../../my/presentation/pages/my_page.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/router/route_names.dart';
import '../../../../core/storage/auth_token_storage.dart';
import '../../../myflight/pages/myflight_page.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/airline_name_mapper.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/airline.dart';

/// 홈 화면 메인 페이지
class HomePage extends StatefulWidget {
  final int initialIndex;

  const HomePage({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex; // Bottom tab bar index

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // 초기 인덱스 설정
    _loadPopularAirlines();
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      setState(() {
        _selectedIndex = widget.initialIndex;
      });
    }
  }
  int _searchTabIndex = 0; // Search tab index (0: Airline, 1: Destination)
  final TextEditingController _airlineSearchController =
      TextEditingController();

  // Selected airports
  Airport? _departureAirport;
  Airport? _arrivalAirport;
  DateTime? _selectedDate;

  // API Service
  final AirlineApiService _apiService = AirlineApiService();

  // Popular Airlines State
  List<AirlineData> _popularAirlines = [];
  bool _isLoadingAirlines = false;
  String _weekLabel = '';
  String? _errorMessage;
  bool _isOfflineMode = false; // 오프라인 모드 상태 복구

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      extendBody: true, // 본문이 탭바 영역까지 확장됨
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 본문 영역 (가장 아래 레이어)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(
                    context,
                  ).unfocus(); // Dismiss keyboard on tap outside
                },
                child: _buildBody(),
              ),
            ),
            
            // 커스텀 앱바 (상단 고정, 투명 그라데이션)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ValueListenableBuilder<bool>(
                valueListenable: NotificationService().hasUnread,
                builder: (context, hasUnread, child) {
                  return CustomAppBar(
                    hasUnreadNotifications: hasUnread,
                    onNotificationTap: () {
                      context.push('/notification');
                    },
                    showLogo: _selectedIndex == 0, // 홈 탭일 때만 로고 표시
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }



  @override
  void dispose() {
    _airlineSearchController.dispose();
    super.dispose();
  }

  /// 평점 순 정렬된 항공사 로드 (상위 3개)
  Future<void> _loadPopularAirlines() async {
    setState(() {
      _isLoadingAirlines = true;
      _errorMessage = null;
    });

    try {
      // 평점 순 정렬 항공사 API 호출
      final List<PopularAirlineResponse> airlines = await _apiService.getSortedAirlines();

      // 상위 3개만 선택
      final top3 = airlines.take(3).toList();

      // 응답 데이터를 UI 모델로 변환
      final List<AirlineData> airlineDataList = top3.map((airline) {
        return AirlineData(
          id: airline.id, // 추가
          code: airline.code, // 추가
          name: AirlineNameMapper.toKorean(airline.name), // 한국어로 변환
          rating: airline.rating,
          logoPath: airline.logoUrl.isNotEmpty
              ? airline.logoUrl
              : 'assets/images/home/korean_air_logo.png', // 기본 이미지
        );
      }).toList();

      setState(() {
        // 데이터가 없으면 기본 데이터 표시
        if (airlineDataList.isEmpty) {
          _popularAirlines = _getDefaultAirlines();
        } else {
          _popularAirlines = airlineDataList;
        }
        _weekLabel = _getCurrentWeekLabel(); // 현재 주차 라벨 사용
        _isLoadingAirlines = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '인기 항공사를 불러오는데 실패했습니다: $e';
        _isLoadingAirlines = false;
        // 에러 시 기본 데이터 표시
        _popularAirlines = _getDefaultAirlines();
        _weekLabel = _getCurrentWeekLabel();
      });
    }
  }

  /// 기본 항공사 데이터 (에러 시 또는 로딩 중)
  List<AirlineData> _getDefaultAirlines() {
    return [
      AirlineData(
        id: '1',
        code: 'KE',
        name: '대한항공',
        rating: 4.3,
        logoPath: 'assets/images/home/korean_air_logo.png',
      ),
      AirlineData(
        id: '2',
        code: 'OZ',
        name: '아시아나항공',
        rating: 4.3,
        logoPath: 'assets/images/home/asiana_logo.png',
      ),
      AirlineData(
        id: '3',
        code: 'TW',
        name: '티웨이항공',
        rating: 4.0,
        logoPath: 'assets/images/home/tway_logo.png',
      ),
    ];
  }

  /// 메인 바디 영역
  Widget _buildBody() {
    // 탭 인덱스에 따라 다른 페이지 표시
    switch (_selectedIndex) {
      case 0: // 홈 탭
        return _buildHomeContent();
      case 1: // 나의비행 탭
        return _buildMyFlightContent();
      case 2: // 마이 탭
        return const MyPage();
      default:
        return _buildHomeContent();
    }
  }

  /// 홈 탭 컨텐츠
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: context.h(82)), // 앱바 높이만큼 상단 여백
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchTabSelector(
            selectedIndex: _searchTabIndex,
            onTap: (index) {
              setState(() {
                _searchTabIndex = index;
              });
            },
            onSearchTap: () => _navigateToSearchResult(),
          ),
          if (_searchTabIndex == 0)
            AirlineSearchInput(controller: _airlineSearchController)
          else
            DestinationSearchSection(
              departureAirport:
                  _departureAirport != null
                      ? '${_departureAirport!.cityName} (${_departureAirport!.airportCode})'
                      : '인천 (INC)',
              arrivalAirport:
                  _arrivalAirport != null
                      ? '${_arrivalAirport!.cityName} (${_arrivalAirport!.airportCode})'
                      : '파리 (CDG)',
              isDepartureSelected: _departureAirport != null,
              isArrivalSelected: _arrivalAirport != null,
              departureDate:
                  _selectedDate != null
                      ? '${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일'
                      : '',
              onDepartureTap: () {
                _showAirportSearchBottomSheet(isDeparture: true);
              },
              onArrivalTap: () {
                _showAirportSearchBottomSheet(isDeparture: false);
              },
              onDateTap: () {
                _showDateSelectionBottomSheet();
              },
              onSwapAirports: () {
                if (_departureAirport != null && _arrivalAirport != null) {
                  setState(() {
                    final temp = _departureAirport;
                    _departureAirport = _arrivalAirport;
                    _arrivalAirport = temp;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('출발지와 도착지를 모두 선택해주세요.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          if (_isLoadingAirlines)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          else if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _loadPopularAirlines,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            )
          else
            PopularAirlinesSection(
              weekLabel:
                  _weekLabel.isNotEmpty ? _weekLabel : _getCurrentWeekLabel(),
              airlines:
                  _popularAirlines.isNotEmpty
                      ? _popularAirlines
                      : _getDefaultAirlines(),
              onMoreTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PopularAirlinesPage(),
                  ),
                );
              },
              onItemTap: (data) => _navigateToAirlineDetail(data),
            ),
        ],
      ),
    );
  }

  /// 현재 날짜의 주차 라벨 생성 (예: "[11월 4주]")
  String _getCurrentWeekLabel() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    // DateTime.weekday: Mon=1, ... Sat=6, Sun=7
    // % 7 -> Sun=0, Mon=1, ... Sat=6
    final firstDayWeekday = firstDayOfMonth.weekday % 7;
    final weekNumber = ((now.day + firstDayWeekday) / 7).ceil();
    return '[${now.month}월 ${weekNumber}주]';
  }

  /// 공항 검색 바텀시트 표시
  void _showAirportSearchBottomSheet({required bool isDeparture}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5), // 50% black overlay
      isScrollControlled: true,
      builder:
          (context) => AirportSearchBottomSheet(
            onAirportSelected: (airport) {
              setState(() {
                if (isDeparture) {
                  _departureAirport = airport;
                } else {
                  _arrivalAirport = airport;
                }
              });
            },
          ),
    );
  }

  /// 날짜 선택 바텀시트 표시
  Future<void> _showDateSelectionBottomSheet() async {
    final result = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      isScrollControlled: true,
      builder: (context) => const DateSelectionBottomSheet(),
    );

    if (result != null) {
      setState(() {
        _selectedDate = result;
      });
    }
  }

  /// 검색 결과 화면으로 이동
  Future<void> _navigateToSearchResult() async {
    // 유효성 검사
    if (_searchTabIndex == 0) {
      // 항공사 검색 탭 - 즉시 이동
      if (_airlineSearchController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('검색할 항공사를 입력해주세요.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AirlineSearchResultPage(
            initialTabIndex: _searchTabIndex,
            departureAirport: _departureAirport,
            arrivalAirport: _arrivalAirport,
            selectedDate: _selectedDate,
            airlineQuery: _airlineSearchController.text,
          ),
        ),
      );
    } else {
      // 목적지 검색 탭 - API 호출 후 이동
      if (_departureAirport == null ||
          _arrivalAirport == null ||
          _selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('출발지, 도착지, 날짜를 모두 선택해주세요.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // 로딩 다이얼로그 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      // 날짜 포맷
      final formattedDate =
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

      // 항공편 검색 API 호출 (최대 5번 재시도)
      const maxRetries = 5;
      int attempt = 0;
      bool success = false;

      while (!success && attempt < maxRetries) {
        attempt++;
        print('🔄 검색 시도 $attempt/$maxRetries');

        try {
          final response = await _apiService.searchFlights(
            origin: _departureAirport!.airportCode,
            destination: _arrivalAirport!.airportCode,
            departureDate: formattedDate,
            adults: 1,
          );

          // 항공편 데이터 그룹화 (항공사 + 경유지 기준)
          print('🟢 API 성공: ${response.data.length}개 항공편 데이터 받음');
          final groupedFlights = _groupFlightsByAirlineAndRouting(response.data);
          print('🟢 그룹화 완료: ${groupedFlights.length}개 고유 경로');

          // 성공!
          success = true;
          
          // 로딩 다이얼로그 닫기
          if (mounted) Navigator.pop(context);

          // 결과 페이지로 이동 (그룹화된 데이터 전달)
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AirlineSearchResultPage(
                  initialTabIndex: _searchTabIndex,
                  departureAirport: _departureAirport,
                  arrivalAirport: _arrivalAirport,
                  selectedDate: _selectedDate,
                  airlineQuery: '',
                  initialSearchResults: groupedFlights, // 그룹화된 항공사 리스트 전달
                ),
              ),
            );
          }
        } catch (e) {
          print('❌ 검색 시도 $attempt 실패: $e');
          
          // 마지막 시도였다면 에러 처리
          if (attempt >= maxRetries) {
            if (mounted) Navigator.pop(context); // 로딩 다이얼로그 닫기
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('항공편 검색에 실패했습니다.\n잠시 후 다시 시도해주세요.'),
                  duration: Duration(seconds: 3),
                ),
              );
            }
            return;
          }
          
          // 1초 대기 후 재시도
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }
  }

  /// 나의비행 탭 컨텐츠 (TODO: 구현 필요)
  Widget _buildMyFlightContent() {
    return const MyFlightPage();
  }

  /// 하단 네비게이션 바
  Widget _buildBottomNavigationBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: CustomTabBar(
        currentIndex: _selectedIndex,
        isOnline: !_isOfflineMode, // 오프라인 모드 상태 전달
        onToggleOffline: () {
          setState(() {
            _isOfflineMode = !_isOfflineMode;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isOfflineMode ? '오프라인 모드로 전환되었습니다.' : '온라인 모드로 전환되었습니다.'),
              duration: const Duration(milliseconds: 1000),
            ),
          );
        },
        onTap: (index) {
          // if (index == 1) {
          //   context.go(RouteNames.myFlight);
          //   return;
          // }
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  /// 항공편 데이터 그룹화 (항공사 + 경유지 기준 중복 제거)
  List<PopularAirlineResponse> _groupFlightsByAirlineAndRouting(List<dynamic> flights) {
    final Map<String, PopularAirlineResponse> uniqueAirlines = {};
    
    for (final flight in flights) {
      final airlineCode = flight.airline?.name ?? '';
      final logoUrl = flight.airline?.logo ?? '';
      
      // 중복 방지: 같은 항공사는 한 번만 추가
      if (!uniqueAirlines.containsKey(airlineCode) && airlineCode.isNotEmpty) {
        uniqueAirlines[airlineCode] = PopularAirlineResponse(
          id: airlineCode,
          name: airlineCode, // 항공사 코드를 이름으로 사용
          code: airlineCode,
          country: '', // API에 국가 정보 없음
          alliance: '', // API에 제휴 정보 없음
          type: 'FSC', // 기본값
          logoUrl: logoUrl,
          rating: flight.ratingScore, // [FIX] 모델의 평점 사용
          reviewCount: flight.reviewCountNum, // [FIX] 모델의 리뷰 수 사용
          rank: 0, // 순위 없음
        );
      }
    }
    
    return uniqueAirlines.values.toList();
  }


  void _navigateToAirlineDetail(AirlineData data) {
    // AirlineData -> Airline 변환 (상세 페이지 이동용)
    // 필수 필드는 더미값으로 채우고, code를 통해 상세 조회 유도
    final airline = Airline(
      name: data.name,
      code: data.code,
      englishName: '', 
      logoPath: data.logoPath,
      imagePath: '',
      tags: [],
      rating: data.rating,
      reviewCount: 0,
      detailRating: const AirlineDetailRating(seatComfort: 0, foodAndBeverage: 0, service: 0, cleanliness: 0, punctuality: 0),
      reviewSummary: const AirlineReviewSummary(goodPoints: [], badPoints: []),
      basicInfo: const AirlineBasicInfo(headquarters: '', hubAirport: '', alliance: '', classes: ''),
    );

    context.pushNamed(
      'airline-detail',
      extra: airline,
    );
  }
}
