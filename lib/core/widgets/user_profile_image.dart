import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

class UserProfileImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final Color? borderColor;

  const UserProfileImage({
    super.key,
    required this.imageUrl,
    this.size = 40,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return _buildDefaultImage();

    Widget imageWidget;

    if (imageUrl.startsWith('http')) {
      imageWidget = Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultImage(),
      );
    } else if (imageUrl.startsWith('/') || imageUrl.startsWith('file://')) {
      imageWidget = Image.file(
        File(imageUrl),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultImage(),
      );
    } else if (imageUrl.startsWith('assets/')) {
      imageWidget = Image.asset(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultImage(),
      );
    } else {
      // Base64 문자열 처리
      try {
        String base64String = imageUrl;
        if (base64String.contains(',')) {
          base64String = base64String.split(',').last;
        }
        base64String = base64String.replaceAll(RegExp(r'\s+'), '');
        
        imageWidget = Image.memory(
          base64Decode(base64String),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultImage(),
        );
      } catch (e) {
        // print('❌ Base64 이미지 디코딩 실패: $e');
        imageWidget = _buildDefaultImage();
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderColor != null ? Border.all(color: borderColor!, width: 1) : null,
      ),
      child: ClipOval(
        child: imageWidget,
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Image.asset(
      'assets/images/my/default_profile.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
    );
  }
}
