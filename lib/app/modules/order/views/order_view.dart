import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:serv/app/global/widgets/loader.dart';
import '../controllers/order_controller.dart';
import '../../../data/models/menu_model.dart';

class OrderView extends GetView<OrderController> {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OrderController());
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3142)),
        ),
        title: const Text(
          'Your Order',
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.cartItems.isEmpty) {
          return const Center(
            child: Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF6C757D),
              ),
            ),
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order items
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Items',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...controller.cartItems.entries.map((entry) {
                        return _buildOrderItem(entry.key, entry.value);
                      }),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Customer details
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        onChanged: (value) => controller.customerName.value = value,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        onChanged: (value) => controller.customerPhone.value = value,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Bill summary
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bill Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildBillRow('Subtotal', '₹${controller.subtotal.toInt()}'),
                      _buildBillRow('Delivery Fee', '₹${controller.deliveryFee.toInt()}'),
                      _buildBillRow('Taxes', '₹${controller.taxes.toInt()}'),
                      const Divider(),
                      _buildBillRow(
                        'Total',
                        '₹${controller.totalAmount.toInt()}',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.placeOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B35),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: controller.isLoading.value
              ? const LoaderCircle()
              : Text(
                  'Place Order • ₹${controller.totalAmount.toInt()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      )),
    );
  }

  Widget _buildOrderItem(MenuModel item, int quantity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.fastfood,
              size: 30,
              color: Color(0xFFFF6B35),
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                Text(
                  '₹${(double.tryParse(item.restrorate) ?? 0.0).toInt()}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6C757D),
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFFF6B35)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => controller.updateQuantity(item, quantity - 1),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.remove,
                      size: 16,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    quantity.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.updateQuantity(item, quantity + 1),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.add,
                      size: 16,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? const Color(0xFF2D3142) : const Color(0xFF6C757D),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? const Color(0xFFFF6B35) : const Color(0xFF2D3142),
            ),
          ),
        ],
      ),
    );
  }
}
