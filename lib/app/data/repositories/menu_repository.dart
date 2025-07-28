import 'package:serv/app/data/models/menu_model.dart';
import '../providers/dummy_data_provider.dart';
import '../providers/items_api_provider.dart';

class MenuRepository {
  final ItemsApiProvider _itemsApiProvider = ItemsApiProvider();
  
  Future<List<MenuModel>> getMenuItems() async {
    try {
      // Try to get items from API first
      return await _itemsApiProvider.getItems();
    } catch (e) {
      print('API failed, falling back to dummy data: ${e.toString()}');
      // Fallback to dummy data if API fails
      try {
        final dummyItems = await DummyDataProvider.getMenuItems();
        // Convert dummy data to new format
        return dummyItems.map((item) => MenuModel(
          itemId: int.tryParse(item.id) ?? 0,
          itemName: item.name,
          restrorate: item.price.toString(),
          status: true,
          
        )).toList();
      } catch (dummyError) {
        throw Exception('Failed to load menu items: $e');
      }
    }
  }

  Future<MenuModel?> getMenuItemById(String id) async {
    try {
      final itemId = int.tryParse(id) ?? 0;
      return await _itemsApiProvider.getItemById(itemId);
    } catch (e) {
      // Fallback to dummy data
      try {
        final dummyItem = await DummyDataProvider.getMenuItemById(id);
        if (dummyItem != null) {
          return MenuModel(
            itemId: int.tryParse(dummyItem.id) ?? 0,
            itemName: dummyItem.name,
            restrorate: dummyItem.price.toString(),
            status: true,
          );
        }
        return null;
      } catch (dummyError) {
        throw Exception('Failed to load menu item: $e');
      }
    }
  }

  Future<List<String>> getCategories() async {
    try {
      return await DummyDataProvider.getCategories();
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
