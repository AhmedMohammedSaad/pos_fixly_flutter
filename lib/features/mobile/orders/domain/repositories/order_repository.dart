import '../entities/order_entity.dart';

/// Repository interface for orders - defines contract for data operations
/// Follows Repository pattern and Dependency Inversion Principle
abstract class OrderRepository {
  /// Get all orders
  Future<List<OrderEntity>> getAllOrders();

  /// Get orders by status
  Future<List<OrderEntity>> getOrdersByStatus(String? status);

  /// Search orders by query
  Future<List<OrderEntity>> searchOrders(String query);

  /// Get order by ID
  Future<OrderEntity> getOrderById(String id);

  /// Update order status
  Future<void> updateOrderStatus(String id, String status);

  /// Delete order
  Future<void> deleteOrder(String id);

  /// Get orders statistics
  Future<Map<String, int>> getOrdersStatistics();

  /// Get orders by date range
  Future<List<OrderEntity>> getOrdersByDateRange(DateTime start, DateTime end);

  /// Get urgent orders
  Future<List<OrderEntity>> getUrgentOrders();

  /// Get overdue orders
  Future<List<OrderEntity>> getOverdueOrders();
}