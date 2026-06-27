import 'package:dio/dio.dart';
import '../config/api_config.dart';

class ApiService {
  late Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors for logging (only technical details, not exposed to users)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true, // Enable to see request body for debugging
      responseBody: true, // Enable to see response body for debugging
      logPrint: (obj) {
        // Custom log function that doesn't expose sensitive data
        print('🔧 API Call: ${obj.toString().replaceAll(RegExp(r'http://[^/]+'), '[SERVER]')}');
      },
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, dynamic data) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, dynamic data) async {
    try {
      final response = await _dio.put(path, data: data);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    // Don't expose technical details to users
    if (error is DioException) {
      // Log detailed error for debugging
      print('🚨 DioException Details:');
      print('  Type: ${error.type}');
      print('  Status Code: ${error.response?.statusCode}');
      print('  Response Data: ${error.response?.data}');
      print('  Response Headers: ${error.response?.headers}');
      print('  Message: ${error.message}');
      
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return Exception('Network timeout. Please check your connection.');
        case DioExceptionType.badResponse:
          // Include server error message if available
          String serverMessage = 'Server error. Please try again later.';
          if (error.response?.data != null) {
            if (error.response!.data is String) {
              serverMessage = 'Server Error: ${error.response!.data}';
            } else if (error.response!.data is Map && error.response!.data['Message'] != null) {
              serverMessage = 'Server Error: ${error.response!.data['Message']}';
            }
          }
          return Exception('${serverMessage} (Status: ${error.response?.statusCode})');
        case DioExceptionType.cancel:
          return Exception('Request was cancelled.');
        case DioExceptionType.connectionError:
          return Exception('No internet connection.');
        default:
          return Exception('Something went wrong. Please try again.');
      }
    }
    return Exception('Something went wrong. Please try again.');
  }
}
