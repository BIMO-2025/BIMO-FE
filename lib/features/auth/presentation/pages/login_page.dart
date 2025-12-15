import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // 충돌 방지 alias
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../../../../core/network/router/app_router.dart';
import '../../../../core/network/router/route_names.dart';
import '../../../../core/storage/auth_token_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/login_usecase.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // UseCase 인스턴스 (DI가 없으므로 직접 생성)
  final LoginUseCase _loginUseCase = LoginUseCase(AuthRepositoryImpl());
  
  bool _isLoading = false;

  /// 소셜 로그인 처리
  /// 소셜 로그인 처리
  Future<void> _login(String provider) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String token = '';
      String? email; // 이메일 변수 상위 스코프 선언
      String? name; // 이름 변수 상위 스코프 선언

      // [Google Login] 실제 SDK 연동
      if (provider == 'google') {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          // 사용자가 취소함
          print('Google Login Cancelled');
          return;
        }

        // 유저 정보 저장
        final AuthTokenStorage storage = AuthTokenStorage();
        await storage.saveUserInfo(
          // name: googleUser.displayName, // 닉네임 설정 전에는 저장 안 함
          email: googleUser.email,
          photoUrl: googleUser.photoUrl,
        );

        email = googleUser.email; // 구글 이메일 저장

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        token = googleAuth.idToken ?? '';
        
        print("✅ Google ID Token Length: ${token.length}");
        int chunkSize = 800;
        for (int i = 0; i < token.length; i += chunkSize) {
            int end = (i + chunkSize < token.length) ? i + chunkSize : token.length;
            print("Token chunk: ${token.substring(i, end)}");
        }
        
        if (token.isEmpty) {
          throw Exception('구글 토큰을 가져오지 못했습니다.');
        }
      } else if (provider == 'apple') {
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        // authorizationCode를 우선적으로 사용해봅니다. (서버 구현에 따라 다름)
        // 보통 서버에서 Apple Auth Key로 검증하려면 authorizationCode가 필요할 수 있습니다.
        token = credential.identityToken ?? ''; 
        
        print("DEBUG: Apple Identity Token: ${credential.identityToken}");
        print("DEBUG: Apple Auth Code: ${credential.authorizationCode}");

        // [New] Firebase Auth 연동
        if (credential.identityToken != null && credential.authorizationCode != null) {
          try {
            final appleProvider = firebase_auth.OAuthProvider('apple.com');
            final appleCredential = appleProvider.credential(
              idToken: credential.identityToken,
              accessToken: credential.authorizationCode,
            );

            await firebase_auth.FirebaseAuth.instance.signInWithCredential(appleCredential);
            final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
            
            if (firebaseUser != null) {
              final firebaseToken = await firebaseUser.getIdToken();
              print("✅ Firebase Auth Login Success! Token: $firebaseToken");
              if (firebaseToken != null) {
                 token = firebaseToken; // 백엔드로 보낼 토큰을 파이어베이스 토큰으로 교체
              }
              
            }
          } catch (e) {
            print("❌ Firebase Auth Failed: $e");
            // 파이어베이스 실패 시엔 기존 애플 토큰으로 진행 시도 (혹은 여기서 return)
          }
        }
        
        if (token.isEmpty) {
           throw Exception('Apple 토큰을 가져오지 못했습니다.');
        }

        // 유저 정보 저장 (참고: Apple은 최초 로그인 시에만 이름/이메일을 줍니다)
        final AuthTokenStorage storage = AuthTokenStorage();
        
        // 이름 정보가 없으면 credential에서 다시 시도 (Apple Login 특성상)
        if (name == null && (credential.givenName != null || credential.familyName != null)) {
            name = '${credential.givenName ?? ""} ${credential.familyName ?? ""}'.trim();
        }
        
        // 여전히 이메일이 없으면 credential에서 다시 시도
        if (email == null) {
          email = credential.email;
        }

        if (email == null) {
          email = credential.email;
        }

        await storage.saveUserInfo(
          // name: name?.isNotEmpty == true ? name : null, // 닉네임 설정 전에는 저장 안 함
          email: credential.email,
        );

      } else {
        // [Kakao] Login Logic
        // 카카오톡 설치 여부 확인
        if (await isKakaoTalkInstalled()) {
          try {
              // 기존 로그인 상태 해제 (권한 재요청을 위해)
              try {
                await UserApi.instance.logout();
                print('카카오 로그아웃 성공 (재로그인 시도)');
              } catch (_) {}

              await UserApi.instance.loginWithKakaoTalk();
              print('카카오톡으로 로그인 성공');
          } catch (error) {
            print('카카오톡으로 로그인 실패 $error');

            // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
            // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도를 하지 않습니다.
            // (ClientError가 아닌 경우에만 웹 로그인 시도)
             if (error is PlatformException && error.code == 'CANCELED') {
                 return;
             }
             // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인 시도
             try {
                await UserApi.instance.loginWithKakaoAccount();
                print('카카오계정으로 로그인 성공');
             } catch (error) {
                print('카카오계정으로 로그인 실패 $error');
                return;
             }
          }
        } else {
          try {
            // 기존 로그인 상태 해제
            try {
              await UserApi.instance.logout();
            } catch (_) {}

            await UserApi.instance.loginWithKakaoAccount();
            print('카카오계정으로 로그인 성공');
          } catch (error) {
            print('카카오계정으로 로그인 실패 $error');
            return;
          }
        }

        User user = await UserApi.instance.me();
        
        // 토큰 가져오기 (OpenID Connect id_token 우선, 없으면 accessToken)
        OAuthToken? auth = await TokenManagerProvider.instance.manager.getToken();
        
        // 백엔드가 ID Token(JWT)을 기대하는 경우를 위해 idToken 우선 사용
        // if (auth?.idToken != null && auth!.idToken!.isNotEmpty) {
        //   token = auth.idToken!;
        //   print("DEBUG: Using Kakao ID Token (OIDC)");
        // } else {
          token = auth?.accessToken ?? '';
          print("DEBUG: Using Kakao Access Token (Fallback)");
        // }
        
        final AuthTokenStorage storage = AuthTokenStorage();
        await storage.saveUserInfo(
            // name: user.kakaoAccount?.profile?.nickname, // 닉네임 설정 전에는 저장 안 함
            email: user.kakaoAccount?.email,
            photoUrl: user.kakaoAccount?.profile?.profileImageUrl,
        );
        
        print("DEBUG: Kakao User Info -> Email: ${user.kakaoAccount?.email}, Nickname: ${user.kakaoAccount?.profile?.nickname}");
        print("DEBUG: Kakao User Scopes -> ${user.kakaoAccount?.toJson()}");

        // 이메일이 없는 경우 (동의 항목 미설정 등) 임시 이메일 생성
        email = user.kakaoAccount?.email;
        if (email == null || email.isEmpty) {
          final tempId = user.id.toString();
          email = 'kakao_temp_$tempId@bimo.temp';
          print("WARNING: Email missing. Using temporary email: $email");
        }

        print("DEBUG: Sending Kakao Token to Server: $token");
        print("DEBUG: Sending Email: $email");
      }

      // 2. 백엔드 API 호출
      final authResult = await _loginUseCase(
        provider: provider,
        token: token,
        // Apple은 토큰 내부에 이메일 정보가 포함되어 있고, 명시적으로 보내면 서버에서 401 에러가 발생함
        // Kakao는 토큰에 없을 수 있어서 임시 이메일을 보냄
        email: provider == 'apple' ? null : email, 
      );
      
      print('✅ Login Successful! Checking User Profile...');
      
      // 3. 닉네임 설정 여부 확인 및 이동
      final user = authResult.user;
      final displayName = user?['display_name'];
      final userId = user?['uid']; // 혹은 id, user_id 등 백엔드 응답 키 확인 필요

      print('✅ Login Successful! User: $displayName');

      // 저장소에 userId와 최신 닉네임 저장 (앱 재시작 시 체크용)
      // 주의: 닉네임 설정이 완료되기 전까지는 name을 저장하지 않음으로써,
      // 앱 재시작 시 Splash에서 닉네임 설정을 강제할 수 있도록 함.
      final storage = AuthTokenStorage();
      await storage.saveUserInfo(
        userId: userId,
        // name: displayName, // <-- 여기서 저장하지 않음!
        email: email, 
      );
      
      // 3. 닉네임 설정 페이지로 이동 (통일)
      // 닉네임이 있어도 설정 페이지로 이동하여 확인/수정하도록 함
      AppRouter.router.push(
        RouteNames.nicknameSetup, 
        extra: {
          'userId': userId ?? '',
          'nickname': displayName,
        },
      );
    } catch (e) {
      // 401 에러(토큰 유효하지 않음)는 테스트 상황에서 정상이므로,
      // 테스트 모드로 간주하고 강제로 로그인을 성공시킵니다.
      
      print('API Error (Expected in Test): $e');

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text('로그인 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
      
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboarding & login/bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // 메인 컨텐츠
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 170), // 스테이터스 바 아래 170px

                // 로고 그룹 (스플래시와 동일)
                _buildLogoGroup(),

                const Spacer(), // 배지+버튼을 하단으로 보내기

                // 소셜 로그인 버튼들 (배지 포함)
                _buildSocialLoginButtons(),

                const SizedBox(height: 36), // 하단 여백
              ],
            ),
          ),
          
          // 로딩 인디케이터
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  /// 로고 그룹 (스플래시와 동일)
  Widget _buildLogoGroup() {
    return SizedBox(
      width: 146,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 로고 이미지 (박스 없이)
          Image.asset(
            'assets/images/onboarding & login/bimo_logo_on.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),

          const SizedBox(height: 24),

          // 텍스트 섹션
          Column(
            children: [
              // "세상에 없던 비행기 모드"
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: -0.32,
                    color: Color(0xFFFFFFFF),
                  ),
                  children: [
                    const TextSpan(text: '세상에 없던 비'),
                    TextSpan(
                      text: '행기',
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.5),
                      ),
                    ),
                    const TextSpan(text: ' 모'),
                    TextSpan(
                      text: '드',
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // BIMO 타이포로고
              SvgPicture.asset(
                'assets/images/onboarding & login/TypoLogo.svg',
                width: 110,
                height: 35,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// "3초만에 빠른 회원가입" 배지
  Widget _buildQuickSignupBadge() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '⚡️',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 6),
              Text(
                '3초만에 빠른 회원가입',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  color: AppColors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 소셜 로그인 버튼들
  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        // "3초만에 빠른 회원가입" 배지
        _buildQuickSignupBadge(),
        
        const SizedBox(height: 24), // 배지와 버튼 사이 24px
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Apple 로그인 (특별 처리: Apple만 bold)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _login('apple'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1A1A1A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/onboarding & login/apple_logo.png',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 8),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 15,
                            letterSpacing: -0.3,
                            color: Color(0xFF1A1A1A),
                          ),
                          children: [
                            TextSpan(
                              text: 'Apple',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: '로 계속하기',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Google 로그인
              _buildLoginButton(
                icon: 'assets/images/onboarding & login/google_logo.png',
                text: '구글로 계속하기',
                backgroundColor: Colors.white,
                textColor: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500,
                onPressed: () => _login('google'),
              ),

              const SizedBox(height: 8),

              // Kakao 로그인
              _buildLoginButton(
                icon: 'assets/images/onboarding & login/kakao_logo.png',
                text: '카카오로 계속하기',
                backgroundColor: const Color(0xFFFEE500),
                textColor: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500,
                onPressed: () => _login('kakao'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 로그인 버튼 위젯
  Widget _buildLoginButton({
    required String icon,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required FontWeight fontWeight,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 15,
                fontWeight: fontWeight,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

