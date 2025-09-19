import 'package:flutter/material.dart';

/// Search widget for orders
/// Follows Single Responsibility Principle
class OrdersSearchWidget extends StatefulWidget {
  final Function(String) onSearch;
  final String initialValue;

  const OrdersSearchWidget({
    super.key,
    required this.onSearch,
    this.initialValue = '',
  });

  @override
  State<OrdersSearchWidget> createState() => _OrdersSearchWidgetState();
}

class _OrdersSearchWidgetState extends State<OrdersSearchWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'البحث في الطلبات...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _controller.clear();
                  widget.onSearch('');
                },
                icon: const Icon(Icons.clear),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      onChanged: widget.onSearch,
      textInputAction: TextInputAction.search,
    );
  }
}