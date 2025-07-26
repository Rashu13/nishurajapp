import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/bill.dart';
import '../../../data/repositories/billing_repository.dart';

class BillingController extends GetxController {
  final BillingRepository _repository = BillingRepository();
  
  final Rx<Bill?> bill = Rx<Bill?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isProcessingPayment = false.obs;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments != null && arguments['orderId'] != null) {
      generateBill(arguments['orderId']);
    }
  }

  Future<void> generateBill(String orderId) async {
    try {
      isLoading.value = true;
      final generatedBill = await _repository.generateBill(orderId);
      bill.value = generatedBill;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate bill: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> processPayment(String paymentMethod) async {
    if (bill.value == null) return;
    
    try {
      isProcessingPayment.value = true;
      await _repository.processBillPayment(bill.value!.id, paymentMethod);
      
      Get.snackbar(
        'Success',
        'Payment processed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
      );
      
      // Navigate back to home after successful payment
      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed('/home');
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Payment failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessingPayment.value = false;
    }
  }

  Future<void> printBill() async {
    if (bill.value == null) return;
    
    try {
      await _repository.printBill(bill.value!.id);
      Get.snackbar(
        'Success',
        'Bill sent to printer',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to print bill: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void proceedToPayment() {
    // Show payment options dialog
    Get.dialog(
      AlertDialog(
        title: const Text('Select Payment Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.money, color: Color(0xFF4CAF50)),
              title: const Text('Cash'),
              onTap: () {
                Get.back();
                processPayment('cash');
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card, color: Color(0xFF2196F3)),
              title: const Text('Card'),
              onTap: () {
                Get.back();
                processPayment('card');
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet, color: Color(0xFFFF9800)),
              title: const Text('Digital Wallet'),
              onTap: () {
                Get.back();
                processPayment('wallet');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String formatCurrency(double amount) {
    return '₹${amount.toInt()}';
  }

  String get formattedDate {
    if (bill.value == null) return '';
    final date = bill.value!.createdAt;
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} on ${_getDayName(date.weekday)}, ${date.day} ${_getMonthName(date.month)}';
  }

  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
