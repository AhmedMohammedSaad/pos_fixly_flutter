import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';

/// Remote data source for orders
/// Follows Single Responsibility Principle and Dependency Inversion
abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getAllOrders();
  Future<List<OrderModel>> getOrdersByStatus(String status);
  Future<List<OrderModel>> searchOrders(String query);
  Future<OrderModel> updateOrderStatus(String orderId, String status);
  Future<void> deleteOrder(String orderId);
  Future<Map<String, int>> getOrdersStatistics();
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  OrderRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
  });

  @override
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<List<OrderModel>> getOrdersByStatus(String status) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/orders?status=$status'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders by status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<List<OrderModel>> searchOrders(String query) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/orders/search?q=$query'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<OrderModel> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update order status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<Map<String, int>> getOrdersStatistics() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/orders/statistics'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return json.map((key, value) => MapEntry(key, value as int));
      } else {
        throw Exception('Failed to load statistics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}