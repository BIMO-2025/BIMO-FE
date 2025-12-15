import 'package:hive/hive.dart';
import '../models/local_flight.dart';

/// 로컬 비행 리포지토리 (Hive 기반)
/// 오프라인 비행 데이터 관리
class LocalFlightRepository {
  static const String _boxName = 'flights';
  late Box<LocalFlight> _box;

  /// 박스 초기화
  Future<void> init() async {
    _box = await Hive.openBox<LocalFlight>(_boxName);
  }

  /// 비행 저장
  Future<void> saveFlight(LocalFlight flight) async {
    await _box.put(flight.id, flight);
    print('✅ 비행 로컬 저장: ${flight.origin} → ${flight.destination}');
  }

  /// 비행 조회
  Future<LocalFlight?> getFlight(String id) async {
    return _box.get(id);
  }

  /// 모든 비행 조회
  Future<List<LocalFlight>> getAllFlights() async {
    return _box.values.toList();
  }

  /// 예정된 비행 조회
  Future<List<LocalFlight>> getScheduledFlights() async {
    final now = DateTime.now();
    return _box.values.where((f) => f.departureTime.isAfter(now)).toList();
  }

  /// 진행 중인 비행 조회
  Future<LocalFlight?> getInProgressFlight() async {
    final now = DateTime.now();
    try {
      return _box.values.firstWhere(
        (f) => now.isAfter(f.departureTime) && now.isBefore(f.arrivalTime),
      );
    } catch (e) {
      return null;
    }
  }

  /// 지난 비행 조회
  Future<List<LocalFlight>> getPastFlights() async {
    final now = DateTime.now();
    return _box.values.where((f) => f.arrivalTime.isBefore(now)).toList();
  }

  /// 비행 업데이트
  Future<void> updateFlight(String id, LocalFlight updatedFlight) async {
    await _box.put(id, updatedFlight);
    print('✅ 비행 업데이트: ${updatedFlight.id}');
  }

  /// 비행 삭제
  Future<void> deleteFlight(String id) async {
    await _box.delete(id);
    print('✅ 비행 삭제: $id');
  }

  /// 모든 비행 삭제 (테스트용)
  Future<void> clearAll() async {
    await _box.clear();
    print('⚠️ 모든 비행 삭제됨');
  }

  /// 비행 상태 업데이트 (scheduled/inProgress/past)
  Future<void> updateFlightStatus(String id) async {
    final flight = await getFlight(id);
    if (flight != null) {
      flight.status = flight.calculateStatus();
      flight.lastModified = DateTime.now();
      await saveFlight(flight);
    }
  }

  /// 모든 비행 상태 업데이트
  Future<void> updateAllFlightStatuses() async {
    final flights = await getAllFlights();
    for (final flight in flights) {
      flight.status = flight.calculateStatus();
      flight.lastModified = DateTime.now();
      await saveFlight(flight);
    }
  }
}
