import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

/// Implementation of OrderRepository
/// Follows Repository pattern and Dependency Inversion Principle
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<OrderEntity>> getAllOrders() async {
    try {
      final orders = await remoteDataSource.getAllOrders();
      return orders;
    } catch (e) {
      throw Exception('Failed to get all orders: $e');
    }
  }

  @override
  Future<List<OrderEntity>> getOrdersByStatus(String? status) async {
    try {
      final orders = await remoteDataSource.getOrdersByStatus(status);
      return orders;
    } catch (e) {
      throw Exception('Failed to get orders by status: $e');
    }
  }

  @override
  Future<List<OrderEntity>> searchOrders(String query) async {
    try {
      final orders = await remoteDataSource.searchOrders(query);
      return orders;
    } catch (e) {
      throw Exception('Failed to search orders: $e');
    }
  }

  @override
  Future<OrderEntity> getOrderById(String id) async {
    try {
      final order = await remoteDataSource.getOrderById(id);
      return order;
    } catch (e) {
      throw Exception('Failed to get order by id: $e');
    }
  }

  @override
  Future<void> updateOrderStatus(String id, String status) async {
    try {
      await remoteDataSource.updateOrderStatus(id, status);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  @override
  Future<void> deleteOrder(String id) async {
    try {
      await remoteDataSource.deleteOrder(id);
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  @override
  Future<Map<String, int>> getOrdersStatistics() async {
    try {
      final allOrders = await remoteDataSource.getAllOrders();
      
      final statistics = <String, int>{
        'total': allOrders.length,
        'pending': 0,
        'reviewed': 0,
        'quoted': 0,
        'in_progress': 0,
        'completed': 0,
        'cancelled': 0,
        'urgent': 0,
        'overdue': 0,
      };

      for (final order in allOrders) {
        // Count by status
        final status = order.status ?? 'unknown';
        if (statistics.containsKey(status)) {
          statistics[status] = statistics[status]! + 1;
        }

        // Count urgent orders
        if (order.isUrgent) {
          statistics['urgent'] = statistics['urgent']! + 1;
        }

        // Count overdue orders
        if (order.isOverdue) {
          statistics['overdue'] = statistics['overdue']! + 1;
        }
      }

      return statistics;
    } catch (e) {
      throw Exception('Failed to get orders statistics: $e');
    }
  }

  @override
  Future<List<OrderEntity>> getOrdersByDateRange(DateTime start, DateTime end) async {
    try {
      final allOrders = await remoteDataSource.getAllOrders();
      
      return allOrders.where((order) {
        if (order.createdAt == null) return false;
        return order.createdAt!.isAfter(start) && order.createdAt!.isBefore(end);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get orders by date range: $e');
    }
  }

  @override
  Future<List<OrderEntity>> getUrgentOrders() async {
    try {
      final allOrders = await remoteDataSource.getAllOrders();
      return allOrders.where((order) => order.isUrgent).toList();
    } catch (e) {
      throw Exception('Failed to get urgent orders: $e');
    }
  }

  @override
  Future<List<OrderEntity>> getOverdueOrders() async {
    try {
      final allOrders = await remoteDataSource.getAllOrders();
      return allOrders.where((order) => order.isOverdue).toList();
    } catch (e) {
      throw Exception('Failed to get overdue orders: $e');
    }
  }
}