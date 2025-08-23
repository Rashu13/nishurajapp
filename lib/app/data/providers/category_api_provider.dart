import 'package:dio/dio.dart';
import 'package:serv/app/data/models/category_model.dart';
import '../../core/config/api_config.dart';

class CategoryApiProvider {
  late Dio _dio;

  CategoryApiProvider() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.apiBaseUrl,
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

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get('/category');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final List<dynamic> tablesData = data['Tables'] ?? [];

        return tablesData.map((item) => CategoryModel.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  Future<CategoryModel?> getCategoryById(int categoryId) async {
    try {
      final response = await _dio.get('/category/$categoryId');
    
      if (response.statusCode == 200) {
        return CategoryModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
 
}