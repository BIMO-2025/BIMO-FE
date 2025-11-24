import 'package:flutter/material.dart';

/// 반응형을 위한 화면 비율 계산 코드
/// 피그마는: 375 x 812 
class Responsive {
  Responsive._();

  /// 기준 디자인 너비 (375)
  static const double designWidth = 375.0;

  /// 기준 디자인 높이 (812)
  static const double designHeight = 812.0;

  /// 현재 화면의 너비를 기준 너비로 나눈 비율
  static double widthRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width / designWidth;
  }

  /// 현재 화면의 높이를 기준 높이로 나눈 비율
  static double heightRatio(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return height / designHeight;
  }

  /// 너비
  static double width(BuildContext context, double designWidth) {
    return designWidth * widthRatio(context);
  }

  /// 높이
  static double height(BuildContext context, double designHeight) {
    return designHeight * heightRatio(context);
  }

  /// 폰트
  static double fontSize(BuildContext context, double designFontSize) {
    // 폰트는 너비 비율을 사용하거나 작은 값 사용 (가독성 유지)
    final ratio = widthRatio(context);
    // 최소 0.8, 최대 1.2로 제한 (너무 작거나 크지 않게)
    final clampedRatio = ratio.clamp(0.8, 1.2);
    return designFontSize * clampedRatio;
  }

  /// 사이즈
  static double size(BuildContext context, double designSize) {
    return designSize * widthRatio(context);
  }

  /// 현재 화면 너비
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// 현재 화면 높이
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// 기준 비율로 스케일링 (높이 기준)
  /// 
  /// 이미지 등 높이가 중요한 경우 사용
  static double scaleByHeight(BuildContext context, double value) {
    return value * heightRatio(context);
  }

  /// 기준 비율로 스케일링 (너비 기준)
  /// 
  /// 일반적인 너비/폰트 등에 사용
  static double scaleByWidth(BuildContext context, double value) {
    return value * widthRatio(context);
  }

  /// Home Indicator 높이를 반응형으로 반환
  /// 
  /// 기준: 34px (디자인 기준)
  static double homeIndicatorHeight(BuildContext context) {
    return height(context, 34.0);
  }

  /// Safe Area 하단 padding (Home Indicator 포함)
  /// 
  /// MediaQuery의 padding.bottom과 비교하여 더 큰 값 사용
  static double bottomSafeArea(BuildContext context) {
    final mediaQueryPadding = MediaQuery.of(context).padding.bottom;
    final homeIndicator = homeIndicatorHeight(context);
    return mediaQueryPadding > 0 ? mediaQueryPadding : homeIndicator;
  }
}

