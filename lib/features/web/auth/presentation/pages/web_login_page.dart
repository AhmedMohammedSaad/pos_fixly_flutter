import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../mobile/auth/presentation/viewmodels/auth_cubit.dart';
import '../../../../mobile/auth/presentation/widgets/login_form_widget.dart';

class WebLoginPage extends StatelessWidget {
  const WebLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: Scaffold(
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
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    // Left side - Welcome section (for larger screens)
                    if (MediaQuery.of(context).size.width > 800)
                      Expanded(
                        flex: 1,
                        child: _buildWelcomeSection(context),
                      ),

                    // Right side - Login form
                    Expanded(
                      flex: MediaQuery.of(context).size.width > 800 ? 1 : 2,
                      child: Center(
                        child: _buildLoginCard(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.dashboard_rounded,
            size: 80,
            color: Colors.white,
          ),
          const SizedBox(height: 32),
          const Text(
            'مرحباً بك في',
            style: TextStyle(
              fontSize: 32,
              color: Colors.white70,
              fontWeight: FontWeight.w300,
            ),
          ),
          const Text(
            'لوحة التحكم',
            style: TextStyle(
              fontSize: 48,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'نظام إدارة شامل',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          _buildFeatureList(),
        ],
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      'إدارة الطلبات بكفاءة',
      'تتبع الحالات في الوقت الفعلي',
      'تقارير وإحصائيات شاملة',
      'واجهة سهلة الاستخدام',
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features
          .map((feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      feature,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Card(
      elevation: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(48),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo and Title
            _buildHeader(context),
            const SizedBox(height: 48),

            // Login Form
            BlocListener<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                } else if (state is AuthAuthenticated) {
                  // Navigate to dashboard
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/dashboard',
                    (route) => false,
                  );
                }
              },
              child: const LoginFormWidget(),
            ),

            const SizedBox(height: 32),

            // Footer
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667eea).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.dashboard_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'تسجيل الدخول',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3748),
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'أدخل بياناتك للوصول إلى لوحة التحكم',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () {
            // TODO: Implement forgot password
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ميزة استعادة كلمة المرور قريباً'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Text(
            'هل نسيت كلمة المرور؟',
            style: TextStyle(
              color: Colors.grey[600],
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '© 2024 Fixly Admin Dashboard. جميع الحقوق محفوظة.',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
