import 'auth_profile.dart';

class AuthSession {
  final String username;      // puedes guardar el usuario con el que logeaste
  final AuthProfile? profile; // payload tipado del backend

  const AuthSession({required this.username, this.profile});

  Map<String, dynamic> toJson() => {
    'username': username,
    'profile': profile?.toJson(),
  };

  factory AuthSession.fromJson(Map<String, dynamic> j) => AuthSession(
    username: (j['username'] ?? '') as String,
    profile: j['profile'] == null ? null : AuthProfile.fromJson(j['profile'] as Map<String, dynamic>),
  );
}
