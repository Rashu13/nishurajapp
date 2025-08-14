import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/bill.dart';
import '../../../core/utils/toast_helper.dart';

class PaymentMethodController extends GetxController {
  late Bill selectedBill;
  var selectedPaymentMethod = ''.obs;
  
  final List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      id: 'credit_card',
      name: 'Credit Card',
      icon: Icons.credit_card,
    ),
    PaymentMethod(
      id: 'debit_card', 
      name: 'Debit Card',
      icon: Icons.payment,
    ),
    PaymentMethod(
      id: 'wallet',
      name: 'Wallet',
      icon: Icons.wallet,
    ),
    PaymentMethod(
      id: 'cash',
      name: 'Cash',
      icon: Icons.money,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    selectedBill = Get.arguments as Bill;
  }

  void selectPaymentMethod(String methodId) {
    selectedPaymentMethod.value = methodId;
  }

  void sendBillToCounter() {
    if (selectedPaymentMethod.value.isEmpty) {
      ToastHelper.showError('Please select a payment method');
      return;
    }

    // Show bill sent confirmation dialog
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bill icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long,
                  size: 40,
                  color: Color(0xFFFF6B35),
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'Bill Sent to Counter',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'Bill has been sent at 2:45 pm',
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
                    Get.offNamed('/payment_successful', arguments: selectedBill);
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

class PaymentMethod {
  final String id;
  final String name;
  final IconData icon;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
  });
}
