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
  /// 기본 타임라인 생성
  Future<List<LocalTimelineEvent>> generateDefaultTimeline(String flightId, DateTime departure, DateTime arrival) async {
    // 도착 시간이 출발 시간보다 이전이면 날짜 변경선/자정 통과로 간주하여 하루 더함
    DateTime adjustedArrival = arrival;
    if (arrival.isBefore(departure)) {
      print('⚠️ 도착 시간이 출발 시간보다 빠름. 하루 더함 처리.');
      adjustedArrival = arrival.add(const Duration(days: 1));
    }

    final totalDuration = adjustedArrival.difference(departure);
    print('📊 타임라인 생성: $flightId, 소요시간: ${totalDuration.inMinutes}분');
    
    final events = <LocalTimelineEvent>[];

    // 1. 이륙 및 안정 (출발 ~ 30분)
    events.add(LocalTimelineEvent(
      id: 'event_1',
      flightId: flightId,
      title: '이륙 및 안정',
      description: '안전한 비행을 위해 좌석벨트를 매주세요.',
      startTime: departure,
      endTime: departure.add(const Duration(minutes: 30)),
      type: 'flight',
      order: 0,
    ));

    // 2. 기내식 (출발 1시간 후)
    if (totalDuration.inHours >= 2) {
      events.add(LocalTimelineEvent(
        id: 'event_2',
        flightId: flightId,
        title: '첫 번째 기내식',
        description: '맛있는 기내식이 제공됩니다.',
        startTime: departure.add(const Duration(minutes: 60)),
        endTime: departure.add(const Duration(minutes: 120)),
        type: 'meal',
        order: 1,
      ));
    }

    // 3. 자유 시간 (중간 시간)
    final freeTimeStart = totalDuration.inHours >= 2 
        ? departure.add(const Duration(minutes: 120)) 
        : departure.add(const Duration(minutes: 30));
    final freeTimeEnd = arrival.subtract(const Duration(minutes: 40));
    
    if (freeTimeEnd.isAfter(freeTimeStart)) {
      events.add(LocalTimelineEvent(
        id: 'event_3',
        flightId: flightId,
        title: '자유 시간',
        description: '영화 감상이나 휴식을 취하세요.',
        startTime: freeTimeStart,
        endTime: freeTimeEnd,
        type: 'rest',
        order: 2,
      ));
    }

    // 4. 착륙 준비 (도착 40분 전 ~ 도착)
    events.add(LocalTimelineEvent(
      id: 'event_4',
      flightId: flightId,
      title: '착륙 준비',
      description: '좌석 등받이를 세우고 테이블을 접어주세요.',
      startTime: arrival.subtract(const Duration(minutes: 40)),
      endTime: arrival,
      type: 'flight',
      order: 3,
    ));

    // 저장
    await saveTimeline(flightId, events);
    return events;
  }
}
