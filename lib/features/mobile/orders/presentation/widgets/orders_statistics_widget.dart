import 'package:flutter/material.dart';

/// Statistics widget for orders
/// Follows Single Responsibility Principle
class OrdersStatisticsWidget extends StatelessWidget {
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final int urgentOrders;

  const OrdersStatisticsWidget({
    super.key,
    required this.totalOrders,
    required this.pendingOrders,
    required this.completedOrders,
    required this.urgentOrders,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'المجموع',
              totalOrders.toString(),
              Colors.blue,
              Icons.list_alt,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'في الانتظار',
              pendingOrders.toString(),
              Colors.orange,
              Icons.pending_actions,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'مكتمل',
              completedOrders.toString(),
              Colors.green,
              Icons.check_circle,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'عاجل',
              urgentOrders.toString(),
              Colors.red,
              Icons.priority_high,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        // Container(
        //   padding: const EdgeInsets.all(8),
        //   decoration: BoxDecoration(
        //     color: color.withOpacity(0.1),
        //     borderRadius: BorderRadius.circular(8),
        //   ),
        //   child: Icon(
        //     icon,
        //     color: color,
        //     size: 20,
        //   ),
        // ),
        // const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
