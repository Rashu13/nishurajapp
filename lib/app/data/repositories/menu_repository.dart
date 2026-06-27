import 'package:serv/app/data/models/menu_model.dart';
import '../providers/items_api_provider.dart';

class MenuRepository {
  final ItemsApiProvider _itemsApiProvider = ItemsApiProvider();
  
  Future<List<MenuModel>> getMenuItems() async {
    try {
      return await _itemsApiProvider.getItems();
    } catch (e) {
      throw Exception('Failed to load menu items: $e');
    }
  }

  Future<MenuModel?> getMenuItemById(String id) async {
    try {
      final itemId = int.tryParse(id) ?? 0;
      return await _itemsApiProvider.getItemById(itemId);
    } catch (e) {
      throw Exception('Failed to load menu item: $e');
    }
  }

  Future<List<String>> getCategories() async {
    try {
      // Categories can be derived from menu items if needed
      return [];
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<List<MenuModel>> getMenuItemsByCategory(String category) async {
    try {
      final items = await getMenuItems();
      // Since we don't have category in MenuModel, return all items for now
      return items;
    } catch (e) {
      throw Exception('Failed to load menu items by category: $e');
    }
  }
}
