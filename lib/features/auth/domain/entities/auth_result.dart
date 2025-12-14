class AuthResult {
  final String accessToken;
  final String tokenType;
  final Map<String, dynamic>? user; // 응답에 없을 수 있음

  AuthResult({
    required this.accessToken,
    required this.tokenType,
    this.user,
  });
}
