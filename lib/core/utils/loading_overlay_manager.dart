import 'package:flutter/material.dart';
import '../widgets/loading_widget.dart';

/// 전역 로딩 관리자
/// API Interceptor에서 로딩 오버레이를 표시/숨기기 위해 사용
class LoadingOverlayManager {
  static final LoadingOverlayManager _instance = LoadingOverlayManager._internal();
  factory LoadingOverlayManager() => _instance;
  LoadingOverlayManager._internal();

  OverlayEntry? _overlayEntry;
  int _requestCount = 0; // 동시 요청 수 추적

  /// 로딩 오버레이 표시
  void show(BuildContext context) {
    _requestCount++;
    
    // 이미 표시 중이면 무시
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => const LoadingWidget(),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  /// 로딩 오버레이 숨기기
  void hide() {
    _requestCount--;
    
    // 모든 요청이 완료되었을 때만 숨김
    if (_requestCount <= 0) {
      _requestCount = 0;
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  /// 강제로 모든 로딩 숨기기 (에러 발생 시 등)
  void forceHide() {
    _requestCount = 0;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
