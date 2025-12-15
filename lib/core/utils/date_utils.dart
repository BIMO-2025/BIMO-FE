/// 날짜 관련 유틸리티
class DateUtils {
  /// 현재 날짜 기준으로 주차 정보 계산
  ///
  /// Returns: {year, month, week, weekLabel}
  static Map<String, dynamic> getCurrentWeekInfo() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    // 해당 월의 몇 주차인지 계산 (1일~7일 = 1주차, 8일~14일 = 2주차...)
    final day = now.day;
    final week = ((day - 1) ~/ 7) + 1;

    // 주차 라벨 생성 (예: "[12월 2주]")
    final weekLabel = '[$month월 $week주]';

    return {'year': year, 'month': month, 'week': week, 'weekLabel': weekLabel};
  }

  /// 특정 날짜 기준으로 주차 정보 계산
  static Map<String, dynamic> getWeekInfo(DateTime date) {
    final year = date.year;
    final month = date.month;
    final day = date.day;
    final week = ((day - 1) ~/ 7) + 1;
    final weekLabel = '[$month월 $week주]';

    return {'year': year, 'month': month, 'week': week, 'weekLabel': weekLabel};
  }
}

