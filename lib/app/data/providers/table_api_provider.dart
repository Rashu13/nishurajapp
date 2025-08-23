import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart' hide Response;
import '../models/table_model.dart';
import '../../core/config/api_config.dart';

class TableApiProvider {
  late Dio _dio;

  TableApiProvider() {
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

  // Get tables with pagination
  Future<List<TableModel>> getTables({int page = 1, int pageSize = 12}) async {
    try {
      final response = await _dio.get('/tables', queryParameters: {
        'page': page,
        'pageSize': pageSize,
      });
      
      if (response.statusCode == 200) {
        final data = response.data['Tables'] as List<dynamic>;
        return data.map((json) => TableModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch tables: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is dio.DioException) {
        print('DioError: ${e.toString()}');
        // Return dummy data for demo purposes - you can remove this in production
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.unknown) {
          return _getDummyTables();
        }
      }
      print('Error fetching tables: ${e.toString()}');
      throw Exception('Failed to fetch tables: ${e.toString()}');
    }
  }

  // Get single table details
  Future<TableModel?> getTableById(int tableId) async {
    try {
      final response = await _dio.get('/tables/$tableId');
      
      if (response.statusCode == 200) {
        return TableModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching table: ${e.toString()}');
      return null;
    }
  }

  // Update table status
  Future<bool> updateTableStatus(int tableId, bool status) async {
    try {
      final response = await _dio.patch('/tables/$tableId', data: {
        'Status': status
      });
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating table status: ${e.toString()}');
      return false;
    }
  }

  // Dummy data for fallback/testing
  List<TableModel> _getDummyTables() {
    return List.generate(
      42,
      (index) => TableModel(
        tableId: 50 + index,
        roomTypeId: 1,
        tableName: _getTableName(index),
        status: index % 3 != 0,  // Every 3rd table is occupied (status=false), rest are available (status=true)
      ),
    );
  }

  // Helper method to generate table names like A1, A2, B1, etc.
  String _getTableName(int index) {
    final section = String.fromCharCode(65 + (index ~/ 6)); // 'A', 'B', 'C', etc.
    final number = (index % 6) + 1; // 1-6
    return '$section$number';
  }
}
