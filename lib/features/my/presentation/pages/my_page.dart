import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../widgets/profile_card.dart';
import '../widgets/menu_section.dart';
import '../widgets/menu_item.dart';
import '../widgets/content_card.dart';

/// 마이 페이지 (탭 컨텐츠)
class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.w(20)),
        child: Column(
          children: [
            // 상단 여백 16px
            SizedBox(height: context.h(16)),

            // 프로필 카드
            // TODO: 백엔드 연동 - 로그인 시 저장된 사용자 정보 (ID, 이름, 이메일, 프로필 이미지) 가져오기
            ProfileCard(
              profileImageUrl:
                  'https://picsum.photos/200', // TODO: 백엔드에서 받아온 프로필 이미지 URL
              name: '여행조아', // TODO: 백엔드에서 받아온 사용자 이름
              email: 'hyerim2003@kakao.com', // TODO: 백엔드에서 받아온 이메일
              onTap: () {
                // TODO: 프로필 상세/편집 화면으로 이동
              },
            ),

            SizedBox(height: context.h(16)),

            // 첫 번째 메뉴 섹션
            MenuSection(
              children: [
                // 내 리뷰 보기
                MenuItem(
                  title: '내 리뷰 보기',
                  onTap: () {
                    // TODO: 내 리뷰 화면으로 이동
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
                    // TODO: 수면 패턴 설정 화면으로 이동
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
                    // TODO: 설정 화면으로 이동
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
                    // TODO: FAQ 화면으로 이동
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
                    // TODO: 공지사항 화면으로 이동
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
