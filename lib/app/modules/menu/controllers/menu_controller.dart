import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/menu_model.dart';
import '../../../data/repositories/menu_repository.dart';
import '../../../routes/app_routes.dart';

class MenuPageController extends GetxController {
  final MenuRepository _menuRepository = MenuRepository();
  
  var isLoading = false.obs;
  var menuItems = <MenuModel>[].obs;
  var cartItems = <MenuModel, int>{}.obs;
  var selectedCategory = 'Starters'.obs;
  var isVegFilter = true.obs;
  var isNonVegFilter = false.obs;
  var tableNumber = '01'.obs;

  final List<String> categories = ['Bar', 'Starters', 'Soup', 'Bread'];

  @override
  void onInit() {
    super.onInit();
    loadMenuItems();
  }

  void loadMenuItems() async {
    try {
      isLoading.value = true;
      final items = await _menuRepository.getMenuItems();
      menuItems.value = items;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load menu items');
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    // Here you can filter items based on category if needed
  }

  void toggleVegFilter(bool value) {
    isVegFilter.value = value;
    // Apply filter logic here
  }

  void toggleNonVegFilter(bool value) {
    isNonVegFilter.value = value;
    // Apply filter logic here
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
    Get.snackbar(
      'Added to Cart',
      '${item.itemName} added to cart',
      duration: const Duration(seconds: 1),
      snackPosition: SnackPosition.BOTTOM,
    );
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
    return total;
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
      final customizations = result['customizations'] as List<String>;
      
      // Add customized item to cart
      if (cartItems.containsKey(customizedItem)) {
        cartItems[customizedItem] = cartItems[customizedItem]! + quantity;
      } else {
        cartItems[customizedItem] = quantity;
      }
      cartItems.refresh();
      
      Get.snackbar(
        'Added to Cart',
        '${customizedItem.itemName} with customizations added to cart',
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.BOTTOM,
      );
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
