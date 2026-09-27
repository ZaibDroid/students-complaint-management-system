import 'user_model.dart';

class AuthResponseModel {
  final String token;
  final UserModel user;
  final String? message;

  const AuthResponseModel({
    required this.token,
    required this.user,
    this.message,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : (json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json);

    return AuthResponseModel(
      token: json['token'] ?? json['access_token'] ?? '',
      user: UserModel.fromJson(userData),
      message: json['message'],
    );
  }
}
