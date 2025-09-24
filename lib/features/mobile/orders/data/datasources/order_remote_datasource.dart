import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';

/// Remote data source for orders - handles API calls
/// Follows Single Responsibility Principle
abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getAllOrders();
  Future<List<OrderModel>> getOrdersByStatus(String? status);
  Future<List<OrderModel>> searchOrders(String query);
  Future<OrderModel> getOrderById(String id);
  Future<void> updateOrderStatus(String id, String status);
  Future<void> deleteOrder(String id);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final SupabaseClient _supabaseClient;

  OrderRemoteDataSourceImpl({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  static const String _table = 'customer_orders';

  @override
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final response = await _supabaseClient
          .from(_table)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  @override
  Future<List<OrderModel>> getOrdersByStatus(String? status) async {
    try {
      final response =
          (status != null && status.isNotEmpty && status.toLowerCase() != 'all')
              ? await _supabaseClient
                  .from(_table)
                  .select()
                  .eq('status', status)
                  .order('created_at', ascending: false)
              : await _supabaseClient
                  .from(_table)
                  .select()
                  .order('created_at', ascending: false);

      return (response as List)
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders by status: $e');
    }
  }

  @override
  Future<List<OrderModel>> searchOrders(String query) async {
    try {
      final response = await _supabaseClient
          .from(_table)
          .select()
          .or(
            'customer_name.ilike.%$query%,'
            'order_number.ilike.%$query%,'
            'service_type.ilike.%$query%',
          )
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search orders: $e');
    }
  }

  @override
  Future<OrderModel> getOrderById(String id) async {
    try {
      final response = await _supabaseClient
          .from(_table)
          .select()
          .eq('order_id', id) // ← غيّرها لـ 'id' لو ده العمود الصحيح
          .single();

      return OrderModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch order by id: $e');
    }
  }

  @override
  Future<void> updateOrderStatus(String id, String status) async {
    try {
      await _supabaseClient.from(_table).update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('order_id', id); // ← غيّرها لـ 'id' لو العمود الصحيح
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  @override
  // يعيد true لو صف واحد على الأقل اتشلّ
  Future<bool> deleteOrder(String id) async {
    try {
      final res = await _supabaseClient
          .from('customer_orders')
          .delete()
          .eq('status', 'cancelled')
          .select('id'); // v2: يرجّع المحذوف

      final deletedCount = (res as List).length;
      return deletedCount > 0;
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }
}
