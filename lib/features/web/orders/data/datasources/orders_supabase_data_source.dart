import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/services/supabase_service.dart';
import '../models/order_model.dart';

abstract class OrdersSupabaseDataSource {
  Future<List<Order>> getAllOrders();
  Future<List<Order>> getOrdersByStatus(String status);
  Future<List<Order>> searchOrders(String query);
  Future<Order?> getOrderById(String id);
  Future<Order> createOrder(Order order);
  Future<Order> updateOrder(Order order);
  Future<void> deleteOrder(String id);
  Future<List<Order>> getFilteredOrders(Map<String, dynamic> filters);
  Future<List<Order>> getSortedOrders(String sortBy, bool ascending);
  Future<Map<String, dynamic>> getOrdersAnalytics();
  Future<void> bulkUpdateOrders(
      List<String> orderIds, Map<String, dynamic> updates);
  Future<void> bulkDeleteOrders(List<String> orderIds);
}

class OrdersSupabaseDataSourceImpl implements OrdersSupabaseDataSource {
  static const String _tableName = 'orders';

  @override
  Future<List<Order>> getAllOrders() async {
    try {
      final response = await SupabaseService.from(_tableName)
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('فشل في جلب الطلبات: ${e.toString()}');
    }
  }

  @override
  Future<List<Order>> getOrdersByStatus(String status) async {
    try {
      final response = await SupabaseService.from(_tableName)
          .select()
          .eq('status', status)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('فشل في جلب الطلبات حسب الحالة: ${e.toString()}');
    }
  }

  @override
  Future<List<Order>> searchOrders(String query) async {
    try {
      final response = await SupabaseService.from(_tableName)
          .select()
          .or('customer_name.ilike.%$query%,customer_phone.ilike.%$query%,id.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List).map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('فشل في البحث عن الطلبات: ${e.toString()}');
    }
  }

  @override
  Future<Order?> getOrderById(String id) async {
    try {
      final response = await SupabaseService.from(_tableName)
          .select()
          .eq('order_id', id)
          .maybeSingle();

      if (response == null) return null;

      return Order.fromJson(response);
    } catch (e) {
      throw Exception('فشل في جلب الطلب: ${e.toString()}');
    }
  }

  @override
  Future<Order> createOrder(Order order) async {
    try {
      final response = await SupabaseService.from(_tableName)
          .insert(order.toJson())
          .select()
          .single();

      return Order.fromJson(response);
    } catch (e) {
      throw Exception('فشل في إنشاء الطلب: ${e.toString()}');
    }
  }

  @override
  Future<Order> updateOrder(Order order) async {
    try {
      final response = await SupabaseService.from(_tableName)
          .update(order.toJson())
          .eq('order_id', order.orderId!)
          .select()
          .single();

      return Order.fromJson(response);
    } catch (e) {
      throw Exception('فشل في تحديث الطلب: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteOrder(String id) async {
    try {
      await SupabaseService.from(_tableName).delete().eq('order_id', id);
    } catch (e) {
      throw Exception('فشل في حذف الطلب: ${e.toString()}');
    }
  }

  @override
  Future<List<Order>> getFilteredOrders(Map<String, dynamic> filters) async {
    try {
      var query = SupabaseService.from(_tableName).select();

      filters.forEach((key, value) {
        if (value != null) {
          query = query.eq(key, value);
        }
      });

      final response = await query.order('created_at', ascending: false);

      return (response as List).map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('فشل في تصفية الطلبات: ${e.toString()}');
    }
  }

  @override
  Future<List<Order>> getSortedOrders(String sortBy, bool ascending) async {
    try {
      final response = await SupabaseService.from(_tableName)
          .select()
          .order(sortBy, ascending: ascending);

      return (response as List).map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('فشل في ترتيب الطلبات: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getOrdersAnalytics() async {
    try {
      // Get total orders count
      final totalOrdersResponse =
          await SupabaseService.from(_tableName).select('*');

      // Get orders by status
      final statusAnalytics = await SupabaseService.from(_tableName)
          .select('status')
          .order('status');

      // Calculate analytics
      final statusCounts = <String, int>{};
      for (final order in statusAnalytics) {
        final status = order['status'] as String;
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }

      return {
        'total_orders': totalOrdersResponse.length,
        'status_counts': statusCounts,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('فشل في جلب إحصائيات الطلبات: ${e.toString()}');
    }
  }

  @override
  Future<void> bulkUpdateOrders(
      List<String> orderIds, Map<String, dynamic> updates) async {
    try {
      await SupabaseService.from(_tableName)
          .update(updates)
          .inFilter('order_id', orderIds);
    } catch (e) {
      throw Exception('فشل في التحديث المجمع للطلبات: ${e.toString()}');
    }
  }

  @override
  Future<void> bulkDeleteOrders(List<String> orderIds) async {
    try {
      await SupabaseService.from(_tableName)
          .delete()
          .inFilter('order_id', orderIds);
    } catch (e) {
      throw Exception('فشل في الحذف المجمع للطلبات: ${e.toString()}');
    }
  }
}
