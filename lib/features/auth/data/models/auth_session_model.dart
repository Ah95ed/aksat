import '../../domain/entities/user.dart';
import 'user_model.dart';

class AuthSessionModel {
  const AuthSessionModel({required this.token, required this.user});

  final String token;
  final User user;

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    final userJson = data['user'] as Map<String, dynamic>? ?? const {};
    return AuthSessionModel(
      token: data['token']?.toString() ?? '',
      user: UserModel.fromJson(userJson),
    );
  }
}
