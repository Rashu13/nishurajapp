import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:serv/app/global/widgets/loader.dart';
import '../../../widgets/common_bottom_navigation_bar.dart';
import '../controllers/bill_generation_controller.dart';
import '../../../data/models/bill.dart';

class BillGenerationView extends GetView<BillGenerationController> {
  const BillGenerationView({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Bill Generation',
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      bottomNavigationBar: CommonBottomNavigationBar(currentIndex: 2),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: controller.updateSearchText,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          
          // Bills list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: LoaderCircle());
              }
              
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.filteredBills.length,
                itemBuilder: (context, index) {
                  final bill = controller.filteredBills[index];
                  return _buildBillCard(bill);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBillCard(Bill bill) {
    return GestureDetector(
      onTap: () => controller.selectBill(bill),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Table No: ${bill.tableNumber}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Bill Amount ₹${bill.total.toInt()}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFFF6B35),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
