import '../datasources/orders_supabase_data_source.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';

/// Supabase implementation of OrderRepository
/// Uses Supabase for real-time data operations
class OrderSupabaseRepositoryImpl implements OrderRepository {
  final OrdersSupabaseDataSource supabaseDataSource;

  OrderSupabaseRepositoryImpl({
    required this.supabaseDataSource,
  });

  @override
  Future<List<OrderEntity>> getAllOrders() async {
    try {
      final orderModels = await supabaseDataSource.getAllOrders();
      return orderModels.map((model) => model as OrderEntity).toList();
    } catch (e) {
      throw Exception('فشل في جلب جميع الطلبات: $e');
    }
  }

  @override
  Future<List<OrderEntity>> getOrdersByStatus(String status) async {
    try {
      final orderModels = await supabaseDataSource.getOrdersByStatus(status);
      return orderModels.map((model) => model as OrderEntity).toList();
    } catch (e) {
      throw Exception('فشل في جلب الطلبات حسب الحالة: $e');
    }
  }

  @override
  Future<List<OrderEntity>> searchOrders(String query) async {
    try {
      final orderModels = await supabaseDataSource.searchOrders(query);
      return orderModels.map((model) => model as OrderEntity).toList();
    } catch (e) {
      throw Exception('فشل في البحث عن الطلبات: $e');
    }
  }

  @override
  Future<OrderEntity> getOrderById(String orderId) async {
    try {
      final orderModel = await supabaseDataSource.getOrderById(orderId);
      if (orderModel == null) {
        throw Exception('الطلب غير موجود');
      }
      return orderModel as OrderEntity;
    } catch (e) {
      throw Exception('فشل في جلب الطلب: $e');
    }
  }

  @override
  Future<OrderEntity> updateOrderStatus(String orderId, String status) async {
    try {
      // First get the existing order
      final existingOrder = await supabaseDataSource.getOrderById(orderId);
      if (existingOrder == null) {
        throw Exception('الطلب غير موجود');
      }

      // Update the status
      final updatedOrder = existingOrder.copyWith(status: status);
      final result = await supabaseDataSource.updateOrder(updatedOrder);
      return result as OrderEntity;
    } catch (e) {
      throw Exception('فشل في تحديث حالة الطلب: $e');
    }
  }

  @override
  Future<bool> deleteOrder(String orderId) async {
    try {
      await supabaseDataSource.deleteOrder(orderId);
      return true;
    } catch (e) {
      throw Exception('فشل في حذف الطلب: $e');
    }
  }

  @override
  Future<List<OrderEntity>> exportOrders() async {
    try {
      // For export, we get all orders
      return await getAllOrders();
    } catch (e) {
      throw Exception('فشل في تصدير الطلبات: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getOrdersAnalytics() async {
    try {
      return await supabaseDataSource.getOrdersAnalytics();
    } catch (e) {
      throw Exception('فشل في جلب إحصائيات الطلبات: $e');
    }
  }

  @override
  Future<void> bulkUpdateOrders(
      List<String> orderIds, Map<String, dynamic> updates) async {
    try {
      await supabaseDataSource.bulkUpdateOrders(orderIds, updates);
    } catch (e) {
      throw Exception('فشل في التحديث المجمع للطلبات: $e');
    }
  }

  @override
  Future<bool> bulkDeleteOrders(List<String> orderIds) async {
    try {
      await supabaseDataSource.bulkDeleteOrders(orderIds);
      return true;
    } catch (e) {
      throw Exception('فشل في الحذف المجمع للطلبات: $e');
    }
  }

  @override
  Future<Map<String, int>> getOrdersStatistics() async {
    try {
      final analytics = await supabaseDataSource.getOrdersAnalytics();
      return Map<String, int>.from(analytics['statusCounts'] ?? {});
    } catch (e) {
      throw Exception('فشل في جلب إحصائيات الطلبات: $e');
    }
  }

  @override
  Future<String> exportOrdersToCSV() async {
    try {
      // This would need to be implemented based on your CSV export requirements
      throw UnimplementedError('تصدير CSV غير مُنفذ بعد');
    } catch (e) {
      throw Exception('فشل في تصدير الطلبات: $e');
    }
  }

  @override
  Future<List<OrderEntity>> getOrdersByTechnician(String technicianId) async {
    try {
      // This would need a technician_id field in your orders table
      final orders = await supabaseDataSource
          .getFilteredOrders({'technician_id': technicianId});
      return orders.map((order) => order as OrderEntity).toList();
    } catch (e) {
      throw Exception('فشل في جلب طلبات الفني: $e');
    }
  }

  @override
  Future<OrderEntity> assignOrderToTechnician(
      String orderId, String technicianId) async {
    try {
      // This would need to be implemented based on your assignment logic
      throw UnimplementedError('تعيين الفني غير مُنفذ بعد');
    } catch (e) {
      throw Exception('فشل في تعيين الفني: $e');
    }
  }

  @override
  Future<List<OrderEntity>> getOverdueOrders() async {
    try {
      // This would need to be implemented based on your overdue logic
      final now = DateTime.now();
      final filters = {
        'preferred_date': 'lt.${now.toIso8601String()}',
        'status': 'neq.completed'
      };
      final orders = await supabaseDataSource.getFilteredOrders(filters);
      return orders.map((order) => order as OrderEntity).toList();
    } catch (e) {
      throw Exception('فشل في جلب الطلبات المتأخرة: $e');
    }
  }

  @override
  Future<List<OrderEntity>> getUrgentOrders() async {
    try {
      final orders =
          await supabaseDataSource.getFilteredOrders({'urgency_level': 'high'});
      return orders.map((order) => order as OrderEntity).toList();
    } catch (e) {
      throw Exception('فشل في جلب الطلبات العاجلة: $e');
    }
  }

  @override
  Future<List<OrderEntity>> bulkUpdateOrderStatus(
      List<String> orderIds, String status) async {
    try {
      await supabaseDataSource.bulkUpdateOrders(orderIds, {'status': status});
      // Return updated orders
      final updatedOrders = <OrderEntity>[];
      for (final orderId in orderIds) {
        final order = await supabaseDataSource.getOrderById(orderId);
        if (order != null) {
          updatedOrders.add(order as OrderEntity);
        }
      }
      return updatedOrders;
    } catch (e) {
      throw Exception('فشل في التحديث المجمع لحالة الطلبات: $e');
    }
  }

  @override
  Future<Map<String, int>> getOrdersCountByStatus() async {
    try {
      final analytics = await supabaseDataSource.getOrdersAnalytics();
      return Map<String, int>.from(analytics['statusCounts'] ?? {});
    } catch (e) {
      throw Exception('فشل في جلب عدد الطلبات حسب الحالة: $e');
    }
  }

  @override
  Future<Map<String, double>> getRevenueAnalytics() async {
    try {
      // This would need to be implemented based on your revenue calculation logic
      throw UnimplementedError('تحليل الإيرادات غير مُنفذ بعد');
    } catch (e) {
      throw Exception('فشل في جلب تحليل الإيرادات: $e');
    }
  }

  @override
  Future<List<OrderEntity>> getFilteredOrders(Map<String, dynamic> filters) {
    // TODO: implement getFilteredOrders
    throw UnimplementedError();
  }

  @override
  Future<List<OrderEntity>> getOrdersByDateRange(
      DateTime startDate, DateTime endDate) {
    // TODO: implement getOrdersByDateRange
    throw UnimplementedError();
  }

  @override
  Future<List<OrderEntity>> getSortedOrders(String sortBy, bool ascending) {
    // TODO: implement getSortedOrders
    throw UnimplementedError();
  }

  @override
  Future<OrderEntity> updateOrder(OrderEntity order) {
    // TODO: implement updateOrder
    throw UnimplementedError();
  }
}

@override
Future<List<OrderEntity>> getFilteredOrders(
    Map<String, dynamic> filters, supabaseDataSource) async {
  try {
    final orderModels = await supabaseDataSource.getFilteredOrders(filters);
    return orderModels.map((model) => model as OrderEntity).toList();
  } catch (e) {
    throw Exception('فشل في تصفية الطلبات: $e');
  }
}

@override
Future<List<OrderEntity>> getSortedOrders(
    String sortBy, bool ascending, supabaseDataSource) async {
  try {
    final orderModels =
        await supabaseDataSource.getSortedOrders(sortBy, ascending);
    return orderModels.map((model) => model as OrderEntity).toList();
  } catch (e) {
    throw Exception('فشل في ترتيب الطلبات: $e');
  }
}

// Additional Supabase-specific methods
Future<OrderEntity> createOrder(OrderEntity order, supabaseDataSource) async {
  try {
    final orderModel = Order.fromEntity(order);
    final result = await supabaseDataSource.createOrder(orderModel);
    return result as OrderEntity;
  } catch (e) {
    throw Exception('فشل في إنشاء الطلب: $e');
  }
}

Future<OrderEntity> updateOrder(OrderEntity order, supabaseDataSource) async {
  try {
    final orderModel = Order.fromEntity(order);
    final result = await supabaseDataSource.updateOrder(orderModel);
    return result as OrderEntity;
  } catch (e) {
    throw Exception('فشل في تحديث الطلب: $e');
  }
}
