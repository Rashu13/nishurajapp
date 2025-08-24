import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/utils/api_error_handler.dart';

class AnalyticsApiProvider {
  static Future<Map<String, dynamic>> fetchAnalyticsSummary(String period, {int? userId}) async {
    final dio = Dio();
    final url = ApiConfig.analyticsSummary;
    
    try {
      // Convert period correctly
      String apiPeriod = _convertPeriodToApi(period);
      
      final queryParams = {
        'period': apiPeriod,
      };
      
      // Add userId if provided
      if (userId != null) {
        queryParams['userId'] = userId.toString();
      }
      
      print('📊 Analytics Summary API Call:');
      print('🔗 URL: $url');
      print('📋 Query Params: $queryParams');
      
      final response = await dio.get(url, queryParameters: queryParams);
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Data: ${response.data}');
      
      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic>) {
          return response.data;
        } else {
          print('⚠️ Warning: Expected Map but got ${response.data.runtimeType}');
          throw Exception('Invalid response format: Expected object');
        }
      }
      throw Exception('HTTP ${response.statusCode}: ${response.statusMessage}');
    } catch (e) {
      print('❌ Analytics Summary Error: $e');
      throw Exception(ApiErrorHandler.getErrorMessage(e, context: 'analytics'));
    }
  }

  static Future<List<dynamic>> fetchOrdersServedChart(String period, {int? userId}) async {
    final dio = Dio();
    final url = ApiConfig.ordersServed;
    
    try {
      // Convert period correctly
      String apiPeriod = _convertPeriodToApi(period);
      
      final queryParams = {
        'period': apiPeriod,
      };
      
      // Add userId if provided
      if (userId != null) {
        queryParams['userId'] = userId.toString();
      }
      
      print('📊 Orders Served API Call:');
      print('🔗 URL: $url');
      print('📋 Query Params: $queryParams');
      
      final response = await dio.get(url, queryParameters: queryParams);
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Data: ${response.data}');
      
      if (response.statusCode == 200) {
        if (response.data is List) {
          return response.data;
        } else {
          print('⚠️ Warning: Expected List but got ${response.data.runtimeType}');
          throw Exception('Invalid response format: Expected array');
        }
      }
      throw Exception('HTTP ${response.statusCode}: ${response.statusMessage}');
    } catch (e) {
      print('❌ Orders Served Error: $e');
      throw Exception(ApiErrorHandler.getErrorMessage(e, context: 'analytics'));
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
