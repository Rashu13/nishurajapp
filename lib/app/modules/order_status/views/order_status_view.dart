import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:serv/app/global/widgets/loader.dart';
import '../controllers/order_status_controller.dart';
import '../../../data/models/order_status.dart';
import '../../../widgets/common_bottom_navigation_bar.dart';

class OrderStatusView extends GetView<OrderStatusController> {
  const OrderStatusView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OrderStatusController());
    
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
          'Order Status',
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                onChanged: controller.searchTable,
                decoration: const InputDecoration(
                  hintText: 'Table No',
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search, color: Color(0xFF6C757D)),
                ),
              ),
            ),
          ),
          
          // Order statuses list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: LoaderCircle());
              }
              
              final filteredStatuses = controller.filteredOrderStatuses;
              
              if (filteredStatuses.isEmpty) {
                return const Center(
                  child: Text(
                    'No running orders found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6C757D),
                    ),
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredStatuses.length,
                itemBuilder: (context, index) {
                  final orderStatus = filteredStatuses[index];
                  return _buildOrderStatusCard(orderStatus);
                },
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: CommonBottomNavigationBar(currentIndex: 3),
    );
  }

  Widget _buildOrderStatusCard(OrderStatus orderStatus) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFF6B35),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.restaurant_menu,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Table ${orderStatus.tableNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          // Order items
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...orderStatus.items.map((item) => _buildOrderItem(item, orderStatus.id)),
                
                const SizedBox(height: 16),
                
                // Action buttons
                Row(
                  children: [
                    // Expanded(
                    //   child: OutlinedButton(
                    //     onPressed: () => controller.sendBill(orderStatus.id),
                    //     style: OutlinedButton.styleFrom(
                    //       side: const BorderSide(color: Color(0xFFFF6B35)),
                    //       padding: const EdgeInsets.symmetric(vertical: 12),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(8),
                    //       ),
                    //     ),
                    //     child: const Text(
                    //       'Send Bill',
                    //       style: TextStyle(
                    //         color: Color(0xFFFF6B35),
                    //         fontWeight: FontWeight.w600,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => controller.addDishes(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Add Dishes',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item, String orderId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3142),
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: controller.getStatusColor(item.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        controller.getStatusDisplayText(item.status),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: controller.getStatusColor(item.status),
                        ),
                      ),
                    ),
                    
                    if (item.isModified) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Modified',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // Quantity controls
          Row(
            children: [
              // Decrease quantity button
              GestureDetector(
                onTap: () => controller.decrementQuantity(orderId, item.id),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.remove,
                    size: 18,
                    color: Color(0xFF6C757D),
                  ),
                ),
              ),
              
              // Quantity display
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
              ),
              
              // Increase quantity button
              GestureDetector(
                onTap: () => controller.incrementQuantity(orderId, item.id),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Delete button
              GestureDetector(
                onTap: () => _showDeleteConfirmation(orderId, item.id, item.name),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String orderId, String itemId, String itemName) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to completely remove "$itemName" from the order?\n\nTip: You can also decrease quantity using the minus (-) button.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteOrderItem(orderId, itemId);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
