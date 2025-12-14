import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'core/theme/app_theme.dart';
import 'core/network/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // UI 스타일 설정
  AppTheme.setSystemUIOverlayStyle();
  
  // 앱 실행 (초기화보다 먼저 실행하여 흰 화면 방지)
  runApp(const MyApp());
  
  // 백그라운드에서 서비스 초기화 시도
  _initializeServices();
}

Future<void> _initializeServices() async {
  try {
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BIMO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
