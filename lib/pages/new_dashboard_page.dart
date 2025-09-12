import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import '../cubit/order_cubit.dart';
import '../cubit/order_state.dart';
import '../widgets/statistics_card.dart';
import '../widgets/interactive_line_chart.dart';
import '../widgets/trading_candlestick_chart.dart';
import '../widgets/animated_pie_chart.dart';
import '../models/chart_data.dart';

class NewDashboardPage extends StatefulWidget {
  const NewDashboardPage({super.key});

  @override
  State<NewDashboardPage> createState() => _NewDashboardPageState();
}

class _NewDashboardPageState extends State<NewDashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    context.read<OrderCubit>().fetchAllOrders();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    context.read<OrderCubit>().fetchAllOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: BlocBuilder<OrderCubit, OrderState>(
            builder: (context, state) {
              if (state is OrderLoading) {
                return _buildLoadingDashboard();
              }

              if (state is OrdersLoaded) {
                return _buildDashboardContent(state);
              }

              if (state is OrderError) {
                return _buildLoadingDashboard(); // إظهار التحميل بدلاً من الخطأ
              }

              return _buildEmptyState();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingDashboard() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(height: 16),
          Text(
            'جاري تحميل البيانات...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ في تحميل البيانات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<OrderCubit>().fetchAllOrders();
              context.read<OrderCubit>().fetchOrderStatistics();
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_outlined,
            size: 64,
            color: Colors.white70,
          ),
          SizedBox(height: 16),
          Text(
            'مرحباً بك في لوحة التحكم',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(OrdersLoaded state) {
    final totalOrders = state.orders.length;
    final currentOrders = state.currentOrders.length;
    final completedOrders = state.completedOrders.length;
    final cancelledOrders = state.cancelledOrders.length;

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صف واحد للإحصائيات والطلبات
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الإحصائيات - نصف العرض
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildStatisticsCards(
                        totalOrders,
                        currentOrders,
                        completedOrders,
                        cancelledOrders,
                      ),
                      const SizedBox(height: 24),
                      // الرسم البياني الدائري
                      _buildChartSection(
                        totalOrders,
                        currentOrders,
                        completedOrders,
                        cancelledOrders,
                      ),
                      const SizedBox(height: 24),
                      // الرسم البياني الشريطي
                      _buildBarChart(
                        currentOrders,
                        completedOrders,
                        cancelledOrders,
                      ),
                      const SizedBox(height: 24),
                      // الرسم البياني الخطي التفاعلي
                      _buildInteractiveLineChart(),
                      const SizedBox(height: 24),
                      // الرسم البياني الشمعي للتداول
                      _buildTradingCandlestickChart(),
                      const SizedBox(height: 24),
                      // الرسم البياني الدائري المطور
                      _buildAdvancedPieChart(
                        totalOrders,
                        currentOrders,
                        completedOrders,
                        cancelledOrders,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // الطلبات - نصف العرض
                Expanded(
                  flex: 1,
                  child: _buildRecentOrders(state.orders.take(100).toList()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(
    int total,
    int current,
    int completed,
    int cancelled,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Text(
              'إحصائيات الطلبات',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.4,
            children: [
              _buildEnhancedStatCard(
                'إجمالي الطلبات',
                total.toString(),
                const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                ),
                Icons.receipt_long_outlined,
                Colors.blue.shade50,
              ),
              _buildEnhancedStatCard(
                'الطلبات الحالية',
                current.toString(),
                const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                ),
                Icons.pending_actions_outlined,
                Colors.orange.shade50,
              ),
              _buildEnhancedStatCard(
                'الطلبات المكتملة',
                completed.toString(),
                const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                Icons.check_circle_outline,
                Colors.green.shade50,
              ),
              _buildEnhancedStatCard(
                'الطلبات الملغية',
                cancelled.toString(),
                const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                ),
                Icons.cancel_outlined,
                Colors.red.shade50,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatCard(
    String title,
    String value,
    LinearGradient gradient,
    IconData icon,
    Color backgroundColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: gradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: gradient.colors.first,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(
    int total,
    int current,
    int completed,
    int cancelled,
  ) {
    if (total == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF8FAFC)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Text(
              'توزيع الطلبات',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              // الرسم البياني الدائري
              Expanded(
                flex: 2,
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: PieChartPainter(
                      current: current,
                      completed: completed,
                      cancelled: cancelled,
                      total: total,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // المفاتيح
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem(
                      'الحالية',
                      const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                      ),
                      current,
                      total,
                      Icons.access_time,
                    ),
                    const SizedBox(height: 12),
                    _buildLegendItem(
                      'المكتملة',
                      const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                      ),
                      completed,
                      total,
                      Icons.check_circle,
                    ),
                    const SizedBox(height: 12),
                    _buildLegendItem(
                      'الملغية',
                      const LinearGradient(
                        colors: [Color(0xFFF44336), Color(0xFFE57373)],
                      ),
                      cancelled,
                      total,
                      Icons.cancel,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    String label,
    LinearGradient gradient,
    int value,
    int total,
    IconData icon,
  ) {
    final percentage = total > 0 ? (value / total * 100).round() : 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradient.colors.first.withOpacity(0.1),
            gradient.colors.last.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gradient.colors.first.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: gradient.colors.first,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$value ($percentage%)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(
    int current,
    int completed,
    int cancelled,
  ) {
    final maxValue = math.max(math.max(current, completed), cancelled);
    if (maxValue == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF8FAFC)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.green.withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Text(
              'مقارنة الطلبات',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(
                  'الحالية',
                  current,
                  maxValue,
                  const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  Icons.pending_actions,
                ),
                _buildBar(
                  'المكتملة',
                  completed,
                  maxValue,
                  const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  Icons.check_circle,
                ),
                _buildBar(
                  'الملغية',
                  cancelled,
                  maxValue,
                  const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  ),
                  Icons.cancel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(
    String label,
    int value,
    int maxValue,
    LinearGradient gradient,
    IconData icon,
  ) {
    final height = maxValue > 0 ? (value / maxValue * 140).toDouble() : 0.0;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            value.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOutCubic,
          height: height,
          width: 50,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: height > 30
              ? Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: gradient.colors.first.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: gradient.colors.first.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: gradient.colors.first,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOrders(List orders) {
    if (orders.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF8FAFC)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.history,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'آخر الطلبات',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد طلبات حتى الآن',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF8FAFC)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.indigo.withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.history,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'آخر الطلبات',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${orders.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...orders
              .take(5)
              .map((order) => _buildRecentOrderItem(order))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildRecentOrderItem(dynamic order) {
    final statusColor = _getStatusColor(order.status);
    final statusGradient = _getStatusGradient(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor.withOpacity(0.05),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: statusGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _getStatusIcon(order.status),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.orderNumber ?? 'بدون رقم',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.customerName ?? 'غير محدد',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: statusGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              _getStatusText(order.status),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'في الانتظار';
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

  LinearGradient _getStatusGradient(String status) {
    switch (status) {
      case 'pending':
        return const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
        );
      case 'in_progress':
        return const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
        );
      case 'completed':
        return const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
        );
      case 'cancelled':
        return const LinearGradient(
          colors: [Color(0xFFF44336), Color(0xFFE57373)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF9E9E9E), Color(0xFFBDBDBD)],
        );
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.access_time;
      case 'in_progress':
        return Icons.autorenew;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  // دالة لبناء الرسم البياني الخطي التفاعلي
  Widget _buildInteractiveLineChart() {
    // بيانات وهمية للمبيعات اليومية
    final List<ChartData> salesData = [
      ChartData(
          date: DateTime.now().subtract(const Duration(days: 14)), value: 1200),
      ChartData(
          date: DateTime.now().subtract(const Duration(days: 13)), value: 1800),
      ChartData(
          date: DateTime.now().subtract(const Duration(days: 12)), value: 1500),
      ChartData(
          date: DateTime.now().subtract(const Duration(days: 11)), value: 2200),
      ChartData(
          date: DateTime.now().subtract(const Duration(days: 10)), value: 1900),
      ChartData(
          date: DateTime.now().subtract(const Duration(days: 9)), value: 2500),
      ChartData(
          date: DateTime.now().subtract(const Duration(days: 8)), value: 2100),
      ChartData(
          date: DateTime.now().subtract(const Duration(days: 7)), value: 2800),
      ChartData(
          date: DateTime.now().subtract(const Duration(days: 6)), value: 2400),
      ChartData(
          date: DateTime.now().subtract(const Duration(days: 5)), value: 3200),
      ChartData(
          date: DateTime.now().subtract(const Duration(days: 4)), value: 2900),
      ChartData(
          date: DateTime.now().subtract(const Duration(days: 3)), value: 3500),
      ChartData(
          date: DateTime.now().subtract(const Duration(days: 2)), value: 3100),
      ChartData(
          date: DateTime.now().subtract(const Duration(days: 1)), value: 3800),
      ChartData(date: DateTime.now(), value: 3400),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: InteractiveLineChart(
        data: salesData,
        title: 'تطور المبيعات اليومية',
        height: 350,
        showGrid: true,
      ),
    );
  }

  // دالة لبناء الرسم البياني الشمعي للتداول
  Widget _buildTradingCandlestickChart() {
    // بيانات وهمية للشموع
    final List<CandlestickData> candleData = [
      CandlestickData(
        date: DateTime.now().subtract(const Duration(days: 14)),
        open: 1200,
        high: 1350,
        low: 1180,
        close: 1320,
        volume: 15000,
      ),
      CandlestickData(
        date: DateTime.now().subtract(const Duration(days: 13)),
        open: 1320,
        high: 1420,
        low: 1280,
        close: 1380,
        volume: 18000,
      ),
      CandlestickData(
        date: DateTime.now().subtract(const Duration(days: 12)),
        open: 1380,
        high: 1450,
        low: 1350,
        close: 1400,
        volume: 22000,
      ),
      CandlestickData(
        date: DateTime.now().subtract(const Duration(days: 11)),
        open: 1400,
        high: 1480,
        low: 1370,
        close: 1450,
        volume: 19000,
      ),
      CandlestickData(
        date: DateTime.now().subtract(const Duration(days: 10)),
        open: 1450,
        high: 1520,
        low: 1420,
        close: 1480,
        volume: 25000,
      ),
      CandlestickData(
        date: DateTime.now().subtract(const Duration(days: 9)),
        open: 1480,
        high: 1550,
        low: 1460,
        close: 1520,
        volume: 21000,
      ),
      CandlestickData(
        date: DateTime.now().subtract(const Duration(days: 8)),
        open: 1520,
        high: 1580,
        low: 1490,
        close: 1550,
        volume: 28000,
      ),
      CandlestickData(
        date: DateTime.now().subtract(const Duration(days: 7)),
        open: 1550,
        high: 1620,
        low: 1530,
        close: 1590,
        volume: 24000,
      ),
      CandlestickData(
        date: DateTime.now().subtract(const Duration(days: 6)),
        open: 1590,
        high: 1650,
        low: 1560,
        close: 1620,
        volume: 30000,
      ),
      CandlestickData(
        date: DateTime.now().subtract(const Duration(days: 5)),
        open: 1620,
        high: 1680,
        low: 1600,
        close: 1650,
        volume: 26000,
      ),
      CandlestickData(
        date: DateTime.now().subtract(const Duration(days: 4)),
        open: 1650,
        high: 1720,
        low: 1630,
        close: 1690,
        volume: 32000,
      ),
      CandlestickData(
        date: DateTime.now().subtract(const Duration(days: 3)),
        open: 1690,
        high: 1750,
        low: 1670,
        close: 1720,
        volume: 29000,
      ),
      CandlestickData(
        date: DateTime.now().subtract(const Duration(days: 2)),
        open: 1720,
        high: 1780,
        low: 1700,
        close: 1750,
        volume: 35000,
      ),
      CandlestickData(
        date: DateTime.now().subtract(const Duration(days: 1)),
        open: 1750,
        high: 1820,
        low: 1730,
        close: 1800,
        volume: 31000,
      ),
      CandlestickData(
        date: DateTime.now(),
        open: 1800,
        high: 1850,
        low: 1780,
        close: 1830,
        volume: 28000,
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TradingCandlestickChart(
        data: candleData,
        title: 'رسم شمعي لتطور الأسعار',
        height: 400,
        enablePanning: true,
        bullishColor: const Color(0xFF00B894),
        bearishColor: const Color(0xFFE17055),
      ),
    );
  }

  // دالة لبناء الرسم البياني الدائري المطور
  Widget _buildAdvancedPieChart(
    int total,
    int current,
    int completed,
    int cancelled,
  ) {
    if (total == 0) {
      return const SizedBox.shrink();
    }

    final List<CustomPieChartData> pieData = [
      CustomPieChartData(
        label: 'الطلبات الحالية',
        value: current.toDouble(),
        color: const Color(0xFF3B82F6),
        percentage: (current / total) * 100,
      ),
      CustomPieChartData(
        label: 'الطلبات المكتملة',
        value: completed.toDouble(),
        color: const Color(0xFF10B981),
        percentage: (completed / total) * 100,
      ),
      CustomPieChartData(
        label: 'الطلبات الملغية',
        value: cancelled.toDouble(),
        color: const Color(0xFFEF4444),
        percentage: (cancelled / total) * 100,
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          AnimatedPieChart(
            data: pieData,
            title: 'توزيع الطلبات التفاعلي',
            height: 400,
            showPercentage: true,
            showLegend: true,
            centerSpaceRadius: 50,
            customColors: const [
              Color(0xFFF59E0B), // برتقالي للحالية
              Color(0xFF10B981), // أخضر للمكتملة
              Color(0xFFEF4444), // أحمر للملغية
            ],
          ),
          const SizedBox(height: 20),
          // ملخص سريع
          Row(
            children: [
              Expanded(
                child: PieChartSummary(
                  data: pieData,
                  title: 'إجمالي الطلبات',
                  icon: Icons.pie_chart,
                  color: const Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PieChartSummary(
                  data: pieData
                      .where((item) => item.label == 'الطلبات المكتملة')
                      .toList(),
                  title: 'معدل الإنجاز',
                  icon: Icons.trending_up,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final int current;
  final int completed;
  final int cancelled;
  final int total;

  PieChartPainter({
    required this.current,
    required this.completed,
    required this.cancelled,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    final paint = Paint()..style = PaintingStyle.fill;

    double startAngle = -math.pi / 2;

    // رسم قطاع الطلبات الحالية
    if (current > 0) {
      final sweepAngle = (current / total) * 2 * math.pi;
      paint.color = Colors.orange;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    }

    // رسم قطاع الطلبات المكتملة
    if (completed > 0) {
      final sweepAngle = (completed / total) * 2 * math.pi;
      paint.color = Colors.green;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    }

    // رسم قطاع الطلبات الملغية
    if (cancelled > 0) {
      final sweepAngle = (cancelled / total) * 2 * math.pi;
      paint.color = Colors.red;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
