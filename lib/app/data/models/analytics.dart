class AnalyticsSummary {
  final double totalRevenue;
  final int totalOrders;
  final double averageOrderValue;

  AnalyticsSummary({
    required this.totalRevenue,
    required this.totalOrders,
    required this.averageOrderValue,
  });

  factory AnalyticsSummary.fromMap(Map<String, dynamic> map) {
    return AnalyticsSummary(
      totalRevenue: (map['TotalRevenue'] as num?)?.toDouble() ?? 0.0,
      totalOrders: (map['TotalOrders'] as num?)?.toInt() ?? 0,
      averageOrderValue: (map['AverageOrderValue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ChartData {
  final String day;
  final int orders;

  ChartData({
    required this.day,
    required this.orders,
  });

  factory ChartData.fromMap(Map<String, dynamic> map) {
    return ChartData(
      day: map['Day'] ?? '',
      orders: (map['Orders'] as num?)?.toInt() ?? 0,
    );
  }
}
