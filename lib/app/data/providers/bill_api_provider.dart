import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/utils/api_error_handler.dart';

class BillApiProvider {
  static Future<List<dynamic>> fetchTableBillSummary() async {
    final dio = Dio();
    final url = ApiConfig.individualTableBills;
    
    try {
      final response = await dio.get(url);
      
      if (response.statusCode == 200 && response.data is List) {
        return response.data;
      }
      throw Exception(ApiErrorHandler.getErrorMessage('Invalid response format', context: 'bills'));
    } catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e, context: 'bills'));
    }
  }

  static Future<bool> resetTable(int tableId) async {
    final dio = Dio();
    final url = ApiConfig.resetTable;
    
    try {
      final response = await dio.post(url, 
        data: {'tableId': tableId},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        // Handle both boolean and object responses
        if (response.data is bool) {
          return response.data;
        } else if (response.data is Map) {
          return response.data['Success'] == true || response.data['success'] == true;
        }
        return true; // Success if status 200
      }
      return false;
    } catch (e) {
      // Don't throw exception for better UX, just return false
      return false;
    }
  }

  static Future<List<dynamic>> fetchTableBillItems(String tableName) async {
    final dio = Dio();
    
    try {
      // Only use the existing active items endpoint
      final activeUrl = ApiConfig.activeTableItems;
      
      final response = await dio.get(activeUrl);
      
      if (response.statusCode == 200 && response.data is List) {
        final allItems = response.data as List;
        final tableItems = allItems.where((item) {
          return item['TableName'] == tableName;
        }).toList();
        
        return tableItems;
      }
      
      throw Exception(ApiErrorHandler.getErrorMessage('Invalid response format', context: 'orders'));
      
    } catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e, context: 'orders'));
    }
  }
}
