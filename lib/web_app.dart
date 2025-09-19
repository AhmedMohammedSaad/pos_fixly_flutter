import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'pages/main_page.dart';
import 'cubit/order_cubit.dart';
import 'features/web/orders/presentation/pages/orders_page.dart';
import 'features/web/orders/presentation/viewmodels/orders_viewmodel.dart';
import 'core/di/injection_container.dart' as di;

class WebApp extends StatelessWidget {
  const WebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderCubit(),
      child: MaterialApp(
        title: 'Fixly Admin Dashboard - لوحة التحكم',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Arial',
          // تحسينات خاصة بالويب
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            elevation: 2,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(8),
          ),
          // تحسين الألوان للشاشات الكبيرة
          scaffoldBackgroundColor: Colors.grey.shade50,
        ),
        home: const WebHomePage(),
        routes: {
          '/orders': (context) => ChangeNotifierProvider(
                create: (context) => di.sl<OrdersViewModel>(),
                child: const OrdersPage(),
              ),
        },
        debugShowCheckedModeBanner: false,
        // تحسينات الأداء للويب
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              // تحسين النص للشاشات عالية الدقة
              textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}

class WebHomePage extends StatelessWidget {
  const WebHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: const MainPage(),
      ),
    );
  }
}