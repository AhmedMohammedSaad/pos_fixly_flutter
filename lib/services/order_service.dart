import '../models/order_model.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  // قائمة الطلبات التجريبية
  final List<Order> _orders = [
    Order(
      orderId: '001',
      orderNumber: 'ORD-2024-001',
      customerName: 'أحمد محمد',
      customerPhone: '01234567890',
      customerAddress: 'شارع النيل، المعادي، القاهرة',
      customerEmail: 'ahmed@example.com',
      serviceType: 'كهرباء',
      problemDescription: 'مشكلة في الإضاءة الرئيسية',
      urgencyLevel: 'high',
      preferredDate: DateTime.now().add(Duration(days: 1)),
      preferredTimeSlot: '10:00 AM - 12:00 PM',
      estimatedBudget: 500.0,
      createdAt: DateTime.now().subtract(Duration(hours: 2)),
      status: 'pending',
    ),
    Order(
      orderId: '002',
      orderNumber: 'ORD-2024-002',
      customerName: 'فاطمة علي',
      customerPhone: '01098765432',
      customerAddress: 'شارع الجامعة، الجيزة',
      customerEmail: 'fatma@example.com',
      serviceType: 'سباكة',
      problemDescription: 'تسريب في الحمام',
      urgencyLevel: 'urgent',
      preferredDate: DateTime.now(),
      preferredTimeSlot: '2:00 PM - 4:00 PM',
      estimatedBudget: 300.0,
      createdAt: DateTime.now().subtract(Duration(hours: 5)),
      status: 'reviewed',
    ),
    Order(
      orderId: '003',
      orderNumber: 'ORD-2024-003',
      customerName: 'محمد حسن',
      customerPhone: '01156789012',
      customerAddress: 'شارع التحرير، وسط البلد، القاهرة',
      customerEmail: 'mohamed@example.com',
      serviceType: 'تكييف',
      problemDescription: 'صيانة دورية للتكييف',
      urgencyLevel: 'medium',
      preferredDate: DateTime.now().add(Duration(days: 3)),
      preferredTimeSlot: '9:00 AM - 11:00 AM',
      estimatedBudget: 200.0,
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      status: 'in_progress',
    ),
    Order(
      orderId: '004',
      orderNumber: 'ORD-2024-004',
      customerName: 'سارة أحمد',
      customerPhone: '01087654321',
      customerAddress: 'شارع الهرم، الجيزة',
      customerEmail: 'sara@example.com',
      serviceType: 'دهان',
      problemDescription: 'دهان غرفة المعيشة',
      urgencyLevel: 'low',
      preferredDate: DateTime.now().add(Duration(days: 7)),
      preferredTimeSlot: '8:00 AM - 5:00 PM',
      estimatedBudget: 1500.0,
      createdAt: DateTime.now().subtract(Duration(days: 2)),
      status: 'completed',
    ),
  ];

  // الحصول على جميع الطلبات
  List<Order> getAllOrders() {
    return List.from(_orders);
  }

  // الحصول على الطلبات حسب الحالة
  List<Order> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // الحصول على طلب بواسطة المعرف
  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.orderId == orderId);
    } catch (e) {
      return null;
    }
  }

  // تحديث حالة الطلب
  bool updateOrderStatus(String orderId, String newStatus) {
    final orderIndex = _orders.indexWhere((order) => order.orderId == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex] = _orders[orderIndex].copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      return true;
    }
    return false;
  }

  // حذف طلب
  bool deleteOrder(String orderId) {
    final orderIndex = _orders.indexWhere((order) => order.orderId == orderId);
    if (orderIndex != -1) {
      _orders.removeAt(orderIndex);
      return true;
    }
    return false;
  }

  // إضافة طلب جديد
  void addOrder(Order order) {
    _orders.add(order);
  }

  // الحصول على إحصائيات الطلبات
  Map<String, int> getOrdersStatistics() {
    final stats = <String, int>{
      'total': _orders.length,
      'pending': 0,
      'reviewed': 0,
      'quoted': 0,
      'in_progress': 0,
      'completed': 0,
      'cancelled': 0,
    };

    for (final order in _orders) {
      final status = order.status ?? 'pending';
      stats[status] = (stats[status] ?? 0) + 1;
    }

    return stats;
  }

  // البحث في الطلبات
  List<Order> searchOrders(String query) {
    if (query.isEmpty) return getAllOrders();
    
    return _orders.where((order) {
      return (order.customerName?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
             (order.orderNumber?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
             (order.customerPhone?.contains(query) ?? false) ||
             (order.serviceType?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }
}