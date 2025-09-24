import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.phone,
    super.avatarUrl,
    super.lastLogin,
    super.isEmailVerified = false,
    super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      role: json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'lastLogin': lastLogin?.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'role': role,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      avatarUrl: user.avatarUrl,
      lastLogin: user.lastLogin,
      isEmailVerified: user.isEmailVerified,
      role: user.role,
    );
  }

  factory UserModel.fromSupabaseUser(supabase.User supabaseUser) {
    return UserModel(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      name: supabaseUser.userMetadata?['name'] as String? ?? 
            supabaseUser.userMetadata?['full_name'] as String? ?? 
            'مستخدم',
      phone: supabaseUser.phone,
      avatarUrl: supabaseUser.userMetadata?['avatar_url'] as String?,
      lastLogin: DateTime.now(),
      isEmailVerified: supabaseUser.emailConfirmedAt != null,
      role: supabaseUser.userMetadata?['role'] as String? ?? 'user',
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? avatarUrl,
    DateTime? lastLogin,
    bool? isEmailVerified,
    String? role,
  }) {
    return UserModel(
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