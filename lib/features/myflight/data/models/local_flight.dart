import 'package:hive/hive.dart';

part 'local_flight.g.dart';

/// 로컬 비행 모델 (Hive)
@HiveType(typeId: 1)
class LocalFlight extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String origin; // ICN

  @HiveField(2)
  String destination; // YYZ

  @HiveField(3)
  DateTime departureTime;

  @HiveField(4)
  DateTime arrivalTime;

  @HiveField(5)
  String totalDuration; // "13h 0m"

  @HiveField(6)
  String status; // scheduled, inProgress, past

  @HiveField(7)
  DateTime lastModified;

  @HiveField(8)
  String? flightGoal; // 시차적응, etc.

  @HiveField(9)
  String? seatClass; // ECONOMY, etc.

  @HiveField(10)
  bool? forceInProgress; // 테스트용: 강제로 진행 중 상태 (nullable for backward compatibility)

  LocalFlight({
    required this.id,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.totalDuration,
    this.status = 'scheduled',
    required this.lastModified,
    this.flightGoal,
    this.seatClass,
    this.forceInProgress,
  });

  /// 비행 상태 계산 (테스트 모드 지원)
  String calculateStatus() {
    // 테스트 모드: 강제로 진행 중
    if (forceInProgress == true) {
      return 'inProgress';
    }
    
    // 이미 종료된 상태라면 유지 (사용자가 종료 버튼 누른 경우 등)
    if (status == 'past') {
      return 'past';
    }
    
    final now = DateTime.now();
    if (now.isBefore(departureTime)) {
      return 'scheduled';
    } else if (now.isAfter(arrivalTime)) {
      return 'past';
    } else {
      return 'inProgress';
    }
  }

  /// API flight_info에서 LocalFlight 생성
  factory LocalFlight.fromFlightInfo(
    Map<String, dynamic> flightInfo,
    DateTime departureTime,
    DateTime arrivalTime,
  ) {
    return LocalFlight(
      id: '${flightInfo['origin']}_${flightInfo['destination']}_${departureTime.millisecondsSinceEpoch}',
      origin: flightInfo['origin'] as String,
      destination: flightInfo['destination'] as String,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      totalDuration: flightInfo['total_duration'] as String,
      status: 'scheduled',
      lastModified: DateTime.now(),
      flightGoal: flightInfo['flight_goal'] as String?,
      seatClass: flightInfo['seat_class'] as String?,
    );
  }
}
