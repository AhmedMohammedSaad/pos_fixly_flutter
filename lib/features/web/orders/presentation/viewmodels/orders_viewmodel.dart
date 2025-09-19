import 'package:flutter/foundation.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/get_all_orders_usecase.dart';
import '../../domain/usecases/get_orders_by_status_usecase.dart';
import '../../domain/usecases/search_orders_usecase.dart';
import '../../domain/usecases/get_order_by_id_usecase.dart';
import '../../domain/usecases/update_order_status_usecase.dart';
import '../../domain/usecases/delete_order_usecase.dart';
import '../../domain/usecases/get_orders_analytics_usecase.dart';
import '../../domain/usecases/export_orders_usecase.dart';
import '../../domain/usecases/bulk_update_orders_usecase.dart';
import '../../domain/usecases/bulk_delete_orders_usecase.dart';
import '../../domain/usecases/get_filtered_orders_usecase.dart';
import '../../domain/usecases/get_sorted_orders_usecase.dart';
import 'package:pos_fixly_admin_dashboard/core/usecases/usecase.dart';

/// ViewModel for orders in web feature
/// Follows MVVM pattern and Single Responsibility Principle
class OrdersViewModel extends ChangeNotifier {
  final GetAllOrdersUseCase getAllOrdersUseCase;
  final GetOrdersByStatusUseCase getOrdersByStatusUseCase;
  final SearchOrdersUseCase searchOrdersUseCase;
  final GetOrderByIdUseCase getOrderByIdUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;
  final DeleteOrderUseCase deleteOrderUseCase;
  final GetOrdersAnalyticsUseCase getOrdersAnalyticsUseCase;
  final ExportOrdersUseCase exportOrdersUseCase;
  final BulkUpdateOrdersUseCase bulkUpdateOrdersUseCase;
  final BulkDeleteOrdersUseCase bulkDeleteOrdersUseCase;
  final GetFilteredOrdersUseCase getFilteredOrdersUseCase;
  final GetSortedOrdersUseCase getSortedOrdersUseCase;

  OrdersViewModel({
    required this.getAllOrdersUseCase,
    required this.getOrdersByStatusUseCase,
    required this.searchOrdersUseCase,
    required this.getOrderByIdUseCase,
    required this.updateOrderStatusUseCase,
    required this.deleteOrderUseCase,
    required this.getOrdersAnalyticsUseCase,
    required this.exportOrdersUseCase,
    required this.bulkUpdateOrdersUseCase,
    required this.bulkDeleteOrdersUseCase,
    required this.getFilteredOrdersUseCase,
    required this.getSortedOrdersUseCase,
  });

  // State management
  List<OrderEntity> _orders = [];
  List<OrderEntity> _filteredOrders = [];
  Map<String, dynamic> _analytics = {};
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedFilter = 'all';
  String _searchQuery = '';
  String _sortBy = 'createdAt';
  bool _sortAscending = false;

  // Getters
  List<OrderEntity> get orders => _filteredOrders;
  Map<String, dynamic> get analytics => _analytics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  // Statistics getters
  int get totalOrders => _orders.length;
  int get pendingOrders => _orders.where((order) => order.isPending).length;
  int get completedOrders => _orders.where((order) => order.isCompleted).length;
  int get urgentOrders => _orders.where((order) => order.isUrgent).length;
  int get overdueOrders => _orders.where((order) => order.isOverdue).length;

  /// Load all orders
  Future<void> loadOrders() async {
    _setLoading(true);
    _clearError();

    try {
      _orders = await getAllOrdersUseCase(NoParams());
      _applyFiltersAndSort();
      notifyListeners();
    } catch (e) {
      _setError('فشل في تحميل الطلبات: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Load analytics data
  Future<void> loadAnalytics() async {
    try {
      _analytics = await getOrdersAnalyticsUseCase(NoParams());
      notifyListeners();
    } catch (e) {
      _setError('فشل في تحميل التحليلات: ${e.toString()}');
    }
  }

  /// Export orders to CSV
  Future<String?> exportOrders() async {
    try {
      return await exportOrdersUseCase(NoParams());
    } catch (e) {
      _setError('فشل في تصدير الطلبات: ${e.toString()}');
      return null;
    }
  }

  /// Filter orders by status
  void filterByStatus(String status) {
    _selectedFilter = status;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Search orders
  void searchOrders(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Sort orders
  void sortOrders(String sortBy, {bool? ascending}) {
    _sortBy = sortBy;
    if (ascending != null) {
      _sortAscending = ascending;
    } else {
      _sortAscending = !_sortAscending;
    }
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Clear filters
  void clearFilters() {
    _selectedFilter = 'all';
    _searchQuery = '';
    _sortBy = 'createdAt';
    _sortAscending = false;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Refresh data
  Future<void> refresh() async {
    await Future.wait([
      loadOrders(),
      loadAnalytics(),
    ]);
  }

  /// Apply filters and sorting
  void _applyFiltersAndSort() {
    _filteredOrders = List.from(_orders);

    // Apply status filter
    if (_selectedFilter != 'all') {
      _filteredOrders = _filteredOrders
          .where((order) => order.status == _selectedFilter)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      _filteredOrders = _filteredOrders.where((order) {
        final query = _searchQuery.toLowerCase();
        return order.customerName?.toLowerCase().contains(query) == true ||
            order.customerPhone?.toLowerCase().contains(query) == true ||
            order.orderNumber?.toLowerCase().contains(query) == true ||
            order.problemDescription?.toLowerCase().contains(query) == true;
      }).toList();
    }

    // Apply sorting
    _filteredOrders.sort((a, b) {
      dynamic aValue, bValue;
      
      switch (_sortBy) {
        case 'customerName':
          aValue = a.customerName ?? '';
          bValue = b.customerName ?? '';
          break;
        case 'status':
          aValue = a.status ?? '';
          bValue = b.status ?? '';
          break;
        case 'urgencyLevel':
          aValue = a.urgencyLevel;
          bValue = b.urgencyLevel;
          break;
        case 'estimatedBudget':
          aValue = a.estimatedBudget ?? 0;
          bValue = b.estimatedBudget ?? 0;
          break;
        case 'createdAt':
        default:
          aValue = a.createdAt ?? DateTime.now();
          bValue = b.createdAt ?? DateTime.now();
          break;
      }

      final comparison = aValue.compareTo(bValue);
      return _sortAscending ? comparison : -comparison;
    });
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
  }
}