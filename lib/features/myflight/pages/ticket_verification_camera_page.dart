import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_extensions.dart';
import 'review_write_page.dart';

/// 티켓 인증 카메라 페이지
class TicketVerificationCameraPage extends StatefulWidget {
  const TicketVerificationCameraPage({super.key});

  @override
  State<TicketVerificationCameraPage> createState() => _TicketVerificationCameraPageState();
}

class _TicketVerificationCameraPageState extends State<TicketVerificationCameraPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _showIntroPopup = false;
  int _currentCameraIndex = 0; // 0: 후면, 1: 전면
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // 팝업을 먼저 표시
    _showIntroPopup = true;
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![_currentCameraIndex],
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      } else {
        // 카메라가 없는 경우 (시뮬레이터 등)
        if (mounted) {
          setState(() {
            _isCameraInitialized = false;
          });
        }
      }
    } catch (e) {
      print('카메라 초기화 오류: $e');
      // 오류 발생 시에도 상태 업데이트
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      return;
    }

    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;
    
    await _cameraController?.dispose();
    
    _cameraController = CameraController(
      _cameras![_currentCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('카메라 전환 오류: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      
      if (image != null) {
        // TODO: 백엔드로 이미지 전송 및 인식 처리
        print('갤러리에서 이미지 선택: ${image.path}');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('티켓 인증 중입니다...')),
          );
          // 2초 후 페이지 닫기
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }
      }
    } catch (e) {
      print('갤러리 이미지 선택 오류: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 카메라 프리뷰
          if (_isCameraInitialized && _cameraController != null)
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // 가이드 영역 (항상 표시)
          Center(
            child: Container(
              width: context.w(300),
              height: context.h(200),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // 안내 텍스트 (가이드 아래 16px)
          Positioned(
            top: MediaQuery.of(context).size.height / 2 + context.h(100) + context.h(16),
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '탑승권을 가이드 안에 맞춰주세요',
                style: AppTextStyles.body.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // 하단 컨트롤 영역 (갤러리 + 촬영 + 전환)
          Positioned(
            bottom: context.h(79),
            left: context.w(20),
            right: context.w(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 갤러리 버튼 (왼쪽)
                GestureDetector(
                  onTap: _pickImageFromGallery,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                
                // 촬영 버튼 (중앙)
                GestureDetector(
                  onTap: _takePicture,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                // 카메라 전환 버튼 (오른쪽)
                GestureDetector(
                  onTap: _flipCamera,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flip_camera_ios,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 임시 다음 버튼 (테스트용)
          Positioned(
            top: MediaQuery.of(context).padding.top + context.h(70),
            right: context.w(20),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReviewWritePage(
                      departureCode: 'DXB',
                      departureCity: '두바이',
                      arrivalCode: 'INC',
                      arrivalCity: '인천',
                      flightNumber: 'DF445/ER555',
                      date: '2025.11.12. (토)',
                      stopover: '02시간 00분 SFO',
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(16),
                  vertical: context.h(8),
                ),
                decoration: BoxDecoration(
                  color: AppColors.yellow1,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '다음',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // 인트로 팝업 (카메라 위에 오버레이)
          if (_showIntroPopup)
            Positioned.fill(
              child: Stack(
                children: [
                  // 배경 블러
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ),
                  ),
                  
                  // 닫기 버튼 (팝업용)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + context.h(21),
                    right: context.w(20),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showIntroPopup = false;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/images/myflight/x.svg',
                                width: 24,
                                height: 24,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // 중앙 컨텐츠
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 티켓 아이콘
                        Image.asset(
                          'assets/images/myflight/ticket_verify.png',
                          width: context.w(120),
                          height: context.h(120),
                          color: Colors.white,
                        ),
                        
                        SizedBox(height: context.h(24)),
                        
                        // 안내 텍스트
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: context.w(40)),
                          child: Text(
                            '탑승을 인증하기 위해,\n탑승권(실물 또는 모바일)을\n촬영해 주세요.',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile image = await _cameraController!.takePicture();
      // TODO: 백엔드로 이미지 전송 및 인식 처리
      print('사진 촬영 완료: ${image.path}');
      
      // 임시로 스낵바 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('티켓 인증 중입니다...')),
        );
        // 2초 후 페이지 닫기 (실제로는 백엔드 응답 후 처리)
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      print('사진 촬영 오류: $e');
    }
  }
}
