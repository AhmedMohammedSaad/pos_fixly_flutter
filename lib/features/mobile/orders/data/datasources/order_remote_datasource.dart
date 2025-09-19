import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/order_entity.dart';
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

  @override
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final response = await _supabaseClient
          .from('orders')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => OrderModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  @override
  Future<List<OrderModel>> getOrdersByStatus(String? status) async {
    try {
      var query = _supabaseClient
          .from('orders')
          .select()
          .order('created_at', ascending: false);

      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      final response = await query;
      return (response as List)
          .map((json) => OrderModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders by status: $e');
    }
  }

  @override
  Future<List<OrderModel>> searchOrders(String query) async {
    try {
      final response = await _supabaseClient
          .from('orders')
          .select()
          .or('customer_name.ilike.%$query%,order_number.ilike.%$query%,service_type.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => OrderModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search orders: $e');
    }
  }

  @override
  Future<OrderModel> getOrderById(String id) async {
    try {
      final response = await _supabaseClient
          .from('orders')
          .select()
          .eq('order_id', id)
          .single();

      return OrderModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch order by id: $e');
    }
  }

  @override
  Future<void> updateOrderStatus(String id, String status) async {
    try {
      await _supabaseClient
          .from('orders')
          .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
          .eq('order_id', id);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  @override
  Future<void> deleteOrder(String id) async {
    try {
      await _supabaseClient
          .from('orders')
          .delete()
          .eq('order_id', id);
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }
}