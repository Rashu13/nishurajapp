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
        actions: [
          IconButton(
            onPressed: () => controller.loadBills(),
            icon: const Icon(
              Icons.refresh,
              color: Color(0xFFFF6B35),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CommonBottomNavigationBar(currentIndex: 2),
      body: Column(
        children: [
          // Bill Type filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Restaurant', 'restaurant'),
                  const SizedBox(width: 8),
                  _buildFilterChip('NC Billing', 'ncBilling'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Room', 'room'),
                ],
              ),
            ),
          ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
              
              // Trigger rebuild when filter changes
              controller.selectedBillTypeFilter.value;
              controller.searchText.value;
              
              final bills = controller.filteredBills;
              
              if (bills.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => controller.loadBills(),
                  child: ListView(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Active Bills',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'All bills are completed',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              // Group bills by table name
              Map<String, List<Bill>> groupedBills = {};
              for (var bill in bills) {
                if (!groupedBills.containsKey(bill.tableNumber)) {
                  groupedBills[bill.tableNumber] = [];
                }
                groupedBills[bill.tableNumber]!.add(bill);
              }
              
              return RefreshIndicator(
                onRefresh: () => controller.loadBills(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: groupedBills.length,
                  itemBuilder: (context, index) {
                    final tableNumber = groupedBills.keys.elementAt(index);
                    final tableBills = groupedBills[tableNumber]!;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Table header
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 12, left: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.table_restaurant,
                                size: 18,
                                color: const Color(0xFFFF6B35),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Table $tableNumber',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3142),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B35).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${tableBills.length} order${tableBills.length > 1 ? 's' : ''}',
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
                        // Bills for this table
                        ...tableBills.map((bill) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildBillCard(bill),
                        )),
                      ],
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Obx(() {
      final isSelected = controller.selectedBillTypeFilter.value == value;
      return GestureDetector(
        onTap: () => controller.selectBillTypeFilter(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFF6B35) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFFFF6B35) : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF2D3142),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBillCard(Bill bill) {
    // Debug: Print bill status to console
    print('🏷️ Building card for Table ${bill.tableNumber}: billStatus=${bill.billStatus}, orderId=${bill.orderId}');
    
    final bool isCompleted = bill.status.toLowerCase() == 'completed';
    final bool isRunning = bill.status.toLowerCase() == 'running';
    
    return GestureDetector(
      onTap: () => controller.selectBill(bill),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isCompleted 
              ? const Color(0xFF4CAF50).withOpacity(0.2)
              : isRunning 
              ? const Color(0xFF2196F3).withOpacity(0.2)
              : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row - Table and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D3142).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.table_restaurant,
                          size: 20,
                          color: const Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Table ${bill.tableNumber}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3142),
                            ),
                          ),
                          Text(
                            bill.orderId,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCompleted 
                        ? const Color(0xFF4CAF50)
                        : isRunning 
                        ? const Color(0xFF2196F3)
                        : const Color(0xFFFF9800),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCompleted ? Icons.check_circle : 
                          isRunning ? Icons.access_time : Icons.schedule,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isCompleted ? 'Completed' : 
                          isRunning ? 'Active' : 'Pending',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Info Row
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.person_outline,
                      label: 'Steward',
                      value: bill.userName.toUpperCase(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.restaurant_menu,
                      label: 'Items',
                      value: '${bill.personCount}',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.receipt_outlined,
                      label: 'GST',
                      value: '₹${bill.gst.toStringAsFixed(2)}',
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Footer Row - Total and Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.currency_rupee,
                            size: 18,
                            color: const Color(0xFFFF6B35),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Amount',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '₹${bill.total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFFF6B35),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      if (isCompleted)
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.refresh),
                            color: const Color(0xFFFF6B35),
                            iconSize: 20,
                            onPressed: () => controller.resetTable(bill),
                            tooltip: 'Reset Table',
                          ),
                        ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D3142).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          color: const Color(0xFF2D3142),
                          iconSize: 16,
                          onPressed: () => controller.selectBill(bill),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
