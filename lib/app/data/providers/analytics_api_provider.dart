import 'package:dio/dio.dart';

class AnalyticsApiProvider {
  static Future<Map<String, dynamic>> fetchAnalyticsSummary(String period, {int? userId}) async {
    final dio = Dio();
    final url = 'http://192.168.1.6:44351/api/kot/analytics/summary';
    
    try {
      print('🔥 Fetching analytics summary for period: $period');
      print('🔥 API URL: $url');
      
      // Convert period correctly
      String apiPeriod = _convertPeriodToApi(period);
      
      final queryParams = {
        'period': apiPeriod,
      };
      
      // Add userId if provided
      if (userId != null) {
        queryParams['userId'] = userId.toString();
      }
      
      print('🔥 Query params: $queryParams');
      print('🔥 Final URL: $url?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}');
      
      final response = await dio.get(url, queryParameters: queryParams);
      
      print('🔥 Response status: ${response.statusCode}');
      print('🔥 Response data: ${response.data}');
      
      if (response.statusCode == 200 && response.data is Map) {
        return response.data;
      }
      throw Exception('Failed to fetch analytics summary - Status: ${response.statusCode}');
    } catch (e) {
      print('❌ Analytics summary API exception: $e');
      if (e is DioException) {
        print('❌ DioException type: ${e.type}');
        print('❌ DioException message: ${e.message}');
        if (e.response != null) {
          print('❌ Response status: ${e.response?.statusCode}');
          print('❌ Response data: ${e.response?.data}');
        }
      }
      rethrow;
    }
  }

  static Future<List<dynamic>> fetchOrdersServedChart(String period, {int? userId}) async {
    final dio = Dio();
    final url = 'http://192.168.1.6:44351/api/kot/analytics/orders-served';
    
    try {
      print('🔥 Fetching orders served chart for period: $period');
      print('🔥 API URL: $url');
      
      // Convert period correctly
      String apiPeriod = _convertPeriodToApi(period);
      
      final queryParams = {
        'period': apiPeriod,
      };
      
      // Add userId if provided
      if (userId != null) {
        queryParams['userId'] = userId.toString();
      }
      
      print('🔥 Query params: $queryParams');
      print('🔥 Final URL: $url?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}');
      
      final response = await dio.get(url, queryParameters: queryParams);
      
      print('🔥 Response status: ${response.statusCode}');
      print('🔥 Response data: ${response.data}');
      
      if (response.statusCode == 200 && response.data is List) {
        return response.data;
      }
      throw Exception('Failed to fetch orders served chart - Status: ${response.statusCode}');
    } catch (e) {
      print('❌ Orders served chart API exception: $e');
      if (e is DioException) {
        print('❌ DioException type: ${e.type}');
        print('❌ DioException message: ${e.message}');
        if (e.response != null) {
          print('❌ Response status: ${e.response?.statusCode}');
          print('❌ Response data: ${e.response?.data}');
        }
      }
      rethrow;
    }
  }

  // Helper method to convert period to API format
  static String _convertPeriodToApi(String period) {
    switch (period.toLowerCase()) {
      case 'this week':
        return 'week';
      case 'this month':
        return 'month';
      case 'this year':
        return 'year';
      default:
        // Remove 'this ' and convert to lowercase
        return period.toLowerCase().replaceAll('this ', '');
    }
  }
}
