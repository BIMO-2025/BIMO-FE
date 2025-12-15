import 'package:intl/intl.dart';

/// 시간 포맷팅 유틸리티 클래스
/// 24시간 형식 ↔ AM/PM 형식 변환, ISO 8601 파싱 등
class TimeFormatter {
  TimeFormatter._();
  
  /// ISO 8601 시간 → AM/PM 형식 (HH:mm a)
  /// 예: "2025-12-31T10:05:00Z" → "10:05 AM"
  static String formatTo12Hour(String iso8601) {
    try {
      final dateTime = DateTime.parse(iso8601.endsWith('Z') ? iso8601 : '${iso8601}Z');
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      print('⚠️ ISO 시간 파싱 실패: $iso8601');
      return iso8601;
    }
  }
  
  /// DateTime → AM/PM 형식
  static String dateTimeToAmPm(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }
  
  /// DateTime → 24시간 형식 (HH:mm)
  static String formatTo24Hour(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
  
  /// ISO 8601 문자열 → DateTime
  static DateTime parseIsoTime(String iso8601) {
    return DateTime.parse(iso8601.endsWith('Z') ? iso8601 : '${iso8601}Z');
  }
  
  /// 시간 범위 포맷팅
  /// 예: "10:05 AM - 11:35 AM"
  static String formatTimeRange(DateTime start, DateTime end) {
    final startStr = dateTimeToAmPm(start);
    final endStr = dateTimeToAmPm(end);
    return '$startStr - $endStr';
  }
  
  /// 시간 범위 포맷팅 (ISO 문자열)
  static String formatTimeRangeFromIso(String startIso, String endIso) {
    final start = parseIsoTime(startIso);
    final end = parseIsoTime(endIso);
    return formatTimeRange(start, end);
  }
  
  /// 24시간 형식 시간 → AM/PM 변환
  /// 예: "14:30" → "02:30 PM"
  static String convert24HourTo12Hour(String time24) {
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dateTime = DateTime(2000, 1, 1, hour, minute);
      return dateTimeToAmPm(dateTime);
    } catch (e) {
      print('⚠️ 24시간 형식 파싱 실패: $time24');
      return time24;
    }
  }
}
