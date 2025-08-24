import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/menu_model.dart';
import '../../../data/models/table_model.dart';
import '../../../data/repositories/menu_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../core/controllers/global_data_controller.dart';

class MenuPageController extends GetxController {
  final MenuRepository _menuRepository = MenuRepository();
  
  var isLoading = false.obs;
  var menuItems = <MenuModel>[].obs;
  var cartItems = <MenuModel, int>{}.obs;
  var selectedCategory = 'Starters'.obs;
  var isVegFilter = true.obs;
  var isNonVegFilter = false.obs;
  var tableNumber = '1'.obs;
  var selectedTable = Rxn<TableModel>();
  var searchQuery = ''.obs;
  var allMenuItems = <MenuModel>[].obs;

  final List<String> categories = ['Bar', 'Starters', 'Soup', 'Bread'];

  @override
  void onInit() {
    super.onInit();
    // Get table from arguments if passed
    final TableModel? table = Get.arguments as TableModel?;
    print('MenuPageController: Received table argument: $table');
    if (table != null) {
      selectedTable.value = table;
      tableNumber.value = table.tableName;
      print('MenuPageController: Set table number to: ${table.tableName}');
      
      // Mark table as occupied when entering menu (booking logic)
      _markTableAsOccupied(table);
    } else {
      print('MenuPageController: No table argument received, using default table number');
    }
    loadMenuItems();
  }

  void _markTableAsOccupied(TableModel table) {
    try {
      // Notify global controller to refresh tables
      GlobalDataController.instance.notifyTableUpdate();
      print('🔄 MenuController: Marked table ${table.tableName} as occupied');
    } catch (e) {
      print('🚨 MenuController: Failed to mark table as occupied: $e');
    }
  }

  void loadMenuItems() async {
    try {
      isLoading.value = true;
      final items = await _menuRepository.getMenuItems();
      allMenuItems.value = items;
      filterMenuItems();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load menu items');
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    filterMenuItems();
  }

  void filterMenuItems() {
    var filteredItems = allMenuItems.where((item) {
      // Search filter
      bool matchesSearch = searchQuery.value.isEmpty ||
          item.itemName.toLowerCase().contains(searchQuery.value.toLowerCase());
      
      return matchesSearch;
    }).toList();
    
    menuItems.value = filteredItems;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    filterMenuItems();
  }

  void clearSearch() {
    searchQuery.value = '';
    filterMenuItems();
  }

  void toggleVegFilter(bool value) {
    isVegFilter.value = value;
    filterMenuItems();
  }

  void toggleNonVegFilter(bool value) {
    isNonVegFilter.value = value;
    filterMenuItems();
  }

  void changeTable(String tableNo) {
    tableNumber.value = tableNo;
  }

  void addToCart(MenuModel item) {
    if (cartItems.containsKey(item)) {
      cartItems[item] = cartItems[item]! + 1;
    } else {
      cartItems[item] = 1;
    }
    cartItems.refresh();
    // Get.snackbar(
    //   'Added to Cart',
    //   '${item.itemName} added to cart',
    //   duration: const Duration(seconds: 1),
    //   snackPosition: SnackPosition.BOTTOM,
    // );
  }

  void removeFromCart(MenuModel item) {
    if (cartItems.containsKey(item)) {
      if (cartItems[item]! > 1) {
        cartItems[item] = cartItems[item]! - 1;
      } else {
        cartItems.remove(item);
      }
      cartItems.refresh();
    }
  }

  int getItemQuantity(MenuModel item) {
    return cartItems[item] ?? 0;
  }

  double get totalAmount {
    double total = 0;
    cartItems.forEach((item, quantity) {
      total += (double.tryParse(item.restrorate) ?? 0.0) * quantity;
    });
    return double.parse(total.toStringAsFixed(2));
  }

  void navigateToMenuItem(MenuModel item) {
    Get.toNamed(AppRoutes.MENU_DETAIL, arguments: item);
  }

  void addToCartWithCustomization(MenuModel item) async {
    // Navigate to customization screen
    final result = await Get.toNamed(AppRoutes.CUSTOMIZATION, arguments: item);
    
    if (result != null && result is Map<String, dynamic>) {
      final customizedItem = result['item'] as MenuModel;
      final quantity = result['quantity'] as int;
      // final customizations = result['customizations'] as List<String>; // Not used currently
      
      // Add customized item to cart
      if (cartItems.containsKey(customizedItem)) {
        cartItems[customizedItem] = cartItems[customizedItem]! + quantity;
      } else {
        cartItems[customizedItem] = quantity;
      }
      cartItems.refresh();
      
      // Get.snackbar(
      //   'Added to Cart',
      //   '${customizedItem.itemName} with customizations added to cart',
      //   duration: const Duration(seconds: 1),
      //   snackPosition: SnackPosition.BOTTOM,
      // );
    }
  }

  void proceedToOrder() {
    if (cartItems.isNotEmpty) {
      // Convert cart items to order format
      List<Map<String, dynamic>> orderItems = cartItems.entries.map((entry) {
        return {
          'item': entry.key,
          'quantity': entry.value,
          'customizations': <String>[], // Empty for now, can be extended
        };
      }).toList();
      
      // Navigate to order summary
      Get.toNamed(AppRoutes.ORDER_SUMMARY, arguments: {
        'items': orderItems,
        'tableNumber': tableNumber.value,
        'selectedTable': selectedTable.value,
      });
    }
  }

  void proceedToOrderOld() {
    if (cartItems.isNotEmpty) {
      // Show options to either view order or proceed to billing
      Get.dialog(
        AlertDialog(
          title: const Text('Proceed with Order'),
          content: const Text('What would you like to do with your order?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                Get.toNamed(AppRoutes.ORDER, arguments: cartItems);
              },
              child: const Text('View Order'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.toNamed(AppRoutes.BILLING, arguments: {'orderId': 'order_123'});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
              ),
              child: const Text(
                'Generate Bill',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
  }

  void clearCart() {
    cartItems.clear();
  }
}
