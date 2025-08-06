import 'package:dio/dio.dart';

class OrderStatusApiProvider {
  static Future<List<dynamic>> fetchActiveTableItems() async {
    final dio = Dio();
    final url = 'http://192.168.1.6:44351/api/kot/active-table-items';
    final response = await dio.get(url);
    if (response.statusCode == 200 && response.data is List) {
      return response.data;
    }
    throw Exception('Failed to fetch active table items');
  }
}
