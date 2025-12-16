import 'package:hive/hive.dart';
import '../models/local_timeline_event.dart';

/// 로컬 타임라인 리포지토리 (Hive 기반)
/// 오프라인 CRUD 작업
class LocalTimelineRepository {
  static const String _boxName = 'timeline_events';
  late Box<LocalTimelineEvent> _box;

  /// 박스 초기화
  Future<void> init() async {
    _box = await Hive.openBox<LocalTimelineEvent>(_boxName);
  }

  /// 비행 ID로 타임라인 전체 저장 (덮어쓰기)
  Future<void> saveTimeline(String flightId, List<LocalTimelineEvent> events) async {
    // 기존 타임라인 삭제
    await deleteTimeline(flightId);
    
    // 새 타임라인 저장
    for (final event in events) {
      final key = '${flightId}_${event.id}';
      await _box.put(key, event);
    }
    
    print('✅ 타임라인 로컬 저장 완료: $flightId (${events.length}개)');
  }

  /// 원본 타임라인 저장 (AI 초기화용)
  Future<void> saveOriginalTimeline(String flightId, List<LocalTimelineEvent> events) async {
    final box = await Hive.openBox<LocalTimelineEvent>('original_timelines');
    final key = 'original_$flightId';
    
    // 기존 원본 타임라인 삭제
    final existingKeys = box.keys.where((k) => k.toString().startsWith(key)).toList();
    for (var k in existingKeys) {
      await box.delete(k);
    }
    
    // 새 원본 타임라인 저장
    for (int i = 0; i < events.length; i++) {
      await box.put('${key}_$i', events[i]);
    }
    
    print('✅ 원본 타임라인 저장 완료: $flightId (${events.length}개)');
  }

  /// 원본 타임라인 로드 (AI 초기화용)
  Future<List<LocalTimelineEvent>> loadOriginalTimeline(String flightId) async {
    final box = await Hive.openBox<LocalTimelineEvent>('original_timelines');
    final key = 'original_$flightId';
    
    final events = <LocalTimelineEvent>[];
    int index = 0;
    while (true) {
      final event = box.get('${key}_$index');
      if (event == null) break;
      events.add(event);
      index++;
    }
    
    if (events.isNotEmpty) {
      print('✅ 원본 타임라인 로드 완료: $flightId (${events.length}개)');
    } else {
      print('⚠️ 원본 타임라인 없음: $flightId');
    }
    
    return events;
  }

  /// 비행 ID로 타임라인 조회
  Future<List<LocalTimelineEvent>> getTimeline(String flightId) async {
    final allEvents = _box.values.where((e) => e.flightId == flightId).toList();
    // order 순으로 정렬
    allEvents.sort((a, b) => a.order.compareTo(b.order));
    return allEvents;
  }

  /// 이벤트 추가
  Future<void> addEvent(LocalTimelineEvent event) async {
    final key = '${event.flightId}_${event.id}';
    await _box.put(key, event);
    print('✅ 이벤트 추가: ${event.title}');
  }

  /// 이벤트 업데이트
  Future<void> updateEvent(String flightId, String eventId, LocalTimelineEvent updatedEvent) async {
    final key = '${flightId}_$eventId';
    await _box.put(key, updatedEvent);
    print('✅ 이벤트 업데이트: ${updatedEvent.title}');
  }

  /// 이벤트 삭제
  Future<void> deleteEvent(String flightId, String eventId) async {
    final key = '${flightId}_$eventId';
    await _box.delete(key);
    print('✅ 이벤트 삭제: $eventId');
  }

  /// 비행 전체 타임라인 삭제
  Future<void> deleteTimeline(String flightId) async {
    final keysToDelete = _box.keys.where((key) => key.toString().startsWith(flightId)).toList();
    for (final key in keysToDelete) {
      await _box.delete(key);
    }
  }

  /// 타임라인 시간 일괄 조정 (지연 시 사용)
  Future<void> shiftTimelineEvents(String flightId, Duration offset) async {
    final events = await getTimeline(flightId);
    print('🔄 [Shift] 시작: $flightId, offset: $offset, 이벤트 수: ${events.length}');
    
    for (final event in events) {
      final oldStart = event.startTime;
      final oldEnd = event.endTime;
      
      event.startTime = event.startTime.add(offset);
      event.endTime = event.endTime.add(offset);
      
      print('   [${event.title}] $oldStart -> ${event.startTime} | $oldEnd -> ${event.endTime}');
      
      final key = '${flightId}_${event.id}';
      await _box.put(key, event);
    }
    
    print('✅ 타임라인 ${events.length}개 이벤트 시간 조정 완료: +$offset');
  }

  /// 모든 타임라인 삭제 (테스트용)
  Future<void> clearAll() async {
    await _box.clear();
    print('⚠️ 모든 타임라인 삭제됨');
  }
}
