import 'package:flutter/material.dart';

/// Statistics card widget for orders in web feature
/// Follows Single Responsibility Principle
class OrdersStatisticsCard extends StatelessWidget {
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final int urgentOrders;
  final int overdueOrders;

  const OrdersStatisticsCard({
    super.key,
    required this.totalOrders,
    required this.pendingOrders,
    required this.completedOrders,
    required this.urgentOrders,
    required this.overdueOrders,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'إجمالي الطلبات',
            totalOrders.toString(),
            Icons.list_alt,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'في الانتظار',
            pendingOrders.toString(),
            Icons.pending_actions,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'مكتملة',
            completedOrders.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'عاجلة',
            urgentOrders.toString(),
            Icons.priority_high,
            Colors.red,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'متأخرة',
            overdueOrders.toString(),
            Icons.schedule,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}