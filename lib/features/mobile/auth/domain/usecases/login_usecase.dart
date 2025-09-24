import 'package:pos_fixly_admin_dashboard/core/usecases/usecase.dart';

import '../entities/user.dart';
import '../entities/login_request.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase implements UseCase<User, LoginRequest> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<User> call(LoginRequest params) async {
    // Validate email format
    if (!_isValidEmail(params.email)) {
      throw Exception('البريد الإلكتروني غير صحيح');
    }

    // Validate password
    if (params.password.isEmpty) {
      throw Exception('كلمة المرور مطلوبة');
    }

    if (params.password.length < 6) {
      throw Exception('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
    }

    // Save remember me preference
    await repository.saveRememberMe(params.rememberMe);

    // Perform login
    return await repository.login(params);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}