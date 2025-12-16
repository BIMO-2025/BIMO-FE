import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/network/router/app_router.dart';
import 'features/myflight/data/models/local_timeline_event.dart';
import 'features/myflight/data/models/local_flight.dart';
import 'features/myflight/data/repositories/local_timeline_repository.dart';
import 'features/myflight/data/repositories/local_flight_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // UI 스타일 설정
  AppTheme.setSystemUIOverlayStyle();
  
// 서비스 초기화 (Hive 등) 후 앱 실행
  // await _initializeServices(); // [CHANGE] 블로킹 방지를 위해 제거
  
  runApp(const MyApp());
}

Future<void> _initializeServices() async {
  try {
    // Hive 초기화 (오프라인 로컬 DB)
    await _initializeHive();
    
    // GoogleService-Info.plist 파일이 Xcode 프로젝트에 제대로 링크되지 않았을 경우를 대비해
    // 코드에서 직접 옵션을 설정하여 초기화합니다.
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCEjW8GSUvAOfuPboPmbPTqUzfu80eq9dg',
        appId: '1:129141636882:ios:ca9ee88e5afb0a916afdcb',
        messagingSenderId: '129141636882',
        projectId: 'bimo-813c3',
        storageBucket: 'bimo-813c3.firebasestorage.app',
        iosBundleId: 'com.opensource.bimo',
      ),
    );
    
    // Kakao SDK 초기화
    KakaoSdk.init(nativeAppKey: 'cb8c2dedbefd9ebb03db10733db79cad');
    print("Services initialized successfully");
  } catch (e) {
    print('Initialization Failed: $e');
  }
}

/// Hive 로컬 DB 초기화
Future<void> _initializeHive() async {
  try {
    // Hive 초기화
    await Hive.initFlutter();
    
    // TypeAdapter 등록
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(LocalTimelineEventAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(LocalFlightAdapter());
    }
    
    // Repository 초기화
    final timelineRepo = LocalTimelineRepository();
    await timelineRepo.init();
    
    final flightRepo = LocalFlightRepository();
    await flightRepo.init();
    
    print('✅ Hive 로컬 DB 초기화 완료');
  } catch (e) {
    print('❌ Hive 초기화 실패: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeServices(),
      builder: (context, snapshot) {
        // 초기화 완료 전이라도 앱을 실행하여 스플래시 화면이 뜨도록 함
        // (SplashPage에서 어차피 로딩 및 토큰 체크를 하므로 바로 진입해도 됨)
        // 단, Hive 박스가 열리기 전에 데이터 접근하면 에러가 날 수 있으므로
        // SplashPage가 최소 2초 대기하는 동안 초기화가 완료될 것으로 기대
        
        return MaterialApp.router(
          title: 'BIMO',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
