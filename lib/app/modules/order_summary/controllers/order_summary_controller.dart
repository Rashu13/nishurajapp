import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/menu_model.dart';
import '../../../data/services/bill_service.dart';
import '../../../data/models/table_model.dart';
import '../../../data/repositories/table_repository.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../core/controllers/global_data_controller.dart';

class OrderSummaryController extends GetxController {
  final BillService _billService = BillService();
  
  // NC Billing constants
  static const double NC_BILLING_DISCOUNT_PERCENTAGE = 0.35;
  static const int NC_BILLING_BILL_TYPE = 2;
  
  var tableNumber = '01'.obs;
  var orderItems = <Map<String, dynamic>>[].obs;
  var remarkText = ''.obs;
  var isLoading = false.obs;
  var selectedTable = Rxn<TableModel>();
  
  @override
  void onInit() {
    super.onInit();
    // Get order items from arguments or cart
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      orderItems.value = List<Map<String, dynamic>>.from(args['items'] ?? []);
      tableNumber.value = args['tableNumber'] ?? '01';
      selectedTable.value = args['selectedTable'] as TableModel?;
    }
  }
  
  double get totalAmount {
    final total = orderItems.fold(0.0, (sum, item) {
      final MenuModel menuItem = item['item'] as MenuModel;
      final int quantity = item['quantity'] as int;
      return sum + ((double.tryParse(menuItem.restrorate) ?? 0.0) * quantity);
    });
    return double.parse(total.toStringAsFixed(2));
  }
  
  /// Get discounted total if NC Billing is selected
  double get displayTotal {
    final billType = selectedTable.value?.roomTypeId ?? 1;
    if (billType == NC_BILLING_BILL_TYPE) {
      return double.parse((totalAmount * NC_BILLING_DISCOUNT_PERCENTAGE).toStringAsFixed(2));
    }
    return totalAmount;
  }
  
  /// Get discount amount in rupees
  double get discountAmount {
    final billType = selectedTable.value?.roomTypeId ?? 1;
    if (billType == NC_BILLING_BILL_TYPE) {
      return double.parse((totalAmount - displayTotal).toStringAsFixed(2));
    }
    return 0.0;
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
  
  void sendToKitchen() async {
    if (orderItems.isEmpty) {
      ToastHelper.showError('No items in order');
      return;
    }
    
    try {
      isLoading.value = true;
      
      // Get table ID from selected table or parse from table number
      int tableId = selectedTable.value?.tableId ?? 1;
      
      print('======= SEND TO KITCHEN DEBUG START =======');
      print('🏓 Table ID: $tableId');
      print('📋 Number of items: ${orderItems.length}');
      print('📝 Remarks: ${remarkText.value}');
      print('🍽️ Order Items Details:');
      for (var item in orderItems) {
        print('  - Item: ${(item['item'] as MenuModel).itemName}, Qty: ${item['quantity']}');
      }
      print('🔍 Selected Table Object: ${selectedTable.value?.toJson()}');
      print('🔍 Table Status BEFORE sending: ${selectedTable.value?.status}');
      print('======= CALLING sendBillToKitchen() =======');
      
      // Send bill to kitchen via API
      final result = await _billService.sendBillToKitchen(
        tableId: tableId,
        billType: selectedTable.value?.roomTypeId ?? 1,
        orderItems: orderItems.toList(),
        remarks: remarkText.value,
      );
      
      print('======= RESPONSE RECEIVED =======');
      print('✅ Result: $result');
      
      isLoading.value = false;
      
      print('Kitchen order result: $result');
      
      // Update table status to occupied (false) after successful KOT
      try {
        final tableRepository = Get.find<TableRepository>();
        await tableRepository.updateTableStatus(tableId, false);
        print('✅ Table $tableId status updated to occupied');
      } catch (e) {
        print('⚠️ Failed to update table status: $e');
      }
      
      // Refresh tables globally after successful KOT
      try {
        GlobalDataController.instance.notifyTableUpdate();
        print('🔄 Notified global data controller to refresh tables');
      } catch (e) {
        print('🚨 Failed to notify global controller: $e');
      }
      
      // Show success dialog with API response data
      _showSuccessDialog(
        kotNumber: result['kotNumber'],
        billNumber: result['billNumber'],
        totalAmount: result['totalAmount'],
      );
      
    } catch (e) {
      isLoading.value = false;
      print('Error sending to kitchen: $e');
      ToastHelper.showError('Failed to send order to kitchen: ${e.toString()}');
    }
  }
  
  void _showSuccessDialog({
    required int kotNumber,
    required double totalAmount,
    int? billNumber,
  }) {
    final currentTime = DateTime.now();
    final timeString = "${currentTime.hour}:${currentTime.minute.toString().padLeft(2, '0')} ${currentTime.hour >= 12 ? 'PM' : 'AM'}";
    
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
                'Order Sent to Kitchen',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'KOT#$kotNumber sent at $timeString',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6C757D),
                ),
              ),
              
              if (billNumber != null) 
                Text(
                  'Bill#$billNumber',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6C757D),
                  ),
                ),
              
              const SizedBox(height: 8),
              
              Text(
                'Total Amount: ₹${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3142),
                ),
              ),
              
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                    Get.back(); // Go back to menu
                    Get.back(); // Go back to home
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
