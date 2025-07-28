import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart' hide Response;

class ApiProvider {
  static const String baseUrl = 'http://192.168.1.6:44351/api'; // Replace with actual API URL
  late Dio _dio;

  ApiProvider() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(milliseconds: 30000),
      receiveTimeout: const Duration(milliseconds: 30000),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  // Menu API calls
  Future<dio.Response> getMenuItems() async {
    try {
      return await _dio.get('/menu');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dio.Response> getMenuItemById(String id) async {
    try {
      return await _dio.get('/menu/$id');
    } catch (e) {
      throw _handleError(e); 
    }
  }

  // Order API calls
  Future<dio.Response> createOrder(Map<String, dynamic> orderData) async {
    try {
      return await _dio.post('/orders', data: orderData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dio.Response> getOrderById(String orderId) async {
    try {
      return await _dio.get('/orders/$orderId');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dio.Response> getOrders() async {
    try {
      return await _dio.get('/orders');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dio.Response> updateOrderStatus(String orderId, String status) async {
    try {
      return await _dio.patch('/orders/$orderId/status', data: {'status': status});
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is dio.DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout. Please try again.';
        case DioExceptionType.badResponse:
          return error.response?.data['message'] ?? 'Server error occurred.';
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        case DioExceptionType.unknown:
          return 'Network error. Please check your connection.';
        default:
          return 'An unexpected error occurred.';
      }
    }
    return error.toString();
  }
}
