import 'package:flutter/material.dart';

/// نموذج بيانات للرسوم البيانية الخطية
class ChartData {
  final DateTime date;
  final double value;
  final String? label;
  final Color? color;

  ChartData({
    required this.date,
    required this.value,
    this.label,
    this.color,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      date: DateTime.parse(json['date']),
      value: json['value'].toDouble(),
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
      'label': label,
    };
  }
}

/// نموذج بيانات للرسوم البيانية الشمعية (Candlestick)
class CandlestickData {
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final double? volume;
  final String? symbol;

  CandlestickData({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.volume,
    this.symbol,
  });

  factory CandlestickData.fromJson(Map<String, dynamic> json) {
    return CandlestickData(
      date: DateTime.parse(json['date']),
      open: json['open'].toDouble(),
      high: json['high'].toDouble(),
      low: json['low'].toDouble(),
      close: json['close'].toDouble(),
      volume: json['volume']?.toDouble(),
      symbol: json['symbol'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
      'symbol': symbol,
    };
  }

  /// تحديد لون الشمعة (أخضر للصعود، أحمر للهبوط)
  Color get candleColor {
    return close >= open ? Colors.green : Colors.red;
  }

  /// تحديد ما إذا كانت الشمعة صاعدة أم هابطة
  bool get isBullish => close >= open;
}

/// نموذج بيانات للرسوم البيانية الدائرية
class CustomPieChartData {
  final String label;
  final double value;
  final Color color;
  final double percentage;

  CustomPieChartData({
    required this.label,
    required this.value,
    required this.color,
    required this.percentage,
  });

  factory CustomPieChartData.fromJson(Map<String, dynamic> json) {
    return CustomPieChartData(
      label: json['label'],
      value: json['value'].toDouble(),
      color: Color(json['color']),
      percentage: json['percentage'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'color': color.value,
      'percentage': percentage,
    };
  }
}

/// نموذج بيانات للإحصائيات العامة
class StatisticsData {
  final String title;
  final double currentValue;
  final double previousValue;
  final String unit;
  final IconData icon;
  final Color color;
  final List<ChartData> trendData;

  StatisticsData({
    required this.title,
    required this.currentValue,
    required this.previousValue,
    required this.unit,
    required this.icon,
    required this.color,
    required this.trendData,
  });

  /// حساب نسبة التغيير
  double get changePercentage {
    if (previousValue == 0) return 0;
    return ((currentValue - previousValue) / previousValue) * 100;
  }

  /// تحديد ما إذا كان التغيير إيجابي أم سلبي
  bool get isPositiveChange => changePercentage >= 0;

  /// لون التغيير (أخضر للإيجابي، أحمر للسلبي)
  Color get changeColor => isPositiveChange ? Colors.green : Colors.red;

  /// أيقونة التغيير
  IconData get changeIcon => isPositiveChange ? Icons.trending_up : Icons.trending_down;
}