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
      
      final response = await dio.get(url, queryParameters: queryParams);
      
      if (response.statusCode == 200 && response.data is Map) {
        return response.data;
      }
      throw Exception(ApiErrorHandler.getErrorMessage('Invalid response format', context: 'analytics'));
    } catch (e) {
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
      
      final response = await dio.get(url, queryParameters: queryParams);
      
      if (response.statusCode == 200 && response.data is List) {
        return response.data;
      }
      throw Exception(ApiErrorHandler.getErrorMessage('Invalid response format', context: 'analytics'));
    } catch (e) {
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
