import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../models/chart_data.dart';

class TradingCandlestickChart extends StatefulWidget {
  final List<CandlestickData> data;
  final String title;
  final String symbol;
  final bool showVolume;
  final bool enableZooming;
  final bool enablePanning;
  final double height;
  final Color bullishColor;
  final Color bearishColor;

  const TradingCandlestickChart({
    Key? key,
    required this.data,
    required this.title,
    this.symbol = 'SYMBOL',
    this.showVolume = true,
    this.enableZooming = true,
    this.enablePanning = true,
    this.height = 400,
    this.bullishColor = const Color(0xFF00C851),
    this.bearishColor = const Color(0xFFFF4444),
  }) : super(key: key);

  @override
  State<TradingCandlestickChart> createState() =>
      _TradingCandlestickChartState();
}

class _TradingCandlestickChartState extends State<TradingCandlestickChart>
    with TickerProviderStateMixin {
  late TrackballBehavior _trackballBehavior;
  late ZoomPanBehavior _zoomPanBehavior;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool showMovingAverage = false;
  int selectedTimeframe = 0; // 0: 1D, 1: 1W, 2: 1M
  final List<String> timeframes = ['1D', '1W', '1M'];

  @override
  void initState() {
    super.initState();
    _initializeBehaviors();
    _initializeAnimation();
  }

  void _initializeBehaviors() {
    _trackballBehavior = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
      tooltipSettings: const InteractiveTooltip(
        enable: true,
        color: Color(0xFF2D3436),
        textStyle: TextStyle(color: Colors.white, fontSize: 12),
        borderColor: Colors.transparent,
        borderRadius: 8,
      ),
    );

    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: widget.enableZooming,
      enablePanning: widget.enablePanning,
      enableDoubleTapZooming: true,
      enableMouseWheelZooming: true,
      zoomMode: ZoomMode.x,
    );
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A1A),
            const Color(0xFF2D2D2D),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return _buildChart();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final currentPrice = widget.data.isNotEmpty ? widget.data.last.close : 0.0;
    final previousPrice = widget.data.length > 1
        ? widget.data[widget.data.length - 2].close
        : currentPrice;
    final priceChange = currentPrice - previousPrice;
    final priceChangePercent =
        previousPrice != 0 ? (priceChange / previousPrice) * 100 : 0.0;
    final isPositive = priceChange >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.symbol,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${currentPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        color: isPositive
                            ? widget.bullishColor
                            : widget.bearishColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${isPositive ? '+' : ''}${priceChange.toStringAsFixed(2)} (${priceChangePercent.toStringAsFixed(2)}%)',
                        style: TextStyle(
                          color: isPositive
                              ? widget.bullishColor
                              : widget.bearishColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeframeSelector(),
              _buildControlButtons(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: timeframes.asMap().entries.map((entry) {
          final index = entry.key;
          final timeframe = entry.value;
          final isSelected = selectedTimeframe == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedTimeframe = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? widget.bullishColor.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: isSelected
                    ? Border.all(color: widget.bullishColor, width: 1)
                    : null,
              ),
              child: Text(
                timeframe,
                style: TextStyle(
                  color:
                      isSelected ? widget.bullishColor : Colors.grey.shade400,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      children: [
        _buildControlButton(
          icon: showMovingAverage ? Icons.show_chart : Icons.trending_up,
          label: 'MA',
          isActive: showMovingAverage,
          onTap: () {
            setState(() {
              showMovingAverage = !showMovingAverage;
            });
          },
        ),
        const SizedBox(width: 8),
        _buildControlButton(
          icon: Icons.refresh,
          label: 'Reset',
          onTap: () {
            _zoomPanBehavior.reset();
            _animationController.reset();
            _animationController.forward();
          },
        ),
        const SizedBox(width: 8),
        _buildControlButton(
          icon: Icons.fullscreen,
          label: 'Zoom',
          onTap: () {
            setState(() {
              _zoomPanBehavior.reset();
            });
          },
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? widget.bullishColor.withOpacity(0.2)
              : Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(6),
          border: isActive
              ? Border.all(color: widget.bullishColor, width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? widget.bullishColor : Colors.grey.shade400,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? widget.bullishColor : Colors.grey.shade400,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        backgroundColor: Colors.transparent,
        trackballBehavior: _trackballBehavior,
        zoomPanBehavior: _zoomPanBehavior,
        primaryXAxis: DateTimeAxis(
          dateFormat: DateFormat.MMMd(),
          majorGridLines: const MajorGridLines(
            width: 0.5,
            color: Color(0xFF404040),
          ),
          axisLine: const AxisLine(width: 0),
          labelStyle: const TextStyle(
            color: Color(0xFF888888),
            fontSize: 10,
          ),
        ),
        primaryYAxis: NumericAxis(
          opposedPosition: true,
          majorGridLines: const MajorGridLines(
            width: 0.5,
            color: Color(0xFF404040),
          ),
          axisLine: const AxisLine(width: 0),
          labelStyle: const TextStyle(
            color: Color(0xFF888888),
            fontSize: 10,
          ),
          numberFormat: NumberFormat.currency(symbol: '\$', decimalDigits: 2),
        ),
        series: _buildSeries(),
        annotations: _buildAnnotations(),
      ),
    );
  }

  List<CartesianSeries> _buildSeries() {
    final series = <CartesianSeries>[
      CandleSeries<CandlestickData, DateTime>(
        dataSource: widget.data,
        xValueMapper: (CandlestickData data, _) => data.date,
        lowValueMapper: (CandlestickData data, _) => data.low,
        highValueMapper: (CandlestickData data, _) => data.high,
        openValueMapper: (CandlestickData data, _) => data.open,
        closeValueMapper: (CandlestickData data, _) => data.close,
        name: widget.symbol,
        bearColor: widget.bearishColor,
        bullColor: widget.bullishColor,
        enableSolidCandles: true,
        animationDuration: 1200 * _animation.value,
      ),
    ];

    // إضافة المتوسط المتحرك إذا كان مفعلاً
    if (showMovingAverage && widget.data.length > 20) {
      final movingAverageData = _calculateMovingAverage(widget.data, 20);
      series.add(
        LineSeries<ChartData, DateTime>(
          dataSource: movingAverageData,
          xValueMapper: (ChartData data, _) => data.date,
          yValueMapper: (ChartData data, _) => data.value,
          name: 'MA(20)',
          color: Colors.orange,
          width: 2,
          animationDuration: 1200 * _animation.value,
        ),
      );
    }

    return series;
  }

  List<ChartData> _calculateMovingAverage(
      List<CandlestickData> data, int period) {
    final result = <ChartData>[];
    for (int i = period - 1; i < data.length; i++) {
      double sum = 0;
      for (int j = i - period + 1; j <= i; j++) {
        sum += data[j].close;
      }
      result.add(ChartData(
        date: data[i].date,
        value: sum / period,
      ));
    }
    return result;
  }

  List<CartesianChartAnnotation> _buildAnnotations() {
    if (widget.data.isEmpty) return [];

    final highestPoint = widget.data.reduce((a, b) => a.high > b.high ? a : b);
    final lowestPoint = widget.data.reduce((a, b) => a.low < b.low ? a : b);

    return [
      CartesianChartAnnotation(
        widget: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: widget.bullishColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'H: ${highestPoint.high.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        coordinateUnit: CoordinateUnit.point,
        x: highestPoint.date,
        y: highestPoint.high,
      ),
      CartesianChartAnnotation(
        widget: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: widget.bearishColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'L: ${lowestPoint.low.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        coordinateUnit: CoordinateUnit.point,
        x: lowestPoint.date,
        y: lowestPoint.low,
      ),
    ];
  }
}
