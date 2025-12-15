import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/widgets/base_bottom_sheet.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../../myflight/data/repositories/flight_repository.dart';
import '../../domain/models/airport.dart';
import 'airport_item.dart';

class AirportSearchBottomSheet extends StatefulWidget {
  final Function(Airport) onAirportSelected;

  const AirportSearchBottomSheet({
    super.key,
    required this.onAirportSelected,
  });

  @override
  State<AirportSearchBottomSheet> createState() =>
      _AirportSearchBottomSheetState();
}

class _AirportSearchBottomSheetState extends State<AirportSearchBottomSheet> {

  final TextEditingController _searchController = TextEditingController();
  final FlightRepository _flightRepository = FlightRepository();
  
  List<Airport> _filteredAirports = []; // Start with empty list
  bool _isLoading = false;
  String? _errorMessage;
  
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// 검색어 변경 시 호출 (디바운싱 적용)
  void _onSearchChanged() {
    // 기존 타이머 취소
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    final query = _searchController.text.trim();
    
    if (query.isEmpty) {
      setState(() {
        _filteredAirports = [];
        _errorMessage = null;
      });
      return;
    }
    
    // 500ms 후에 검색 실행 (디바운싱)
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchAirports(query);
    });
  }

  /// 공항 검색 API 호출
  Future<void> _searchAirports(String keyword) async {
    // 최소 길이 검증
    if (keyword.length < 1) { // 1글자부터 검색 허용 (매퍼가 있으므로)
      setState(() {
        _filteredAirports = [];
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }
    
    // 한글 필터링 제거 (매퍼가 처리함)

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // FlightRepository를 통해 검색 (내부적으로 매핑 처리됨)
      final airports = await _flightRepository.searchAirports(keyword);

      setState(() {
        _filteredAirports = airports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '검색 중 오류가 발생했습니다';
        _isLoading = false;
        _filteredAirports = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseBottomSheet(
      title: '공항 검색',
      child: Column(
        children: [
          SizedBox(height: context.h(15)), // 15px gap
          // Search bar
          Container(
            width: context.w(335),
            height: context.h(50),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1), // FFFFFF 10%
              borderRadius: BorderRadius.circular(context.w(14)),
            ),
            child: Stack(
              children: [
                // Search icon
                Positioned(
                  left: context.w(15),
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Image.asset(
                      'assets/images/search/search_icon.png',
                      width: context.w(24),
                      height: context.h(24),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // TextField
                Padding(
                  padding: EdgeInsets.only(
                    left: context.w(50),
                    right: context.w(45), // Space for clear button
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: context.fs(15), // Body style
                      fontWeight: FontWeight.w400, // Regular
                      height: 1.5, // 150%
                      letterSpacing: -context.fs(0.3), // -2% of 15
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: '미국',
                      hintStyle: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: context.fs(15),
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        letterSpacing: -context.fs(0.3),
                        color: Colors.grey[600],
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: context.h(15),
                      ),
                    ),
                  ),
                ),
                // Clear button (X icon)
                if (_searchController.text.isNotEmpty)
                  Positioned(
                    right: context.w(15),
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          _searchController.clear();
                        },
                        child: Icon(
                          Icons.close,
                          color: Colors.grey[600],
                          size: context.w(20),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: context.h(16)),
          // Airport list (로딩/에러/결과)
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : _filteredAirports.isEmpty
                        ? const SizedBox.shrink()
                        : ListView.builder(
                            itemCount: _filteredAirports.length,
                            itemBuilder: (context, index) {
                              final airport = _filteredAirports[index];
                              return AirportItem(
                                airport: airport,
                                onTap: () {
                                  // COUNTRY 또는 CITY 타입인 경우 -> 검색어 자동완성 후 재검색
                                  // (사용자가 해당 지역의 공항을 찾기 위해 '진입'하는 개념)
                                  if (airport.type == SearchResultType.COUNTRY || 
                                      airport.type == SearchResultType.CITY) {
                                    
                                    _searchController.text = airport.cityName;
                                    _searchController.selection = TextSelection.fromPosition(
                                      TextPosition(offset: _searchController.text.length),
                                    );
                                    // 텍스트 변경으로 인해 리스너가 호출되어 검색이 트리거됨
                                  } else {
                                    // AIRPORT 타입 -> 최종 선택
                                    widget.onAirportSelected(airport);
                                    Navigator.pop(context);
                                  }
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
