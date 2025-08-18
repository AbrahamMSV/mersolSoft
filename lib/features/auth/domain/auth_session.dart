class AuthSession {
  final String username;
  final Map<String, dynamic> data;

  const AuthSession({
    required this.username,
    this.data = const {},
  });
}
