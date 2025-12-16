import 'package:hive/hive.dart';

part 'local_timeline_event.g.dart';

/// 로컬 타임라인 이벤트 모델 (Hive)
@HiveType(typeId: 0)
class LocalTimelineEvent extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String flightId; // 연결된 비행 ID

  @HiveField(2)
  int order; // 순서

  @HiveField(3)
  String type; // TAKEOFF, MEAL, SLEEP, FREE_TIME, CUSTOM

  @HiveField(4)
  String title;

  @HiveField(5)
  String description;

  @HiveField(6)
  DateTime startTime;

  @HiveField(7)
  DateTime endTime;

  @HiveField(8)
  String? iconType; // airplane_takeoff, meal, moon, etc.

  @HiveField(9)
  bool isEditable; // 수정 가능 여부

  @HiveField(10)
  bool isCustom; // 사용자가 추가한 것인지

  @HiveField(11)
  bool isActive; // UI 상태 (파란색 하이라이트)

  LocalTimelineEvent({
    required this.id,
    required this.flightId,
    required this.order,
    required this.type,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.iconType,
    this.isEditable = false,
    this.isCustom = false,
    this.isActive = false,
  });

  /// API 응답에서 LocalTimelineEvent 생성
  factory LocalTimelineEvent.fromApiResponse(
    Map<String, dynamic> json,
    String flightId,
  ) {
    print('🔍 [Timeline Event] Parsing: ${json['title']}');
    print('   start_time: ${json['start_time']}');
    print('   end_time: ${json['end_time']}');
    
    final startTime = DateTime.parse(json['start_time'] as String);
    final endTime = DateTime.parse(json['end_time'] as String);
    
    print('   parsed start: $startTime');
    print('   parsed end: $endTime');
    
    return LocalTimelineEvent(
      id: json['order'].toString(), // order를 ID로 사용
      flightId: flightId,
      order: json['order'] as int,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: startTime,
      endTime: endTime,
      iconType: json['icon_type'] as String?,
      isEditable: (json['type'] as String) == 'FREE_TIME',
      isCustom: false,
      isActive: false,
    );
  }

  /// TimelineEvent (UI 모델)로 변환
  dynamic toTimelineEvent() {
    // FlightPlanPage의 TimelineEvent 형식으로 변환
    return {
      'icon': _mapIconTypeToAsset(iconType, type),
      'title': title,
      'time': '${_formatTime(startTime)} - ${_formatTime(endTime)}',
      'description': description,
      'isEditable': isEditable,
      'isActive': isActive,
    };
  }
  
  /// icon_type을 asset 경로로 매핑 (FlightPlanPage와 동일)
  String? _mapIconTypeToAsset(String? iconType, String? eventType) {
    // FREE_TIME은 아이콘 없음
    if (eventType == 'FREE_TIME') {
      return null;
    }
    
    if (iconType == null) return null;
    
    switch (iconType.toLowerCase()) {
      case 'airplane_takeoff':
      case 'airplane_landing':
      case 'airplane':
        return 'assets/images/myflight/airplane.png';
      case 'meal':
        return 'assets/images/myflight/meal.png';
      case 'moon':
      case 'sleep':
        return 'assets/images/myflight/moon.png';
      default:
        return null;
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
