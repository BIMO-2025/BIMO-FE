import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/widgets/base_bottom_sheet.dart';
import '../../../../core/utils/responsive_extensions.dart';

class DateSelectionBottomSheet extends StatefulWidget {
  const DateSelectionBottomSheet({super.key});

  @override
  State<DateSelectionBottomSheet> createState() =>
      _DateSelectionBottomSheetState();
}

class _DateSelectionBottomSheetState extends State<DateSelectionBottomSheet> {
  DateTime? _selectedDate;
  final DateTime _startDate = DateTime.now();
  final int _monthCount = 12; // Show next 12 months

  @override
  Widget build(BuildContext context) {
    return BaseBottomSheet(
      title: '날짜 선택',
      child: Stack(
        children: [
          Column(
            children: [
              // Weekday Header
              _buildWeekdayHeader(context),
              SizedBox(height: context.h(20)), // Header-List gap
              // Month List
              Expanded(
                child: ListView.builder(
                  itemCount: _monthCount,
                  padding: EdgeInsets.only(
                    bottom: context.h(120), // Space for button area
                  ),
                  itemBuilder: (context, index) {
                    final monthDate = DateTime(
                      _startDate.year,
                      _startDate.month + index,
                      1,
                    );
                    return _buildMonthSection(context, monthDate);
                  },
                ),
              ),
            ],
          ),
          // Confirm Button Area with Image Background and Blur
          Positioned(
            left: context.w(20),
            right: context.w(20),
            bottom: MediaQuery.of(context).padding.bottom + context.h(36),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.w(28)), // 버튼 둥글기
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  height: context.h(50), // 높이 50으로 조정
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/search/bottom_button_bg.png'),
                      fit: BoxFit.cover,
                      opacity: 0.2, // 더 연하게 (글자 비치게)
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1), // FFFFFF 10%
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(context.w(28)),
                  ),
                  child: _buildConfirmButton(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader(BuildContext context) {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: weekdays.map((day) {
          return SizedBox(
            width: context.w(40), // Approximate width for alignment
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: context.fs(15),
                  fontWeight: FontWeight.w500,
                  color: Colors.white, // White color
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthSection(BuildContext context, DateTime monthDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month Title
        Padding(
          padding: EdgeInsets.only(
            left: context.w(20),
            bottom: context.h(20),
            top: context.h(20),
          ),
          child: Text(
            '${monthDate.year}년 ${monthDate.month}월',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: context.fs(19),
              fontWeight: FontWeight.w500, // Medium
              color: Colors.white,
            ),
          ),
        ),
        // Date Grid
        _buildDateGrid(context, monthDate),
      ],
    );
  }

  Widget _buildDateGrid(BuildContext context, DateTime monthDate) {
    final daysInMonth =
        DateTime(monthDate.year, monthDate.month + 1, 0).day;
    final firstWeekday = monthDate.weekday % 7; // 0 for Sunday, 6 for Saturday
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day); // 시간 제거

    // Total cells needed: empty slots for start offset + actual days
    final totalCells = firstWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(20)),
      child: Column(
        children: List.generate(rows, (rowIndex) {
          return Padding(
            padding: EdgeInsets.only(bottom: context.h(20)), // Row gap
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (colIndex) {
                final dayIndex = (rowIndex * 7) + colIndex - firstWeekday + 1;
                
                if (dayIndex < 1 || dayIndex > daysInMonth) {
                  return SizedBox(width: context.w(40)); // Empty slot
                }

                final currentDate = DateTime(
                  monthDate.year,
                  monthDate.month,
                  dayIndex,
                );
                
                final isSelected = _selectedDate != null &&
                    _selectedDate!.year == currentDate.year &&
                    _selectedDate!.month == currentDate.month &&
                    _selectedDate!.day == currentDate.day;

                // 과거 날짜인지 확인 (오늘 포함 미래만 선택 가능)
                final isPastDate = currentDate.isBefore(todayDate);

                return GestureDetector(
                  onTap: isPastDate
                      ? null // 과거 날짜는 클릭 불가
                      : () {
                          setState(() {
                            _selectedDate = currentDate;
                          });
                        },
                  child: Container(
                    width: context.w(40),
                    height: context.w(40), // Square
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF007AFF) // Blue selection
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$dayIndex',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: context.fs(15), // Body style
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isPastDate
                              ? Colors.white.withOpacity(0.1) // 과거 날짜: FFFFFF 10%
                              : Colors.white, // 미래 날짜: FFFFFF 100%
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    final isEnabled = _selectedDate != null;
    
    return GestureDetector(
      onTap: isEnabled
          ? () {
              Navigator.pop(context, _selectedDate);
            }
          : null,
      child: Container(
        width: double.infinity,
        // height와 decoration 제거 (부모 컨테이너가 담당)
        color: Colors.transparent, 
        child: Center(
          child: Text(
            '확인',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: context.fs(15), // Medium 15
              fontWeight: FontWeight.w500, // Medium
              height: 1.2, // 120%
              letterSpacing: -context.fs(0.225), // -1.5% of 15
              color: isEnabled
                  ? Colors.white
                  : Colors.white.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }
}
