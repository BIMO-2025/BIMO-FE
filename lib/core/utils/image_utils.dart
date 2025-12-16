import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

/// 이미지 경로에 따라 적절한 Image 위젯을 반환하는 유틸리티 함수
class ImageUtils {
  /// 이미지 빌더 - Base64, HTTP, Asset, File 모두 지원
  static Widget buildImage(
    String imagePath, {
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
  }) {
    // Base64 데이터 URL 처리
    if (imagePath.startsWith('data:image')) {
      try {
        final base64String = imagePath.split(',')[1];
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? Container(color: const Color(0xFF333333));
          },
        );
      } catch (e) {
        print('❌ Base64 디코딩 실패: $e');
        return errorWidget ?? Container(color: const Color(0xFF333333));
      }
    }
    // HTTP URL 처리
    else if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              Image.network(
                'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800&q=80',
                fit: fit,
              );
        },
      );
    }
    // Asset 경로 처리
    else if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? Container(color: const Color(0xFF333333));
        },
      );
    }
    // 로컬 파일 경로 처리
    else {
      return Image.file(
        File(imagePath),
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? Container(color: const Color(0xFF333333));
        },
      );
    }
  }
}
