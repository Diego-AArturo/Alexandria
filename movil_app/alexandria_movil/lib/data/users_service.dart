import 'package:alexandria_movil/data/api_client.dart';

class UserData {
  UserData({
    required this.id,
    required this.email,
    required this.name,
    this.googleUid,
    this.profilePhoto,
    this.language,
  });

  final int? id;
  final String email;
  final String name;
  final String? googleUid;
  final String? profilePhoto;
  final String? language;

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as int?,
      email: json['email'] as String,
      name: json['name'] as String,
      googleUid: json['google_uid'] as String?,
      profilePhoto: json['profile_photo'] as String?,
      language: json['language'] as String?,
    );
  }
}

class UsersService {
  UsersService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<UserData> getByEmail(String email, {String? token}) async {
    final headers = token != null ? {'Authorization': 'Bearer $token'} : null;
    final json = await _client.get('/users/by-email?email=$email', headers: headers);
    return UserData.fromJson(json);
  }

  Future<UserData> updateProfile({
    required String token,
    String? name,
    String? language,
    String? password,
  }) async {
    final json = await _client.put(
      '/users/profile',
      headers: {'Authorization': 'Bearer $token'},
      body: {
        if (name != null) 'name': name,
        if (language != null) 'language': language,
        if (password != null && password.isNotEmpty) 'password': password,
      },
    );
    return UserData.fromJson(json);
  }
}
