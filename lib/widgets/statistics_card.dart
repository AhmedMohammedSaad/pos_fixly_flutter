import 'package:flutter/material.dart';

class StatisticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;

  const StatisticsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class StatisticsGrid extends StatelessWidget {
  final Map<String, dynamic> statistics;
  final Function(String)? onFilterByStatus;

  const StatisticsGrid({
    Key? key,
    required this.statistics,
    this.onFilterByStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        StatisticsCard(
          title: 'إجمالي الطلبات',
          value: '${statistics['total'] ?? 0}',
          icon: Icons.assignment,
          color: Colors.blue,
          subtitle: 'جميع الطلبات',
        ),
        StatisticsCard(
          title: 'في الانتظار',
          value: '${statistics['pending'] ?? 0}',
          icon: Icons.pending,
          color: Colors.orange,
          subtitle: 'تحتاج مراجعة',
          onTap: onFilterByStatus != null ? () => onFilterByStatus!('pending') : null,
        ),
        StatisticsCard(
          title: 'جاري التنفيذ',
          value: '${statistics['in_progress'] ?? 0}',
          icon: Icons.work,
          color: Colors.indigo,
          subtitle: 'قيد العمل',
          onTap: onFilterByStatus != null ? () => onFilterByStatus!('in_progress') : null,
        ),
        StatisticsCard(
          title: 'مكتملة',
          value: '${statistics['completed'] ?? 0}',
          icon: Icons.check_circle,
          color: Colors.green,
          subtitle: 'تم الانتهاء',
          onTap: onFilterByStatus != null ? () => onFilterByStatus!('completed') : null,
        ),
        StatisticsCard(
          title: 'تم المراجعة',
          value: '${statistics['reviewed'] ?? 0}',
          icon: Icons.rate_review,
          color: Colors.blue[700]!,
          subtitle: 'جاهزة للتسعير',
          onTap: onFilterByStatus != null ? () => onFilterByStatus!('reviewed') : null,
        ),
        StatisticsCard(
          title: 'ملغية',
          value: '${statistics['cancelled'] ?? 0}',
          icon: Icons.cancel,
          color: Colors.red,
          subtitle: 'طلبات ملغية',
          onTap: onFilterByStatus != null ? () => onFilterByStatus!('cancelled') : null,
        ),
      ],
    );
  }
}