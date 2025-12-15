import 'dart:io'; // File 클래스 사용을 위해 추가
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../../../core/storage/auth_token_storage.dart';
import '../../../../core/network/api/user_api_service.dart'; // UserApiService import
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
  
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }
  
  Future<void> _loadUserInfo() async {
    final storage = AuthTokenStorage(); // Singleton
    final userInfo = await storage.getUserInfo();
    
    if (mounted) {
      setState(() {
        _name = userInfo['name'] ?? '사용자';
        _email = userInfo['email'] ?? '';
        
        final savedPhotoUrl = userInfo['photoUrl'];
        if (savedPhotoUrl != null && savedPhotoUrl.isNotEmpty) {
           _profileImageUrl = savedPhotoUrl;
        }
      });
    }
  }

  /// 갤러리에서 이미지 선택 (로컬 저장)
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // 1. UI에 즉시 반영 (로컬 파일 경로)
        setState(() {
          _profileImageUrl = image.path;
        });
        
        // 2. 로컬 스토리지에 저장 (API 없음)
        // 현재는 서버 API가 없으므로 로컬 경로를 저장하여 앱 재시작 시에도 유지되도록 함
        final storage = AuthTokenStorage();
        await storage.saveUserInfo(photoUrl: image.path);
        print('💾 프로필 이미지 로컬 저장 완료: ${image.path}');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('프로필 사진이 변경되었습니다.'),
              duration: Duration(seconds: 1),
            ),
          );
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
                          onTap: () {
                            // TODO: 수면 사운드 재생
                          },
                        );
                      } else if (index == 1) {
                        return ContentCard(
                          title: '집중력 향상',
                          subtitle: '업무와 학습에\n몰입할 수 있는 사운드',
                          onTap: () {
                            // TODO: 집중력 사운드 재생/일시정지
                          },
                        );
                      } else {
                        return ContentCard(
                          title: '자연의 소리',
                          subtitle: '기내의 소음을\n잊게 해주는 사운드',
                          onTap: () {
                            // TODO: 자연의 소리 재생
                          },
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
