import 'package:dio/dio.dart';

class BillApiProvider {
  static Future<List<dynamic>> fetchTableBillSummary() async {
    final dio = Dio();
    final url = 'http://192.168.1.6:44351/api/kot/table-bill-summary';
    
    try {
      print('🔥 Fetching table bill summary');
      print('🔥 API URL: $url');
      
      final response = await dio.get(url);
      
      print('🔥 Response status: ${response.statusCode}');
      print('🔥 Response data: ${response.data}');
      
      if (response.statusCode == 200 && response.data is List) {
        return response.data;
      }
      throw Exception('Failed to fetch table bill summary');
    } catch (e) {
      print('❌ Bill API exception: $e');
      throw Exception('Failed to fetch table bill summary: $e');
    }
  }

  static Future<List<dynamic>> fetchTableBillItems(String tableName) async {
    final dio = Dio();
    final url = 'http://192.168.1.6:44351/api/kot/active-table-items';
    
    try {
      print('🔥 Fetching table bill items for: $tableName');
      print('🔥 API URL: $url');
      
      final response = await dio.get(url);
      
      print('🔥 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.data is List) {
        // Filter items for specific table
        final allItems = response.data as List;
        final tableItems = allItems.where((item) {
          return item['TableName'] == tableName;
        }).toList();
        
        print('🔥 Found ${tableItems.length} items for table $tableName');
        return tableItems;
      }
      throw Exception('Failed to fetch table bill items');
    } catch (e) {
      print('❌ Bill items API exception: $e');
      throw Exception('Failed to fetch table bill items: $e');
    }
  }
}
