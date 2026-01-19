import 'package:alexandria_movil/data/api_client.dart';

class UserData {
  UserData({
    required this.id,
    required this.email,
    required this.name,
    this.googleUid,
    this.profilePhoto,
  });

  final int? id;
  final String email;
  final String name;
  final String? googleUid;
  final String? profilePhoto;

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as int?,
      email: json['email'] as String,
      name: json['name'] as String,
      googleUid: json['google_uid'] as String?,
      profilePhoto: json['profile_photo'] as String?,
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
}
