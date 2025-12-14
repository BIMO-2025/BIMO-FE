import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../domain/models/airline.dart';
import '../../domain/models/airport.dart';
import '../../data/mock_airlines.dart';
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

  const AirlineSearchResultPage({
    super.key,
    required this.initialTabIndex,
    this.departureAirport,
    this.arrivalAirport,
    this.selectedDate,
    this.airlineQuery,
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

  @override
  void initState() {
    super.initState();
    _searchTabIndex = widget.initialTabIndex;
    _airlineSearchController =
        TextEditingController(text: widget.airlineQuery);
    _airlineSearchController.addListener(() {
      setState(() {});
    });

    // Initialize local state
    _departureAirport = widget.departureAirport;
    _arrivalAirport = widget.arrivalAirport;
    _selectedDate = widget.selectedDate;
  }

  @override
  void dispose() {
    _airlineSearchController.dispose();
    super.dispose();
  }

  List<Airline> _getFilteredAirlines() {
    List<Airline> result;
    if (_searchTabIndex == 0) {
      final query = _airlineSearchController.text.trim();
      if (query.isEmpty) {
        result = List.from(mockAirlines);
      } else {
        result = mockAirlines.where((airline) {
          return airline.name.contains(query) ||
              airline.englishName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    } else {
      // 목적지 검색인 경우 일단 전체 노출 (추후 필터링 로직 추가 가능)
      result = List.from(mockAirlines);
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

            // 3. Result List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: context.w(20)),
              itemCount: filteredAirlines.length,
              itemBuilder: (context, index) {
                final airline = filteredAirlines[index];
                // Mocking route info based on index/airline for demo
                final isDirect = airline.name == '대한항공' || airline.name == '에어프랑스';
                final routeInfo = isDirect ? '직항' : '아디스아바바 경유';
                
                return _buildAirlineResultCard(context, airline, routeInfo, isDirect);
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
    String routeInfo,
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
        padding: EdgeInsets.all(context.w(20)),
        constraints: BoxConstraints(
          minHeight: context.h(110),
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
              // Route Info (직항/경유)
              Text(
                routeInfo,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: context.fs(13),
                  fontWeight: FontWeight.w500,
                  color: AppColors.yellow1,
                ),
              ),
              SizedBox(height: context.h(4)),
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
              SizedBox(height: context.h(1)),
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
