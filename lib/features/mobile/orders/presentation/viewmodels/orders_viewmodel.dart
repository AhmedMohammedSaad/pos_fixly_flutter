import 'package:flutter/foundation.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/get_all_orders_usecase.dart';
import '../../domain/usecases/get_orders_by_status_usecase.dart';
import '../../domain/usecases/search_orders_usecase.dart';
import '../../domain/usecases/update_order_status_usecase.dart';
import 'package:pos_fixly_admin_dashboard/core/usecases/usecase.dart';

/// ViewModel for Orders - handles business logic and state management
/// Follows MVVM pattern and Single Responsibility Principle
class OrdersViewModel extends ChangeNotifier {
  final GetAllOrdersUseCase _getAllOrdersUseCase;
  final GetOrdersByStatusUseCase _getOrdersByStatusUseCase;
  final SearchOrdersUseCase _searchOrdersUseCase;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;

  OrdersViewModel({
    required GetAllOrdersUseCase getAllOrdersUseCase,
    required GetOrdersByStatusUseCase getOrdersByStatusUseCase,
    required SearchOrdersUseCase searchOrdersUseCase,
    required UpdateOrderStatusUseCase updateOrderStatusUseCase,
  })  : _getAllOrdersUseCase = getAllOrdersUseCase,
        _getOrdersByStatusUseCase = getOrdersByStatusUseCase,
        _searchOrdersUseCase = searchOrdersUseCase,
        _updateOrderStatusUseCase = updateOrderStatusUseCase;

  // State variables
  List<OrderEntity> _orders = [];
  List<OrderEntity> _filteredOrders = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedFilter = 'all';
  String _searchQuery = '';

  // Getters
  List<OrderEntity> get orders => _filteredOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;
  bool get hasOrders => _filteredOrders.isNotEmpty;
  bool get hasError => _errorMessage != null;

  // Statistics getters
  int get totalOrders => _orders.length;
  int get pendingOrders => _orders.where((order) => order.isPending).length;
  int get completedOrders => _orders.where((order) => order.isCompleted).length;
  int get urgentOrders => _orders.where((order) => order.isUrgent).length;
  int get overdueOrders => _orders.where((order) => order.isOverdue).length;

  /// Load all orders
  Future<void> loadAllOrders({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    _setLoading(true);
    _clearError();

    try {
      final orders = await _getAllOrdersUseCase(NoParams());
      _orders = orders;
      _applyFilters();
      
      if (kDebugMode) {
        print('✅ تم تحميل ${orders.length} طلب بنجاح');
      }
    } catch (e) {
      _setError('فشل في تحميل الطلبات: ${e.toString()}');
      if (kDebugMode) {
        print('❌ خطأ في تحميل الطلبات: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Filter orders by status
  Future<void> filterOrdersByStatus(String? status) async {
    _selectedFilter = status ?? 'all';
    
    if (status == null || status == 'all') {
      await loadAllOrders();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final orders = await _getOrdersByStatusUseCase(StringParams(status));
      _orders = orders;
      _applyFilters();
      
      if (kDebugMode) {
        print('✅ تم تصفية الطلبات بحالة: $status');
      }
    } catch (e) {
      _setError('فشل في تصفية الطلبات: ${e.toString()}');
      if (kDebugMode) {
        print('❌ خطأ في تصفية الطلبات: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Search orders
  Future<void> searchOrders(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      await loadAllOrders();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final orders = await _searchOrdersUseCase(StringParams(query));
      _orders = orders;
      _applyFilters();
      
      if (kDebugMode) {
        print('✅ تم البحث عن: $query');
      }
    } catch (e) {
      _setError('فشل في البحث: ${e.toString()}');
      if (kDebugMode) {
        print('❌ خطأ في البحث: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _updateOrderStatusUseCase(
        UpdateStatusParams(id: orderId, status: newStatus),
      );

      // Update local state
      final orderIndex = _orders.indexWhere((order) => order.orderId == orderId);
      if (orderIndex != -1) {
        // Create a new list with updated order
        final updatedOrders = List<OrderEntity>.from(_orders);
        // Note: In a real implementation, you'd need a copyWith method on OrderEntity
        // For now, we'll reload the data
        await loadAllOrders(forceRefresh: true);
      }

      if (kDebugMode) {
        print('✅ تم تحديث حالة الطلب: $orderId إلى $newStatus');
      }
    } catch (e) {
      _setError('فشل في تحديث حالة الطلب: ${e.toString()}');
      if (kDebugMode) {
        print('❌ خطأ في تحديث حالة الطلب: $e');
      }
    }
  }

  /// Refresh orders
  Future<void> refreshOrders() async {
    await loadAllOrders(forceRefresh: true);
  }

  /// Clear search and filters
  void clearFilters() {
    _selectedFilter = 'all';
    _searchQuery = '';
    loadAllOrders();
  }

  /// Private methods
  void _applyFilters() {
    _filteredOrders = List.from(_orders);
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}