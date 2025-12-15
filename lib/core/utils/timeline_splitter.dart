import '../data/models/local_timeline_event.dart';

/// 타임라인 스마트 분할 로직
/// 사용자가 기존 블록에 스케줄을 추가하면 자동으로 남는 시간을 "자유 시간"으로 분할
class TimelineSplitter {
  TimelineSplitter._();

  /// 기존 타임라인 블록을 사용자 스케줄로 분할
  /// 
  /// 예: 기존 10:00~12:00 (이륙 및 안정) + 사용자 10:00~11:00 (독서)
  /// 결과: [10:00~11:00 독서], [11:00~12:00 자유시간]
  static List<LocalTimelineEvent> splitTimelineBlock({
    required LocalTimelineEvent existingBlock,
    required LocalTimelineEvent userSchedule,
  }) {
    final List<LocalTimelineEvent> result = [];

    // 1. 사용자 스케줄이 블록 완전히 덮으면
    if (userSchedule.startTime == existingBlock.startTime &&
        userSchedule.endTime == existingBlock.endTime) {
      return [userSchedule];
    }

    // 2. 사용자 스케줄이 블록 시작 부분을 덮으면
    if (userSchedule.startTime == existingBlock.startTime &&
        userSchedule.endTime.isBefore(existingBlock.endTime)) {
      result.add(userSchedule);
      result.add(createFreeTimeBlock(
        flightId: existingBlock.flightId,
        order: existingBlock.order + 1,
        startTime: userSchedule.endTime,
        endTime: existingBlock.endTime,
      ));
      return result;
    }

    // 3. 사용자 스케줄이 블록 중간을 덮으면
    if (userSchedule.startTime.isAfter(existingBlock.startTime) &&
        userSchedule.endTime.isBefore(existingBlock.endTime)) {
      // 앞쪽 자유 시간
      result.add(createFreeTimeBlock(
        flightId: existingBlock.flightId,
        order: existingBlock.order,
        startTime: existingBlock.startTime,
        endTime: userSchedule.startTime,
      ));
      // 사용자 스케줄
      result.add(userSchedule);
      // 뒤쪽 자유 시간
      result.add(createFreeTimeBlock(
        flightId: existingBlock.flightId,
        order: existingBlock.order + 2,
        startTime: userSchedule.endTime,
        endTime: existingBlock.endTime,
      ));
      return result;
    }

    // 4. 사용자 스케줄이 블록 끝 부분을 덮으면
    if (userSchedule.startTime.isAfter(existingBlock.startTime) &&
        userSchedule.endTime == existingBlock.endTime) {
      result.add(createFreeTimeBlock(
        flightId: existingBlock.flightId,
        order: existingBlock.order,
        startTime: existingBlock.startTime,
        endTime: userSchedule.startTime,
      ));
      result.add(userSchedule);
      return result;
    }

    // 5. 겹치지 않으면 원본 반환
    return [existingBlock];
  }

  /// 자유 시간 블록 생성
  static LocalTimelineEvent createFreeTimeBlock({
    required String flightId,
    required int order,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return LocalTimelineEvent(
      id: 'free_${startTime.millisecondsSinceEpoch}',
      flightId: flightId,
      order: order,
      type: 'FREE_TIME',
      title: '자유 시간',
      description: '자유롭게 일정을 등록하실 수 있습니다.',
      startTime: startTime,
      endTime: endTime,
      iconType: null,
      isEditable: true,
      isCustom: false,
      isActive: false,
    );
  }

  /// 타임라인 병합 및 시간 충돌 해결
  /// 전체 타임라인을 시간 순으로 정렬하고 겹치는 부분 해결
  static List<LocalTimelineEvent> mergeAndResolveConflicts(
    List<LocalTimelineEvent> events,
  ) {
    if (events.isEmpty) return [];

    // 시간 순 정렬
    events.sort((a, b) => a.startTime.compareTo(b.startTime));

    final List<LocalTimelineEvent> merged = [];
    LocalTimelineEvent current = events.first;

    for (int i = 1; i < events.length; i++) {
      final next = events[i];

      // 시간 겹침 체크
      if (current.endTime.isAfter(next.startTime)) {
        // 사용자 커스텀이 우선
        if (next.isCustom && !current.isCustom) {
          // 현재 블록 잘라내기
          if (current.startTime.isBefore(next.startTime)) {
            merged.add(LocalTimelineEvent(
              id: '${current.id}_split',
              flightId: current.flightId,
              order: current.order,
              type: current.type,
              title: current.title,
              description: current.description,
              startTime: current.startTime,
              endTime: next.startTime,
              iconType: current.iconType,
              isEditable: current.isEditable,
              isCustom: current.isCustom,
              isActive: current.isActive,
            ));
          }
          current = next;
        }
      } else {
        merged.add(current);
        current = next;
      }
    }

    merged.add(current);

    // order 재정렬
    for (int i = 0; i < merged.length; i++) {
      merged[i].order = i + 1;
    }

    return merged;
  }

  /// 타임라인 간격 체크 및 자유 시간 자동 생성
  /// 이벤트 사이에 시간 간격이 있으면 자유 시간으로 채움
  static List<LocalTimelineEvent> fillGapsWithFreeTime(
    List<LocalTimelineEvent> events,
    String flightId,
  ) {
    if (events.isEmpty) return [];

    events.sort((a, b) => a.startTime.compareTo(b.startTime));

    final List<LocalTimelineEvent> filled = [];
    filled.add(events.first);

    for (int i = 1; i < events.length; i++) {
      final previous = filled.last;
      final current = events[i];

      // 간격이 있으면 자유 시간 추가
      if (current.startTime.isAfter(previous.endTime)) {
        final gap = createFreeTimeBlock(
          flightId: flightId,
          order: previous.order + 1,
          startTime: previous.endTime,
          endTime: current.startTime,
        );
        filled.add(gap);
      }

      filled.add(current);
    }

    // order 재정렬
    for (int i = 0; i < filled.length; i++) {
      filled[i].order = i + 1;
    }

    return filled;
  }
}
