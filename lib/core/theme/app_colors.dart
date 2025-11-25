import 'package:flutter/material.dart';

/// BIMO 앱의 색상 시스템
/// Figma 디자인 시스템 기반
class AppColors {
  AppColors._();

  // Base Colors
  /// 기본 블랙 - #1A1A1A
  static const Color black = Color(0xFF1A1A1A);
  
  /// 기본 화이트 - #FFFFFF
  static const Color white = Color(0xFFFFFFFF);
  
  /// 블루 1 - #0080FF
  static const Color blue1 = Color(0xFF0080FF);
  
  /// 옐로우 1 - #DDFF66
  static const Color yellow1 = Color(0xFFDDFF66);

  // Semantic Colors
  /// 주요 배경색
  static const Color background = black;
  
  /// 서페이스 색상
  static const Color surface = white;
  
  /// 주요 텍스트 색상
  static const Color textPrimary = white;
  
  /// 보조 텍스트 색상
  static const Color textSecondary = Color(0xFF999999);
  
  /// 3차 텍스트 색상
  static const Color textTertiary = Color(0xFF666666);

  // System Colors
  /// 에러 색상
  static const Color error = Color(0xFFFF3B30);
  
  /// 성공 색상
  static const Color success = Color(0xFF34C759);
  
  /// 경고 색상
  static const Color warning = Color(0xFFFFCC00);

  // Gradients
  /// 앱바 그라데이션
  /// linear-gradient(0deg, rgba(26, 26, 26, 0.00) 0%, #1A1A1A 100%)
  static const LinearGradient appBarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A1A1A), // 100% - Black at top
      Color(0x001A1A1A), // 0% - Transparent at bottom
    ],
    stops: [0.0, 1.0],
  );
}

