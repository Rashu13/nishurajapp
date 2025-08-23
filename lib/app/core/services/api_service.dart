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
      requestBody: false, // Don't log request body in production
      responseBody: false, // Don't log response body in production
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
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return Exception('Network timeout. Please check your connection.');
        case DioExceptionType.badResponse:
          return Exception('Server error. Please try again later.');
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
