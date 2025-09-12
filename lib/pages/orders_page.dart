import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/order_cubit.dart';
import '../cubit/order_state.dart';
import '../models/order_model.dart';
import '../widgets/order_card.dart';
import 'order_details_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().fetchAllOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterOrders(String? status) {
    setState(() {
      _selectedFilter = status ?? 'all';
    });
    context.read<OrderCubit>().fetchOrdersByStatus(status);
  }

  void _searchOrders(String query) {
    if (query.isEmpty) {
      context.read<OrderCubit>().fetchAllOrders();
    } else {
      context.read<OrderCubit>().searchOrders(query);
    }
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _isRefreshing = true;
    });
    
    try {
      await context.read<OrderCubit>().fetchAllOrders(forceRefresh: true);
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
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
        content: Text('هل أنت متأكد من حذف هذا الطلب نهائياً؟'),
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

  void _clearAllOrders() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد مسح قاعدة البيانات'),
        content: Text(
            'هل أنت متأكد من مسح جميع الطلبات نهائياً؟ هذا الإجراء لا يمكن التراجع عنه!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<OrderCubit>().clearAllOrders();
              Navigator.pop(context);
            },
            child: Text('مسح الكل',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الطلبات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.blue.withOpacity(0.3),
        actions: [
          IconButton(
            onPressed: _isRefreshing ? null : _refreshOrders,
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'تحديث الطلبات',
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'clear_all') {
                _clearAllOrders();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red),
                    SizedBox(width: 8),
                    Text('مسح قاعدة البيانات',
                        style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث والفلتر
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF1565C0),
                  const Color(0xFF1976D2),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // شريط البحث
                TextField(
                  controller: _searchController,
                  onChanged: _searchOrders,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'البحث في الطلبات...',
                    hintStyle: const TextStyle(fontSize: 16),
                    prefixIcon: const Icon(Icons.search, size: 24),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // فلتر الحالة
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('الكل', 'all'),
                      _buildFilterChip('الحالية', 'current'),
                      _buildFilterChip('في الانتظار', 'pending'),
                      _buildFilterChip('قيد التنفيذ', 'in_progress'),
                      _buildFilterChip('مكتملة', 'completed'),
                      _buildFilterChip('ملغية', 'cancelled'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // قائمة الطلبات
          Expanded(
            child: BlocConsumer<OrderCubit, OrderState>(
              listener: (context, state) {
                // إزالة عرض رسائل الخطأ - سيتم إظهار التحميل بدلاً منها
                // if (state is OrderError) {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(
                //       content: Text(state.message),
                //       backgroundColor: Colors.red,
                //     ),
                //   );
                // }
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
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              builder: (context, state) {
                // معالجة حالات التحميل المختلفة
                if (state is OrderLoading ||
                    state is OrderUpdating ||
                    state is OrderDeleting) {
                  return _buildLoadingGrid();
                }

                if (state is OrdersLoaded) {
                  // تحديد القائمة المناسبة حسب الفلتر المحدد
                  List<Order> ordersToShow;
                  switch (_selectedFilter) {
                    case 'current':
                      ordersToShow = state.currentOrders;
                      break;
                    case 'pending':
                      ordersToShow = state.orders.where((order) => order.status == 'pending' || order.status == null).toList();
                      break;
                    case 'in_progress':
                      ordersToShow = state.orders.where((order) => order.status == 'in_progress').toList();
                      break;
                    case 'completed':
                      ordersToShow = state.completedOrders;
                      break;
                    case 'cancelled':
                      ordersToShow = state.cancelledOrders;
                      break;
                    case 'all':
                    default:
                      ordersToShow = state.orders;
                      break;
                  }
                  return _buildOrdersGrid(ordersToShow);
                }

                if (state is OrderSearchResults) {
                  return _buildOrdersGrid(state.searchResults);
                }

                if (state is OrderError) {
                  // إظهار التحميل بدلاً من رسالة الخطأ
                  return _buildLoadingGrid();
                }

                return const Center(
                  child: Text('لا توجد طلبات'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF1565C0),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) => _filterOrders(value),
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFFFF6F00),
        checkmarkColor: Colors.white,
        elevation: isSelected ? 4 : 2,
        shadowColor: isSelected
            ? Colors.orange.withOpacity(0.4)
            : Colors.grey.withOpacity(0.2),
        side: BorderSide(
          color: isSelected
              ? const Color(0xFFFF6F00)
              : const Color(0xFF1565C0).withOpacity(0.3),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // مؤشر التحميل الرئيسي
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFFFF6F00),
                  ),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'جاري تحميل الطلبات...',
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
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) => _buildSkeletonCard(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard() {
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
            _buildShimmerContainer(
              height: 20,
              width: double.infinity,
            ),
            const SizedBox(height: 12),
            // حالة الطلب
            _buildShimmerContainer(
              height: 16,
              width: 120,
            ),
            const SizedBox(height: 8),
            // تاريخ الطلب
            _buildShimmerContainer(
              height: 16,
              width: 80,
            ),
            const SizedBox(height: 12),
            // أزرار الإجراءات
            Row(
              children: [
                _buildShimmerContainer(
                  height: 32,
                  width: 60,
                ),
                const SizedBox(width: 8),
                _buildShimmerContainer(
                  height: 32,
                  width: 60,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerContainer({
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

  Widget _buildOrdersGrid(List<Order> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد طلبات',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
          return GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.1,
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
                      builder: (context) => OrderDetailsPage(order: order),
                    ),
                  );
                },
                onStatusChanged: (newStatus) =>
                    _updateOrderStatus(order.orderId!, newStatus),
                onDelete: () => _deleteOrder(order.orderId!),
                isGridView: true,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    Color statusColor = _getStatusColor(order.status);
    IconData statusIcon = _getStatusIcon(order.status);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsPage(order: order),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رقم الطلب والحالة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.orderNumber ?? 'بدون رقم',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor),
                    ),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                      size: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // اسم العميل
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.customerName ?? 'غير محدد',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // رقم الهاتف
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.customerPhone ?? 'غير محدد',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // نوع الخدمة
              Row(
                children: [
                  Icon(
                    Icons.build,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.serviceType ?? 'غير محدد',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // تاريخ الإنشاء
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(order.createdAt),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'in_progress':
        return Icons.work;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'غير محدد';
    return '${date.day}/${date.month}/${date.year}';
  }
}
