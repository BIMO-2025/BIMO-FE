import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data; // Timezone 데이터
import 'package:timezone/timezone.dart' as tz;
import 'package:path_provider/path_provider.dart';

enum NotificationType { flight, review, promotion }

class NotificationItem {
  final String title;
  final String message;
  final String time;
  bool isRead;
  final NotificationType type;


  final String? assetIcon; // 커스텀 에셋 아이콘 경로

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
    required this.type,
    this.assetIcon,
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
  
  // flutter_local_notifications 플러그인
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  NotificationService._internal() {
    _updateUnreadStatus();
    _setupMethodChannel();
    _initializeNotifications();
  }

  // 알림 초기화
  Future<void> _initializeNotifications() async {
    // 1. Timezone 데이터 초기화 (필수)
    tz_data.initializeTimeZones();
    
    // 2. 로컬 타임존 설정 (한국 시간대 'Asia/Seoul'로 고정하거나 시스템 타임존 사용)
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    } catch (e) {
      print('⚠️ 타임존 설정 오류(기본값 사용): $e');
      // 에러 발생 시 UTC 등을 기본값으로 사용할 수 있음
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        print('📱 알림 탭됨: ${details.payload}');
      },
    );
    
    // iOS 권한 요청
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    
    print('✅ 알림 초기화 완료');
  }

  // MethodChannel 설정
  static const MethodChannel _channel = MethodChannel('com.example.bimo_fe/notification');

  void _setupMethodChannel() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onNotificationReceived') {
        final args = call.arguments as Map;
        final title = args['title'] as String;
        final body = args['body'] as String;
        final payload = args['payload'] as String;
        
        print('📱 [Flutter] 네이티브로부터 알림 수신: $title');
        print('📱 [Flutter] Payload: $payload');
        
        // Payload 파싱하여 앱 내 알림 목록에 추가
        _addNotificationFromPayload(title, body, payload);
      }
    });
  }

  void _addNotificationFromPayload(String title, String body, String payload) {
    print('🔍 Payload 파싱 시작: $payload');
    
    // 타임라인 알림인지 확인
    if (payload.contains('_timeline_')) {
      // 타임라인 알림 추가
      addNotification(
        NotificationItem(
          title: title,
          message: body,
          time: '방금 전',
          isRead: false,
          type: NotificationType.flight, // 타임라인도 flight 타입 사용
          assetIcon: payload.split('|').length > 1 ? payload.split('|')[1] : null,
        ),
      );
      print('✅ 타임라인 알림 추가 완료: $title');
    } else {
      // 일반 비행 알림 추가
      addNotification(
        NotificationItem(
          title: title,
          message: body,
          time: '방금 전',
          isRead: false,
          type: NotificationType.flight,
        ),
      );
      print('✅ 비행 알림 추가 완료: $title');
    }
  }

  // 알림 목록 (ValueNotifier) - 초기에는 비어있음
  final ValueNotifier<List<NotificationItem>> notifications = ValueNotifier([]);

  // 읽지 않은 알림 여부 (ValueNotifier)
  final ValueNotifier<bool> hasUnread = ValueNotifier(false);

  // 초기화 시 읽지 않은 알림 상태 확인
  void _updateUnreadStatus() {
    hasUnread.value = notifications.value.any((item) => !item.isRead);
  }

  // 알림 추가 메서드
  void addNotification(NotificationItem notification) {
    final currentNotifications = List<NotificationItem>.from(notifications.value);
    currentNotifications.insert(0, notification); // 최신 알림을 맨 위에
    notifications.value = currentNotifications;
    _updateUnreadStatus();
    print('✅ 알림 추가됨: ${notification.title}');
  }

  // 비행 2시간 전 알림 스케줄링
  Future<void> scheduleFlightReminder({
    required String flightNumber,
    required DateTime scheduledTime,
  }) async {
    try {
      print('✅ 알림 스케줄링 시작:');
      print('   비행편: $flightNumber');
      print('   알림 시간: $scheduledTime');
      
      // 과거 시간 체크
      if (scheduledTime.isBefore(DateTime.now())) {
        print('⚠️ 알림 시간이 과거입니다. 즉시 발송합니다.');
        
        // 즉시 알림 표시
        const androidDetails = AndroidNotificationDetails(
          'flight_channel',
          'Flight Notifications',
          channelDescription: '비행 알림',
          importance: Importance.high,
          priority: Priority.high,
        );
        
        const iosDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );
        
        const details = NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        );
        
        await _flutterLocalNotificationsPlugin.show(
          0,
          '비행 2시간 전',
          '$flightNumber편 출발 2시간 전입니다. 공항으로 출발하세요.',
          details,
          payload: 'flight_$flightNumber',
        );
        
        print('✅ 즉시 알림 발송 완료');
      } else {
        // 미래 시간에 알림 스케줄링
        final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
        
        const androidDetails = AndroidNotificationDetails(
          'flight_channel',
          'Flight Notifications',
          channelDescription: '비행 알림',
          importance: Importance.high,
          priority: Priority.high,
        );
        
        const iosDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );
        
        const details = NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        );
        
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          0,
          '비행 2시간 전',
          '$flightNumber편 출발 2시간 전입니다. 공항으로 출발하세요.',
          tzScheduledTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'flight_$flightNumber',
        );
        
        print('✅ 알림 스케줄링 완료: ${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')}');
      }
    } catch (e) {
      print('❌ 알림 스케줄링 실패: $e');
    }

  }

  // 즉시 알림 표시 (Public 메서드)
  Future<void> showInstantNotification(String title, String body, {String? payload, String? iconAssetPath}) async {
    try {
      print('🚀 즉시 알림 발송: $title');
      
      // Asset 아이콘 처리
      String? largeIconPath;
      if (iconAssetPath != null) {
        largeIconPath = await _assetToFile(iconAssetPath);
      }

      // Android 설정
      final androidDetails = AndroidNotificationDetails(
        'timeline_channel',
        'Timeline Notifications',
        channelDescription: '비행 타임라인 알림',
        importance: Importance.high,
        priority: Priority.high,
        largeIcon: largeIconPath != null ? FilePathAndroidBitmap(largeIconPath) : null,
      );
      
      // iOS 설정
      List<DarwinNotificationAttachment>? iosAttachments;
      if (largeIconPath != null) {
        iosAttachments = [DarwinNotificationAttachment(largeIconPath)];
      }

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        attachments: iosAttachments,
      );
      
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      // ID는 현재 시간 기반으로 생성
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      print('❌ 즉시 알림 발송 실패: $e');
    }
  }

  // 타임라인 알림 스케줄링 (커스텀 아이콘 포함)
  Future<void> scheduleTimelineNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? iconAssetPath,
  }) async {
    try {
      print('✅ 타임라인 알림 스케줄링: $title ($scheduledTime)');
      
      // Asset 아이콘을 파일로 변환 (Large Icon용)
      String? largeIconPath;
      if (iconAssetPath != null) {
        largeIconPath = await _assetToFile(iconAssetPath);
      }

      // Android 설정
      final androidDetails = AndroidNotificationDetails(
        'timeline_channel',
        'Timeline Notifications',
        channelDescription: '비행 타임라인 알림',
        importance: Importance.high,
        priority: Priority.high,
        largeIcon: largeIconPath != null ? FilePathAndroidBitmap(largeIconPath) : null,
      );
      
      // iOS 설정
      // iOS는 attachments를 사용하여 이미지를 표시해야 함
      List<DarwinNotificationAttachment>? iosAttachments;
      if (largeIconPath != null) {
        iosAttachments = [DarwinNotificationAttachment(largeIconPath)];
      }

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        attachments: iosAttachments,
      );
      
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      // Payload에 아이콘 경로 포함 (구분자 | 사용)
      // 예: flight_timeline_123|assets/images/timeline/checkin.png
      final payload = 'flight_timeline_$id${iconAssetPath != null ? "|$iconAssetPath" : ""}';

      if (scheduledTime.isBefore(DateTime.now())) {
        // 즉시 발송
        await _flutterLocalNotificationsPlugin.show(
          id,
          title,
          body,
          details,
          payload: payload,
        );
      } else {
        // 스케줄링
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(scheduledTime, tz.local),
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );
      }
      print('✅ 알림 예약 성공: $title');
    } catch (e) {
      print('❌ 타임라인 알림 스케줄링 실패: $e');
    }
  }

  // Asset 이미지를 임시 파일로 저장하여 경로 반환
  Future<String?> _assetToFile(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${assetPath.split("/").last}');
      await tempFile.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
      return tempFile.path;
    } catch (e) {
      print('❌ Asset 파일 변환 실패: $e');
      return null;
    }
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
