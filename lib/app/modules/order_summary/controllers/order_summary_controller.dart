import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/menu_item.dart';

class OrderSummaryController extends GetxController {
  var tableNumber = '01'.obs;
  var orderItems = <Map<String, dynamic>>[].obs;
  var remarkText = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Get order items from arguments or cart
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      orderItems.value = List<Map<String, dynamic>>.from(args['items'] ?? []);
      tableNumber.value = args['tableNumber'] ?? '01';
    }
  }
  
  double get totalAmount {
    return orderItems.fold(0.0, (sum, item) {
      final MenuItem menuItem = item['item'] as MenuItem;
      final int quantity = item['quantity'] as int;
      return sum + (menuItem.price * quantity);
    });
  }
  
  void updateTableNumber(String number) {
    tableNumber.value = number;
  }
  
  void updateRemark(String text) {
    remarkText.value = text;
  }
  
  void removeItem(int index) {
    orderItems.removeAt(index);
  }
  
  void updateQuantity(int index, int newQuantity) {
    if (newQuantity > 0) {
      orderItems[index]['quantity'] = newQuantity;
      orderItems.refresh();
    } else {
      removeItem(index);
    }
  }
  
  void sendToKitchen() {
    if (orderItems.isEmpty) {
      Get.snackbar('Error', 'No items in order');
      return;
    }
    
    // Show order sent confirmation dialog
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Kitchen icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  size: 40,
                  color: Color(0xFFFF6B35),
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'Order Send to Kitchen',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'Order has been sent at 1:45 pm',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6C757D),
                ),
              ),
              
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                    Get.back(); // Go back to previous screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back to Homepage',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
