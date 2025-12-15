import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../domain/models/airline.dart';
import '../../domain/models/airport.dart';
import '../../data/mock_airlines.dart';
import '../../data/datasources/airline_api_service.dart';
import '../../data/models/popular_airline_response.dart';
import '../../data/airline_mapper.dart';
import '../widgets/search_tab_selector.dart';
import '../widgets/airline_search_input.dart';
import '../widgets/destination_search_section.dart';
import '../widgets/airport_search_bottom_sheet.dart';
import '../widgets/date_selection_bottom_sheet.dart';
import 'airline_detail_page.dart';

class AirlineSearchResultPage extends StatefulWidget {
  final int initialTabIndex;
  final Airport? departureAirport;
  final Airport? arrivalAirport;
  final DateTime? selectedDate;
  final String? airlineQuery;
  final List<PopularAirlineResponse>? initialSearchResults; // 초기 검색 결과

  const AirlineSearchResultPage({
    super.key,
    required this.initialTabIndex,
    this.departureAirport,
    this.arrivalAirport,
    this.selectedDate,
    this.airlineQuery,
    this.initialSearchResults, // 추가
  });

  @override
  State<AirlineSearchResultPage> createState() =>
      _AirlineSearchResultPageState();
}

class _AirlineSearchResultPageState extends State<AirlineSearchResultPage> {
  late int _searchTabIndex;
  late TextEditingController _airlineSearchController;
  
  // Local state for destination search
  Airport? _departureAirport;
  Airport? _arrivalAirport;
  DateTime? _selectedDate;
  
  // Sort state
  int _selectedSortIndex = 0; // 0: 평점 높은 순, 1: 리뷰 많은 순

  // API Service
  final AirlineApiService _apiService = AirlineApiService();
  
  // API 상태 관리
  bool _isLoading = false;
  String? _errorMessage;
  List<PopularAirlineResponse> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchTabIndex = widget.initialTabIndex;
    _airlineSearchController =
        TextEditingController(text: widget.airlineQuery);

    // Initialize local state
    _departureAirport = widget.departureAirport;
    _arrivalAirport = widget.arrivalAirport;
    _selectedDate = widget.selectedDate;

    // 초기 검색 결과가 있으면 사용 (홈에서 전달받은 경우)
    if (widget.initialSearchResults != null &&
        widget.initialSearchResults!.isNotEmpty) {
      _searchResults = widget.initialSearchResults!;
      _isLoading = false;
    } else if (widget.airlineQuery != null && widget.airlineQuery!.isNotEmpty) {
      // 초기 검색어가 있으면 API 호출 (항공사 검색)
      _searchAirlines();
    }
  }

  @override
  void dispose() {
    _airlineSearchController.dispose();
    super.dispose();
  }

  /// 항공사 검색 API 호출
  Future<void> _searchAirlines() async {
    final query = _airlineSearchController.text.trim();
    
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 한글 키워드를 항공사 코드로 변환
      final searchKeyword = AirlineMapper.convertSearchKeyword(query);
      
      print('🔍 원본 검색어: $query');
      print('🔍 변환된 검색어: $searchKeyword');
      
      final results = await _apiService.searchAirlines(query: searchKeyword);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '검색 중 오류가 발생했습니다: $e';
        _isLoading = false;
        _searchResults = [];
      });
    }
  }

  /// 목적지 기반 항공편 검색 API 호출 (재시도 포함)
  Future<void> _searchFlights() async {
    // 필수 파라미터 확인
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

    const maxRetries = 5; // 최대 재시도 횟수
    int attempt = 0;
    bool success = false;

    while (!success && attempt < maxRetries) {
      try {
        attempt++;
        print('🔄 검색 시도 $attempt/$maxRetries');

        // 날짜 포맷: YYYY-MM-DD
        final formattedDate = 
            '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

        final response = await _apiService.searchFlights(
          origin: _departureAirport!.airportCode,
          destination: _arrivalAirport!.airportCode,
          departureDate: formattedDate,
          adults: 1,
        );

        // 성공! airlines 리스트를 사용하여 항공사 정보 조회
        if (response.airlines.isNotEmpty) {
          // 각 항공사 이름으로 검색하여 상세 정보 가져오기
          final List<PopularAirlineResponse> airlineResults = [];
          for (final airlineInfo in response.airlines) {
            try {
              // airlineName만 추출하여 검색
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

          // 성공!
          success = true;
          
          // 로딩 다이얼로그 닫기
          if (mounted) Navigator.pop(context);
          
          setState(() {
            _searchResults = airlineResults;
            _isLoading = false;
            _errorMessage = null;
          });
          return; // 성공하면 종료
        } else {
          // 결과가 없음
          success = true;
          
          // 로딩 다이얼로그 닫기
          if (mounted) Navigator.pop(context);
          
          setState(() {
            _searchResults = [];
            _isLoading = false;
            _errorMessage = null;
          });
          return; // 결과가 없어도 종료
        }
      } catch (e) {
        print('❌ 검색 시도 $attempt 실패: $e');
        
        // 마지막 시도였다면 에러 처리
        if (attempt >= maxRetries) {
          // 로딩 다이얼로그 닫기
          if (mounted) Navigator.pop(context);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('항공편 검색에 실패했습니다.\n잠시 후 다시 시도해주세요.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
          
          setState(() {
            _isLoading = false;
            _errorMessage = '항공편 검색에 실패했습니다.';
            _searchResults = [];
          });
          return;
        }
        
        // 재시도 전 대기 (1초)
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  List<Airline> _getFilteredAirlines() {
    List<Airline> result;
    
    // API 결과가 있으면 사용 (항공사 검색 또는 목적지 검색 모두)
    if (_searchResults.isNotEmpty) {
      // API 응답을 Airline 모델로 변환
      result = _searchResults.map<Airline>((apiAirline) {
        // mock 데이터에서 매칭되는 항공사 찾기 (상세 정보용)
        final mockAirline = mockAirlines.firstWhere(
          (mock) => mock.name == apiAirline.name,
          orElse: () => mockAirlines.first, // 없으면 기본값
        );
        
        // API 데이터와 mock 데이터 병합
        return Airline(
          name: apiAirline.name,
          code: apiAirline.code, // 항공사 코드 추가
          englishName: mockAirline.englishName,
          rating: apiAirline.rating,
          reviewCount: apiAirline.reviewCount,
          logoPath: apiAirline.logoUrl.isNotEmpty 
              ? apiAirline.logoUrl 
              : mockAirline.logoPath,
          imagePath: mockAirline.imagePath,
          tags: mockAirline.tags,
          detailRating: mockAirline.detailRating,
          reviewSummary: mockAirline.reviewSummary,
          basicInfo: mockAirline.basicInfo,
        );
      }).toList();
    } else {
      result = [];
    }

    // Sort logic
    if (_selectedSortIndex == 0) {
      // 평점 높은 순
      result.sort((a, b) => b.rating.compareTo(a.rating));
    } else {
      // 리뷰 많은 순
      result.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final filteredAirlines = _getFilteredAirlines();

    return Scaffold(
      backgroundColor: const Color(0xFF131313), // Dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF131313),
        elevation: 0,
        leadingWidth: context.w(60), // 20 padding + 40 icon
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
          '항공사 검색',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: context.fs(17),
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Search Inputs (Reused)
            _buildSearchSection(context),
            
            SizedBox(height: context.h(24)),

            // 2. Search Results Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.w(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '총 ${filteredAirlines.length} 건의 검색 결과',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: context.fs(15),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSortIndex = 0;
                          });
                        },
                        child: Text(
                          '평점 높은 순',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: context.fs(13),
                            fontWeight: FontWeight.w400,
                            color: _selectedSortIndex == 0
                                ? Colors.white
                                : const Color(0xFF8E8E93),
                          ),
                        ),
                      ),
                      SizedBox(width: context.w(8)),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSortIndex = 1;
                          });
                        },
                        child: Text(
                          '리뷰 많은 순',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: context.fs(13),
                            fontWeight: FontWeight.w400,
                            color: _selectedSortIndex == 1
                                ? Colors.white
                                : const Color(0xFF8E8E93),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: context.h(16)),

            // 3. Result List (로딩/에러/결과)
            if (_isLoading && _searchTabIndex == 0)
              Padding(
                padding: EdgeInsets.symmetric(vertical: context.h(50)),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            else if (_errorMessage != null && _searchTabIndex == 0)
              Padding(
                padding: EdgeInsets.all(context.w(20)),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: context.h(12)),
                      ElevatedButton(
                        onPressed: _searchAirlines,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              )
            else if (filteredAirlines.isEmpty && _searchTabIndex == 0)
              Padding(
                padding: EdgeInsets.symmetric(vertical: context.h(50)),
                child: Center(
                  child: Text(
                    '검색 결과가 없습니다.',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: context.fs(15),
                      color: const Color(0xFF8E8E93),
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: context.w(20)),
                itemCount: filteredAirlines.length,
                itemBuilder: (context, index) {
                  final airline = filteredAirlines[index];
                  // Mocking route info based on index/airline for demo
                  final isDirect = airline.name == '대한항공' || airline.name == '에어프랑스';
                  
                  return _buildAirlineResultCard(context, airline, isDirect);
                },
              ),
            SizedBox(height: context.h(40)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Column(
      children: [
        SearchTabSelector(
          selectedIndex: _searchTabIndex,
          onTap: (index) {
            setState(() {
              _searchTabIndex = index;
            });
          },
          onSearchTap: () {
            // 돋보기 버튼 클릭 시 검색 실행
            if (_searchTabIndex == 0) {
              _searchAirlines(); // 항공사 검색
            } else {
              _searchFlights(); // 목적지 기반 항공편 검색
            }
          },
        ),
        if (_searchTabIndex == 0)
          AirlineSearchInput(controller: _airlineSearchController)
        else
          DestinationSearchSection(
            departureAirport: _departureAirport != null
                ? '${_departureAirport!.cityName} (${_departureAirport!.airportCode})'
                : '인천 (INC)',
            arrivalAirport: _arrivalAirport != null
                ? '${_arrivalAirport!.cityName} (${_arrivalAirport!.airportCode})'
                : '파리 (CDG)',
            isDepartureSelected: _departureAirport != null,
            isArrivalSelected: _arrivalAirport != null,
            departureDate: _selectedDate != null
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
              }
            },
          ),
      ],
    );
  }

  /// 공항 검색 바텀시트 표시
  void _showAirportSearchBottomSheet({required bool isDeparture}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      isScrollControlled: true,
      builder: (context) => AirportSearchBottomSheet(
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

  Widget _buildAirlineResultCard(
    BuildContext context,
    Airline airline,
    bool isDirect,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AirlineDetailPage(airline: airline),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: context.h(12)),
        padding: EdgeInsets.symmetric(horizontal: context.w(20), vertical: context.h(20)),
        constraints: BoxConstraints(
          minHeight: context.h(90), // 90으로 변경
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A), // Dark grey card
          borderRadius: BorderRadius.circular(context.w(16)),
        ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Airline Name
              Text(
                airline.name,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: context.fs(17),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: context.h(4)), // 간격 조정
              // Rating & Review Count
              Row(
                children: [
                  Text(
                    '${airline.rating}',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: context.fs(13),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8E8E93),
                    ),
                  ),
                  Text(
                    '/5.0',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: context.fs(13),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8E8E93).withOpacity(0.5),
                    ),
                  ),
                  SizedBox(width: context.w(4)),
                  Text(
                    '(${_formatNumber(airline.reviewCount)})',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: context.fs(13),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Logo
          Container(
            width: context.w(50),
            height: context.w(50),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(context.w(14)), // 14로 변경
            ),
            padding: EdgeInsets.all(context.w(8)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.w(6)),
              child: _buildLogoImage(airline.logoPath),
            ),
          ),
        ],
      ),
    ));
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  /// 로고 이미지 빌드 (네트워크 URL 또는 로컬 asset)
  Widget _buildLogoImage(String logoPath) {
    final isNetworkImage = logoPath.startsWith('http://') || 
                          logoPath.startsWith('https://');

    if (isNetworkImage) {
      return Image.network(
        logoPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.flight,
            color: Colors.grey.withOpacity(0.3),
            size: 24,
          );
        },
      );
    } else {
      return Image.asset(
        logoPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.flight,
            color: Colors.grey.withOpacity(0.3),
            size: 24,
          );
        },
      );
    }
  }
}
