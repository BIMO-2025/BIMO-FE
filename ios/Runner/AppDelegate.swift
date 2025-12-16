import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // UNUserNotificationCenter delegate 설정
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// iOS 10+ 포그라운드 알림 처리
@available(iOS 10.0, *)
extension AppDelegate {
  // 포그라운드에서 알림을 받았을 때
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    let userInfo = notification.request.content.userInfo
    let title = notification.request.content.title
    let body = notification.request.content.body
    let payload = userInfo["payload"] as? String ?? ""
    
    print("📱 [iOS] 포그라운드 알림 수신: \(title)")
    
    // Flutter로 알림 정보 전달
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "com.example.bimo_fe/notification",
        binaryMessenger: controller.binaryMessenger
      )
      
      channel.invokeMethod("onNotificationReceived", arguments: [
        "title": title,
        "body": body,
        "payload": payload
      ])
    }
    
    // 알림을 표시하도록 설정
    completionHandler([.alert, .sound, .badge])
  }
}
