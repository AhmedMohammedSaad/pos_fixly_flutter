import 'package:flutter/material.dart';

/// Search bar widget for orders in web feature
/// Follows Single Responsibility Principle
class OrdersSearchBar extends StatefulWidget {
  final String searchQuery;
  final Function(String) onSearchChanged;

  const OrdersSearchBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  State<OrdersSearchBar> createState() => _OrdersSearchBarState();
}

class _OrdersSearchBarState extends State<OrdersSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(OrdersSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      _controller.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'البحث في الطلبات (رقم الطلب، اسم العميل، رقم الهاتف...)',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[500],
            size: 20,
          ),
          suffixIcon: widget.searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _controller.clear();
                    widget.onSearchChanged('');
                  },
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[500],
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
}