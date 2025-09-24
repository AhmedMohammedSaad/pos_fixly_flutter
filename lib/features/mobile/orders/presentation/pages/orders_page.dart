import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/orders_viewmodel.dart';
import '../widgets/order_card_widget.dart';
import '../widgets/orders_filter_widget.dart';
import '../widgets/empty_orders_widget.dart';
import '../widgets/error_orders_widget.dart';
// ملاحظة: حذفنا OrdersStatisticsWidget من الشاشة الرئيسية بناءً على طلبك

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _searchInAppBar = false; // بحث داخل الـ AppBar

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersViewModel>().loadAllOrders();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrdersViewModel>();

    return Scaffold(
      appBar: _buildAppBar(vm),
      body: RefreshIndicator.adaptive(
        onRefresh: vm.refreshOrders,
        edgeOffset: 8,
        displacement: 44,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ======= الهيدر: فلترة الحالة فقط =======
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: OrdersFilterWidget(
                  selectedFilter: vm.selectedFilter,
                  onFilterChanged: (filter) => vm.filterOrdersByStatus(filter),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // ======= حالات الصفحة =======
            if (vm.isLoading && !vm.hasOrders)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (vm.hasError && !vm.hasOrders)
              SliverFillRemaining(
                hasScrollBody: false,
                child: ErrorOrdersWidget(
                  errorMessage: vm.errorMessage ?? 'حدث خطأ غير متوقع',
                  onRetry: () => vm.loadAllOrders(forceRefresh: true),
                ),
              )
            else if (!vm.hasOrders)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyOrdersWidget(
                  onRefresh: () => vm.loadAllOrders(forceRefresh: true),
                ),
              )
            else
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                sliver: SliverList.builder(
                  itemCount: vm.orders.length,
                  itemBuilder: (context, index) {
                    final order = vm.orders[index];
                    return OrderCardWidget(
                      order: order,
                      onTap: () => _navigateToOrderDetails(order.orderId),
                      onStatusChanged: (newStatus) =>
                          _updateOrderStatus(vm, order.orderId!, newStatus),
                      onDelete: () => _confirmDelete(vm, order.orderId!),
                    );
                  },
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  // ================= AppBar =================
  PreferredSizeWidget _buildAppBar(OrdersViewModel vm) {
    return AppBar(
      centerTitle: true,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _searchInAppBar
            ? _AppBarSearchField(
                key: const ValueKey('search-open'),
                controller: _searchController,
                initialValue: vm.searchQuery,
                onChanged: vm.searchOrders,
                onClose: () {
                  setState(() => _searchInAppBar = false);
                  _searchController.clear();
                  vm.clearFilters(); // يرجّع All ويعيد التحميل
                },
              )
            : const Text('الطلبات', key: ValueKey('title')),
      ),
      // لا يوجد refresh أو filter — الاعتماد على السحب للتحديث وفلتر الحالة أعلى القائمة
      actions: [
        if (!_searchInAppBar)
          IconButton(
            tooltip: 'بحث',
            onPressed: () => setState(() => _searchInAppBar = true),
            icon: const Icon(Icons.search),
          ),
        PopupMenuButton<int>(
          tooltip: 'قائمة',
          itemBuilder: (context) => [
            // ملخص سريع داخل المينيو فقط (اختياري)
            PopupMenuItem<int>(
              enabled: false,
              child: _StatsPopup(
                total: vm.totalOrders,
                pending: vm.pendingOrders,
                completed: vm.completedOrders,
                urgent: vm.urgentOrders,
                overdue: vm.overdueOrders,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ================= Bottom Bar =================
  Widget _buildBottomBar() {
    return BottomAppBar(
      elevation: 8,
      shape: const AutomaticNotchedShape(
        RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        StadiumBorder(),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _navigateToAddOrder,
            icon: const Icon(Icons.add),
            label: const Text('إضافة طلب'),
          ),
        ),
      ),
    );
  }

  // ================= Actions =================
  void _navigateToOrderDetails(String? orderId) {
    if (orderId == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('عرض تفاصيل الطلب: $orderId')),
    );
  }

  void _navigateToAddOrder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('إضافة طلب جديد')),
    );
  }

  void _updateOrderStatus(
      OrdersViewModel vm, String orderId, String newStatus) {
    vm.updateOrderStatus(orderId, newStatus);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تحديث الحالة إلى: ${_statusAr(newStatus)}')),
    );
  }

  void _confirmDelete(OrdersViewModel vm, String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الطلب نهائياً؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              // vm.deleteOrder(orderId);
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

  String _statusAr(String status) {
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

// ====== حقل البحث داخل الـ AppBar ======
class _AppBarSearchField extends StatelessWidget {
  const _AppBarSearchField({
    super.key,
    required this.controller,
    required this.initialValue,
    required this.onChanged,
    required this.onClose,
  });

  final TextEditingController controller;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    if (controller.text != initialValue) {
      controller.text = initialValue;
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }

    return Row(
      children: [
        const Icon(Icons.search, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'ابحث برقم الطلب / العميل / الخدمة…',
              border: InputBorder.none,
              isDense: true,
            ),
            onChanged: onChanged,
          ),
        ),
        IconButton(
          tooltip: 'إغلاق',
          onPressed: onClose,
          icon: const Icon(Icons.close),
        )
      ],
    );
  }
}

// ====== كونتينر ملخص سريع داخل قائمة الثلاث نقاط (يظل فقط داخل المينيو) ======
class _StatsPopup extends StatelessWidget {
  const _StatsPopup({
    required this.total,
    required this.pending,
    required this.completed,
    required this.urgent,
    required this.overdue,
  });

  final int total;
  final int pending;
  final int completed;
  final int urgent;
  final int overdue;

  @override
  Widget build(BuildContext context) {
    final chips = <_StatChip>[
      _StatChip(label: 'الإجمالي', value: total, color: Colors.blueGrey),
      _StatChip(label: 'في الانتظار', value: pending, color: Colors.orange),
      _StatChip(label: 'مكتمل', value: completed, color: Colors.green),
      _StatChip(label: 'عاجل', value: urgent, color: Colors.red),
      _StatChip(label: 'متأخر', value: overdue, color: Colors.purple),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ملخص سريع', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final MaterialColor color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color.shade800,
              )),
          Text('$value',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color.shade800,
              )),
        ],
      ),
    );
  }
}
