import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'web_app.dart';
import 'mobile_app.dart';
import 'core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Dependency Injection
  await di.init();

  await Supabase.initialize(
    url: 'https://mtxmzitasqtuukdhipav.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im10eG16aXRhc3F0dXVrZGhpcGF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcwMDI0NjksImV4cCI6MjA3MjU3ODQ2OX0.2cBXwkbv5-BizATym0ubpN3_Df5nYp71eP_NJHQ81Lw',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // التوجيه التلقائي حسب المنصة
    if (kIsWeb) {
      // للويب: تطبيق منفصل مع تصميم مناسب للشاشات الكبيرة
      return const WebApp();
    } else {
      // للموبايل: تطبيق منفصل مع تصميم متجاوب للشاشات المختلفة
      return const MobileApp();
    }
  }
}
