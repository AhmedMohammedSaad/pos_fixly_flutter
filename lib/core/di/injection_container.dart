import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

// Web Orders Feature
import '../../features/web/orders/data/datasources/orders_remote_data_source.dart';
import '../../features/web/orders/data/repositories/order_repository_impl.dart';
import '../../features/web/orders/domain/repositories/order_repository.dart';
import '../../features/web/orders/domain/usecases/get_all_orders_usecase.dart';
import '../../features/web/orders/domain/usecases/get_orders_by_status_usecase.dart';
import '../../features/web/orders/domain/usecases/search_orders_usecase.dart';
import '../../features/web/orders/domain/usecases/get_order_by_id_usecase.dart';
import '../../features/web/orders/domain/usecases/update_order_status_usecase.dart';
import '../../features/web/orders/domain/usecases/delete_order_usecase.dart';
import '../../features/web/orders/domain/usecases/export_orders_usecase.dart';
import '../../features/web/orders/domain/usecases/get_orders_analytics_usecase.dart';
import '../../features/web/orders/domain/usecases/bulk_update_orders_usecase.dart';
import '../../features/web/orders/domain/usecases/bulk_delete_orders_usecase.dart';
import '../../features/web/orders/domain/usecases/get_filtered_orders_usecase.dart';
import '../../features/web/orders/domain/usecases/get_sorted_orders_usecase.dart';
import '../../features/web/orders/presentation/viewmodels/orders_viewmodel.dart';

// Mobile Orders Feature (if exists)
// import '../../features/mobile/orders/...';

final sl = GetIt.instance;

/// Dependency Injection Container
/// Follows Dependency Inversion Principle
Future<void> init() async {
  //! Features - Web Orders
  await _initWebOrdersFeature();

  //! Features - Mobile Orders (if needed)
  // await _initMobileOrdersFeature();

  //! Core
  await _initCore();

  //! External
  await _initExternal();
}

/// Initialize Web Orders Feature Dependencies
Future<void> _initWebOrdersFeature() async {
  // ViewModels
  sl.registerFactory(
    () => OrdersViewModel(
      getAllOrdersUseCase: sl(),
      getOrdersByStatusUseCase: sl(),
      searchOrdersUseCase: sl(),
      getOrderByIdUseCase: sl(),
      updateOrderStatusUseCase: sl(),
      deleteOrderUseCase: sl(),
      exportOrdersUseCase: sl(),
      getOrdersAnalyticsUseCase: sl(),
      bulkUpdateOrdersUseCase: sl(),
      bulkDeleteOrdersUseCase: sl(),
      getFilteredOrdersUseCase: sl(),
      getSortedOrdersUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetAllOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetOrdersByStatusUseCase(sl()));
  sl.registerLazySingleton(() => SearchOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetOrderByIdUseCase(sl()));
  sl.registerLazySingleton(() => UpdateOrderStatusUseCase(sl()));
  sl.registerLazySingleton(() => DeleteOrderUseCase(sl()));
  sl.registerLazySingleton(() => ExportOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetOrdersAnalyticsUseCase(sl()));
  sl.registerLazySingleton(() => BulkUpdateOrdersUseCase(sl()));
  sl.registerLazySingleton(() => BulkDeleteOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetFilteredOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetSortedOrdersUseCase(sl()));

  // Repository
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSourceImpl(
      client: sl(),
      baseUrl: _getBaseUrl(),
    ),
  );
}

/// Initialize Mobile Orders Feature Dependencies (if needed)
// Future<void> _initMobileOrdersFeature() async {
//   // Add mobile-specific dependencies here
// }

/// Initialize Core Dependencies
Future<void> _initCore() async {
  // Add core dependencies like network info, error handling, etc.
}

/// Initialize External Dependencies
Future<void> _initExternal() async {
  // HTTP Client
  sl.registerLazySingleton(() => http.Client());
}

/// Get base URL based on environment
String _getBaseUrl() {
  // You can configure this based on your environment
  // For development
  return 'http://localhost:8000';
  
  // For production
  // return 'https://your-api-domain.com';
}