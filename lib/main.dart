import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:pos_fixly_admin_dashboard/core/config/shared_prefs_helper.dart';

import 'package:pos_fixly_admin_dashboard/features/mobile/auth/presentation/pages/login_page.dart';
import 'package:pos_fixly_admin_dashboard/features/mobile/auth/presentation/viewmodels/auth_cubit.dart';
import 'package:pos_fixly_admin_dashboard/features/mobile/orders/presentation/pages/orders_page.dart';
import 'package:pos_fixly_admin_dashboard/features/mobile/orders/presentation/view_models/orders_viewmodel.dart';
import 'package:pos_fixly_admin_dashboard/features/mobile/orders/domain/usecases/get_all_orders_usecase.dart';
import 'package:pos_fixly_admin_dashboard/features/mobile/orders/domain/usecases/get_orders_by_status_usecase.dart';
import 'package:pos_fixly_admin_dashboard/features/mobile/orders/domain/usecases/search_orders_usecase.dart';
import 'package:pos_fixly_admin_dashboard/features/mobile/orders/domain/usecases/update_order_status_usecase.dart';
import 'package:pos_fixly_admin_dashboard/features/mobile/orders/data/repositories/order_repository_impl.dart';
import 'package:pos_fixly_admin_dashboard/features/mobile/orders/data/datasources/order_remote_datasource.dart';
import 'package:pos_fixly_admin_dashboard/features/web/auth/presentation/pages/web_login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (consider using env vars instead of hardcoding keys)
  await Supabase.initialize(
    url: 'https://mtxmzitasqtuukdhipav.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im10eG16aXRhc3F0dXVrZGhpcGF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcwMDI0NjksImV4cCI6MjA3MjU3ODQ2OX0.2cBXwkbv5-BizATym0ubpN3_Df5nYp71eP_NJHQ81Lw',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Prefer Supabase auth session; fall back to SharedPreferences flag.
  Future<bool> _isLoggedIn() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) return true;

    return await SharedPrefsHelper.getBool('isLoggedIn');
  }

  /// Create OrdersViewModel with direct dependencies
  OrdersViewModel _createOrdersViewModel() {
    // Create data source
    final dataSource = OrderRemoteDataSourceImpl(
      supabaseClient: Supabase.instance.client,
    );

    // Create repository
    final repository = OrderRepositoryImpl(
      remoteDataSource: dataSource,
    );

    // Create use cases
    final getAllOrdersUseCase = GetAllOrdersUseCase(repository);
    final getOrdersByStatusUseCase = GetOrdersByStatusUseCase(repository);
    final searchOrdersUseCase = SearchOrdersUseCase(repository);
    final updateOrderStatusUseCase = UpdateOrderStatusUseCase(repository);

    // Create and return ViewModel
    return OrdersViewModel(
      getAllOrdersUseCase: getAllOrdersUseCase,
      getOrdersByStatusUseCase: getOrdersByStatusUseCase,
      searchOrdersUseCase: searchOrdersUseCase,
      updateOrderStatusUseCase: updateOrderStatusUseCase,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // === Add your blocs/cubits here ===
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()),
        // BlocProvider<OrdersCubit>(create: (_) => OrdersCubit()),

        // === Add your ViewModels here ===
        ChangeNotifierProvider<OrdersViewModel>(
          create: (_) => _createOrdersViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'Fixly',
        debugShowCheckedModeBanner: false,
        home: FutureBuilder<bool>(
          future: _isLoggedIn(),
          builder: (context, snapshot) {
            // Simple splash while checking auth
            if (snapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final loggedIn = snapshot.data ?? false;

            // WEB: use WebLoginPage if not logged in; else go to orders
            if (kIsWeb) {
              return loggedIn ? const OrdersPage() : const WebLoginPage();
            }

            // MOBILE: use LoginPage if not logged in; else go to orders
            return loggedIn ? const OrdersPage() : const LoginPage();
          },
        ),
        // Optional routes:
        // routes: {
        //   '/login': (_) => kIsWeb ? const WebLoginPage() : const LoginPage(),
        //   '/orders': (_) => const OrdersPage(),
        // },
      ),
    );
  }
}
