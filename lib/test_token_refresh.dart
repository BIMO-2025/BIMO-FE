import 'package:flutter/material.dart';
import 'core/storage/auth_token_storage.dart';
import 'core/network/api_client.dart';
import 'core/constants/api_constants.dart';

/// 토큰 갱신 테스트 페이지
class TestTokenRefreshPage extends StatelessWidget {
  const TestTokenRefreshPage({super.key});

  Future<void> _testTokenRefresh(BuildContext context) async {
    final storage = AuthTokenStorage();
    
    // 1. 현재 토큰 확인
    final currentToken = await storage.getAccessToken();
    print('📌 현재 Access Token: $currentToken');
    
    // 2. Access Token을 무효화 (임의의 값으로 변경)
    await storage.saveAccessToken('invalid_token_for_testing');
    print('❌ Access Token을 무효화했습니다');
    
    // 3. API 요청 (401 에러 발생 예상)
    try {
      final apiClient = ApiClient();
      final response = await apiClient.get(ApiConstants.userProfile);
      print('✅ API 요청 성공: ${response.statusCode}');
      print('📄 응답 데이터: ${response.data}');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('토큰 갱신 성공! 로그를 확인하세요.')),
        );
      }
    } catch (e) {
      print('❌ API 요청 실패: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('토큰 갱신 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('토큰 갱신 테스트'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '토큰 갱신 테스트',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              '버튼을 누르면:\n1. Access Token을 무효화\n2. API 요청\n3. 자동 토큰 갱신 시도',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _testTokenRefresh(context),
              child: const Text('토큰 갱신 테스트 실행'),
            ),
            const SizedBox(height: 20),
            const Text(
              '터미널 로그를 확인하세요!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
