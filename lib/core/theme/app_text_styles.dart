import 'package:flutter/material.dart';

/// BIMO 앱의 텍스트 스타일 시스템
/// Pretendard 폰트 기반 (Variable 폰트 효과를 weight로 구현)
///
/// 사용 가능한 weight:
/// - 100: Thin
/// - 200: ExtraLight
/// - 300: Light
/// - 400: Regular
/// - 500: Medium
/// - 600: SemiBold
/// - 700: Bold
/// - 800: ExtraBold
/// - 900: Black
class AppTextStyles {
  AppTextStyles._();

  // Base Pretendard TextStyle
  static const TextStyle _basePretendard = TextStyle(fontFamily: 'Pretendard');

  /// Display - 40pt, SemiBold (600), 100% line height, -2% letter spacing
  /// 주로 큰 제목이나 헤딩에 사용
  static TextStyle get display => _basePretendard.copyWith(
    fontSize: 40,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.0, // 100%
    letterSpacing: -0.8, // -2% of 40
  );

  /// Large - 19pt, Bold (700), 120% line height, -2% letter spacing
  /// 중요한 제목이나 강조 텍스트
  static TextStyle get large => _basePretendard.copyWith(
    fontSize: 19,
    fontWeight: FontWeight.w700, // Bold
    height: 1.2, // 120%
    letterSpacing: -0.38, // -2% of 19
  );

  /// Large Light - 19pt, SemiBold (600), 120% line height, -2% letter spacing
  /// Large의 경량 버전
  static TextStyle get largeLight => _basePretendard.copyWith(
    fontSize: 19,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.2, // 120%
    letterSpacing: -0.38, // -2% of 19
  );

  /// Medium - 17pt, SemiBold (600), 150% line height, -2% letter spacing
  /// 중간 크기 제목이나 부제목
  static TextStyle get medium => _basePretendard.copyWith(
    fontSize: 17,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.5, // 150%
    letterSpacing: -0.34, // -2% of 17
  );

  /// Body - 15pt, Regular (400), 150% line height, -2% letter spacing
  /// 기본 본문 텍스트
  static TextStyle get body => _basePretendard.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w400, // Regular
    height: 1.5, // 150%
    letterSpacing: -0.3, // -2% of 15
  );

  /// Big Body - 15pt, SemiBold (600), 150% line height, -2% letter spacing
  /// 강조된 본문 텍스트
  static TextStyle get bigBody => _basePretendard.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.5, // 150%
    letterSpacing: -0.3, // -2% of 15
  );

  /// Small Body - 13pt, Regular (400), 120% line height, -2% letter spacing
  /// 작은 본문이나 캡션
  static TextStyle get smallBody => _basePretendard.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400, // Regular
    height: 1.2, // 120%
    letterSpacing: -0.26, // -2% of 13
  );

  /// Button Text - 15pt, Medium (500), 120% line height, -0.225px letter spacing
  /// 버튼 텍스트용
  static TextStyle get buttonText => _basePretendard.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w500, // Medium
    height: 1.2, // 120%
    letterSpacing: -0.225,
  );
}
