import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/login_request_model.dart';
import '../../../../../core/services/supabase_service.dart';

abstract class AuthDataSource {
  Future<UserModel> login(LoginRequestModel request);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<void> saveRememberMe(bool rememberMe);
  Future<bool> getRememberMe();
  Future<void> saveUserSession(UserModel user);
  Future<void> clearUserSession();
  Future<UserModel?> getStoredUserData();
  Stream<AuthState> get authStateChanges;
}

class AuthDataSourceImpl implements AuthDataSource {
  final SharedPreferences _prefs;

  AuthDataSourceImpl(this._prefs);

  @override
  Future<UserModel> login(LoginRequestModel request) async {
    try {
      final response = await SupabaseService.signInWithEmailAndPassword(
        email: request.email,
        password: request.password,
      );

      if (response.user == null) {
        throw Exception('فشل في تسجيل الدخول');
      }

      final user = UserModel.fromSupabaseUser(response.user!);
      await saveUserSession(user);

      if (request.rememberMe) {
        await saveRememberMe(true);
      }

      return user;
    } on AuthException catch (e) {
      throw Exception(_getArabicErrorMessage(e.message));
    } catch (e) {
      throw Exception('حدث خطأ أثناء تسجيل الدخول');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await SupabaseService.signOut();
      await clearUserSession();
    } catch (e) {
      throw Exception('حدث خطأ أثناء تسجيل الخروج');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final supabaseUser = SupabaseService.currentUser;
    if (supabaseUser != null) {
      return UserModel.fromSupabaseUser(supabaseUser);
    }
    
    // If no active Supabase user, try to get stored user data
    return await getStoredUserData();
  }

  @override
  Future<bool> isLoggedIn() async {
    return SupabaseService.currentUser != null;
  }

  @override
  Future<void> saveRememberMe(bool rememberMe) async {
    await _prefs.setBool('remember_me', rememberMe);
  }

  @override
  Future<bool> getRememberMe() async {
    return _prefs.getBool('remember_me') ?? false;
  }

  @override
  Future<void> saveUserSession(UserModel user) async {
    // Supabase handles session management automatically
    // Save complete user data locally in SharedPreferences
    await _prefs.setString('user_id', user.id);
    await _prefs.setString('user_email', user.email);
    await _prefs.setString('user_name', user.name ?? '');
    await _prefs.setString('user_phone', user.phone ?? '');
    await _prefs.setString('user_avatar_url', user.avatarUrl ?? '');
    await _prefs.setString('user_role', user.role ?? 'user');
    await _prefs.setBool('user_email_verified', user.isEmailVerified);
    await _prefs.setString('user_last_login', user.lastLogin?.toIso8601String() ?? '');
    
    // Save complete user data as JSON for easy retrieval
    await _prefs.setString('user_data_json', jsonEncode(user.toJson()));
  }

  @override
  Future<void> clearUserSession() async {
    await _prefs.remove('user_id');
    await _prefs.remove('user_email');
    await _prefs.remove('user_name');
    await _prefs.remove('user_phone');
    await _prefs.remove('user_avatar_url');
    await _prefs.remove('user_role');
    await _prefs.remove('user_email_verified');
    await _prefs.remove('user_last_login');
    await _prefs.remove('user_data_json');
    await _prefs.remove('remember_me');
  }

  @override
  Future<UserModel?> getStoredUserData() async {
    try {
      final userDataJson = _prefs.getString('user_data_json');
      if (userDataJson != null) {
        final userData = jsonDecode(userDataJson) as Map<String, dynamic>;
        return UserModel.fromJson(userData);
      }
      
      // Fallback: try to construct from individual fields
      final userId = _prefs.getString('user_id');
      final userEmail = _prefs.getString('user_email');
      
      if (userId != null && userEmail != null) {
        return UserModel(
          id: userId,
          email: userEmail,
          name: _prefs.getString('user_name'),
          phone: _prefs.getString('user_phone'),
          avatarUrl: _prefs.getString('user_avatar_url'),
          role: _prefs.getString('user_role') ?? 'user',
          isEmailVerified: _prefs.getBool('user_email_verified') ?? false,
          lastLogin: _prefs.getString('user_last_login') != null 
              ? DateTime.parse(_prefs.getString('user_last_login')!)
              : null,
        );
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<AuthState> get authStateChanges => SupabaseService.authStateChanges;

  String _getArabicErrorMessage(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'بيانات تسجيل الدخول غير صحيحة';
    } else if (error.contains('Email not confirmed')) {
      return 'يرجى تأكيد البريد الإلكتروني أولاً';
    } else if (error.contains('Too many requests')) {
      return 'محاولات كثيرة، يرجى المحاولة لاحقاً';
    }
    return 'حدث خطأ أثناء تسجيل الدخول';
    // In a real app, this would clear secure storage
  }
}
