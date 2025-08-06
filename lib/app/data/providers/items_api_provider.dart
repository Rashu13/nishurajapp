import 'package:dio/dio.dart';
import '../models/menu_model.dart';

class ItemsApiProvider {
  static const String baseUrl = 'http://192.168.1.6:44351/api';
  late Dio _dio;

  ItemsApiProvider() {
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

  Future<List<MenuModel>> getItems() async {
    try {
      final response = await _dio.get('/items');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final List<dynamic> itemsData = data['Items'] ?? [];
        
        return itemsData.map((item) => MenuModel.fromJson(item)).toList();
      }
      
      return _getDummyItems();
    } catch (e) {
      return _getDummyItems();
    }
  }

  Future<MenuModel?> getItemById(int itemId) async {
    try {
      final response = await _dio.get('/items/$itemId');
      
      if (response.statusCode == 200) {
        return MenuModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  List<MenuModel> _getDummyItems() {
    return [
      MenuModel(
        itemId: 1,
        itemName: 'Chicken Biryani',
        restrorate: '250',
        status: true,
      ),
      MenuModel(
        itemId: 2,
        itemName: 'Butter Chicken',
        restrorate: '320',
        status: true,
      ),
      MenuModel(
        itemId: 3,
        itemName: 'Paneer Tikka',
        restrorate: '180',
        status: true,
      ),
      MenuModel(
        itemId: 4,
        itemName: 'Dal Tadka',
        restrorate: '120',
        status: true,
      ),
      MenuModel(
        itemId: 5,
        itemName: 'Naan',
        restrorate: '40',
        status: true,
      ),
    ];
  }
}