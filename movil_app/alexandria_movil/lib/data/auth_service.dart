import 'package:alexandria_movil/data/api_client.dart';


class AuthToken {
  AuthToken({required this.accessToken, this.tokenType = 'bearer'});

  final String accessToken;
  final String tokenType;

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['access_token'] as String,
      tokenType: (json['token_type'] as String?) ?? 'bearer',
    );
  }
}

class AuthService {
  AuthService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<AuthToken> register({
    required String email,
    required String name,
    required String password,
  }) async {
    final json = await _client.post(
      '/auth/register',
      body: {
        'email': email,
        'name': name,
        'password': password,
      },
    );
    return AuthToken.fromJson(json);
  }

  Future<AuthToken> login({
    required String email,
    required String password,
  }) async {
    final json = await _client.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );
    return AuthToken.fromJson(json);
  }

  Future<AuthToken> googleLogin({required String idToken}) async {
    final json = await _client.post(
      '/auth/google/callback',
      body: {'id_token': idToken},
    );
    return AuthToken.fromJson(json);
  }
}
