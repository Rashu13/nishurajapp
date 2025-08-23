import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/utils/api_error_handler.dart';

class OrderStatusApiProvider {
  static Future<List<dynamic>> fetchActiveTableItems() async {
    final dio = Dio();
    final url = ApiConfig.activeTableItems;
    final response = await dio.get(url);
    if (response.statusCode == 200 && response.data is List) {
      return response.data;
    }
    throw Exception(ApiErrorHandler.getErrorMessage('Invalid response', context: 'orders'));
  }

  static Future<bool> deleteKOTItem(String kotdId) async {
    final dio = Dio();
    final url = ApiConfig.deleteSimpleItem;
    
    try {
      // Send just the KOTDID as integer in request body
      final kotdIdInt = int.parse(kotdId);
      
      final response = await dio.post(url, 
        data: kotdIdInt,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => true, // Accept all status codes
        ),
      );
      
      if (response.statusCode == 200) {
        if (response.data is Map && response.data['Success'] == true) {
          return true;
        } else {
          return false;
        }
      } else if (response.statusCode == 404) {
        // Backend endpoint not deployed yet - use temporary local delete
        return true; // Allow local delete for now
      } else {
        return false;
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          // Backend endpoint not deployed yet - allow local delete
          return true;
        }
      }
      // For other errors, still allow local delete temporarily
      return true;
    }
  }

  static Future<bool> updateKOTItemQuantity(String kotdId, double newQuantity) async {
    final dio = Dio();
    final url = ApiConfig.updateItemQty;
    
    try {
      final requestBody = {
        "KOTDID": int.parse(kotdId),
        "NewQty": newQuantity
      };
      
      final response = await dio.post(url, 
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => true, // Accept all status codes
        ),
      );
      
      if (response.statusCode == 200) {
        if (response.data is Map && response.data['Success'] == true) {
          return true;
        } else {
          return false;
        }
      } else if (response.statusCode == 404) {
        // Backend endpoint not deployed yet - use temporary local update
        return true; // Allow local update for now
      } else {
        return false;
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          // Backend endpoint not deployed yet - allow local update
          return true;
        }
      }
      // For other errors, still allow local update temporarily
      return true;
    }
  }
}
