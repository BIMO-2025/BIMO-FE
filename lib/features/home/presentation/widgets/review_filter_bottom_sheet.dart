import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../../../core/widgets/base_bottom_sheet.dart';
import '../../domain/models/airport.dart';
import 'destination_search_section.dart';
import 'airport_search_bottom_sheet.dart';

class ReviewFilterBottomSheet extends StatefulWidget {
  const ReviewFilterBottomSheet({super.key});

  @override
  State<ReviewFilterBottomSheet> createState() => _ReviewFilterBottomSheetState();
}

class _ReviewFilterBottomSheetState extends State<ReviewFilterBottomSheet> {
  String _departureAirport = '인천 (INC)';
  String _arrivalAirport = '파리 (CDG)';
  
  String? _selectedPeriod;
  String? _selectedRating;
  bool _photoOnly = false;
  
  // Store airport codes for API 
  String _departureAirportCode = 'ICN';
  String _arrivalAirportCode = 'CDG';
  
  bool _isFilterApplied = false; // Track if filter has been applied

  final List<String> _periods = ['전체', '최근 3개월', '최근 6개월', '최근 1년'];

  final List<String> _ratings = ['전체', '5점', '4점', '3점', '2점', '1점'];

  @override
  void initState() {
    super.initState();
    _selectedPeriod = '전체';
    _selectedRating = '전체';
  }

  // Check if any filter is different from default
  bool get _hasNonDefaultFilters {
    return _selectedPeriod != '전체' ||
        _selectedRating != '전체' ||
        _photoOnly == true ||
        _departureAirportCode != 'ICN' ||
        _arrivalAirportCode != 'CDG';
  }

  void _showAirportSearch(BuildContext context, bool isDeparture) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AirportSearchBottomSheet(
        onAirportSelected: (Airport airport) {
          setState(() {
            final airportString = '${airport.cityName} (${airport.airportCode})';
            if (isDeparture) {
              _departureAirport = airportString;
              _departureAirportCode = airport.airportCode;
            } else {
              _arrivalAirport = airportString;
              _arrivalAirportCode = airport.airportCode;
            }
          });
        },
      ),
    );
  }

  void _swapAirports() {
    if (_departureAirport.isNotEmpty && _arrivalAirport.isNotEmpty) {
      setState(() {
        final temp = _departureAirport;
        _departureAirport = _arrivalAirport;
        _arrivalAirport = temp;
        
        final tempCode = _departureAirportCode;
        _departureAirportCode = _arrivalAirportCode;
        _arrivalAirportCode = tempCode;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      // Reset to defaults
      _departureAirport = '인천 (INC)'; // 오타 수정: INC -> ICN? UI값은 그대로 유지
      _arrivalAirport = '파리 (CDG)';
      _departureAirportCode = 'ICN';
      _arrivalAirportCode = 'CDG';
      
      _selectedPeriod = '전체';
      _selectedRating = '전체';
      _photoOnly = false;
      _isFilterApplied = false;
    });
  }

  void _applyFilters() {
    if (_isFilterApplied) {
      // If filter is already applied, reset it
      _resetFilters();
      Navigator.pop(context, false); // Return false when filter is cleared
    } else {
      // Apply filters and return data
      setState(() {
        _isFilterApplied = _hasNonDefaultFilters;
      });
      
      final filterData = {
        'applied': _hasNonDefaultFilters,
        'departureAirport': _departureAirportCode,
        'arrivalAirport': _arrivalAirportCode,
        'period': _selectedPeriod,
        'minRating': _selectedRating,
        'photoOnly': _photoOnly,
      };
      
      Navigator.pop(context, filterData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseBottomSheet(
      title: '리뷰 필터',
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: context.h(120), // Space for button
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.w(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: context.h(3)),
                  
                  // Reset button
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _resetFilters,
                      child: Text(
                        '초기화',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: context.fs(14),
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.h(16)),

                  // Route Section
                  Text(
                    '노선',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: context.fs(16),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: context.h(8)),
                  
                  // Airport cards with exact same style as DestinationSearchSection
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        children: [
                          // Departure Airport
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _showAirportSearch(context, true),
                              child: Container(
                                width: context.w(163.5),
                                height: context.h(87),
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.w(20),
                                  vertical: context.h(15),
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(context.w(14)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '출발 공항',
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: context.fs(15),
                                        fontWeight: FontWeight.w600,
                                        height: 1.5,
                                        letterSpacing: -context.fs(0.3),
                                        color: AppColors.white,
                                      ),
                                    ),
                                    SizedBox(height: context.h(10)),
                                    Text(
                                      _departureAirport,
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: context.fs(13),
                                        fontWeight: FontWeight.w400,
                                        height: 1.5,
                                        letterSpacing: -context.fs(0.26),
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: context.w(8)),
                          // Arrival Airport
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _showAirportSearch(context, false),
                              child: Container(
                                width: context.w(163.5),
                                height: context.h(87),
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.w(20),
                                  vertical: context.h(15),
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(context.w(14)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '도착 공항',
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: context.fs(15),
                                        fontWeight: FontWeight.w600,
                                        height: 1.5,
                                        letterSpacing: -context.fs(0.3),
                                        color: AppColors.white,
                                      ),
                                    ),
                                    SizedBox(height: context.h(10)),
                                    Text(
                                      _arrivalAirport,
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: context.fs(13),
                                        fontWeight: FontWeight.w400,
                                        height: 1.5,
                                        letterSpacing: -context.fs(0.26),
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Swap icon - same style as DestinationSearchSection
                      GestureDetector(
                        onTap: _swapAirports,
                        child: Container(
                          width: context.w(32),
                          height: context.w(32),
                          decoration: BoxDecoration(
                            color: const Color(0xFF131313),
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            'assets/images/home/swap_airports.png',
                            width: context.w(32),
                            height: context.w(32),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.h(16)),



                  // Period Section
                  Text(
                    '기간',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: context.fs(16),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: context.h(12)),
                  Wrap(
                    spacing: context.w(8),
                    runSpacing: context.h(8),
                    children: _periods.map((period) {
                      final isSelected = _selectedPeriod == period;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPeriod = period;
                          });
                        },
                        child: IntrinsicWidth(
                          child: Container(
                            height: context.h(33),
                            padding: EdgeInsets.symmetric(
                              horizontal: context.w(16),
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.blue1 : const Color(0xFF333333),
                              borderRadius: BorderRadius.circular(context.w(8)),
                            ),
                            child: Center(
                              child: Text(
                                period,
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: context.fs(13),
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                  letterSpacing: -context.fs(0.26),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: context.h(32)),

                  // Rating Section
                  Text(
                    '평점',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: context.fs(16),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: context.h(12)),
                  Wrap(
                    spacing: context.w(8),
                    runSpacing: context.h(8),
                    children: _ratings.map((rating) {
                      final isSelected = _selectedRating == rating;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRating = rating;
                          });
                        },
                        child: IntrinsicWidth(
                          child: Container(
                            height: context.h(33),
                            padding: EdgeInsets.symmetric(
                              horizontal: context.w(16),
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.blue1 : const Color(0xFF333333),
                              borderRadius: BorderRadius.circular(context.w(8)),
                            ),
                            child: Center(
                              child: Text(
                                rating,
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: context.fs(13),
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                  letterSpacing: -context.fs(0.26),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: context.h(32)),

                  // Photo Only Checkbox - right aligned
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _photoOnly = !_photoOnly;
                          });
                        },
                        child: Container(
                          width: context.w(24),
                          height: context.w(24),
                          decoration: BoxDecoration(
                            color: _photoOnly ? AppColors.blue1 : const Color(0xFF333333),
                            borderRadius: BorderRadius.circular(context.w(4)),
                          ),
                          child: _photoOnly
                              ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: context.w(16),
                                )
                              : null,
                        ),
                      ),
                      SizedBox(width: context.w(8)),
                      Text(
                        '사진 리뷰만 보기',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: context.fs(16),
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Apply Button with same style as date selection confirm button
          Positioned(
            left: context.w(20),
            right: context.w(20),
            bottom: MediaQuery.of(context).padding.bottom + context.h(36),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.w(28)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  height: context.h(50),
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/search/bottom_button_bg.png'),
                      fit: BoxFit.cover,
                      opacity: 0.2,
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(context.w(28)),
                  ),
                  child: GestureDetector(
                    onTap: _applyFilters,
                    child: Container(
                      width: double.infinity,
                      color: Colors.transparent,
                      child: Center(
                        child: Text(
                          _isFilterApplied ? '필터 해제' : '적용하기',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: context.fs(15),
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                            letterSpacing: -context.fs(0.225),
                            color: Colors.white,
                          ),
                        ),
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
}
