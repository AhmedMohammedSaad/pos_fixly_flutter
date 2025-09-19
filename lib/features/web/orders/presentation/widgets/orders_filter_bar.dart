import 'package:flutter/material.dart';

/// Filter bar widget for orders in web feature
/// Follows Single Responsibility Principle
class OrdersFilterBar extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final String sortBy;
  final bool sortAscending;
  final Function(String, {bool? ascending}) onSortChanged;
  final VoidCallback onClearFilters;

  const OrdersFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.sortBy,
    required this.sortAscending,
    required this.onSortChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Status Filters
        _buildFilterSection(),
        
        const SizedBox(width: 24),
        
        // Sort Options
        _buildSortSection(),
        
        const Spacer(),
        
        // Clear Filters Button
        TextButton.icon(
          onPressed: onClearFilters,
          icon: const Icon(Icons.clear_all),
          label: const Text('مسح المرشحات'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Row(
      children: [
        Text(
          'تصفية حسب الحالة:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 12),
        Wrap(
          spacing: 8,
          children: [
            _buildFilterChip('all', 'الكل'),
            _buildFilterChip('pending', 'في الانتظار'),
            _buildFilterChip('reviewed', 'تم المراجعة'),
            _buildFilterChip('in_progress', 'قيد التنفيذ'),
            _buildFilterChip('completed', 'مكتمل'),
            _buildFilterChip('cancelled', 'ملغي'),
          ],
        ),
      ],
    );
  }

  Widget _buildSortSection() {
    return Row(
      children: [
        Text(
          'ترتيب حسب:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 12),
        DropdownButton<String>(
          value: sortBy,
          onChanged: (value) {
            if (value != null) {
              onSortChanged(value);
            }
          },
          items: const [
            DropdownMenuItem(
              value: 'createdAt',
              child: Text('تاريخ الإنشاء'),
            ),
            DropdownMenuItem(
              value: 'customerName',
              child: Text('اسم العميل'),
            ),
            DropdownMenuItem(
              value: 'status',
              child: Text('الحالة'),
            ),
            DropdownMenuItem(
              value: 'urgencyLevel',
              child: Text('الأولوية'),
            ),
            DropdownMenuItem(
              value: 'estimatedBudget',
              child: Text('التكلفة المقدرة'),
            ),
          ],
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => onSortChanged(sortBy),
          icon: Icon(
            sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
            size: 20,
          ),
          tooltip: sortAscending ? 'تصاعدي' : 'تنازلي',
        ),
      ],
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
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}