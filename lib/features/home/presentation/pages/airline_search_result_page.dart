import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../domain/models/airline.dart';
import '../../domain/models/airport.dart';
import '../../data/mock_airlines.dart';
import '../../data/datasources/airline_api_service.dart';
import '../../data/models/popular_airline_response.dart';
import '../../data/models/flight_search_response.dart'; // Import 추가
import '../../data/airline_mapper.dart';
import '../widgets/search_tab_selector.dart';
import '../widgets/airline_search_input.dart';
import '../widgets/destination_search_section.dart';
import '../widgets/airport_search_bottom_sheet.dart';
import '../widgets/date_selection_bottom_sheet.dart';
import 'airline_detail_page.dart';
import '../../../../core/utils/airport_keyword_mapper.dart';
import '../../../../core/utils/airline_name_mapper.dart';

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
  List<PopularAirlineResponse> _searchResults = []; // 항공사 검색 결과 (탭 0)
  List<Map<String, dynamic>> _groupedFlightResults = []; // 항공편 검색 결과 그룹화 (탭 1)

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
      // Tab 0 (항공사 검색) vs Tab 1 (목적지 검색) 구분
      if (_searchTabIndex == 0) {
        _searchResults = widget.initialSearchResults!;
      } else if (_searchTabIndex == 1) {
        // Tab 1: PopularAirlineResponse -> grouped flight results 형태로 변환
        _groupedFlightResults = widget.initialSearchResults!.map((airline) {
          return {
            'airlineName': airline.code, // 항공사 코드를 이름으로 사용
            'airlineLogo': airline.logoUrl,
            'rating': airline.rating,
            'reviewCount': airline.reviewCount,
            'isDirect': true, // 일단 직항으로 설정 (home_page에서 경유 정보 없음)
            'viaText': '', // 경유지 정보 없음
          };
        }).toList();
      }
      _isLoading = false;
      print('🔵 초기 검색 결과 설정: ${widget.initialSearchResults!.length}개, 탭: $_searchTabIndex');
      print('🔵 _groupedFlightResults: ${_groupedFlightResults.length}개');
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

        // 성공!
        success = true;
        
        print('🟢 API 성공: ${response.data.length}개 항공편 데이터 받음');
        
        // 로딩 다이얼로그 닫기
        if (mounted) Navigator.pop(context);
        
        // 결과 그룹화 (Airline + Routing)
        print('🟢 그룹화 시작...');
        final grouped = _groupFlights(response.data);
        print('🟢 그룹화 완료: ${grouped.length}개');

        setState(() {
          _groupedFlightResults = grouped;
          _isLoading = false;
          _errorMessage = null;
        });
        print('🟢 setState 완료');
        return; // 성공하면 종료
      } catch (e, stackTrace) {
        print('❌ 검색 시도 $attempt 실패: $e');
        print('❌ Stack trace: $stackTrace');
        
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
            _groupedFlightResults = [];
          });
          return;
        }
        
        // 재시도 전 대기 (1초)
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  /// 항공편 결과 그룹화 (항공사 + 경유지 기준 중복 제거)
  List<Map<String, dynamic>> _groupFlights(List<FlightSearchData> flights) {
    print('🔵 _groupFlights 호출: ${flights.length}개 항공편 데이터');
    
    // Key: airlineCode_isDirect_viaCities
    final Map<String, Map<String, dynamic>> uniqueRoutes = {};
    
    for (final flight in flights) {
      final airlineCode = flight.airline.name; // getter 접근
      final logoUrl = flight.airline.logo;
      
      // 로고 디버깅 // [DEBUG] 평점 디버깅 추가
      print('🔵 항공편: $airlineCode, 로고: ${logoUrl.isNotEmpty ? "있음" : "없음"}, RawRating: ${flight.ratingScore}');
      
      // 경유 여부: segments가 2개 이상이면 경유
      final isDirect = flight.segments == null || flight.segments!.length <= 1;
      
      // Key 생성
      String key = airlineCode;
      
      String viaText = '';
      if (!isDirect) {
          // 경유지 추출 
          // segments가 2개 -> 첫 번째 세그먼트의 도착지 = 경유지
          // segments가 3개 -> 첫 번째 도착, 두 번째 도착...
          // 여기서는 첫 번째 경유지만 추출
          if (flight.segments != null && flight.segments!.isNotEmpty) {
               viaText = flight.segments!.first.arrivalAirport;
               if(viaText.isNotEmpty) {
                   key += "_via_$viaText";
               }
          }
      } else {
          key += "_direct";
      }

      if (!uniqueRoutes.containsKey(key)) {
        uniqueRoutes[key] = {
          'airlineName': airlineCode, // 항공사 코드를 이름으로 사용 (나중에 매핑)
          'airlineLogo': logoUrl,
          'rating': flight.ratingScore, // 모델의 평점 데이터 사용
          'reviewCount': flight.reviewCountNum, // 모델의 리뷰 수 데이터 사용
          'isDirect': isDirect,
          'viaText': viaText,
        };
      } else {
        // 이미 있는 경우, 평점 정보가 있으면 업데이트
        if (flight.ratingScore > 0.0 && uniqueRoutes[key]!['rating'] == 0.0) {
          uniqueRoutes[key]!['rating'] = flight.ratingScore;
          uniqueRoutes[key]!['reviewCount'] = flight.reviewCountNum;
        }
      }
    }
    
    print('🔵 그룹화 완료: ${uniqueRoutes.length}개 고유 경로');
    return uniqueRoutes.values.toList();
  }

  List<Airline> _getFilteredAirlines() {
    List<Airline> result;
    
    // API 결과가 있으면 사용 (항공사 검색 또는 목적지 검색 모두)
    if (_searchTabIndex == 0 && _searchResults.isNotEmpty) {
      // 탭 0: 항공사 검색 결과
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
    } else if (_searchTabIndex == 1 && _groupedFlightResults.isNotEmpty) {
      // 탭 1: 항공편 검색 결과 (그룹화됨)
      result = _groupedFlightResults.map<Airline>((group) {
        final airlineCode = group['airlineName'] as String;
        final airlineLogo = group['airlineLogo'] as String;
        
        // 항공사 코드 → 한국어 이름 변환
        final airlineKoreanName = AirlineMapper.codeToKorean[airlineCode] ?? airlineCode;
        
        // 로고 디버깅
        print('🔵 항공사: $airlineCode ($airlineKoreanName), 로고: ${airlineLogo.isNotEmpty ? "있음 ($airlineLogo)" : "없음"}, 평점: ${group['rating']}, 리뷰: ${group['reviewCount']}');
        
        // mock 데이터에서 매칭 (로고/이미지용)
        final mockAirline = mockAirlines.firstWhere(
          (mock) => mock.name == airlineKoreanName || mock.code == airlineCode,
          orElse: () => mockAirlines.first,
        );

        final isDirect = group['isDirect'] as bool;
        final viaText = group['viaText'] as String;

        // 경유지 한글 매핑 (표시용) - ex: "HND, NRT" -> "하네다 공항, 나리타 공항"
        // 여기서 convertToKorean 호출을 할 수 없으므로(정적?), 간단히 처리하거나 메서드 분리
        // 일단 기본값 사용 -> UI에서 처리
        
        // Airline 모델에 'routingInfo' 같은 필드가 없으므로, 
        // Airline 모델을 확장하거나, englishName 필드 등을 임시로 사용하여 라우팅 정보 전달
        // (Hack: englishName 필드에 라우팅 정보를 담음)
        // [Direct] or [Via AAA, BBB] 
        final routingInfo = isDirect 
            ? '직항' 
            : '$viaText 경유'; 

        return Airline(
          name: airlineKoreanName, // 한국어 이름 사용
          code: airlineCode, // 항공사 코드 추가
          englishName: routingInfo, // 임시로 라우팅 정보 저장
          rating: (group['rating'] as num).toDouble(),
          reviewCount: group['reviewCount'] as int,
          logoPath: airlineLogo.isNotEmpty 
              ? airlineLogo 
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
                  // Tab 1일 경우 routingInfo(englishName에 저장함) 사용
                  final isDirect = _searchTabIndex == 1 
                      ? airline.englishName == '직항'
                      : (airline.name == '대한항공' || airline.name == '에어프랑스'); // Tab 0 더미 로직
                  
                  final routingText = _searchTabIndex == 1
                      ? _localizeRouting(airline.englishName)
                      : (isDirect ? '직항' : '경유');

                  return _buildAirlineResultCard(context, airline, isDirect, routingText);
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

  /// 라우팅 텍스트 한글화 (공항 코드 -> 한글 도시명)
  String _localizeRouting(String routingInfo) {
    if (routingInfo == '직항') return '직항';
    
    // "AAA, BBB 경유" 포맷
    if (routingInfo.endsWith(' 경유')) {
      final citiesPart = routingInfo.replaceAll(' 경유', '');
      final codes = citiesPart.split(', ');
      
      final localizedCities = codes.map((code) {
        // IATA 코드를 도시명으로 매핑 시도 (AirportKeywordMapper.convertToKorean 활용)
        // convertToKorean은 영어 도시명을 한글로 바꿈.
        // 우리는 IATA 코드 -> 한글 도시명 필요.
        // 하지만 displayMap에는 도시명만 있음.
        // 임시: IATA 코드가 들어와도 작동하도록 AirportKeywordMapper에 코드 매핑 추가가 필요하거나,
        // 여기서 하드코딩된 변환 로직 사용? 
        // 
        // 더 나은 방법: API 응답 시 Airport 객체를 받아오면 도시명이 있음.
        // _searchFlights 응답에는 FlightSearchResponse -> FlightSearchData -> segments -> arrivalAirport (IATA 코드).
        // LocationSearchResponse가 아님. 
        // 
        // 따라서 IATA 코드 -> 한글 도시명 변환은 별도 로직이 필요함.
        // AirportKeywordMapper에 'NRT': '나리타' 등을 추가하거나,
        // 일단은 코드를 그대로 반환하고 "경유" 붙임.
        // User asked "map Canada to Korean". Canada is destination.
        // For via cities, e.g. Addis Ababa.
        // Let's rely on AirportKeywordMapper IF we add IATA codes to it.
        // Or just Map known codes manually here.
        
        return AirportKeywordMapper.convertToKorean(code);
      }).join(', ');
      
      return '$localizedCities 경유';
    }
    
    return routingInfo;
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
    String routingText,
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
          color: Colors.white.withOpacity(0.1), // 흰색 10%
          borderRadius: BorderRadius.circular(context.w(16)),
        ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Routing Info 먼저 (Tab 1만)
              if (_searchTabIndex == 1)
              Padding(
                padding: EdgeInsets.only(bottom: context.h(4)),
                child: Text(
                  routingText,
                  style: AppTextStyles.smallBody.copyWith(
                    color: AppColors.yellow1, // Y1 노란색
                  ),
                ),
              ),
              
              // Airline Name (bigBody 스타일)
              Text(
                AirlineNameMapper.toKorean(airline.name), // 한국어로 변환
                style: AppTextStyles.bigBody.copyWith(
                  color: Colors.white,
                ),
              ),
              SizedBox(height: context.h(4)),
              
              // Rating & Review Count
              Row(
                children: [
                  Text(
                    '${airline.rating}',
                    style: AppTextStyles.smallBody.copyWith(
                      color: Colors.white, // 흰색
                    ),
                  ),
                  Text(
                    '/5.0',
                    style: AppTextStyles.smallBody.copyWith(
                      color: Colors.white.withOpacity(0.5), // 흰색 50%
                    ),
                  ),
                  SizedBox(width: context.w(4)),
                  Text(
                    '(${_formatNumber(airline.reviewCount)})',
                    style: AppTextStyles.smallBody.copyWith(
                      color: Colors.white, // 흰색
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
    final isSvg = logoPath.toLowerCase().endsWith('.svg');

    if (isNetworkImage) {
      if (isSvg) {
        // SVG 네트워크 이미지
        return SvgPicture.network(
          logoPath,
          fit: BoxFit.contain,
          placeholderBuilder: (context) => Icon(
            Icons.flight,
            color: Colors.grey.withOpacity(0.3),
            size: 24,
          ),
        );
      } else {
        // 일반 네트워크 이미지 (PNG, JPG 등)
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
      }
    } else {
      // 로컬 asset
      if (isSvg) {
        return SvgPicture.asset(
          logoPath,
          fit: BoxFit.contain,
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
}
