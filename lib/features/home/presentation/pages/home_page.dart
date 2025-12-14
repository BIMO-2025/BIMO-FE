import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_tab_bar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../widgets/search_tab_selector.dart';
import '../widgets/airline_search_input.dart';
import '../widgets/destination_search_section.dart';
import '../widgets/popular_airlines_section.dart';
import '../widgets/airport_search_bottom_sheet.dart';
import '../widgets/date_selection_bottom_sheet.dart';
import 'airline_search_result_page.dart';
import 'popular_airlines_page.dart';
import '../../domain/models/airport.dart';
import '../../data/datasources/airline_api_service.dart';
import '../../data/models/popular_airline_response.dart';
import '../../../my/presentation/pages/my_page.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/router/route_names.dart';
import '../../../../core/storage/auth_token_storage.dart';
import '../../../myflight/pages/myflight_page.dart';
import '../../../../core/services/notification_service.dart';

/// 홈 화면 메인 페이지
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Bottom tab bar index
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      extendBody: true, // 본문이 탭바 영역까지 확장됨
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 커스텀 앱바 (높이 82px)
            ValueListenableBuilder<bool>(
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
            // 본문 영역
            Expanded(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(
                    context,
                  ).unfocus(); // Dismiss keyboard on tap outside
                },
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadPopularAirlines();
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
      final List<dynamic> airlines = await _apiService.getSortedAirlines();

      // 상위 3개만 선택
      final top3 = airlines.take(3).toList();

      // 응답 데이터를 UI 모델로 변환
      final List<AirlineData> airlineDataList = top3.map((airline) {
        return AirlineData(
          name: airline.name,
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
        name: '대한항공',
        rating: 4.3,
        logoPath: 'assets/images/home/korean_air_logo.png',
      ),
      AirlineData(
        name: '아시아나항공',
        rating: 4.3,
        logoPath: 'assets/images/home/asiana_logo.png',
      ),
      AirlineData(
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

          // 항공사 정보 조회
          final List<PopularAirlineResponse> airlineResults = [];
          if (response.airlines.isNotEmpty) {
            for (final airlineInfo in response.airlines) {
              try {
                final results = await _apiService.searchAirlines(
                  query: airlineInfo.airlineName,
                );
                if (results.isNotEmpty) {
                  airlineResults.add(results.first);
                }
              } catch (e) {
                print('항공사 정보 조회 실패: ${airlineInfo.airlineName} - $e');
              }
            }
          }

          // 성공!
          success = true;
          
          // 로딩 다이얼로그 닫기
          if (mounted) Navigator.pop(context);

          // 결과 페이지로 이동 (검색 결과 전달)
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
                  initialSearchResults: airlineResults, // 검색 결과 전달
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
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
