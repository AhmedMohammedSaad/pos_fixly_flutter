import '../entities/user.dart';
import '../entities/login_request.dart';

abstract class AuthRepository {
  Future<User> login(LoginRequest request);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<void> saveRememberMe(bool rememberMe);
  Future<bool> getRememberMe();
  Future<User?> getStoredUserData();
}