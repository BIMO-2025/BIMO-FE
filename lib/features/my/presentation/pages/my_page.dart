import 'dart:io'; // File 클래스 사용을 위해 추가
import 'dart:convert'; // base64 디코딩을 위해 추가
import 'package:path_provider/path_provider.dart'; // 로컬 경로를 위해 추가
import 'package:audioplayers/audioplayers.dart'; // AudioPlayer import
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../../../core/storage/auth_token_storage.dart';
import '../../../../core/network/api/user_api_service.dart'; // UserApiService import
import '../../data/repositories/user_repository_impl.dart';
import '../widgets/profile_card.dart';
import '../widgets/menu_section.dart';
import '../widgets/menu_item.dart';
import '../widgets/content_card.dart';
import 'my_info_page.dart';
import 'settings_page.dart';
import 'faq_page.dart';
import 'announcement_page.dart';
import 'my_reviews_page.dart';
import 'sleep_pattern_page.dart';

/// 마이 페이지 (탭 컨텐츠)
class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final UserApiService _userApiService = UserApiService(); // API 서비스 인스턴스
  String _name = '사용자';
  String _email = '';
  String _profileImageUrl = ''; // Default (empty string to trigger default image in ProfileCard)
  bool _isLoading = false; // 로딩 상태
  
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
  
  // 오디오 플레이어 관련 상태
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _currentlyPlayingIndex; // 현재 재생 중인 카드 인덱스
  bool _isPlaying = false; // 재생 상태

  Future<void> _toggleAudio(int index, String fileName) async {
    try {
      if (_currentlyPlayingIndex == index && _isPlaying) {
        // 이미 재생 중인 것을 다시 누르면 정지
        await _audioPlayer.stop();
        setState(() {
          _isPlaying = false;
        });
      } else {
        // 다른 것을 누르거나 멈춘 상태에서 누르면 재생
        await _audioPlayer.stop(); // 이전 것 정지
        // 파일명은 'audio/' 경로 아래에 있는 것으로 가정
        // AssetSource는 'assets/'를 자동으로 붙여주므로 'audio/xxx.mp3'만 넘기면 됨
        // 만약 assets/audio/ 아래에 있다면 'audio/$fileName'
        await _audioPlayer.play(AssetSource('audio/$fileName'));
        
        setState(() {
          _currentlyPlayingIndex = index;
          _isPlaying = true;
        });

        // 재생 완료 시 처리
        _audioPlayer.onPlayerComplete.listen((event) {
          if (mounted) {
            setState(() {
              _isPlaying = false;
            });
          }
        });
      }
    } catch (e) {
      print('❌ 오디오 재생 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오디오 재생 실패: $e')),
        );
      }
    }
  }
  
  Future<void> _loadUserInfo() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final storage = AuthTokenStorage();
      final userInfo = await storage.getUserInfo();
      
      String name = userInfo['name'] ?? '사용자';
      String email = userInfo['email'] ?? '';
      String? photoUrl = userInfo['photoUrl'];
      
      // 로컬 파일 경로가 있는지 확인
      bool hasLocalFile = false;
      if (photoUrl != null && photoUrl.isNotEmpty) {
        // 파일 경로인지 확인 (절대 경로 또는 로컬 파일)
        if (photoUrl.startsWith('/') || photoUrl.startsWith('file://')) {
          final file = File(photoUrl.replaceFirst('file://', ''));
          hasLocalFile = await file.exists();
        }
      }
      
      // 로컬 파일이 없으면 서버에서 조회
      if (!hasLocalFile) {
        try {
          final userRepository = UserRepositoryImpl();
          final userProfile = await userRepository.getUserProfile();
          print('✅ 서버에서 프로필 정보 조회: $userProfile');
          
          // base64 이미지를 로컬 파일로 저장
          final photoUrlBase64 = userProfile['photo_url'];
          if (photoUrlBase64 != null && photoUrlBase64.isNotEmpty) {
            try {
              // data URL 프리픽스 제거
              String base64String = photoUrlBase64;
              if (base64String.contains(',')) {
                base64String = base64String.split(',').last;
              }
              
              // base64 디코딩
              final bytes = base64Decode(base64String);
              
              // 로컬 디렉토리 가져오기
              final directory = await getApplicationDocumentsDirectory();
              final filePath = '${directory.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
              
              // 파일로 저장
              final file = File(filePath);
              await file.writeAsBytes(bytes);
              
              photoUrl = filePath;
              print('✅ 프로필 사진 로컬 저장 완료: $photoUrl');
              
              // 스토리지에 저장
              await storage.saveUserInfo(
                name: userProfile['display_name'] ?? name,
                photoUrl: photoUrl,
                email: userProfile['email'] ?? email,
                userId: userProfile['uid'],
              );
            } catch (e) {
              print('❌ base64 디코딩 실패: $e');
            }
          }
        } catch (e) {
          print('⚠️ 서버 프로필 조회 실패: $e');
        }
      }
      
      if (mounted) {
        setState(() {
          _name = name;
          _email = email;
          _profileImageUrl = photoUrl ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ 프로필 정보 로드 실패: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 갤러리에서 이미지 선택 및 업로드
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // 1. 로컬 파일을 영구 저장소로 복사
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedPath = '${directory.path}/$fileName';
        final savedFile = File(savedPath);
        await savedFile.writeAsBytes(await File(image.path).readAsBytes());
        
        // 2. UI에 즉시 반영
        setState(() {
          _profileImageUrl = savedPath;
        });
        
        // 3. 백엔드에 업로드 (백그라운드)
        try {
          final userRepository = UserRepositoryImpl();
          await userRepository.updateProfilePhoto(image.path);
          print('✅ 프로필 사진 업로드 성공');
          
          // 4. 로컬 스토리지 업데이트
          final storage = AuthTokenStorage();
          final userInfo = await storage.getUserInfo();
          await storage.saveUserInfo(
            name: userInfo['name'],
            photoUrl: savedPath,
            email: userInfo['email'],
            userId: userInfo['userId'],
          );
        } catch (e) {
          print('❌ 프로필 사진 업로드 실패: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('프로필 사진 업로드에 실패했습니다.')),
            );
          }
        }
      }
    } catch (e) {
      print('❌ 이미지 선택 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사진을 선택할 수 없습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 중일 때 로딩 인디케이터 표시
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.blue1,
        ),
      );
    }
    
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.w(20)),
        child: Column(
          children: [
            // 상단 여백 (앱바 높이 82 + 추가 16)
            SizedBox(height: context.h(82) + context.h(16)),

            // 프로필 카드
            ProfileCard(
              profileImageUrl: _profileImageUrl,
              name: _name,
              email: _email,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyInfoPage()),
                ).then((_) {
                  // 정보 페이지에서 돌아왔을 때 갱신 (닉네임 변경 등)
                  _loadUserInfo();
                });
              },
              onProfileImageTap: _pickImage,
            ),

            SizedBox(height: context.h(16)),

            // 첫 번째 메뉴 섹션
            MenuSection(
              children: [
                // 내 리뷰 보기
                MenuItem(
                  title: '내 리뷰 보기',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyReviewsPage(),
                      ),
                    );
                  },
                ),
                SizedBox(height: context.h(10)),
                Container(
                  width: context.w(295),
                  height: 1,
                  color: AppColors.white.withOpacity(0.1),
                ),
                SizedBox(height: context.h(10)),

                // 수면 패턴 설정
                MenuItem(
                  title: '수면 패턴 설정',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SleepPatternPage(),
                      ),
                    );
                  },
                ),
                SizedBox(height: context.h(10)),
                Container(
                  width: context.w(295),
                  height: 1,
                  color: AppColors.white.withOpacity(0.1),
                ),
                SizedBox(height: context.h(10)),

                // 오프라인 콘텐츠
                MenuItem(
                  title: '오프라인 콘텐츠',
                  hasInfoIcon: true,
                  onTap: () {
                    // TODO: 오프라인 콘텐츠 화면으로 이동
                  },
                ),
                SizedBox(height: context.h(15)), // 카드들 위 15
                // 콘텐츠 카드 (가로 스크롤)
                SizedBox(
                  height: context.h(100), // 96 → 100
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    itemCount: 3,
                    separatorBuilder:
                        (context, index) => SizedBox(width: context.w(8)),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ContentCard(
                          title: '수면 및 휴식',
                          subtitle: '편안한 휴식과\n숙면을 위한 사운드',
                          isPlaying: _currentlyPlayingIndex == 0 && _isPlaying,
                          onTap: () => _toggleAudio(0, 'sleep.mp3'),
                        );
                      } else if (index == 1) {
                        return ContentCard(
                          title: '집중력 향상',
                          subtitle: '업무와 학습에\n몰입할 수 있는 사운드',
                          isPlaying: _currentlyPlayingIndex == 1 && _isPlaying,
                          onTap: () => _toggleAudio(1, 'focus.mp3'),
                        );
                      } else {
                        return ContentCard(
                          title: '자연의 소리',
                          subtitle: '기내의 소음을\n잊게 해주는 사운드',
                          isPlaying: _currentlyPlayingIndex == 2 && _isPlaying,
                          onTap: () => _toggleAudio(2, 'nature.mp3'),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: context.h(16)),

            // 두 번째 메뉴 섹션 (335 x 192 Hug)
            MenuSection(
              children: [
                // 설정
                MenuItem(
                  title: '설정',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
                SizedBox(height: context.h(10)),
                Container(
                  width: context.w(295),
                  height: 1,
                  color: AppColors.white.withOpacity(0.1),
                ),
                SizedBox(height: context.h(10)),

                // FAQ
                MenuItem(
                  title: 'FAQ',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FaqPage()),
                    );
                  },
                ),
                SizedBox(height: context.h(10)),
                Container(
                  width: context.w(295),
                  height: 1,
                  color: AppColors.white.withOpacity(0.1),
                ),
                SizedBox(height: context.h(10)),

                // 1:1 카카오톡 문의
                MenuItem(
                  title: '1:1 카카오톡 문의',
                  onTap: () {
                    // TODO: 카카오톡 문의 링크 열기
                  },
                ),
                SizedBox(height: context.h(10)),
                Container(
                  width: context.w(295),
                  height: 1,
                  color: AppColors.white.withOpacity(0.1),
                ),
                SizedBox(height: context.h(10)),

                // 공지사항
                MenuItem(
                  title: '공지사항',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnnouncementPage(),
                      ),
                    );
                  },
                ),
              ],
            ),

            SizedBox(height: context.h(100)), // 탭바 공간 확보
          ],
        ),
      ),
    );
  }
}
