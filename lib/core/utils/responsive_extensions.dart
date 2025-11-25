import 'package:flutter/material.dart';
import 'responsive.dart';

/// 반응형 디자인을 쉽게 사용하기 위한 Extension
extension ResponsiveExtension on BuildContext {
  /// 디자인 너비를 현재 화면에 맞게 변환
  /// 
  /// 사용 예시:
  /// ```dart
  /// SizedBox(width: context.w(100))  // 디자인 100 → 실제 크기
  /// ```
  double w(double designWidth) => Responsive.width(this, designWidth);

  /// 디자인 높이를 현재 화면에 맞게 변환
  /// 
  /// 사용 예시:
  /// ```dart
  /// SizedBox(height: context.h(50))  // 디자인 50 → 실제 크기
  /// ```
  double h(double designHeight) => Responsive.height(this, designHeight);

  /// 디자인 사이즈를 현재 화면에 맞게 변환 (정사각형)
  /// 
  /// 사용 예시:
  /// ```dart
  /// SizedBox(
  ///   width: context.s(100),
  ///   height: context.s(100),
  /// )
  /// ```
  double s(double designSize) => Responsive.size(this, designSize);

  /// 디자인 폰트 크기를 현재 화면에 맞게 변환
  /// 
  /// 사용 예시:
  /// ```dart
  /// TextStyle(fontSize: context.fs(16))
  /// ```
  double fs(double designFontSize) => Responsive.fontSize(this, designFontSize);

  /// 현재 화면 너비
  double get screenWidth => Responsive.screenWidth(this);

  /// 현재 화면 높이
  double get screenHeight => Responsive.screenHeight(this);

  /// 너비 비율
  double get widthRatio => Responsive.widthRatio(this);

  /// 높이 비율
  double get heightRatio => Responsive.heightRatio(this);
}

