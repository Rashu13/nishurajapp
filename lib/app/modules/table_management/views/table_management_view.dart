import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/common_bottom_navigation_bar.dart';
import '../controllers/table_management_controller.dart';

class TableManagementView extends GetView<TableManagementController> {
  const TableManagementView({super.key});

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
          'Table Management',
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage tables assigned to you',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tab bar
            Obx(() => Row(
              children: [
                _buildTab('Table', 0),
                const SizedBox(width: 16),
                _buildTab('Diners', 1),
                const SizedBox(width: 16),
                _buildTab('Seating time', 2),
              ],
            )),
            
            const SizedBox(height: 24),
            
            // Table list
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: controller.tables.length,
                itemBuilder: (context, index) {
                  final table = controller.tables[index];
                  return _buildTableItem(table);
                },
              )),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CommonBottomNavigationBar(
        currentIndex: 1, // Tables tab
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = controller.selectedTab.value == index;
    
    return GestureDetector(
      onTap: () => controller.selectTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B35) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTableItem(TableAssignment table) {
    final isOccupied = table.status == TableStatus.occupied;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Table number
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isOccupied ? const Color(0xFFFF6B35) : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                table.tableNumber,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isOccupied ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Table info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${table.waiterName} (${table.guests})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3142),
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  table.time,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6C757D),
                  ),
                ),
              ],
            ),
          ),
          
          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isOccupied 
                ? const Color(0xFFFF6B35).withOpacity(0.1)
                : const Color(0xFF28A745).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              isOccupied ? 'Occupied' : 'Available',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isOccupied 
                  ? const Color(0xFFFF6B35)
                  : const Color(0xFF28A745),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
