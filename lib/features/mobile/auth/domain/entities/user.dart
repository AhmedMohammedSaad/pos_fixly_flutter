import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? avatarUrl;
  final DateTime? lastLogin;
  final bool isEmailVerified;
  final String? role;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.avatarUrl,
    this.lastLogin,
    this.isEmailVerified = false,
    this.role,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        phone,
        avatarUrl,
        lastLogin,
        isEmailVerified,
        role,
      ];

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? avatarUrl,
    DateTime? lastLogin,
    bool? isEmailVerified,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastLogin: lastLogin ?? this.lastLogin,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      role: role ?? this.role,
    );
  }
}