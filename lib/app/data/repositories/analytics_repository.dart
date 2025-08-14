import '../models/analytics.dart';
import '../providers/analytics_api_provider.dart';

class AnalyticsRepository {
  Future<AnalyticsSummary> getAnalyticsSummary(String period, {int? userId}) async {
    try {
      final data = await AnalyticsApiProvider.fetchAnalyticsSummary(period, userId: userId);
      return AnalyticsSummary.fromMap(data);
    } catch (e) {
      throw Exception('Failed to load analytics summary: $e');
    }
  }

  Future<List<ChartData>> getOrdersServedChart(String period, {int? userId}) async {
    try {
      final data = await AnalyticsApiProvider.fetchOrdersServedChart(period, userId: userId);
      return data.map((item) => ChartData.fromMap(item)).toList();
    } catch (e) {
      throw Exception('Failed to load orders served chart: $e');
    }
  }
}
