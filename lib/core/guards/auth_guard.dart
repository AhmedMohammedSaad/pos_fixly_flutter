import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/mobile/auth/presentation/viewmodels/auth_cubit.dart';
import '../../features/mobile/auth/domain/repositories/auth_repository.dart';
import '../../features/mobile/auth/data/repositories/auth_repository_impl.dart';
import '../../features/mobile/auth/data/datasources/auth_datasource.dart';
import '../../features/web/auth/presentation/pages/web_login_page.dart';

class AuthGuard extends StatefulWidget {
  final Widget child;
  final bool isWebPlatform;

  const AuthGuard({
    super.key,
    required this.child,
    this.isWebPlatform = false,
  });

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authDataSource = AuthDataSourceImpl(prefs);
      final authRepository = AuthRepositoryImpl(authDataSource);
      
      // Check if user is logged in
      final isLoggedIn = await authRepository.isLoggedIn();
      
      if (isLoggedIn) {
        // Check if remember me is enabled
        final rememberMe = await authRepository.getRememberMe();
        
        if (rememberMe) {
          // User should stay logged in
          setState(() {
            _isAuthenticated = true;
            _isLoading = false;
          });
          return;
        }
      }
      
      // User is not authenticated or remember me is disabled
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    } catch (e) {
      // Error checking auth status, assume not authenticated
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (!_isAuthenticated) {
      // Redirect to login page if not authenticated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      });
      return _buildLoadingScreen(); // Show loading while redirecting
    }

    return widget.child;
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.dashboard_rounded,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 32),
              Text(
                'Fixly Admin Dashboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'جاري التحقق من حالة تسجيل الدخول...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 32),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper widget for easier usage
class AuthenticatedRoute extends StatelessWidget {
  final Widget child;
  final bool isWebPlatform;

  const AuthenticatedRoute({
    super.key,
    required this.child,
    this.isWebPlatform = false,
  });

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      isWebPlatform: isWebPlatform,
      child: child,
    );
  }
}