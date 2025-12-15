import 'package:flutter/foundation.dart';

/// 전역 타임라인 데이터 관리 싱글톤
class TimelineState extends ChangeNotifier {
  static final TimelineState _instance = TimelineState._internal();
  
  factory TimelineState() {
    return _instance;
  }
  
  TimelineState._internal();
  
  // 타임라인 API 응답 데이터
  Map<String, dynamic>? _timelineData;
  
  // 타임라인 데이터 getter
  Map<String, dynamic>? get timelineData => _timelineData;
  
  // 타임라인 데이터 setter
  set timelineData(Map<String, dynamic>? data) {
    _timelineData = data;
    notifyListeners();
  }
  
  // 타임라인 데이터 존재 여부
  bool get hasTimeline => _timelineData != null;
  
  // 타임라인 데이터 초기화
  void clearTimeline() {
    _timelineData = null;
    notifyListeners();
  }
}
