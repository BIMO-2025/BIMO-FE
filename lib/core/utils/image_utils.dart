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
    // 4. 그 외 (Base64 시도 후 실패 시 파일로 처리)
    else {
      // 4-1. Base64 디코딩 시도
      try {
        String possibleBase64 = imagePath;
        // 공백 제거 (일부 경우 발생 가능)
        possibleBase64 = possibleBase64.replaceAll(RegExp(r'\s+'), '');
        
        // Base64 유효성 검사 (길이 및 문자) - 간단히 try-catch로 처리
        final bytes = base64Decode(possibleBase64);
        return Image.memory(
          bytes,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? Container(color: const Color(0xFF333333));
          },
        );
      } catch (e) {
        // 4-2. Base64 아니면 로컬 파일로 처리
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
}
