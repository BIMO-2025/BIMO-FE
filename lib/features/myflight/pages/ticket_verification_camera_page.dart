import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_extensions.dart';
import '../data/repositories/review_verification_repository.dart';
import 'review_write_page.dart';

/// 티켓 인증 카메라 페이지
class TicketVerificationCameraPage extends StatefulWidget {
  final String departureCode;
  final String departureCity;
  final String arrivalCode;
  final String arrivalCity;
  final String flightNumber;
  final String date;
  final String? stopover;

  const TicketVerificationCameraPage({
    super.key,
    required this.departureCode,
    required this.departureCity,
    required this.arrivalCode,
    required this.arrivalCity,
    required this.flightNumber,
    required this.date,
    this.stopover,
  });

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
  final ReviewVerificationRepository _repository = ReviewVerificationRepository();
  bool _isVerifying = false;

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

  Future<void> _processImage(String imagePath) async {
    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
    });

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('티켓을 인증하고 있습니다...'),
            duration: Duration(seconds: 10), // 충분히 길게 설정
          ),
        );
      }

      print('📸 티켓 이미지 인증 시작: $imagePath');
      final isVerified = await _repository.verifyTicket([imagePath]);

      if (!mounted) return;

      // 스낵바 닫기
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (isVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 인증 성공! 리뷰를 작성해주세요.')),
        );
        
        // 잠시 후 이동 (사용자가 성공 메시지를 볼 수 있도록)
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ReviewWritePage(
                departureCode: widget.departureCode,
                departureCity: widget.departureCity,
                arrivalCode: widget.arrivalCode,
                arrivalCity: widget.arrivalCity,
                flightNumber: widget.flightNumber,
                date: widget.date,
                stopover: widget.stopover ?? '직항',
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ 인증 실패. 탑승권이 잘 보이도록 다시 촬영해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('티켓 인증 처리 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      
      if (image != null) {
        await _processImage(image.path);
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

          // 닫기 버튼 (우측 상단)
          Positioned(
            top: MediaQuery.of(context).padding.top + context.h(10),
            right: context.w(20),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
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
          // 로딩 오버레이
          if (_isVerifying)
             Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        '티켓을 확인하고 있습니다...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
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

    if (_isVerifying) return;

    try {
      final XFile image = await _cameraController!.takePicture();
      await _processImage(image.path);
    } catch (e) {
      print('사진 촬영 오류: $e');
    }
  }
}
