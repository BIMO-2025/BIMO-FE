import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// BIMO 앱의 테마 시스템
class AppTheme {
  AppTheme._();

  /// 다크 테마 (기본)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: AppColors.blue1,
        secondary: AppColors.yellow1,
        surface: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.black,
        onSurface: AppColors.white,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: AppColors.background,
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.large.copyWith(
          color: AppColors.textPrimary,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.display.copyWith(
          color: AppColors.textPrimary,
        ),
        headlineLarge: AppTextStyles.large.copyWith(
          color: AppColors.textPrimary,
        ),
        headlineMedium: AppTextStyles.medium.copyWith(
          color: AppColors.textPrimary,
        ),
        bodyLarge: AppTextStyles.bigBody.copyWith(
          color: AppColors.textPrimary,
        ),
        bodyMedium: AppTextStyles.body.copyWith(
          color: AppColors.textPrimary,
        ),
        bodySmall: AppTextStyles.smallBody.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      // Page Transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: NoTransitionsBuilder(),
          TargetPlatform.iOS: NoTransitionsBuilder(),
          TargetPlatform.macOS: NoTransitionsBuilder(),
        },
      ),
    );
  }

  /// 라이트 테마 (추후 필요시 구현)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.blue1,
        secondary: AppColors.yellow1,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.black,
      ),
      
      // 추후 라이트 테마 상세 구현
    );
  }

  /// 앱바 그라데이션 컨테이너를 생성하는 헬퍼 메서드
  /// 
  /// 사용 예시:
  /// ```dart
  /// AppBar(
  ///   flexibleSpace: AppTheme.buildAppBarGradient(),
  ///   // ...
  /// )
  /// ```
  static Widget buildAppBarGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.appBarGradient,
      ),
    );
  }

  /// 시스템 UI 오버레이 스타일 설정
  static void setSystemUIOverlayStyle({
    Color? statusBarColor,
    Brightness? statusBarIconBrightness,
    Color? systemNavigationBarColor,
    Brightness? systemNavigationBarIconBrightness,
  }) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: statusBarColor ?? Colors.transparent,
        statusBarIconBrightness: statusBarIconBrightness ?? Brightness.light,
        systemNavigationBarColor: systemNavigationBarColor ?? Colors.transparent,
        systemNavigationBarIconBrightness: systemNavigationBarIconBrightness ?? Brightness.light,
      ),
    );
  }
}

/// 페이지 전환 애니메이션 제거를 위한 빌더
class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

