import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/order_model.dart';
import '../cubit/order_cubit.dart';
import '../cubit/order_state.dart';
import '../widgets/order_card.dart';
import '../widgets/statistics_card.dart';
import 'order_details_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _selectedStatus = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // تحميل البيانات والإحصائيات معاً لتحسين الأداء
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final orderCubit = context.read<OrderCubit>();
    // تحميل البيانات والإحصائيات بشكل متوازي
    await Future.wait([
      orderCubit.fetchAllOrders(),
      orderCubit.fetchOrderStatistics(),
    ]);
  }

  void _filterOrders() {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      context.read<OrderCubit>().searchOrders(query);
    } else {
      // استخدام البيانات المحفوظة إذا كانت متوفرة
      context.read<OrderCubit>().fetchOrdersByStatus(_selectedStatus);
    }
  }

  // إعادة تحديث البيانات
  Future<void> _refreshData() async {
    await context.read<OrderCubit>().fetchAllOrders(forceRefresh: true);
    await context.read<OrderCubit>().fetchOrderStatistics();
  }

  // دالة لحساب عدد الأعمدة حسب عرض الشاشة
  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth > 1200) {
      return 3; // كمبيوتر - 3 أعمدة
    } else if (screenWidth > 600) {
      return 2; // تابلت - عمودين
    } else {
      return 1; // هاتف - عمود واحد
    }
  }

  void _updateOrderStatus(String orderId, String newStatus) {
    context.read<OrderCubit>().updateOrderStatus(orderId, newStatus);
    // إعادة جلب البيانات بعد تحديث الحالة
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<OrderCubit>().fetchAllOrders(forceRefresh: true);
      }
    });
  }

  void _deleteOrder(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف هذا الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<OrderCubit>().deleteOrder(orderId);
              Navigator.pop(context);
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'لوحة تحكم Fixly',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // إحصائيات سريعة
          BlocBuilder<OrderCubit, OrderState>(
            builder: (context, state) {
              Map<String, int> statistics = {
                'total': 0,
                'pending': 0,
                'in_progress': 0,
                'completed': 0
              };

              if (state is OrderStatisticsLoaded) {
                statistics = state.statistics;
              } else if (state is OrdersLoaded) {
                // حساب الإحصائيات من البيانات المحملة لتجنب استعلام إضافي
                final orders = state.orders;
                statistics = {
                  'total': orders.length,
                  'pending': orders
                      .where((order) =>
                          order.status == null || order.status == 'pending')
                      .length,
                  'in_progress': orders
                      .where((order) => order.status == 'in_progress')
                      .length,
                  'completed': orders
                      .where((order) => order.status == 'completed')
                      .length,
                };
              }

              return Container(
                padding: EdgeInsets.all(16),
                color: Colors.blue[50],
                child: Row(
                  children: [
                    Expanded(
                      child: StatisticsCard(
                        title: 'إجمالي الطلبات',
                        value: statistics['total'].toString(),
                        color: Colors.blue,
                        icon: Icons.assignment,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: StatisticsCard(
                        title: 'في الانتظار',
                        value: statistics['pending'].toString(),
                        color: Colors.orange,
                        icon: Icons.pending,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: StatisticsCard(
                        title: 'جاري التنفيذ',
                        value: statistics['in_progress'].toString(),
                        color: Colors.purple,
                        icon: Icons.work,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: StatisticsCard(
                        title: 'مكتمل',
                        value: statistics['completed'].toString(),
                        color: Colors.green,
                        icon: Icons.check_circle,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // شريط البحث والتصفية
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'البحث في الطلبات...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) => _filterOrders(),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: [
                      DropdownMenuItem(
                          value: 'all', child: Text('جميع الحالات')),
                      DropdownMenuItem(
                          value: 'pending', child: Text('في الانتظار')),
                      DropdownMenuItem(
                          value: 'reviewed', child: Text('تم المراجعة')),
                      DropdownMenuItem(
                          value: 'quoted', child: Text('تم التسعير')),
                      DropdownMenuItem(
                          value: 'in_progress', child: Text('جاري التنفيذ')),
                      DropdownMenuItem(
                          value: 'completed', child: Text('مكتمل')),
                      DropdownMenuItem(value: 'cancelled', child: Text('ملغي')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                      _filterOrders();
                    },
                  ),
                ),
              ],
            ),
          ),

          // قائمة الطلبات
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: BlocConsumer<OrderCubit, OrderState>(
                listener: (context, state) {
                  if (state is OrderUpdated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم تحديث حالة الطلب بنجاح'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (state is OrderDeleted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم حذف الطلب بنجاح'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  // إزالة عرض رسائل الخطأ - سيتم إظهار التحميل بدلاً منها
                  // else if (state is OrderError) {
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     SnackBar(
                  //       content: Text('خطأ: ${state.message}'),
                  //       backgroundColor: Colors.red,
                  //     ),
                  //   );
                  // }
                },
                builder: (context, state) {
                  if (state is OrderLoading) {
                    return _buildSkeletonLoader();
                  }

                  if (state is OrderError) {
                    // إظهار التحميل بدلاً من رسالة الخطأ
                    return _buildSkeletonLoader();
                  }

                  List<Order> orders = [];
                  if (state is OrdersLoaded) {
                    orders = _selectedStatus == 'all'
                        ? state.orders
                        : state.orders
                            .where((order) => order.status == _selectedStatus)
                            .toList();
                  } else if (state is OrderSearchResults) {
                    orders = _selectedStatus == 'all'
                        ? state.searchResults
                        : state.searchResults
                            .where((order) => order.status == _selectedStatus)
                            .toList();
                  }

                  return orders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'لا توجد طلبات',
                                style:
                                    TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.all(16),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final crossAxisCount =
                                  _getCrossAxisCount(constraints.maxWidth);
                              return GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: orders.length,
                                itemBuilder: (context, index) {
                                  final order = orders[index];
                                  return OrderCard(
                                    order: order,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              OrderDetailsPage(order: order),
                                        ),
                                      );
                                    },
                                    onStatusChanged: (newStatus) =>
                                        _updateOrderStatus(
                                            order.orderId!, newStatus),
                                    onDelete: () =>
                                        _deleteOrder(order.orderId!),
                                  );
                                },
                              );
                            },
                          ),
                        );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Skeleton Loader لتحسين تجربة المستخدم
  Widget _buildSkeletonLoader() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // مؤشر التحميل الرئيسي
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue.shade600,
                  ),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'جاري تحميل البيانات...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // شبكة الكروت الوهمية
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // عنوان الطلب
                            _buildDashboardShimmerContainer(
                              height: 20,
                              width: double.infinity,
                            ),
                            const SizedBox(height: 12),
                            // حالة الطلب
                            _buildDashboardShimmerContainer(
                              height: 16,
                              width: 120,
                            ),
                            const SizedBox(height: 8),
                            // تاريخ الطلب
                            _buildDashboardShimmerContainer(
                              height: 16,
                              width: 80,
                            ),
                            const SizedBox(height: 12),
                            // أزرار الإجراءات
                            Row(
                              children: [
                                _buildDashboardShimmerContainer(
                                  height: 32,
                                  width: 60,
                                ),
                                const SizedBox(width: 8),
                                _buildDashboardShimmerContainer(
                                  height: 32,
                                  width: 60,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardShimmerContainer({
    required double height,
    required double width,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade100,
            Colors.grey.shade300,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildOldSkeletonCard() {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Spacer(),
                Container(
                  width: 60,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 4),
            Container(
              width: 200,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Spacer(),
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
