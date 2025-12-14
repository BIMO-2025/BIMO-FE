import 'package:flutter/material.dart';

enum NotificationType { flight, review, promotion }

class NotificationItem {
  final String title;
  final String message;
  final String time;
  bool isRead;
  final NotificationType type;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
    required this.type,
  });

  IconData get icon {
    switch (type) {
      case NotificationType.flight:
        return Icons.flight_takeoff;
      case NotificationType.review:
        return Icons.star;
      case NotificationType.promotion:
        return Icons.local_offer;
    }
  }
}

class NotificationService {
  // 싱글톤 패턴
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal() {
    _updateUnreadStatus();
  }

  // 알림 목록 (ValueNotifier)
  final ValueNotifier<List<NotificationItem>> notifications = ValueNotifier([
    NotificationItem(
      title: '탑승 수속 시작',
      message: 'KE901편 탑승 수속이 시작되었습니다. 카운터 A로 이동해주세요.',
      time: '방금 전',
      isRead: false,
      type: NotificationType.flight,
    ),
    NotificationItem(
      title: '리뷰 작성 완료',
      message: '대한항공 리뷰 작성이 완료되었습니다. 100 포인트를 획득하셨습니다!',
      time: '1시간 전',
      isRead: true,
      type: NotificationType.review,
    ),
    NotificationItem(
      title: '특가 항공권 알림',
      message: '찜해두신 파리행 항공권이 최저가로 떨어졌습니다. 지금 확인해보세요.',
      time: '어제',
      isRead: true,
      type: NotificationType.promotion,
    ),
  ]);

  // 읽지 않은 알림 여부 (ValueNotifier)
  final ValueNotifier<bool> hasUnread = ValueNotifier(true);

  // 초기화 시 읽지 않은 알림 상태 확인
  void _updateUnreadStatus() {
    hasUnread.value = notifications.value.any((item) => !item.isRead);
  }

  // 알림 읽음 처리
  void markAsRead(int index) {
    final currentNotifications = List<NotificationItem>.from(notifications.value);
    if (index >= 0 && index < currentNotifications.length) {
      // 이미 읽은 상태면 무시
      if (currentNotifications[index].isRead) return;

      currentNotifications[index].isRead = true;
      notifications.value = currentNotifications; // 리스트 업데이트로 리스너 알림
      _updateUnreadStatus();
    }
  }

  // 모든 알림 읽음 처리
  void markAllAsRead() {
    final currentNotifications = List<NotificationItem>.from(notifications.value);
    bool hasChanges = false;
    for (var item in currentNotifications) {
      if (!item.isRead) {
        item.isRead = true;
        hasChanges = true;
      }
    }
    
    if (hasChanges) {
      notifications.value = currentNotifications;
      _updateUnreadStatus();
    }
  }
}
