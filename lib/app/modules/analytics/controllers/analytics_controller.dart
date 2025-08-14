import 'package:get/get.dart';
import '../../../data/repositories/analytics_repository.dart';
import '../../../data/models/analytics.dart';
import '../../../core/utils/toast_helper.dart';

class AnalyticsController extends GetxController {
  final AnalyticsRepository _repository = AnalyticsRepository();
  
  var selectedPeriod = 'This Week'.obs;
  var totalRevenue = 0.0.obs;
  var totalOrders = 0.obs;
  var averageOrderValue = 0.0.obs;
  var isLoading = false.obs;
  
  final List<String> periods = ['This Week', 'This Month', 'This Year'];
  
  // Chart data for orders served
  var ordersServedData = <ChartData>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAnalyticsData();
  }
  
  void changePeriod(String period) {
    selectedPeriod.value = period;
    loadAnalyticsData();
  }
  
  Future<void> loadAnalyticsData() async {
    try {
      isLoading.value = true;
      
      // Use the selected period directly - API provider will handle conversion
      String period = selectedPeriod.value;
      
      // For now, using userId = 1 as seen in your Postman test
      // You can modify this to get from login session or user preferences
      int userId = 1;
      
      print('🔥 Loading analytics for period: $period with userId: $userId');
      
      // Load summary data
      final summary = await _repository.getAnalyticsSummary(period, userId: userId);
      totalRevenue.value = summary.totalRevenue;
      totalOrders.value = summary.totalOrders;
      averageOrderValue.value = summary.averageOrderValue;
      
      print('✅ Summary loaded: Revenue=${summary.totalRevenue}, Orders=${summary.totalOrders}');
      
      // Load chart data
      final chartData = await _repository.getOrdersServedChart(period, userId: userId);
      ordersServedData.assignAll(chartData);
      
      print('✅ Chart data loaded: ${chartData.length} items');
      
    } catch (e) {
      print('❌ Analytics loading error: $e');
      ToastHelper.showError('Failed to load analytics data: ${e.toString()}');
      
      // Fallback to dummy data if API fails
      _loadDummyData();
    } finally {
      isLoading.value = false;
    }
  }
  
  void _loadDummyData() {
    // Fallback dummy data based on selected period
    switch (selectedPeriod.value) {
      case 'This Week':
        totalRevenue.value = 15420.0;
        totalOrders.value = 156;
        averageOrderValue.value = 98.85;
        ordersServedData.assignAll([
          ChartData(day: 'Mon', orders: 12),
          ChartData(day: 'Tue', orders: 18),
          ChartData(day: 'Wed', orders: 25),
          ChartData(day: 'Thu', orders: 15),
          ChartData(day: 'Fri', orders: 30),
          ChartData(day: 'Sat', orders: 35),
          ChartData(day: 'Sun', orders: 22),
        ]);
        break;
      case 'This Month':
        totalRevenue.value = 67800.0;
        totalOrders.value = 680;
        averageOrderValue.value = 99.70;
        ordersServedData.assignAll([
          ChartData(day: 'Mon', orders: 95),
          ChartData(day: 'Tue', orders: 88),
          ChartData(day: 'Wed', orders: 102),
          ChartData(day: 'Thu', orders: 76),
          ChartData(day: 'Fri', orders: 115),
          ChartData(day: 'Sat', orders: 125),
          ChartData(day: 'Sun', orders: 79),
        ]);
        break;
      case 'This Year':
        totalRevenue.value = 812400.0;
        totalOrders.value = 8200;
        averageOrderValue.value = 99.07;
        ordersServedData.assignAll([
          ChartData(day: 'Mon', orders: 1150),
          ChartData(day: 'Tue', orders: 1050),
          ChartData(day: 'Wed', orders: 1250),
          ChartData(day: 'Thu', orders: 950),
          ChartData(day: 'Fri', orders: 1450),
          ChartData(day: 'Sat', orders: 1550),
          ChartData(day: 'Sun', orders: 800),
        ]);
        break;
    }
  }
}
