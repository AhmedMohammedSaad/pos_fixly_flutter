import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/orders_viewmodel.dart';
import '../widgets/orders_data_table.dart';
import '../widgets/orders_statistics_card.dart';
import '../widgets/orders_filter_bar.dart';
import '../widgets/orders_search_bar.dart';

/// Orders page for web feature
/// Follows MVVM pattern and Single Responsibility Principle
class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersViewModel>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<OrdersViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              // Header
              _buildHeader(viewModel),
              
              // Statistics Cards
              _buildStatisticsSection(viewModel),
              
              // Filters and Search
              _buildFiltersSection(viewModel),
              
              // Data Table
              Expanded(
                child: _buildDataTableSection(viewModel),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(OrdersViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'إدارة الطلبات',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          
          // Export Button
          ElevatedButton.icon(
            onPressed: viewModel.isLoading ? null : () => _exportOrders(viewModel),
            icon: const Icon(Icons.download),
            label: const Text('تصدير'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Refresh Button
          ElevatedButton.icon(
            onPressed: viewModel.isLoading ? null : () => viewModel.refresh(),
            icon: viewModel.isLoading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: const Text('تحديث'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(OrdersViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: OrdersStatisticsCard(
        totalOrders: viewModel.totalOrders,
        pendingOrders: viewModel.pendingOrders,
        completedOrders: viewModel.completedOrders,
        urgentOrders: viewModel.urgentOrders,
        overdueOrders: viewModel.overdueOrders,
      ),
    );
  }

  Widget _buildFiltersSection(OrdersViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          OrdersSearchBar(
            searchQuery: viewModel.searchQuery,
            onSearchChanged: viewModel.searchOrders,
          ),
          
          const SizedBox(height: 16),
          
          // Filter Bar
          OrdersFilterBar(
            selectedFilter: viewModel.selectedFilter,
            onFilterChanged: viewModel.filterByStatus,
            sortBy: viewModel.sortBy,
            sortAscending: viewModel.sortAscending,
            onSortChanged: viewModel.sortOrders,
            onClearFilters: viewModel.clearFilters,
          ),
        ],
      ),
    );
  }

  Widget _buildDataTableSection(OrdersViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              viewModel.errorMessage!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.red[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.refresh(),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(24),
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
      child: OrdersDataTable(
        orders: viewModel.orders,
        sortBy: viewModel.sortBy,
        sortAscending: viewModel.sortAscending,
        onSort: viewModel.sortOrders,
      ),
    );
  }

  Future<void> _exportOrders(OrdersViewModel viewModel) async {
    try {
      final csvData = await viewModel.exportOrders();
      if (csvData != null) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تصدير الطلبات بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في تصدير الطلبات: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}