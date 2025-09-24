import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/login_request.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/auth_datasource.dart';

// Auth States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

// Auth Cubit
class AuthCubit extends Cubit<AuthState> {
  late final LoginUseCase loginUseCase;

  AuthCubit() : super(AuthInitial()) {
    _initializeUseCase();
  }

  void _initializeUseCase() async {
    final prefs = await SharedPreferences.getInstance();
    final authDataSource = AuthDataSourceImpl(prefs);
    final authRepository = AuthRepositoryImpl(authDataSource);
    loginUseCase = LoginUseCase(authRepository);
  }

  Future<void> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      emit(AuthLoading());

      final loginRequest = LoginRequest(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      final user = await loginUseCase(loginRequest);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      emit(AuthLoading());
      // Here you would call logout use case
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('فشل في تسجيل الخروج: ${e.toString()}'));
    }
  }

  void clearError() {
    if (state is AuthError) {
      emit(AuthUnauthenticated());
    }
  }

  void reset() {
    emit(AuthInitial());
  }
}