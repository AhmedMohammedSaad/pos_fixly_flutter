import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/orders_remote_data_source.dart';
import '../models/order_model.dart';

/// Implementation of OrderRepository for web platform
/// Follows Repository pattern and Single Responsibility Principle
class OrderRepositoryImpl implements OrderRepository {
  final OrdersRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<OrderEntity>> getAllOrders() async {
    try {
      final orderModels = await remoteDataSource.getAllOrders();
      return orderModels.map((model) => model as OrderEntity).toList();
    } catch (e) {
      throw Exception('Failed to get all orders: $e');
    }
  }

  @override
  Future<List<OrderEntity>> getOrdersByStatus(String status) async {
    try {
      final orderModels = await remoteDataSource.getOrdersByStatus(status);
      return orderModels.map((model) => model as OrderEntity).toList();
    } catch (e) {
      throw Exception('Failed to get orders by status: $e');
    }
  }

  @override
  Future<List<OrderEntity>> searchOrders(String query) async {
    try {
      final orderModels = await remoteDataSource.searchOrders(query);
      return orderModels.map((model) => model as OrderEntity).toList();
    } catch (e) {
      throw Exception('Failed to search orders: $e');
    }
  }

  @override
  Future<OrderEntity> getOrderById(String orderId) async {
    try {
      final orderModel = await remoteDataSource.getOrderById(orderId);
      return orderModel as OrderEntity;
    } catch (e) {
      throw Exception('Failed to get order by ID: $e');
    }
  }

  @override
  Future<OrderEntity> updateOrderStatus(String orderId, String status) async {
    try {
      final orderModel = await remoteDataSource.updateOrderStatus(orderId, status);
      return orderModel as OrderEntity;
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  @override
  Future<bool> deleteOrder(String orderId) async {
    try {
      await remoteDataSource.deleteOrder(orderId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  @override
  Future<String> exportOrdersToCSV() async {
    try {
      return await remoteDataSource.exportOrdersToCSV();
    } catch (e) {
      throw Exception('Failed to export orders to CSV: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getOrdersAnalytics() async {
    try {
      return await remoteDataSource.getOrdersAnalytics();
    } catch (e) {
      throw Exception('Failed to get orders analytics: $e');
    }
  }

  @override
  Future<List<OrderEntity>> getOrdersByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final orderModels = await remoteDataSource.getOrdersByDateRange(startDate, endDate);
      return orderModels.map((model) => model as OrderEntity).toList();
    } catch (e) {
      throw Exception('Failed to get orders by date range: $e');
    }
  }

  @override
  Future<List<OrderEntity>> getOrdersByTechnician(String technicianId) async {
    try {
      final orderModels = await remoteDataSource.getOrdersByTechnician(technicianId);
      return orderModels;
    } catch (e) {
      throw Exception('Failed to get orders by technician: $e');
    }
  }





  @override
  Future<List<OrderEntity>> bulkUpdateOrderStatus(
    List<String> orderIds, 
    String status
  ) async {
    try {
      final List<OrderEntity> updatedOrders = [];
      
      for (final orderId in orderIds) {
        final updatedOrder = await remoteDataSource.updateOrderStatus(orderId, status);
        updatedOrders.add(updatedOrder);
      }
      
      return updatedOrders;
    } catch (e) {
      throw Exception('Failed to bulk update order status: $e');
    }
  }

  @override
  Future<bool> bulkDeleteOrders(List<String> orderIds) async {
    try {
      for (final orderId in orderIds) {
        await remoteDataSource.deleteOrder(orderId);
      }
      return true;
    } catch (e) {
      throw Exception('Failed to bulk delete orders: $e');
    }
  }

  @override
  Future<List<OrderEntity>> getFilteredOrders(Map<String, dynamic> filters) async {
    try {
      final orderModels = await remoteDataSource.getFilteredOrders(filters);
      return orderModels;
    } catch (e) {
      throw Exception('Failed to get filtered orders: $e');
    }
  }

  @override
  Future<List<OrderEntity>> getSortedOrders(String sortBy, bool ascending) async {
    try {
      final orderModels = await remoteDataSource.getSortedOrders(sortBy, ascending);
      return orderModels;
    } catch (e) {
      throw Exception('Failed to get sorted orders: $e');
    }
  }

  @override
  Future<OrderEntity> updateOrder(OrderEntity order) async {
    try {
      final orderModel = Order.fromEntity(order);
      final updatedModel = await remoteDataSource.updateOrder(orderModel);
      return updatedModel;
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  @override
  Future<Map<String, int>> getOrdersStatistics() async {
    try {
      return await remoteDataSource.getOrdersStatistics();
    } catch (e) {
      throw Exception('Failed to get orders statistics: $e');
    }
  }



  @override
  Future<List<OrderEntity>> getUrgentOrders() async {
    try {
      final orderModels = await remoteDataSource.getUrgentOrders();
      return orderModels;
    } catch (e) {
      throw Exception('Failed to get urgent orders: $e');
    }
  }

  @override
  Future<List<OrderEntity>> getOverdueOrders() async {
    try {
      final orderModels = await remoteDataSource.getOverdueOrders();
      return orderModels;
    } catch (e) {
      throw Exception('Failed to get overdue orders: $e');
    }
  }

  @override
  Future<Map<String, int>> getOrdersCountByStatus() async {
    try {
      return await remoteDataSource.getOrdersCountByStatus();
    } catch (e) {
      throw Exception('Failed to get orders count by status: $e');
    }
  }

  @override
  Future<Map<String, double>> getRevenueAnalytics() async {
    try {
      return await remoteDataSource.getRevenueAnalytics();
    } catch (e) {
      throw Exception('Failed to get revenue analytics: $e');
    }
  }

  @override
  Future<OrderEntity> assignOrderToTechnician(String orderId, String technicianId) async {
    try {
      final orderModel = await remoteDataSource.assignOrderToTechnician(orderId, technicianId);
      return orderModel as OrderEntity;
    } catch (e) {
      throw Exception('Failed to assign order to technician: $e');
    }
  }
}