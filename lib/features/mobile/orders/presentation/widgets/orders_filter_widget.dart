import 'package:flutter/material.dart';

/// Filter widget for orders
/// Follows Single Responsibility Principle
class OrdersFilterWidget extends StatelessWidget {
  final String selectedFilter;
  final Function(String?) onFilterChanged;

  const OrdersFilterWidget({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('all', 'الكل'),
          const SizedBox(width: 8),
          _buildFilterChip('pending', 'في الانتظار'),
          const SizedBox(width: 8),
          _buildFilterChip('reviewed', 'تم المراجعة'),
          const SizedBox(width: 8),
          _buildFilterChip('in_progress', 'قيد التنفيذ'),
          const SizedBox(width: 8),
          _buildFilterChip('completed', 'مكتمل'),
          const SizedBox(width: 8),
          _buildFilterChip('cancelled', 'ملغي'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = selectedFilter == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        onFilterChanged(selected ? value : 'all');
      },
      selectedColor: Colors.blue.withOpacity(0.2),
      checkmarkColor: Colors.blue,
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}