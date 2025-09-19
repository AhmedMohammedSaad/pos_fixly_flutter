import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';

/// Abstract interface for orders remote data source
abstract class OrdersRemoteDataSource {
  Future<List<Order>> getAllOrders();
  Future<List<Order>> getOrdersByStatus(String status);
  Future<List<Order>> searchOrders(String query);
  Future<Order> getOrderById(String orderId);
  Future<Order> updateOrderStatus(String orderId, String status);
  Future<bool> deleteOrder(String orderId);
  Future<String> exportOrdersToCSV();
  Future<Map<String, dynamic>> getOrdersAnalytics();
  Future<List<Order>> getOrdersByDateRange(DateTime startDate, DateTime endDate);
  Future<List<Order>> getOrdersByTechnician(String technicianId);
  Future<List<Order>> getFilteredOrders(Map<String, dynamic> filters);
  Future<List<Order>> getSortedOrders(String sortBy, bool ascending);
  Future<Order> updateOrder(Order order);
  Future<Map<String, int>> getOrdersStatistics();
  Future<List<Order>> getUrgentOrders();
  Future<List<Order>> getOverdueOrders();
  Future<Map<String, int>> getOrdersCountByStatus();
  Future<Map<String, double>> getRevenueAnalytics();
  Future<Order> assignOrderToTechnician(String orderId, String technicianId);
}

/// Implementation of orders remote data source
class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  OrdersRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
  });

  @override
  Future<List<Order>> getAllOrders() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> ordersJson = jsonResponse['data'] ?? [];
        
        return ordersJson
            .map((orderJson) => Order.fromJson(orderJson))
            .toList();
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  @override
  Future<List<Order>> getOrdersByStatus(String status) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/orders?status=$status'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> ordersJson = jsonResponse['data'] ?? [];
        
        return ordersJson
            .map((orderJson) => Order.fromJson(orderJson))
            .toList();
      } else {
        throw Exception('Failed to load orders by status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching orders by status: $e');
    }
  }

  @override
  Future<List<Order>> searchOrders(String query) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/orders/search?q=${Uri.encodeComponent(query)}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> ordersJson = jsonResponse['data'] ?? [];
        
        return ordersJson
            .map((orderJson) => Order.fromJson(orderJson))
            .toList();
      } else {
        throw Exception('Failed to search orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching orders: $e');
    }
  }

  @override
  Future<Order> getOrderById(String orderId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/orders/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final Map<String, dynamic> orderJson = jsonResponse['data'];
        
        return Order.fromJson(orderJson);
      } else {
        throw Exception('Failed to load order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching order: $e');
    }
  }

  @override
  Future<Order> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await client.patch(
        Uri.parse('$baseUrl/api/orders/$orderId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final Map<String, dynamic> orderJson = jsonResponse['data'];
        
        return Order.fromJson(orderJson);
      } else {
        throw Exception('Failed to update order status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating order status: $e');
    }
  }

  @override
  Future<bool> deleteOrder(String orderId) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/api/orders/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error deleting order: $e');
    }
  }

  @override
  Future<String> exportOrdersToCSV() async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/orders/export'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'format': 'csv',
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['download_url'] ?? '';
      } else {
        throw Exception('Failed to export orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error exporting orders: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getOrdersAnalytics() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/orders/analytics'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['data'] ?? {};
      } else {
        throw Exception('Failed to load analytics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching analytics: $e');
    }
  }

  @override
  Future<List<Order>> getOrdersByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/orders?start_date=${startDate.toIso8601String()}&end_date=${endDate.toIso8601String()}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> ordersJson = jsonResponse['data'] ?? [];
        
        return ordersJson
            .map((orderJson) => Order.fromJson(orderJson))
            .toList();
      } else {
        throw Exception('Failed to load orders by date range: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching orders by date range: $e');
    }
  }

  @override
  Future<List<Order>> getOrdersByTechnician(String technicianId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/orders/technician/$technicianId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> ordersJson = jsonResponse['data'] ?? [];
        
        return ordersJson
            .map((orderJson) => Order.fromJson(orderJson))
            .toList();
      } else {
        throw Exception('Failed to load orders by technician: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching orders by technician: $e');
    }
  }

  @override
  Future<List<Order>> getFilteredOrders(Map<String, dynamic> filters) async {
    try {
      final queryParams = filters.entries
          .map((entry) => '${entry.key}=${entry.value}')
          .join('&');
      
      final response = await client.get(
        Uri.parse('$baseUrl/api/orders/filter?$queryParams'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> ordersJson = jsonResponse['data'] ?? [];
        
        return ordersJson
            .map((orderJson) => Order.fromJson(orderJson))
            .toList();
      } else {
        throw Exception('Failed to load filtered orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching filtered orders: $e');
    }
  }

  @override
  Future<List<Order>> getSortedOrders(String sortBy, bool ascending) async {
    try {
      final sortOrder = ascending ? 'asc' : 'desc';
      final response = await client.get(
        Uri.parse('$baseUrl/api/orders?sort_by=$sortBy&sort_order=$sortOrder'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> ordersJson = jsonResponse['data'] ?? [];
        
        return ordersJson
            .map((orderJson) => Order.fromJson(orderJson))
            .toList();
      } else {
        throw Exception('Failed to load sorted orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching sorted orders: $e');
    }
  }

  @override
  Future<Order> updateOrder(Order order) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/api/orders/${order.orderId}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(order.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return Order.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Failed to update order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating order: $e');
    }
  }

  @override
  Future<Map<String, int>> getOrdersStatistics() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/orders/statistics'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final Map<String, dynamic> data = jsonResponse['data'] ?? {};
        return data.map((key, value) => MapEntry(key, value as int));
      } else {
        throw Exception('Failed to load orders statistics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching orders statistics: $e');
    }
  }

  @override
  Future<List<Order>> getUrgentOrders() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/orders/urgent'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> ordersJson = jsonResponse['data'] ?? [];
        
        return ordersJson
            .map((orderJson) => Order.fromJson(orderJson))
            .toList();
      } else {
        throw Exception('Failed to load urgent orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching urgent orders: $e');
    }
  }

  @override
  Future<List<Order>> getOverdueOrders() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/orders/overdue'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> ordersJson = jsonResponse['data'] ?? [];
        
        return ordersJson
            .map((orderJson) => Order.fromJson(orderJson))
            .toList();
      } else {
        throw Exception('Failed to load overdue orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching overdue orders: $e');
    }
  }

  @override
  Future<Map<String, int>> getOrdersCountByStatus() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/orders/count-by-status'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final Map<String, dynamic> data = jsonResponse['data'] ?? {};
        return data.map((key, value) => MapEntry(key, value as int));
      } else {
        throw Exception('Failed to load orders count by status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching orders count by status: $e');
    }
  }

  @override
  Future<Map<String, double>> getRevenueAnalytics() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/orders/revenue-analytics'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final Map<String, dynamic> data = jsonResponse['data'] ?? {};
        return data.map((key, value) => MapEntry(key, (value as num).toDouble()));
      } else {
        throw Exception('Failed to load revenue analytics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching revenue analytics: $e');
    }
  }

  @override
  Future<Order> assignOrderToTechnician(String orderId, String technicianId) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/orders/$orderId/assign'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'technician_id': technicianId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return Order.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Failed to assign order to technician: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error assigning order to technician: $e');
    }
  }
}