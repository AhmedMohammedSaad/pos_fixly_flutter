import 'package:flutter/material.dart';
import '../../domain/entities/order_entity.dart';

/// Data table widget for orders in web feature
/// Follows Single Responsibility Principle
class OrdersDataTable extends StatelessWidget {
  final List<OrderEntity> orders;
  final String sortBy;
  final bool sortAscending;
  final Function(String, {bool? ascending}) onSort;

  const OrdersDataTable({
    super.key,
    required this.orders,
    required this.sortBy,
    required this.sortAscending,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      child: PaginatedDataTable(
        header: Text(
          'الطلبات (${orders.length})',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        rowsPerPage: 10,
        showCheckboxColumn: false,
        columns: _buildColumns(),
        source: _OrdersDataSource(orders),
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      DataColumn(
        label: const Text('رقم الطلب'),
        onSort: (columnIndex, ascending) => onSort('orderNumber', ascending: ascending),
      ),
      DataColumn(
        label: const Text('اسم العميل'),
        onSort: (columnIndex, ascending) => onSort('customerName', ascending: ascending),
      ),
      DataColumn(
        label: const Text('رقم الهاتف'),
      ),
      DataColumn(
        label: const Text('نوع الخدمة'),
      ),
      DataColumn(
        label: const Text('الحالة'),
        onSort: (columnIndex, ascending) => onSort('status', ascending: ascending),
      ),
      DataColumn(
        label: const Text('الأولوية'),
        onSort: (columnIndex, ascending) => onSort('urgencyLevel', ascending: ascending),
      ),
      DataColumn(
        label: const Text('التكلفة المقدرة'),
        numeric: true,
        onSort: (columnIndex, ascending) => onSort('estimatedBudget', ascending: ascending),
      ),
      DataColumn(
        label: const Text('تاريخ الإنشاء'),
        onSort: (columnIndex, ascending) => onSort('createdAt', ascending: ascending),
      ),
      const DataColumn(
        label: Text('الإجراءات'),
      ),
    ];
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(64),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد طلبات',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'لم يتم العثور على أي طلبات تطابق المعايير المحددة.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersDataSource extends DataTableSource {
  final List<OrderEntity> orders;

  _OrdersDataSource(this.orders);

  @override
  DataRow? getRow(int index) {
    if (index >= orders.length) return null;
    
    final order = orders[index];
    
    return DataRow(
      cells: [
        DataCell(
          Text(
            order.orderNumber ?? 'غير محدد',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(Text(order.customerName ?? 'غير محدد')),
        DataCell(Text(order.customerPhone ?? 'غير محدد')),
        DataCell(Text(order.serviceType ?? 'غير محدد')),
        DataCell(_buildStatusChip(order)),
        DataCell(_buildPriorityChip(order)),
        DataCell(
          Text(
            order.estimatedBudget != null 
                ? '${order.estimatedBudget!.toStringAsFixed(2)} ر.س'
                : 'غير محدد',
          ),
        ),
        DataCell(
          Text(
            order.createdAt != null
                ? '${order.createdAt!.day}/${order.createdAt!.month}/${order.createdAt!.year}'
                : 'غير محدد',
          ),
        ),
        DataCell(_buildActionsMenu(order)),
      ],
    );
  }

  Widget _buildStatusChip(OrderEntity order) {
    Color backgroundColor;
    Color textColor;
    
    switch (order.status) {
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case 'reviewed':
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        break;
      case 'in_progress':
        backgroundColor = Colors.amber.withOpacity(0.1);
        textColor = Colors.amber[700]!;
        break;
      case 'completed':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      case 'cancelled':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        order.statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(OrderEntity order) {
    Color backgroundColor;
    Color textColor;
    
    switch (order.urgencyLevel) {
      case 'high':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
      case 'medium':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case 'low':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        order.priorityText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionsMenu(OrderEntity order) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        // Handle action selection
        switch (value) {
          case 'view':
            // Navigate to order details
            break;
          case 'edit':
            // Navigate to edit order
            break;
          case 'delete':
            // Show delete confirmation
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility, size: 16),
              SizedBox(width: 8),
              Text('عرض'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 16),
              SizedBox(width: 8),
              Text('تعديل'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 16, color: Colors.red),
              SizedBox(width: 8),
              Text('حذف', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => orders.length;

  @override
  int get selectedRowCount => 0;
}