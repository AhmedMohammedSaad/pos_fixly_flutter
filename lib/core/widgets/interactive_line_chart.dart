import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/chart_data.dart';

class InteractiveLineChart extends StatefulWidget {
  final List<ChartData> data;
  final String title;
  final Color primaryColor;
  final Color gradientStartColor;
  final Color gradientEndColor;
  final bool showGrid;
  final bool showTooltip;
  final double height;
  final String yAxisLabel;
  final String xAxisLabel;

  const InteractiveLineChart({
    Key? key,
    required this.data,
    required this.title,
    this.primaryColor = const Color(0xFF6C5CE7),
    this.gradientStartColor = const Color(0xFF6C5CE7),
    this.gradientEndColor = const Color(0xFFA29BFE),
    this.showGrid = true,
    this.showTooltip = true,
    this.height = 300,
    this.yAxisLabel = 'القيمة',
    this.xAxisLabel = 'التاريخ',
  }) : super(key: key);

  @override
  State<InteractiveLineChart> createState() => _InteractiveLineChartState();
}

class _InteractiveLineChartState extends State<InteractiveLineChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int touchedIndex = -1;
  bool showAverage = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          Expanded(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return LineChart(
                  _buildLineChartData(),
                  duration: const Duration(milliseconds: 250),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
              'إجمالي النقاط: ${widget.data.length}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildActionButton(
              icon: showAverage ? Icons.show_chart : Icons.trending_up,
              onTap: () {
                setState(() {
                  showAverage = !showAverage;
                });
              },
              color: widget.primaryColor,
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.refresh,
              onTap: () {
                _animationController.reset();
                _animationController.forward();
              },
              color: Colors.orange,
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

  LineChartData _buildLineChartData() {
    final spots = widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return FlSpot(index.toDouble(), data.value * _animation.value);
    }).toList();

    final averageValue = widget.data.isNotEmpty
        ? widget.data.map((e) => e.value).reduce((a, b) => a + b) /
            widget.data.length
        : 0.0;

    return LineChartData(
      gridData: FlGridData(
        show: widget.showGrid,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < widget.data.length) {
                final date = widget.data[index].date;
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    '${date.day}/${date.month}',
                    style: const TextStyle(
                      color: Color(0xFF636E72),
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                    ),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(
                  color: Color(0xFF636E72),
                  fontWeight: FontWeight.w400,
                  fontSize: 10,
                ),
              );
            },
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      minX: 0,
      maxX: widget.data.length.toDouble() - 1,
      minY: widget.data.isNotEmpty
          ? widget.data.map((e) => e.value).reduce((a, b) => a < b ? a : b) - 1
          : 0,
      maxY: widget.data.isNotEmpty
          ? widget.data.map((e) => e.value).reduce((a, b) => a > b ? a : b) + 1
          : 10,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              widget.gradientStartColor,
              widget.gradientEndColor,
            ],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: touchedIndex == index ? 6 : 4,
                color: widget.primaryColor,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                widget.gradientStartColor.withOpacity(0.3),
                widget.gradientEndColor.withOpacity(0.1),
              ],
            ),
          ),
        ),
        if (showAverage)
          LineChartBarData(
            spots: List.generate(
              widget.data.length,
              (index) => FlSpot(index.toDouble(), averageValue),
            ),
            isCurved: false,
            color: Colors.orange,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            dashArray: [5, 5],
          ),
      ],
      lineTouchData: LineTouchData(
        enabled: widget.showTooltip,
        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
          setState(() {
            if (touchResponse != null &&
                touchResponse.lineBarSpots != null &&
                touchResponse.lineBarSpots!.isNotEmpty) {
              touchedIndex = touchResponse.lineBarSpots!.first.spotIndex;
            } else {
              touchedIndex = -1;
            }
          });
        },
        getTouchedSpotIndicator:
            (LineChartBarData barData, List<int> spotIndexes) {
          return spotIndexes.map((spotIndex) {
            return TouchedSpotIndicatorData(
              FlLine(
                color: widget.primaryColor.withOpacity(0.8),
                strokeWidth: 2,
                dashArray: [3, 3],
              ),
              FlDotData(
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 8,
                    color: widget.primaryColor,
                    strokeWidth: 3,
                    strokeColor: Colors.white,
                  );
                },
              ),
            );
          }).toList();
        },
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: widget.primaryColor.withOpacity(0.9),
          tooltipRoundedRadius: 8,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final flSpot = barSpot;
              final index = flSpot.x.toInt();
              if (index >= 0 && index < widget.data.length) {
                final data = widget.data[index];
                return LineTooltipItem(
                  '${data.date.day}/${data.date.month}/${data.date.year}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(
                      text:
                          '${widget.yAxisLabel}: ${data.value.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                );
              }
              return null;
            }).toList();
          },
        ),
      ),
    );
  }
}
