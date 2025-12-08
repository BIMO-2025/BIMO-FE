import 'package:flutter/foundation.dart';
import '../../features/myflight/models/flight_model.dart';

/// 전역 비행 상태 관리 싱글톤
class FlightState extends ChangeNotifier {
  static final FlightState _instance = FlightState._internal();
  
  factory FlightState() {
    return _instance;
  }
  
  FlightState._internal();
  
  // 예정된 비행 목록
  final List<Flight> _scheduledFlights = [];
  
  // 예정된 비행 목록 getter
  List<Flight> get scheduledFlights => List.unmodifiable(_scheduledFlights);
  
  // 비행 추가
  void addFlight(Flight flight) {
    _scheduledFlights.add(flight);
    notifyListeners();
  }
  
  // 비행 제거
  void removeFlight(Flight flight) {
    _scheduledFlights.remove(flight);
    notifyListeners();
  }
  
  // 특정 인덱스의 비행 제거
  void removeFlightAt(int index) {
    if (index >= 0 && index < _scheduledFlights.length) {
      _scheduledFlights.removeAt(index);
      notifyListeners();
    }
  }
  
  // 모든 비행 제거
  void clearFlights() {
    _scheduledFlights.clear();
    notifyListeners();
  }
}
