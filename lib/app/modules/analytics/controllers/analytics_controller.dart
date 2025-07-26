import 'package:get/get.dart';

class AnalyticsController extends GetxController {
  var selectedPeriod = 'This Week'.obs;
  var totalRevenue = 15420.0.obs;
  var totalOrders = 156.obs;
  var averageOrderValue = 98.85.obs;
  
  final List<String> periods = ['This Week', 'This Month', 'This Year'];
  
  // Chart data for orders served
  final List<ChartData> ordersServedData = [
    ChartData('Mon', 12),
    ChartData('Tue', 18),
    ChartData('Wed', 25),
    ChartData('Thu', 15),
    ChartData('Fri', 30),
    ChartData('Sat', 35),
    ChartData('Sun', 22),
  ];
  
  void changePeriod(String period) {
    selectedPeriod.value = period;
    // Update data based on selected period
    updateDataForPeriod(period);
  }
  
  void updateDataForPeriod(String period) {
    switch (period) {
      case 'This Week':
        totalRevenue.value = 15420.0;
        totalOrders.value = 156;
        averageOrderValue.value = 98.85;
        break;
      case 'This Month':
        totalRevenue.value = 67800.0;
        totalOrders.value = 680;
        averageOrderValue.value = 99.70;
        break;
      case 'This Year':
        totalRevenue.value = 812400.0;
        totalOrders.value = 8200;
        averageOrderValue.value = 99.07;
        break;
    }
  }
}

class ChartData {
  final String day;
  final int orders;
  
  ChartData(this.day, this.orders);
}
