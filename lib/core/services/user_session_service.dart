import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserSessionService {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userDataKey = 'user_data';
  static const String _sessionKey = 'user_session';

  /// Save user login state
  static Future<void> saveLoginState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  /// Get user login state
  static Future<bool> getLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Save user data
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = jsonEncode(userData);
    await prefs.setString(_userDataKey, userDataJson);
  }

  /// Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = prefs.getString(_userDataKey);
    if (userDataJson != null) {
      return jsonDecode(userDataJson) as Map<String, dynamic>;
    }
    return null;
  }

  /// Save session data
  static Future<void> saveSession(Session session) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionData = {
      'access_token': session.accessToken,
      'refresh_token': session.refreshToken,
      'expires_at': session.expiresAt,
      'user_id': session.user.id,
      'user_email': session.user.email,
    };
    await prefs.setString(_sessionKey, jsonEncode(sessionData));
  }

  /// Get saved session data
  static Future<Map<String, dynamic>?> getSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString(_sessionKey);
    if (sessionJson != null) {
      return jsonDecode(sessionJson) as Map<String, dynamic>;
    }
    return null;
  }

  /// Clear all user data
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userDataKey);
    await prefs.remove(_sessionKey);
  }

  /// Check if session is valid (not expired)
  static Future<bool> isSessionValid() async {
    final sessionData = await getSessionData();
    if (sessionData == null) return false;

    final expiresAt = sessionData['expires_at'] as int?;
    if (expiresAt == null) return false;

    final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
    return DateTime.now().isBefore(expiryDate);
  }

  /// Save user profile data
  static Future<void> saveUserProfile({
    required String userId,
    required String email,
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    final userData = {
      'id': userId,
      'email': email,
      'name': name,
      'phone': phone,
      'avatar_url': avatarUrl,
      'last_login': DateTime.now().toIso8601String(),
    };
    await saveUserData(userData);
  }

  /// Get user profile data
  static Future<Map<String, dynamic>?> getUserProfile() async {
    return await getUserData();
  }

  /// Update user profile data
  static Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    final currentData = await getUserData() ?? {};
    final updatedData = {...currentData, ...updates};
    await saveUserData(updatedData);
  }

  /// Check if user has completed profile setup
  static Future<bool> hasCompletedProfile() async {
    final userData = await getUserData();
    if (userData == null) return false;
    
    return userData['name'] != null && 
           userData['phone'] != null && 
           userData['name'].toString().isNotEmpty &&
           userData['phone'].toString().isNotEmpty;
  }

  /// Save login method (email, google, apple, etc.)
  static Future<void> saveLoginMethod(String method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('login_method', method);
  }

  /// Get login method
  static Future<String?> getLoginMethod() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('login_method');
  }

  /// Save remember me preference
  static Future<void> saveRememberMe(bool remember) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', remember);
  }

  /// Get remember me preference
  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('remember_me') ?? false;
  }
}