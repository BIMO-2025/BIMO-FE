import 'dart:async';
import 'package:flutter/material.dart';
import '../../../home/domain/models/airport.dart';
import '../../../home/data/models/flight_search_response.dart';
import '../../data/repositories/flight_repository.dart';

class AddFlightViewModel extends ChangeNotifier {
  final FlightRepository _repository;

  // 생성자
  AddFlightViewModel({FlightRepository? repository})
      : _repository = repository ?? FlightRepository();

  // --- 상태 변수 ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // 공항 검색 결과
  List<Airport> _airportResults = [];
  List<Airport> get airportResults => _airportResults;

  // 항공편 검색 결과
  List<FlightSearchData> _flightResults = [];
  List<FlightSearchData> get flightResults => _flightResults;

  // 선택된 항공편
  FlightSearchData? _selectedFlight;
  FlightSearchData? get selectedFlight => _selectedFlight;

  // 디바운스 타이머
  Timer? _debounce;

  // --- 메서드 ---

  /// 로딩 상태 변경
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// 공항 검색 (Debounce 적용)
  void searchAirports(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      _airportResults = [];
      notifyListeners();
      return;
    }

    // 500ms 디바운스
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await _repository.searchAirports(query);
        _airportResults = results;
        _error = null;
      } catch (e) {
        print('Error searching airports: $e');
        _airportResults = [];
        // 사용자에게 에러를 보여줄지 말지 결정 필요
      } finally {
        notifyListeners();
      }
    });
  }

  /// 항공편 검색
  Future<void> searchFlights({
    required String origin,
    required String destination,
    required DateTime departureDate,
    bool hasLayover = false,
  }) async {
    _setLoading(true);
    _error = null;
    _flightResults = [];
    _selectedFlight = null;

    try {
      final dateStr = '${departureDate.year}-${departureDate.month.toString().padLeft(2, '0')}-${departureDate.day.toString().padLeft(2, '0')}';
      
      final response = await _repository.searchFlights(
        origin: origin,
        destination: destination,
        departureDate: dateStr,
      );

      // 경유편 필터링
      List<FlightSearchData> results = response.data;
      if (!hasLayover) {
        // 경유편이 없는(세그먼트가 1개인) 항공편만 필터링
        results = results.where((flight) {
           // 세그먼트 정보가 없으면 직항으로 간주하거나, 데이터 구조에 따라 다름
           // 여기서는 segments 리스트 길이를 확인
           return (flight.segments?.length ?? 1) <= 1;
        }).toList();
      }
      
      _flightResults = results;

    } catch (e) {
      _error = '항공편을 찾을 수 없습니다.\n잠시 후 다시 시도해 주세요.';
      print('Error searching flights: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 항공편 선택
  void selectFlight(FlightSearchData? flight) {
    _selectedFlight = flight;
    notifyListeners();
  }

  /// 폼 초기화
  void clear() {
    _airportResults = [];
    _flightResults = [];
    _selectedFlight = null;
    _error = null;
    notifyListeners();
  }
}
