import '../../domain/entities/user.dart';
import '../../domain/entities/login_request.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

import '../models/login_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<User> login(LoginRequest request) async {
    try {
      final loginRequestModel = LoginRequestModel.fromEntity(request);
      final userModel = await dataSource.login(loginRequestModel);
      return userModel;
    } catch (e) {
      throw Exception('فشل في تسجيل الدخول: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dataSource.logout();
    } catch (e) {
      throw Exception('فشل في تسجيل الخروج: ${e.toString()}');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      return await dataSource.getCurrentUser();
    } catch (e) {
      throw Exception('فشل في الحصول على بيانات المستخدم: ${e.toString()}');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return await dataSource.isLoggedIn();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> saveRememberMe(bool rememberMe) async {
    try {
      await dataSource.saveRememberMe(rememberMe);
    } catch (e) {
      throw Exception('فشل في حفظ إعدادات التذكر: ${e.toString()}');
    }
  }

  @override
  Future<bool> getRememberMe() async {
    try {
      return await dataSource.getRememberMe();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<User?> getStoredUserData() async {
    try {
      return await dataSource.getStoredUserData();
    } catch (e) {
      return null;
    }
  }
}