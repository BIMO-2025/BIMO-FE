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
    final allFlights = _box.values.toList();
    print('📦 [Hive] 전체 비행 수: ${allFlights.length}');
    
    for (final f in allFlights) {
      final isPast = f.departureTime.isBefore(now);
      print('   ${f.origin}-${f.destination}: departure=${f.departureTime}, status=${f.status}, isPast=$isPast');
    }
    
    // status가 'past'가 아니고, 출발 시간이 미래인 비행만 반환
    final scheduled = allFlights.where((f) => f.status != 'past' && f.departureTime.isAfter(now)).toList();
    print('✅ [Hive] 예정된 비행: ${scheduled.length}개');
    return scheduled;
  }

  /// 진행 중인 비행 조회
  Future<LocalFlight?> getInProgressFlight() async {
    final now = DateTime.now();
    try {
      return _box.values.firstWhere(
        (f) => f.forceInProgress == true || (f.status != 'past' && now.isAfter(f.departureTime) && now.isBefore(f.arrivalTime)),
      );
    } catch (e) {
      return null;
    }
  }

  /// 지난 비행 조회 (status가 'past'인 비행만)
  Future<List<LocalFlight>> getPastFlights() async {
    final allFlights = _box.values.toList();
    print('📦 [Past Flights] 전체 비행: ${allFlights.length}개');
    for (final f in allFlights) {
      print('   ${f.origin}-${f.destination}: status=${f.status}');
    }
    final pastFlights = allFlights.where((f) => f.status == 'past').toList();
    print('✅ [Past Flights] 지난 비행 (status=past): ${pastFlights.length}개');
    return pastFlights;
  }

  /// 비행 업데이트
  Future<void> updateFlight(String id, LocalFlight updatedFlight) async {
    await _box.put(id, updatedFlight);
    print('✅ 비행 업데이트: ${updatedFlight.id}');
  }

  /// 비행 시간 지연
  Future<void> delayFlight(String id, Duration delay) async {
    final flight = await getFlight(id);
    if (flight != null) {
      flight.departureTime = flight.departureTime.add(delay);
      flight.arrivalTime = flight.arrivalTime.add(delay);
      flight.lastModified = DateTime.now();
      await saveFlight(flight);
      print('✅ 비행 시간 지연 적용: ${flight.id} (+${delay.inMinutes}분)');
    }
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

  /// 비행 강제 활성화 (시뮬레이션 용)
  Future<void> setInProgressFlight(String id) async {
    final allFlights = _box.values.toList();
    for (final f in allFlights) {
      if (f.forceInProgress ?? false) {
        f.forceInProgress = false;
        await _box.put(f.id, f);
      }
    }

    final target = _box.get(id);
    if (target != null) {
      target.forceInProgress = true;
      await _box.put(id, target);
      print('✅ 비행 강제 활성화: $id');
    }
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
