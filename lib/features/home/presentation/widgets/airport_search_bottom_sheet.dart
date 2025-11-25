import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/mock_airports.dart';
import '../../domain/models/airport.dart';
import 'airport_item.dart';
import '../../../../core/utils/responsive_extensions.dart';


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
  List<Airport> _filteredAirports = []; // Start with empty list

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterAirports);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterAirports() {
    setState(() {
      final query = _searchController.text;
      if (query.isEmpty) {
        _filteredAirports = []; // Empty list when no search text
      } else {
        _filteredAirports = mockAirports
            .where((airport) => airport.matchesQuery(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(context.w(24)),
        topRight: Radius.circular(context.w(24)),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(
          width: context.w(375),
          height: context.h(750),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(context.w(24)),
              topRight: Radius.circular(context.w(24)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.1), // FFFFFF 10%
                offset: const Offset(0, -1), // X: 0, Y: -1
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
          // Header
          Container(
            width: context.w(375),
            height: context.h(82),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
            ),
            child: Stack(
              children: [
                // Content
                Center(
                  child: Text(
                    '공항 검색',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: context.fs(19), // Large style
                      fontWeight: FontWeight.w700, // Bold
                      height: 1.2, // 120%
                      letterSpacing: -context.fs(0.38), // -2% of 19
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                ),
                // Back button
                Positioned(
                  left: context.w(20),
                  top: 0,
                  bottom: 0,
                  child: Center(
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
                ),
              ],
            ),
          ),
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
          // Airport list
          Expanded(
            child: _filteredAirports.isEmpty
                ? Center(
                    child: Text(
                      '검색 결과가 없습니다',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredAirports.length,
                    itemBuilder: (context, index) {
                      final airport = _filteredAirports[index];
                      return AirportItem(
                        airport: airport,
                        onTap: () {
                          widget.onAirportSelected(airport);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}
