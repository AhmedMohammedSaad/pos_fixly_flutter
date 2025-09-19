import 'package:flutter/material.dart';
import '../../domain/entities/order_entity.dart';

/// Order Card Widget - displays order information in a card format
/// Follows Single Responsibility Principle and Widget composition
class OrderCardWidget extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback? onTap;
  final Function(String)? onStatusChanged;
  final VoidCallback? onDelete;

  const OrderCardWidget({
    super.key,
    required this.order,
    this.onTap,
    this.onStatusChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildCustomerInfo(),
              const SizedBox(height: 12),
              _buildServiceInfo(),
              const SizedBox(height: 12),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.orderNumber ?? 'غير محدد',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              _buildStatusChip(),
            ],
          ),
        ),
        _buildUrgencyIndicator(),
        if (onDelete != null) _buildDeleteButton(),
      ],
    );
  }

  Widget _buildStatusChip() {
    final statusColor = _getStatusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Text(
        order.statusArabic,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildUrgencyIndicator() {
    if (!order.isHighPriority) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getUrgencyColor(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        order.urgencyLevelArabic,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return IconButton(
      onPressed: onDelete,
      icon: const Icon(Icons.delete_outline),
      color: Colors.red,
      iconSize: 20,
    );
  }

  Widget _buildCustomerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          icon: Icons.person_outline,
          label: 'العميل',
          value: order.customerName ?? 'غير محدد',
        ),
        const SizedBox(height: 4),
        _buildInfoRow(
          icon: Icons.phone_outlined,
          label: 'الهاتف',
          value: order.customerPhone ?? 'غير محدد',
        ),
        if (order.customerAddress != null) ...[
          const SizedBox(height: 4),
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: 'العنوان',
            value: order.customerAddress!,
            maxLines: 2,
          ),
        ],
      ],
    );
  }

  Widget _buildServiceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          icon: Icons.build_outlined,
          label: 'نوع الخدمة',
          value: order.serviceType ?? 'غير محدد',
        ),
        if (order.problemDescription != null) ...[
          const SizedBox(height: 4),
          _buildInfoRow(
            icon: Icons.description_outlined,
            label: 'وصف المشكلة',
            value: order.problemDescription!,
            maxLines: 3,
          ),
        ],
        if (order.estimatedBudget != null) ...[
          const SizedBox(height: 4),
          _buildInfoRow(
            icon: Icons.attach_money_outlined,
            label: 'الميزانية المتوقعة',
            value: '${order.estimatedBudget!.toStringAsFixed(0)} جنيه',
          ),
        ],
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Expanded(
          child: _buildDateInfo(),
        ),
        if (onStatusChanged != null) _buildStatusDropdown(),
      ],
    );
  }

  Widget _buildDateInfo() {
    final createdAt = order.createdAt;
    final preferredDate = order.preferredDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (createdAt != null)
          Text(
            'تاريخ الإنشاء: ${_formatDate(createdAt)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        if (preferredDate != null) ...[
          const SizedBox(height: 2),
          Text(
            'التاريخ المفضل: ${_formatDate(preferredDate)}',
            style: TextStyle(
              fontSize: 12,
              color: order.isOverdue ? Colors.red : Colors.grey[600],
              fontWeight: order.isOverdue ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButton<String>(
      value: order.status,
      underline: const SizedBox.shrink(),
      items: [
        'pending',
        'reviewed',
        'quoted',
        'in_progress',
        'completed',
        'cancelled',
      ].map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(
            _getStatusArabic(status),
            style: const TextStyle(fontSize: 12),
          ),
        );
      }).toList(),
      onChanged: (newStatus) {
        if (newStatus != null && onStatusChanged != null) {
          onStatusChanged!(newStatus);
        }
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (order.status) {
      case 'pending':
        return Colors.orange;
      case 'reviewed':
        return Colors.blue;
      case 'quoted':
        return Colors.purple;
      case 'in_progress':
        return Colors.deepOrange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getUrgencyColor() {
    switch (order.urgencyLevel) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      default:
        return Colors.green;
    }
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}