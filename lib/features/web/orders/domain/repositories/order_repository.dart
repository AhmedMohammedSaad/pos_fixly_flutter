import '../entities/order_entity.dart';

/// Repository interface for orders in web feature
/// Follows Repository pattern and Dependency Inversion Principle
abstract class OrderRepository {
  /// Get all orders
  Future<List<OrderEntity>> getAllOrders();

  /// Get orders by status
  Future<List<OrderEntity>> getOrdersByStatus(String status);

  /// Search orders by query
  Future<List<OrderEntity>> searchOrders(String query);

  /// Get orders by date range
  Future<List<OrderEntity>> getOrdersByDateRange(DateTime startDate, DateTime endDate);

  /// Get order by ID
  Future<OrderEntity?> getOrderById(String orderId);

  /// Update order status
  Future<OrderEntity> updateOrderStatus(String orderId, String status);

  /// Update order details
  Future<OrderEntity> updateOrder(OrderEntity order);

  /// Delete order
  Future<bool> deleteOrder(String orderId);

  /// Get orders statistics
  Future<Map<String, int>> getOrdersStatistics();

  /// Get orders analytics
  Future<Map<String, dynamic>> getOrdersAnalytics();

  /// Export orders to CSV
  Future<String> exportOrdersToCSV();

  /// Get orders by technician
  Future<List<OrderEntity>> getOrdersByTechnician(String technicianId);

  /// Assign order to technician
  Future<OrderEntity> assignOrderToTechnician(String orderId, String technicianId);

  /// Get overdue orders
  Future<List<OrderEntity>> getOverdueOrders();

  /// Get urgent orders
  Future<List<OrderEntity>> getUrgentOrders();

  /// Bulk update orders status
  Future<List<OrderEntity>> bulkUpdateOrderStatus(List<String> orderIds, String status);

  /// Get orders count by status
  Future<Map<String, int>> getOrdersCountByStatus();

  /// Get revenue analytics
  Future<Map<String, double>> getRevenueAnalytics();

  /// Bulk delete orders
  Future<bool> bulkDeleteOrders(List<String> orderIds);

  /// Get filtered orders
  Future<List<OrderEntity>> getFilteredOrders(Map<String, dynamic> filters);

  /// Get sorted orders
  Future<List<OrderEntity>> getSortedOrders(String sortBy, bool ascending);
}