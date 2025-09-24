import '../../domain/entities/login_request.dart';

class LoginRequestModel extends LoginRequest {
  const LoginRequestModel({
    required super.email,
    required super.password,
    super.rememberMe = false,
  });

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) {
    return LoginRequestModel(
      email: json['email'] as String,
      password: json['password'] as String,
      rememberMe: json['rememberMe'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'rememberMe': rememberMe,
    };
  }

  factory LoginRequestModel.fromEntity(LoginRequest request) {
    return LoginRequestModel(
      email: request.email,
      password: request.password,
      rememberMe: request.rememberMe,
    );
  }

  LoginRequestModel copyWith({
    String? email,
    String? password,
    bool? rememberMe,
  }) {
    return LoginRequestModel(
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}