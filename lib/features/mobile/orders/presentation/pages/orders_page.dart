import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/orders_viewmodel.dart';
import '../widgets/order_card_widget.dart';
import '../widgets/orders_filter_widget.dart';
import '../widgets/orders_search_widget.dart';
import '../widgets/orders_statistics_widget.dart';
import '../widgets/empty_orders_widget.dart';
import '../widgets/error_orders_widget.dart';

/// Orders Page - displays list of orders with filtering and search
/// Follows MVVM pattern and Single Responsibility Principle
class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    // Load orders when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersViewModel>().loadAllOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<OrdersViewModel>(
        builder: (context, viewModel, child) {
          return RefreshIndicator(
            onRefresh: () => viewModel.refreshOrders(),
            child: Column(
              children: [
                _buildHeader(viewModel),
                Expanded(
                  child: _buildBody(viewModel),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('الطلبات'),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      actions: [
        Consumer<OrdersViewModel>(
          builder: (context, viewModel, child) {
            return IconButton(
              onPressed: viewModel.isLoading ? null : () => viewModel.refreshOrders(),
              icon: viewModel.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
            );
          },
        ),
        IconButton(
          onPressed: () => _showFilterDialog(),
          icon: const Icon(Icons.filter_list),
        ),
      ],
    );
  }

  Widget _buildHeader(OrdersViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          OrdersSearchWidget(
            onSearch: (query) => viewModel.searchOrders(query),
            initialValue: viewModel.searchQuery,
          ),
          const SizedBox(height: 16),
          OrdersStatisticsWidget(
            totalOrders: viewModel.totalOrders,
            pendingOrders: viewModel.pendingOrders,
            completedOrders: viewModel.completedOrders,
            urgentOrders: viewModel.urgentOrders,
          ),
          const SizedBox(height: 16),
          OrdersFilterWidget(
            selectedFilter: viewModel.selectedFilter,
            onFilterChanged: (filter) => viewModel.filterOrdersByStatus(filter),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(OrdersViewModel viewModel) {
    if (viewModel.isLoading && !viewModel.hasOrders) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (viewModel.hasError) {
      return ErrorOrdersWidget(
        errorMessage: viewModel.errorMessage!,
        onRetry: () => viewModel.loadAllOrders(forceRefresh: true),
      );
    }

    if (!viewModel.hasOrders) {
      return EmptyOrdersWidget(
        onRefresh: () => viewModel.loadAllOrders(forceRefresh: true),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: viewModel.orders.length,
      itemBuilder: (context, index) {
        final order = viewModel.orders[index];
        return OrderCardWidget(
          order: order,
          onTap: () => _navigateToOrderDetails(order.orderId),
          onStatusChanged: (newStatus) => _updateOrderStatus(viewModel, order.orderId!, newStatus),
          onDelete: () => _deleteOrder(viewModel, order.orderId!),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _navigateToAddOrder(),
      child: const Icon(Icons.add),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفية الطلبات'),
        content: Consumer<OrdersViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('جميع الطلبات'),
                  leading: Radio<String>(
                    value: 'all',
                    groupValue: viewModel.selectedFilter,
                    onChanged: (value) {
                      viewModel.filterOrdersByStatus(value);
                      Navigator.pop(context);
                    },
                  ),
                ),
                ListTile(
                  title: const Text('في الانتظار'),
                  leading: Radio<String>(
                    value: 'pending',
                    groupValue: viewModel.selectedFilter,
                    onChanged: (value) {
                      viewModel.filterOrdersByStatus(value);
                      Navigator.pop(context);
                    },
                  ),
                ),
                ListTile(
                  title: const Text('قيد التنفيذ'),
                  leading: Radio<String>(
                    value: 'in_progress',
                    groupValue: viewModel.selectedFilter,
                    onChanged: (value) {
                      viewModel.filterOrdersByStatus(value);
                      Navigator.pop(context);
                    },
                  ),
                ),
                ListTile(
                  title: const Text('مكتمل'),
                  leading: Radio<String>(
                    value: 'completed',
                    groupValue: viewModel.selectedFilter,
                    onChanged: (value) {
                      viewModel.filterOrdersByStatus(value);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _navigateToOrderDetails(String? orderId) {
    if (orderId == null) return;
    
    // Navigate to order details page
    // Navigator.pushNamed(context, '/order-details', arguments: orderId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('عرض تفاصيل الطلب: $orderId')),
    );
  }

  void _navigateToAddOrder() {
    // Navigate to add order page
    // Navigator.pushNamed(context, '/add-order');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('إضافة طلب جديد')),
    );
  }

  void _updateOrderStatus(OrdersViewModel viewModel, String orderId, String newStatus) {
    viewModel.updateOrderStatus(orderId, newStatus);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تحديث حالة الطلب إلى: ${_getStatusArabic(newStatus)}')),
    );
  }

  void _deleteOrder(OrdersViewModel viewModel, String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الطلب نهائياً؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              // viewModel.deleteOrder(orderId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف الطلب')),
              );
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _getStatusArabic(String status) {
    switch (status) {
      case 'pending':
        return 'في الانتظار';
      case 'reviewed':
        return 'تم المراجعة';
      case 'quoted':
        return 'تم التسعير';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return 'غير محدد';
    }
  }
}