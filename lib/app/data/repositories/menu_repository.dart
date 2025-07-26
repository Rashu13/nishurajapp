import '../models/menu_item.dart';
import '../providers/dummy_data_provider.dart';

class MenuRepository {
  Future<List<MenuItem>> getMenuItems() async {
    try {
      return await DummyDataProvider.getMenuItems();
    } catch (e) {
      throw Exception('Failed to load menu items: $e');
    }
  }

  Future<MenuItem?> getMenuItemById(String id) async {
    try {
      return await DummyDataProvider.getMenuItemById(id);
    } catch (e) {
      throw Exception('Failed to load menu item: $e');
    }
  }

  Future<List<String>> getCategories() async {
    try {
      return await DummyDataProvider.getCategories();
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<List<MenuItem>> getMenuItemsByCategory(String category) async {
    try {
      return await DummyDataProvider.getMenuItemsByCategory(category);
    } catch (e) {
      throw Exception('Failed to load menu items by category: $e');
    }
  }
}
