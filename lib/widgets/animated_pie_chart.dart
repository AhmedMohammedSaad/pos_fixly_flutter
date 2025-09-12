import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/chart_data.dart';
import 'dart:math' as math;

class AnimatedPieChart extends StatefulWidget {
  final List<CustomPieChartData> data;
  final String title;
  final double radius;
  final bool showPercentage;
  final bool showLegend;
  final bool enableTouch;
  final double centerSpaceRadius;
  final double height;
  final List<Color>? customColors;

  const AnimatedPieChart({
    Key? key,
    required this.data,
    required this.title,
    this.radius = 100,
    this.showPercentage = true,
    this.showLegend = true,
    this.enableTouch = true,
    this.centerSpaceRadius = 40,
    this.height = 350,
    this.customColors,
  }) : super(key: key);

  @override
  State<AnimatedPieChart> createState() => _AnimatedPieChartState();
}

class _AnimatedPieChartState extends State<AnimatedPieChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _rotationController;
  late Animation<double> _animation;
  late Animation<double> _rotationAnimation;
  int touchedIndex = -1;
  bool isRotating = false;

  // ألوان افتراضية جذابة
  final List<Color> _defaultColors = [
    const Color(0xFF6C5CE7),
    const Color(0xFFA29BFE),
    const Color(0xFF00B894),
    const Color(0xFF00CEC9),
    const Color(0xFFE17055),
    const Color(0xFFFD79A8),
    const Color(0xFFFFD93D),
    const Color(0xFF74B9FF),
    const Color(0xFF81ECEC),
    const Color(0xFFFAB1A0),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          Expanded(
            child: widget.showLegend
                ? Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildPieChart(),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 1,
                        child: _buildLegend(),
                      ),
                    ],
                  )
                : _buildPieChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final totalValue = widget.data.fold<double>(0, (sum, item) => sum + (item as CustomPieChartData).value);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'إجمالي: ${totalValue.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildActionButton(
              icon: isRotating ? Icons.stop : Icons.rotate_right,
              onTap: () {
                if (isRotating) {
                  _rotationController.stop();
                  setState(() {
                    isRotating = false;
                  });
                } else {
                  _rotationController.repeat();
                  setState(() {
                    isRotating = true;
                  });
                }
              },
              color: Colors.purple,
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.refresh,
              onTap: () {
                _animationController.reset();
                _animationController.forward();
                if (isRotating) {
                  _rotationController.stop();
                  setState(() {
                    isRotating = false;
                  });
                }
              },
              color: Colors.blue,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(
          icon,
          size: 16,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return AnimatedBuilder(
      animation: Listenable.merge([_animation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.rotate(
          angle: isRotating ? _rotationAnimation.value : 0,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                enabled: widget.enableTouch,
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: widget.centerSpaceRadius,
              sections: _buildPieSections(),
            ),
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    final colors = widget.customColors ?? _defaultColors;
    
    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = (widget.radius + (isTouched ? 20 : 0)) * _animation.value;
      final color = colors[index % colors.length];

      return PieChartSectionData(
        color: color,
        value: data.value * _animation.value,
        title: widget.showPercentage ? '${data.percentage.toStringAsFixed(1)}%' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
        badgeWidget: isTouched ? _buildBadge(data, color) : null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }

  Widget _buildBadge(CustomPieChartData data, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        data.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    final colors = widget.customColors ?? _defaultColors;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'التفاصيل',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: widget.data.length,
            itemBuilder: (context, index) {
              final data = widget.data[index];
              final color = colors[index % colors.length];
              final isSelected = index == touchedIndex;
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected ? Border.all(color: color, width: 2) : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: const Color(0xFF2D3436),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                data.value.toStringAsFixed(0),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                '${data.percentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Widget مساعد لعرض إحصائيات سريعة
class PieChartSummary extends StatelessWidget {
  final List<CustomPieChartData> data;
  final String title;
  final IconData icon;
  final Color color;

  const PieChartSummary({
    Key? key,
    required this.data,
    required this.title,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalValue = data.fold<double>(0, (sum, item) => sum + (item as CustomPieChartData).value);
    final maxItem = data.isNotEmpty
        ? data.reduce((a, b) => (a as CustomPieChartData).value > (b as CustomPieChartData).value ? a : b)
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'الإجمالي: ${totalValue.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          if (maxItem != null) ...[
            const SizedBox(height: 4),
            Text(
              'الأعلى: ${maxItem.label} (${maxItem.percentage.toStringAsFixed(1)}%)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}